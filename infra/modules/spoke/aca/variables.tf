################################
#         Generics
################################

variable "prefix" {
  description = "prefix"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "resource_group_name" {
  description = "RG Name"
  type        = string
}

variable "storage_name" {
  description = "Azure Storage Account Name"
  type        = string
}

variable "storage_key" {
  description = "Azure Storage Key"
  type        = string
}
variable "appinsights_key" {
  description = "value of the appinsights key"
  type        = string
}

variable "appinsights_connectionstring" {
  description = "value of the appinsights connectionstring"
  type        = string
}

variable "acr_url" {
  description = "value of the acr url"
  type        = string
}

variable "acr_id" {
  description = "value of the acr id"
  type        = string
}

variable "acr_username" {
  description = "value of the acr username"
  type        = string
}

variable "acr_password" {
  description = "value of the acr password"
  type        = string
}

variable "loganalytics_id" {
  description = "value of the loganalytics id"
  type        = string
}

variable "subnet_id" {
  description = "value of the infrastructure subnet id"
  type        = string
}


##########################################################################################################
# This is an overkilled way to create ACA apps :) - The benefit is that it avoids repeating the same code
# The idea is to have a list of objects, each object is an app
# you only need to define the non default values for each app
# Consider just duplicating whatever you need. Hardcoding is not that bad, and very simple to read :)
##########################################################################################################

variable "container_apps" {
  description = "Specifies the container apps in the managed environment."
  # First we define all the pottential parameters that we could use
  type = list(object({
    name                           = string
    revision_mode                  = optional(string)
    ingress                        = optional(object({
      allow_insecure_connections   = optional(bool)
      external_enabled             = optional(bool)
      target_port                  = optional(number)
      transport                    = optional(string)
      traffic_weight               = optional(list(object({
        label                      = optional(string)
        latest_revision            = optional(bool)
        revision_suffix            = optional(string)
        percentage                 = optional(number)
      })))
    }))
    secrets                        = optional(list(object({
      name                         = string
      value                        = string
    })))
    template                       = object({
      containers                   = list(object({
        name                       = string
        image                      = string
        args                       = optional(list(string))
        command                    = optional(list(string))
        cpu                        = optional(number)
        memory                     = optional(string)
        env                        = optional(list(object({
          name                     = string
          secret_name              = optional(string)
          value                    = optional(string)
        })))
      }))
      min_replicas                 = optional(number)
      max_replicas                 = optional(number)
      revision_suffix              = optional(string)
    })
  }))
  default                          = [
  # This is application 1: Client
  {
    name                           = "client"
    ingress                        = {
      external_enabled             = true
      target_port                  = 3000
      transport                    = "http"
      traffic_weight               = [{
        label                      = "blue"
        latest_revision            = true
        revision_suffix            = "blue"
        percentage                 = 100
      }]
    }
    template                       = {
      containers                   = [{
        name                       = "hello-k8s-node"
        image                      = "dapriosamples/hello-k8s-node:latest"
        cpu                        = 0.5
        memory                     = "1Gi"
        env                        = [{
          name                     = "APP_PORT"
          value                    = 3000
        }]
      }]
      min_replicas                 = 1
      max_replicas                 = 1
    }
  },
  # This is application 2: Chunker
  {
    name                           = "pythonapp"
    template                       = {
      containers                   = [{
        name                       = "hello-k8s-python"
        image                      = "dapriosamples/hello-k8s-python:latest"
        cpu                        = 0.5
        memory                     = "1Gi"
      }]
      min_replicas                 = 1
      max_replicas                 = 1
    }
  }]
}