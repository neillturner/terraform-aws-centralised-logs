variable "aws_region" {
  description = "aws region used to construct Amazon Resource Names (ARNs)."
  default     = "eu-west-1"
}

variable "aws_account_id" {
  description = "12 digit aws account id used to construct Amazon Resource Names (ARNs)."
}

variable "aws_elasticsearch_domain" {
  description = "domain name for aws elasticsearch cluster."
  default     = "logs-data"
}

variable "zone_id" {
  description = "Route 53 zone id for DNS for aws elasticsearch cluster "
}

variable "elasticsearch_version" {
  description = "Elastic Search Service cluster version number."
  default     = "5.5"
}

variable "vpc_id" {
  description = "Vpc id where the Elastic Search Service cluster will be launched."
}

variable "subnet_ids" {
  type = list
  description = "List of VPC Subnet IDs for the Elastic Search Service EndPoints will be created."
  default = []
}

variable "ingress_allow_cidr_blocks" {
  default     = []
  description = "Specifies the ingress CIDR blocks allowed to access the elasticsearch cluster."
  type        = "list"
}

variable "s3_bucket_elb_logs_arn" {
  description = "Amazon Resource Names (ARNs) of the S3 bucket containing ELB and ALB logs."
}

variable "s3_bucket_elb_logs_id" {
  description = "id of the S3 bucket containing ELB and ALB logs."
}
