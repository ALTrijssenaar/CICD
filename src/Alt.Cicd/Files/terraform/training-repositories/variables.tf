variable "token" {
  type        = string
  description = "GitHub token"
}

variable "owner" {
  type        = string
  description = "GitHub owner"
}

variable "teams" {
  type = list(object({
    name      = string
    challenge = string
  }))
  validation {
    condition = alltrue([for team in var.teams : contains([
      "codeowners",
      "codespaces"
    ], team.challenge)])
    error_message = "challenge must be one of: codeowners, codespaces."
  }
}
