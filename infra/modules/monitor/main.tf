locals {
  log_analytics_destination = "log-analytics-destination"
}

resource "azurerm_monitor_data_collection_rule" "rule_1" {
  name                = "dcr-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Endpoint
  # data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.endpoint1.id

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = local.log_analytics_destination
    }

    # This was in preview
    # azure_monitor_metrics {
    #   name = "metrics-destination"
    # }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = [local.log_analytics_destination]
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics", "Microsoft-Perf"]
    destinations = [local.log_analytics_destination]
  }

  data_sources {

    syslog {
      facility_names = ["auth", "cron", "daemon", "kern", "syslog", "user", "local0"]
      log_levels     = ["Debug"]
      name           = "syslog-datasource"
    }

    performance_counter {
      streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["Processor(*)\\% Processor Time"]
      name                          = "perfcounter-datasource"
    }
  }
}

# Associate to a Data Collection Rule
resource "azurerm_monitor_data_collection_rule_association" "association_1" {
  name                    = "association1"
  target_resource_id      = var.vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.rule_1.id
  description             = "Exploring data collection on Azure"
  # data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.endpoint1.id
}
