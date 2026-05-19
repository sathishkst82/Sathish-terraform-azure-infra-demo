# terraform-azure-opella

Enterprise Azure landing-zone style Terraform solution for dev/prod environments.

## Architecture Overview
```mermaid
flowchart TB
  GH[GitHub Actions + OIDC] --> TF[Terraform]
  TF --> RG[Resource Group]
  RG --> VNET[Hub-ready VNET]
  VNET --> S1[management-subnet]
  VNET --> S2[application-subnet]
  VNET --> S3[data-subnet]
  VNET --> S4[private-endpoint-subnet]
  VNET --> S5[future-reserved-subnet]
  RG --> VM[Linux VM(s)]
  RG --> SA[Storage Account + Containers]
  RG --> GOV[Policy Initiative: Opella-Governance-Baseline]
```

## Folder Structure
- `modules/`: reusable `vnet`, `vm`, `storage`, `governance`
- `environments/dev|prod`: env composition + backend state config
- `docs/policies`: Azure policy JSON
- `.github/workflows`: CI/Plan/Apply/Policy pipelines
- `tests`: Terratest samples

## Design decisions (key)
- **locals** centralize naming and tagging (`rg-opella-dev-eastus`, `vnet-opella-prod-eastus`).
- **for_each** scales subnets, NSGs, VMs, containers, and policy definitions.
- **dynamic blocks** for subnet delegation, service endpoints, NSG rules, and initiative references.
- **lifecycle**: `prevent_destroy` on VNET, `create_before_destroy` on NSGs, `ignore_changes` for review tags.
- **validation** enforces SSH key quality.
- **conditional resources** optional public IPs and NSGs.
- **depends_on** only where association ordering is required.

## CIDR Strategy
- DEV: `10.10.0.0/16`
- PROD: `10.20.0.0/16`
- Non-overlapping for peering/hybrid readiness, with reserved growth subnet.

## Security and Governance
- Azure Policy initiative includes mandatory tags, allowed regions, and deny public IP.
- Storage is TLS 1.2+, private containers, public access disabled by default.
- Wiz CLI in CI provides shift-left IaC misconfiguration scanning.
- OIDC is used in workflows (no client secrets).
- Future OPA: add conftest/policy bundle gate in `policy-validation.yml`.

## Deployment
1. Configure backend bootstrap resources (`rg-opella-tfstate`, storage account, `tfstate` container).
2. `cd environments/dev`
3. `terraform init`
4. `terraform plan -var='ssh_public_key=ssh-ed25519 AAAA...'`
5. `terraform apply`

## Example tfvars
```hcl
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExample user@laptop"
```

## Example plan snippet
```text
Plan: 24 to add, 0 to change, 0 to destroy.
+ azurerm_virtual_network.this
+ azurerm_subnet.this["management"]
+ azurerm_linux_virtual_machine.this["vm1"]
+ azurerm_policy_set_definition.baseline
```

## terraform-docs Inputs/Outputs
Use: `make docs` (pre-commit also runs terraform-docs).
