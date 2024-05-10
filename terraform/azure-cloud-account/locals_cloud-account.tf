locals {

  prefix = var.prefix != null ? "${var.prefix}-" : ""

  resource_group_suffix = "fortigatecnf-account"
  resource_group_name   = var.prefix != null ? "rg-${local.prefix}${local.resource_group_suffix}" : "rg-${local.resource_group_suffix}"
  location              = "eastus"

  environment_tag = "CNF Account"

  resource_groups = {
    (local.resource_group_name) = {
      name     = local.resource_group_name
      location = local.location
      tags = {
        Environment = local.environment_tag
      }
    }
  }

  user_assigned_identities = {
    "id-${local.prefix}fortigatecnf_account" = {
      resource_group_name = azurerm_resource_group.resource_group[local.resource_group_name].name
      location            = azurerm_resource_group.resource_group[local.resource_group_name].location

      name = "id-${local.prefix}fortigatecnf_account"
    }
  }

  # Subscription Roles that will be assigned to the Managed Identity
  role_definition_names = ["Contributor", "User Access Administrator"]

  # Create a list of Managed Identities and Roles
  user_assigned_identity_roles_list = setproduct(values(local.user_assigned_identities), local.role_definition_names)

  # Create a map of Role Scope, Role and Managed Identity (principal_id) from the list
  role_assignments = {
    for item in local.user_assigned_identity_roles_list :
    format("%s-%s", item[0]["name"], item[1]) => {
      user_assigned_identity_name = item[0]["name"],
      scope                       = data.azurerm_subscription.subscription.id,
      role_definition_name        = item[1],
      principal_id                = azurerm_user_assigned_identity.user_assigned_identity[item[0]["name"]].principal_id,
    }
  }

  # Tenant Directory roles assigned to the Managed Identities 
  directory_roles = {
    "Application Administrator" = {
      display_name = "Application Administrator"
    }
  }

  # Assigning Privileged Roles to the Managed Identities requires that the authenticated
  # user or service principal has the role of "Privileged Role Administrator"
  assign_directory_roles = true

  # Tenant/Directory Roles that will be assigned to the Managed Identity
  directory_role_definition_names = ["Application Administrator"]

  # Create a list of Managed Identities and Roles
  user_assigned_identity_directory_roles_list = setproduct(values(local.user_assigned_identities), local.directory_role_definition_names)

  # Create a map of Role Scope, Role and Managed Identity (principal_id) from the list
  directory_role_assignments = {
    for item in local.user_assigned_identity_directory_roles_list :
    format("%s-%s", item[0]["name"], item[1]) => {
      user_assigned_identity_name = item[0]["name"],
      scope                       = data.azurerm_subscription.subscription.id,
      role_id                     = azuread_directory_role.directory_role[item[1]].id,
      principal_object_id         = azurerm_user_assigned_identity.user_assigned_identity[item[0]["name"]].principal_id,
    } if local.assign_directory_roles
  }

  application_registrations = {
    "app-fortigatecnf-account" = {
      display_name     = "app-fortigatecnf-account"
      description      = "Application Registration for FortiGate CNF Account"
      sign_in_audience = "AzureADMultipleOrgs"
    }
  }
}

# Output the map of Role Assignments
output "role_assignments_map" {
  value = local.role_assignments
}
