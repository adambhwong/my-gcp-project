# Prometheus Collector Module

Manages GCP VM based prometheus-collector to pull metrics into Cloud Metrics

## Terraform Documentation

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
| [google_compute_firewall.allow_iap_ssh_prometheus](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.collector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_project_iam_member.log_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.metric_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.prometheus_collector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gmp_image"></a> [gmp\_image](#input\_gmp\_image) | Google Managed Service for Prometheus collector image | `string` | `"gke.gcr.io/prometheus-engine/prometheus:v2.53.5-gmp.1-gke.2"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Compute Engine machine type | `string` | `"e2-micro"` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | VPC network name (e.g., main-vpc) | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_scrape_targets"></a> [scrape\_targets](#input\_scrape\_targets) | Map of home Linux nodes to scrape | <pre>map(object({<br/>    target   = string<br/>    instance = string<br/>    location = string<br/>  }))</pre> | `{}` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnetwork ID (10.10.1.0/24 subnet) | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP Zone for the collector VM | `string` | `"europe-west2-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | n/a |
| <a name="output_internal_ip"></a> [internal\_ip](#output\_internal\_ip) | n/a |
<!-- END_TF_DOCS -->
