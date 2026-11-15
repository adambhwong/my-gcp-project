output "docker_repo_url" {
  value = module.artifact_registry.docker_repo_url
}

output "gcp_dns_name_servers" {
  value = module.dns.name_servers
}

# Pass the outputs directly into your GitHub Actions workflow configuration
output "github_wif" {
  value = {
    provider        = module.github_wif.workload_identity_provider
    service_account = module.github_wif.service_account_email
  }
}
