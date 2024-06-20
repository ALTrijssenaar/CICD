resource "github_repository" "this" {
  name       = var.repository
  visibility = "public"
  has_issues = true

  template {
    owner                = var.template.owner
    repository           = var.template.repository
    include_all_branches = false
  }
}

resource "github_issue" "collaborators" {
  repository = github_repository.this.name
  title      = "Add collaborators to this repo"
  body       = <<EOT
## Comment below to be added as a collaborator

We will all be using this repository today. Even though it's public right now, you will not be able to make changes until you're given the correct permissions. We've automated this process via the GitHub API. Once you comment, we will add you as a collaborator.

You'll start to receive a lot of emails. (❗) You can slow these down immediately by clicking the **Unwatch** button at the top of the page and selecting either the **Participating and @mentions** or **Ignore** option.
EOT
}

# little hack to refresh collobarators on every apply
#   source: https://stackoverflow.com/a/73752527/129269
resource "value_unknown_proposer" "default" {}
resource "value_is_known" "collaborators" {
  value            = local.collaborators
  guid_seed        = var.repository
  proposed_unknown = value_unknown_proposer.default.value
}

resource "github_repository_collaborator" "collaborator" {
  repository = resource.github_repository.this.name
  for_each   = value_is_known.collaborators.result ? local.collaborators : []
  username   = each.value
  permission = "push"
}
