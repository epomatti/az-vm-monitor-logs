# Azure VM + Monitor Agent

Native monitoring with Azure VMs using the Azure Monitor Agent.

Two methods are implemented:
- Data collection (direct configuration with Terraform)
- Monitor VM Insights

## Data Collection

### Requirements

For the Azure Monitor Agent, check the [requirements][1].

- Permissions
- Authentication / Identity
- Networking / Azure Firewall

### Install

Run the from `infra` directory:

```
terraform init
terraform apply
```

### Monitoring

The agent is configured via [Data Collection Rules][2]. Check the documentation for details.


## VM Insights

Another method of monitoring VMs is via [Monitor VM Insights][3]

The startup code is in the `./infra2` directory.




[1]: https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-manage?tabs=azure-portal
[2]: https://learn.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent?tabs=portal
[3]: https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview
