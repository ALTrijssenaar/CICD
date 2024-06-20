variable "teamname" {
  type        = string
  description = "Name of the team"  
}

variable "location" {
  type        = string
  description = "Location of the team"
}

variable "template" {
  type = object({
    owner      = string
    repository = string
  })
  description = "Configuration for the template repository"
}
