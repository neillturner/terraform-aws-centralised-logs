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
+------------+        |ELB Logs  +---------->    | Kibana |   |
                      |  (S3)    |          |    |        |   |
                      |          |          |    +----^---+   |
                      +----------+          +---------|-------+
                                                      |
                                                      |
                                     +----------------|------+
                                     |Client   +---------+   |
                                     |Work-    |Proxy (optional)
                                     |station  +----^----+   |
                                     |              |        |
                                     |         +----+----+   |
                                     |         |         |   |
                                     |         | Browser |   |
                                     |         |         |   |
                                     |         +---------+   |
                                     +-----------------------+

```


The sample terraform https://github.com/neillturner/terraform-aws-centralised-logs shows how simple it is to create a centralised logging using AWS elasticsearch service, lambda and cloudwatch logs.

It calls 3 terraform registry modules:

egarbi/es-cluster - create the AWS elastic search cluster.

neillturner/lambda-es-cleanup - lambda to cleanup at 1am each morning delete old logs data.

neillturner/elb-logs-to-elasticsearch - lambda to load elb logs from S3 to elasticsearch cluster.

Server instances need to be setup to send logs to AWS cloudwatch logs via the the AWS Cloudwatch logs agent.
See https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_GettingStarted.html

Currently manually in the AWS console each cloudwatch log needs to be configured to call the AWS supplied lambda to load the data into the AWS Elasticsearch cluster see https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_ES_Stream.html

The AWS elasticsearch service should be setup in a private VPC so it cannot be accessed via the public internet.

Additional security can be setup by using a proxy. See:

https://aws.amazon.com/blogs/security/how-to-control-access-to-your-amazon-elasticsearch-service-domain/

https://medium.com/@yogeshdarji99/how-to-configure-aws-elasticsearch-kibana-proxy-4130914acc19

https://medium.com/@dophuoc/setting-up-kibana-proxy-for-aws-elastic-search-3b4ed05cecbb

Finally the lambdas have limitations in the amount of data they can process. lmbda limitations go to firehose.
See:

https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-aws-integrations.html

https://aws.amazon.com/blogs/database/send-apache-web-logs-to-amazon-elasticsearch-service-with-kinesis-firehose/
