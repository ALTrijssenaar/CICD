module "team" {
  source = "../module/training-repository"
  providers = {
    github = github
  }

  for_each = {
    for index, team in var.teams : "challenge-${team.name}-${team.challenge}" => team
  }

  repository = "challenge-${each.value.name}-${each.value.challenge}"
  template = {
    owner      = "Trijssenaar"
    repository = "challenge-${each.value.challenge}"
  }
}
