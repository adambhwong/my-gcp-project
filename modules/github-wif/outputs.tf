# Output resource details for your GitHub Actions YAML
output "workload_identity_provider" {
  description = "The Workload Identity Provider resource name to use in GitHub Actions."
  value       = google_iam_workload_identity_pool_provider.provider.name
}

output "service_account_email" {
  description = "The email address of the created GCP service account."
  value       = data.google_service_account.github_sa.email
}
