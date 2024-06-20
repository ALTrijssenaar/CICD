output "repository" {
  value = resource.github_repository.this
}

output "issue" {
  value = resource.github_issue.collaborators
}

output "collaborators" {
  value = value_is_known.collaborators.result ? local.collaborators : []
}
