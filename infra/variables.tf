variable "prefix" {
  type    = string
  default = "crgar-leg"
}
variable "SSH_USERNAME" {
  type      = string
  sensitive = true
  default   = "adminuser"
}
variable "SSH_PASSWORD" {
  type      = string
  sensitive = true
}
variable "GRAPHANA_ADMIN_EMAIL" {
  type      = string
  sensitive = true
}