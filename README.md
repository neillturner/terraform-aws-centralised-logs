# terraform-aws-centralised-logs

AWS ElasticSearch Service can be used to provide a cost-effective centralised log management service.



```
+------------+        +----------+          +-----------------+
| Server     |        |Cloudwatch|  lambda  |  ElasticSearch  |   cleanup
| Instance   |    +--->   Logs   +---------->    Service      <----------+
+------------+    |   |          |          |                 |   lambda
||Cloudwatch||    |   +----------+          |                 |
||  Agent   |-----+                         |                 |
|------------|        +----------+  lambda  |    +--------+   |
+------------+        |ALB Logs  +---------->    | Kibana |   |
                      |  (S3)    |          |    |        |   |
                      |          |          |    +----^---+   |
                      +----------+          +---------|-------+
                                                      |
                                                      |
                                     +----------------|------+
                                     |Client   +---------+   |
                                     |Work-    |         |   |
                                     |Station  | Browser |   |
                                     |         |         |   |
                                     |         +---------+   |
                                     +-----------------------+

```


This directory contains terraform module to setup centralised logs

It calls 3 terraform registry modules:
1. egarbi/es-cluster - create the AWS elastic search cluster.
2. neillturner/lambda-es-cleanup - lambda to cleanup at 1am each morning delete old logs data.
3. neillturner/alb-logs-to-elasticsearch - lambda to load alb logs from S3 to elasticsearch cluster.

Server instances need to be setup to send logs to AWS cloudwatch logs via the the AWS Cloudwatch logs agent.
See https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_GettingStarted.html

Currently manually in the AWS console each cloudwatch log needs to be configured to call the AWS supplied lambda to load the data into the AWS Elasticsearch cluster see https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_ES_Stream.html

The AWS elasticsearch service should be setup in a private VPC so it cannot be accessed via the public internet.

Additional security can be setup by using a proxy. See:

https://aws.amazon.com/blogs/security/how-to-control-access-to-your-amazon-elasticsearch-service-domain/

https://medium.com/@yogeshdarji99/how-to-configure-aws-elasticsearch-kibana-proxy-4130914acc19

https://medium.com/@dophuoc/setting-up-kibana-proxy-for-aws-elastic-search-3b4ed05cecbb

Finally the lambdas have limitations in the amount of data they can process. lambda limitations go to firehose.
See:

https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-aws-integrations.html

https://aws.amazon.com/blogs/database/send-apache-web-logs-to-amazon-elasticsearch-service-with-kinesis-firehose/


## Module Input Variables

| Variable Name | Example Value | Description | Default Value | Required |
| --- | --- | --- | --- |  --- |
|  aws_elasticsearch_domain | "logs-data" | domain name for aws elasticsearch cluster | "logs-data" | True
|  vpc_id | vpc-9999999  | Vpc id where the Elastic Search Service cluster will be launched | | True
| subnet_ids | `["subnet-1111111", "subnet-222222"]` | Subnet IDs you want to deploy the lambda in. Only fill this in if you want to deploy your Lambda function inside a VPC. | | False |
|  ingress_allow_cidr_blocks | ["172.10.0.0/16"] |  CIDR blocks allowed to access the elasticsearch cluster | | False
|  ingress_allow_security_groups | ["sg-9999999999"] | security groups allowed to access the elasticsearch cluster | | False
|  aws_account_id | "${data.aws_caller_identity.current.account_id}" | 12 digit aws account id used to construct Amazon Resource Names (ARNs) | | True
| s3_bucket_alb_logs_arn | alb-logs | The arn of the s3 bucket containing the alb logs | `None` | True |
| s3_bucket_alb_logs_id | alb-logs | The id of the s3 bucket containing the alb logs | `None` | True |


## Example

```
provider "aws" {
  region = "eu-central-1"
}

data "aws_caller_identity" "current" {}

module "centralised-logs" {
  source        = "neillturner/centralised-logs/aws"
  version       = "0.1.0"
  aws_elasticsearch_domain      = "logs-data"
  vpc_id                        = "vpc-9999999999"
  subnet_ids                    = ["subnet-999999999999"]
  ingress_allow_cidr_blocks     = ["172.10.0.0/16"]
  ingress_allow_security_groups = ["sg-9999999999"] # vpc-99999999 default
  aws_account_id                = "${data.aws_caller_identity.current.account_id}"
  s3_bucket_alb_logs_arn        = "arn:aws:s3:::test.alb.logs"
  s3_bucket_alb_logs_id         = "test.alb.logs"
}
```