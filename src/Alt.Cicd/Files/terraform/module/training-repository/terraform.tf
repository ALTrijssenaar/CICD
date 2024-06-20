terraform {
  required_providers {
    github = {
      source                = "integrations/github"
      version               = "6.2.2"
      configuration_aliases = [github]
    }

    value = {
      source  = "pseudo-dynamic/value"
      version = "0.5.5"
    }

  }

  required_version = ">=1.8.5"
}
