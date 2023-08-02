variable "prefix" {
  type    = string
  default = "crgar-aca"
}
variable "SSH_USERNAME" {
  type      = string
  sensitive = true
  default = "adminuser"
}
variable "SSH_PASSWORD" {
  type      = string
  sensitive = true
}