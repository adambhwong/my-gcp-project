# Network Module

Manages GCP VM based VPN gateway using wireguard

## Terraform Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_wireguard"></a> [wireguard](#requirement\_wireguard) | ~> 0.4 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | 8.11.0 |
| <a name="provider_wireguard"></a> [wireguard](#provider\_wireguard) | 0.4.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_address.vpn_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.vpn_data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_firewall.allow_iap_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance_from_template.vpn_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_from_template) | resource |
| [google_compute_instance_template.vpn_template](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_route.wg_routes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_dns_record_set.vpn_dns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_project_iam_member.vpn_log_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret.wg_secrets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.vpn_secret_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_version.wg_secret_versions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.vpn_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [wireguard_asymmetric_key.peers](https://registry.terraform.io/providers/OJFord/wireguard/latest/docs/resources/asymmetric_key) | resource |
| [wireguard_asymmetric_key.server](https://registry.terraform.io/providers/OJFord/wireguard/latest/docs/resources/asymmetric_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dns_domain"></a> [dns\_domain](#input\_dns\_domain) | Cloud DNS domain name (with trailing dot, e.g., gcp.2am.xyz.) | `string` | n/a | yes |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Cloud DNS public zone name for the VPN A record | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Compute Engine machine type (e.g., e2-micro) | `string` | `"e2-micro"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region for the static IP and VPN gateway | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnetwork ID where the VPN VM will be deployed | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC network ID where custom routes will be attached | `string` | n/a | yes |
| <a name="input_vpc_subnet_cidrs"></a> [vpc\_subnet\_cidrs](#input\_vpc\_subnet\_cidrs) | List of VPC subnet CIDRs to include in peer AllowedIPs | `list(string)` | n/a | yes |
| <a name="input_wg_peers"></a> [wg\_peers](#input\_wg\_peers) | WireGuard peers and their remote subnets | <pre>list(object({<br/>    name      = string<br/>    tunnel_ip = string # e.g., "10.13.13.2/32"<br/>    cidr      = string # Remote LAN CIDR, e.g., "192.168.1.0/24"<br/>  }))</pre> | n/a | yes |
| <a name="input_wg_server_address"></a> [wg\_server\_address](#input\_wg\_server\_address) | WireGuard server tunnel interface IP/CIDR (e.g., 10.13.13.1/24) | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP availability zone for the VPN VM (e.g., europe-west2-a) | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_vpn_fqdn"></a> [vpn\_fqdn](#output\_vpn\_fqdn) | Public DNS hostname for the WireGuard endpoint |
| <a name="output_vpn_private_ip"></a> [vpn\_private\_ip](#output\_vpn\_private\_ip) | Internal VPC IP of the WireGuard gateway |
| <a name="output_vpn_public_ip"></a> [vpn\_public\_ip](#output\_vpn\_public\_ip) | Static external IP of the WireGuard gateway |
<!-- END_TF_DOCS -->
