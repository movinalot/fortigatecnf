resource "azuread_directory_role" "directory_role" {
  for_each = local.assign_directory_roles ? local.directory_roles : {}

  display_name = each.value.display_name
}

output "directory_roles" {
  value = azuread_directory_role.directory_role[*]
}