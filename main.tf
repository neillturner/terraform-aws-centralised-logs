resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

# create elasticsearch cluster to hold logs data
module "logs_data_es_cluster" {
  source                    = "github.com/neillturner/terraform-aws-es-cluster"
#  source                    = "egarbi/es-cluster/aws"
#  version                   = "0.0.7"
  name                      = "${var.aws_elasticsearch_domain}"
  elasticsearch_version     = "${var.elasticsearch_version}"
  vpc_id                    = "${var.vpc_id}"
  subnet_ids                = var.subnet_ids
  volume_size               = "${var.volume_size}"
  zone_id                   = "${var.zone_id}"
  itype                     = "m4.large.elasticsearch"
  ingress_allow_cidr_blocks = var.ingress_allow_cidr_blocks
  ingress_allow_security_groups = var.ingress_allow_security_groups
  access_policies           = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow"
        }
    ]
}
CONFIG
}  

# allow aws supplied lambda to load data into elasticsearch cluster
resource "aws_iam_role" "int_lambda_elasticsearch_execution" {
  name = "int_lambda_elasticsearch_execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "int_lambda_elasticsearch_execution" {
  name = "int-lambda-elasticsearch-execution"
  role = "${aws_iam_role.int_lambda_elasticsearch_execution.id}"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "es:ESHttpPost",
      "Resource": "arn:aws:es:*:*:*"
    }
  ]
}
EOT
}

# lambda to cleanup at 1am each morning delete old logs data
module "lambda-es-cleanup" {
  source       = "neillturner/lambda-es-cleanup/aws"
  version      = "0.2.0"
  delete_after = "${var.delete_after}"
  es_endpoint  = "${module.logs_data_es_cluster.es_endpoint}"
  schedule     = "cron(0 1 * * ? *)"
  subnet_ids   = var.subnet_ids
}

# lambda to load alb logs from S3 to elasticsearch cluster
module "alb-logs-to-elasticsearch" {
  source        = "neillturner/alb-logs-to-elasticsearch/aws"
  version       = "0.1.0"
  es_endpoint   = "${module.logs_data_es_cluster.es_endpoint}"
  s3_bucket_arn = "${var.s3_bucket_alb_logs_arn}"
  s3_bucket_id  = "${var.s3_bucket_alb_logs_id}"
  subnet_ids    = var.subnet_ids
}
