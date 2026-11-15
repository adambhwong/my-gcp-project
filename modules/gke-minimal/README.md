<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_container_cluster.primary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.primary_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_project_iam_member.gke_node_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.gke_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the GKE cluster | `string` | n/a | yes |
| <a name="input_master_authorized_cidr_blocks"></a> [master\_authorized\_cidr\_blocks](#input\_master\_authorized\_cidr\_blocks) | CIDR blocks allowed to access the GKE control plane endpoint | <pre>list(object({<br/>    cidr_block   = string<br/>    display_name = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_block": "0.0.0.0/0",<br/>    "display_name": "Any"<br/>  }<br/>]</pre> | no |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block) | Master CIDR block (must be a /28 CIDR not overlapping with 10.10.1.0/24 or 10.20.0.0/16) | `string` | `"10.10.255.0/28"` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | VPC network name or self\_link (e.g., main-vpc) | `string` | n/a | yes |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of nodes in the zonal node pool | `number` | `1` | no |
| <a name="input_node_machine_type"></a> [node\_machine\_type](#input\_node\_machine\_type) | Machine type for GKE worker nodes (e2-medium is the practical minimum for GKE system pods + GMP) | `string` | `"e2-medium"` | no |
| <a name="input_pods_ipv4_cidr_block"></a> [pods\_ipv4\_cidr\_block](#input\_pods\_ipv4\_cidr\_block) | Secondary CIDR block for GKE Pods (must not overlap with 10.10.0.0/16 or 10.2.0.0/24) | `string` | `"10.20.0.0/16"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_services_ipv4_cidr_block"></a> [services\_ipv4\_cidr\_block](#input\_services\_ipv4\_cidr\_block) | Secondary CIDR block for GKE Services | `string` | `"10.21.0.0/20"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnetwork self\_link or ID for GKE nodes (e.g., 10.10.1.0/24) | `string` | n/a | yes |
| <a name="input_use_spot_nodes"></a> [use\_spot\_nodes](#input\_use\_spot\_nodes) | Use Spot VMs to reduce GKE node cost by ~60-80% | `bool` | `false` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP Zone for the zonal GKE cluster (e.g., europe-west2-a) | `string` | `"europe-west2-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_certificate"></a> [ca\_certificate](#output\_ca\_certificate) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | n/a |
| <a name="output_node_service_account"></a> [node\_service\_account](#output\_node\_service\_account) | n/a |
| <a name="output_pods_cidr"></a> [pods\_cidr](#output\_pods\_cidr) | n/a |
<!-- END_TF_DOCS -->