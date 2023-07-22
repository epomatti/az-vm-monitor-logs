# Azure VM + Monitor Agent

Native monitoring with Azure VMs using the Azure Monitor Agent.

## Requirements

For the Azure Monitor Agent, check the [requirements][1].

- Permissions
- Authentication / Identity
- Networking / Azure Firewall

## Install

Run the from `infra` directory:

```
terraform init
terraform apply
```

## Monitoring

The agent is configured via [Data Collection Rules][2]. Check the documentation for details.


[1]: https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-manage?tabs=azure-portal
[2]: https://learn.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent?tabs=portal
