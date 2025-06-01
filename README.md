# feedback-network
Terraform code to create network for feedback app
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.98.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_external_vpc"></a> [external\_vpc](#module\_external\_vpc) | terraform-aws-modules/vpc/aws | 5.1.2 |
| <a name="module_vpc_app"></a> [vpc\_app](#module\_vpc\_app) | terraform-aws-modules/vpc/aws | 5.1.2 |

## Resources

| Name | Type |
|------|------|
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.external_front_end](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.front_end](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.external_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sg_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sg_external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_policy.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_policy) | resource |
| [aws_vpc_endpoint_service.endpoint_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) | resource |
| [aws_vpc_endpoint_service_allowed_principal.allow_me](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service_allowed_principal) | resource |
| [aws_vpc_security_group_egress_rule.egress_external_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.inbound_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.inbound_external_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.inbound_external_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_cidr"></a> [app\_cidr](#input\_app\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name for the vpc | `string` | `"feedback-app-vpc"` | no |
| <a name="input_external_cidr"></a> [external\_cidr](#input\_external\_cidr) | CIDR block for the external VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_external_enabled"></a> [external\_enabled](#input\_external\_enabled) | Flag to create External VPC. | `bool` | `true` | no |
| <a name="input_external_name"></a> [external\_name](#input\_external\_name) | Name for the vpc for external access | `string` | `"external-vpc"` | no |
| <a name="input_from_port"></a> [from\_port](#input\_from\_port) | Starting port for the security group ingress rule | `number` | `5000` | no |
| <a name="input_internal_cidr"></a> [internal\_cidr](#input\_internal\_cidr) | CIDR block for the internal VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_internal_enabled"></a> [internal\_enabled](#input\_internal\_enabled) | Flag to create Internal VPC. | `bool` | `true` | no |
| <a name="input_internal_name"></a> [internal\_name](#input\_internal\_name) | Name for the vpc for internal access | `string` | `"internal-vpc"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the VPC and resources | `map(string)` | `{}` | no |
| <a name="input_to_port"></a> [to\_port](#input\_to\_port) | Ending port for the security group ingress rule | `number` | `5000` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | n/a |
| <a name="output_sg_app"></a> [sg\_app](#output\_sg\_app) | Security group for the application instances |
| <a name="output_subnet_ranges"></a> [subnet\_ranges](#output\_subnet\_ranges) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | List if IDs of the private subnets in the VPC |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the target group for the Network Load Balancer |
| <a name="output_vpc_app_id"></a> [vpc\_app\_id](#output\_vpc\_app\_id) | ID of the VPC for the feedback application |
