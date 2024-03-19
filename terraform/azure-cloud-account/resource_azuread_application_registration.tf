resource "azuread_application_registration" "application_registration" {
  for_each = local.application_registrations

  display_name     = each.value.display_name
  description      = each.value.description
  sign_in_audience = each.value.sign_in_audience

}

output "application_registrations" {
  value = var.enable_output ? azuread_application_registration.application_registration[*] : null
}
