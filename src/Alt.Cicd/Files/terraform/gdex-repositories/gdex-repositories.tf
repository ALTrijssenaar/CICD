module "team" {
  source = "../module/gdex-repository"
  providers = {
    github = github
  }

  for_each = {
    for index, team in var.teams : team.name => team
  }

  teamname = each.value.name
  location = each.value.location
  template = {
    owner      = var.template.owner
    repository = var.template.repository
  }
}
