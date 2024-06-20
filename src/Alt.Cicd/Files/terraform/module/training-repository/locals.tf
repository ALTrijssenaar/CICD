locals {
  collaborators = toset([for comment in jsondecode(data.github_rest_api.comments.body) : comment.user.login])
}
