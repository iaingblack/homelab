terraform {
  required_providers {
    octopusdeploy = {
      source  = "OctopusDeployLabs/octopusdeploy"
    }
  }
}

provider "octopusdeploy" {
  address  = var.serverURL
  api_key  = var.apiKey
  space_id = var.space
}

data "octopusdeploy_environments" "this" {
#  name = upper("dev")
  partial_name = "PR"
  skip = 0
  take = 1
}


#output "envs_found" {
#  value = data.octopusdeploy_environments.this.*
#}

output "env_name" {
  value = "${data.octopusdeploy_environments.this.environments[0].name}"
}
output "env_id" {
  value = "${data.octopusdeploy_environments.this.environments[0].id}"
}