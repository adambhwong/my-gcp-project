# Network Module

Manages GCP VPC networking, subnets and related network configuration.

## Terraform Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_internal_vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_wg_subnets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_wireguard](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.main_vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.nat_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.subnets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | GCP region for VPC resources | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of VPC subnets to create | <pre>list(object({<br/>    name = string<br/>    cidr = string<br/>  }))</pre> | `[]` | no |
| <a name="input_wg_subnets"></a> [wg\_subnets](#input\_wg\_subnets) | List of remote WireGuard subnets allowed to communicate with the VPC | <pre>list(object({<br/>    name = string<br/>    cidr = string<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet names to their GCP resource IDs |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | n/a |
| <a name="output_wg_subnet_cidrs"></a> [wg\_subnet\_cidrs](#output\_wg\_subnet\_cidrs) | List of WireGuard remote subnet CIDRs (useful for VPC routes) |
<!-- END_TF_DOCS -->
