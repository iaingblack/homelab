terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
    }
  }
}

provider "octopusdeploy" {
  address  = var.serverURL
  api_key  = var.apiKey
  space_id = var.space
}

resource "octopusdeploy_environment" "development-environment" {
  name = "AutomationEnv1"
}

data "octopusdeploy_environments" "example" {
  partial_name = "AutomationEnv1"
}

output "test" {
  value = data.octopusdeploy_environments.example.id
}