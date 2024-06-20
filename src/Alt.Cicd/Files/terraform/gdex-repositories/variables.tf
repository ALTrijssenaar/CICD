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
    name     = string
    location = string
  }))
}

variable "template" {
  type = object({
    owner      = string
    repository = string
  })
}

