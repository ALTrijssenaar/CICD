data "github_rest_api" "comments" {
  endpoint = "repos/${resource.github_repository.this.full_name}/issues/${resource.github_issue.collaborators.number}/comments"
}
