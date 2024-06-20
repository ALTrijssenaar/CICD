resource "github_repository" "this" {
  name                 = var.teamname
  visibility           = "public"
  has_issues           = true
  vulnerability_alerts = false

  template {
    owner                = var.template.owner
    repository           = var.template.repository
    include_all_branches = false
  }
}

resource "github_team" "this" {
  name        = var.teamname
  description = "Team for ${var.teamname}"
  privacy     = "closed"
}

resource "github_team_repository" "this" {
  team_id    = github_team.this.id
  repository = github_repository.this.name
  permission = "admin"
}
