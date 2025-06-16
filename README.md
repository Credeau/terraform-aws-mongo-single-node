<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0, < 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.cpu_usage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.disk_usage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_usage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ebs_volume.mongo_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_iam_instance_profile.mongo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssh_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.mongo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.mongo_eni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_s3_bucket.mongo_assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.mongo_assets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_object.cloudwatch_agent_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.mongo_cloudwatch_script](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.mongod_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.mongod_service_override_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_security_group.mongodb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sns_topic.alert_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.email_subscriptions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_volume_attachment.mongo_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_subnet.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_email_recipients"></a> [alert\_email\_recipients](#input\_alert\_email\_recipients) | email recipients for sns alerts | `list(string)` | `[]` | no |
| <a name="input_application"></a> [application](#input\_application) | Application name for which this database is provisioned | `string` | `"dummy"` | no |
| <a name="input_base_snapshot_id"></a> [base\_snapshot\_id](#input\_base\_snapshot\_id) | ID of an existing EBS snapshot to create the volume from. If not specified, an empty volume will be created. | `string` | `null` | no |
| <a name="input_cpu_threshold"></a> [cpu\_threshold](#input\_cpu\_threshold) | CPU threshold for scaling | `number` | `60` | no |
| <a name="input_disk_iops"></a> [disk\_iops](#input\_disk\_iops) | IOPS to provision in database storage | `number` | `3000` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Size in GBs to provision as database storage | `number` | `50` | no |
| <a name="input_disk_threshold"></a> [disk\_threshold](#input\_disk\_threshold) | Disk threshold for scaling | `number` | `70` | no |
| <a name="input_encrypt_storage"></a> [encrypt\_storage](#input\_encrypt\_storage) | Enable/Disable the encryption of database storage | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Provisioning environment | `string` | `"dev"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Type of instance to provision for mongo | `string` | `"t3a.medium"` | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | SSH key pair to use for system access | `string` | n/a | yes |
| <a name="input_memory_threshold"></a> [memory\_threshold](#input\_memory\_threshold) | Memory threshold for scaling | `number` | `60` | no |
| <a name="input_mongo_data_location"></a> [mongo\_data\_location](#input\_mongo\_data\_location) | Directory location where MOngoDB will store its data | `string` | `"/var/lib/mongodb"` | no |
| <a name="input_mongo_default_storage_compression_type"></a> [mongo\_default\_storage\_compression\_type](#input\_mongo\_default\_storage\_compression\_type) | Default storage compression type | `string` | `"zstd"` | no |
| <a name="input_mongo_password"></a> [mongo\_password](#input\_mongo\_password) | value | `string` | n/a | yes |
| <a name="input_mongo_port"></a> [mongo\_port](#input\_mongo\_port) | Port number to bind with mongo db | `number` | `27017` | no |
| <a name="input_mongo_user_name"></a> [mongo\_user\_name](#input\_mongo\_user\_name) | value | `string` | `"mongo"` | no |
| <a name="input_mongodb_whitelisted_cidrs"></a> [mongodb\_whitelisted\_cidrs](#input\_mongodb\_whitelisted\_cidrs) | List of CIDR block IP ranges to allow connecting with MongoDB (port: 27017) | `list(string)` | `[]` | no |
| <a name="input_mongodb_whitelisted_sg_ids"></a> [mongodb\_whitelisted\_sg\_ids](#input\_mongodb\_whitelisted\_sg\_ids) | List of Security Group IDs to allow connecting with MongoDB (port: 27017) | `list(string)` | `[]` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | organization name | `string` | `"credeau"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS operational region | `string` | `"ap-south-1"` | no |
| <a name="input_ssh_whitelisted_cidrs"></a> [ssh\_whitelisted\_cidrs](#input\_ssh\_whitelisted\_cidrs) | List of CIDR block IP ranges to allow SSH on MongoDB instance (port: 22) | `list(string)` | `[]` | no |
| <a name="input_ssh_whitelisted_sg_ids"></a> [ssh\_whitelisted\_sg\_ids](#input\_ssh\_whitelisted\_sg\_ids) | List of Security Group IDs to allow SSH on MongoDB instance (port: 22) | `list(string)` | `[]` | no |
| <a name="input_stack_owner"></a> [stack\_owner](#input\_stack\_owner) | owner of the stack | `string` | `"tech@credeau.com"` | no |
| <a name="input_stack_team"></a> [stack\_team](#input\_stack\_team) | team of the stack | `string` | `"devops"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | VPC Subnet ID to launch the server network | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID of the VPC to provision the resources in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | AMI ID of the Ubuntu image used for MongoDB instance |
| <a name="output_application_identifier"></a> [application\_identifier](#output\_application\_identifier) | Common application-specific identifier used for tagging and metric grouping |
| <a name="output_assets_bucket"></a> [assets\_bucket](#output\_assets\_bucket) | Bucket on which the MongoDB bootstrap assets are uploaded |
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | Availability zone in which the MongoDB resources are deployed |
| <a name="output_host_address"></a> [host\_address](#output\_host\_address) | The resolved IP address of the MongoDB instance (public or private based on setup) |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | IAM role ARN attached to the MongoDB instances |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 instance ID for the MongoDB host |
| <a name="output_port"></a> [port](#output\_port) | The port MongoDB is listening on (default: 27017) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID attached to the MongoDB instance |
| <a name="output_volume_mount_path"></a> [volume\_mount\_path](#output\_volume\_mount\_path) | Device path where the MongoDB volume is attached on the instance |
<!-- END_TF_DOCS -->