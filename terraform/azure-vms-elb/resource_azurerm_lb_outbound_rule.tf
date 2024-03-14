resource "azurerm_lb_outbound_rule" "lb_outbound_rule" {
  for_each = local.lb_outbound_rules

  name                    = each.value.name
  loadbalancer_id         = each.value.loadbalancer_id
  protocol                = each.value.protocol
  backend_address_pool_id = each.value.backend_address_pool_id

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configurations
    content {
      name = frontend_ip_configuration.value.name
    }
  }
}

output "lb_outbound_rules" {
  value = var.enable_output ? azurerm_lb_outbound_rule.lb_outbound_rule[*] : null
}
