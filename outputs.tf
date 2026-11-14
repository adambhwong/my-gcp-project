output "docker_repo_url" {
  value = module.artifact_registry.docker_repo_url
}

output "gcp_dns_name_servers" {
  value = module.dns.name_servers
}

