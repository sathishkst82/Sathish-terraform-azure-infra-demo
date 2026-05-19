# Terraform GitHub Actions Orchestration

## Workflow Execution Flow
```mermaid
flowchart TD
A[Workflow Dispatch]
A --> B{Terraform Action}
B -->|Validate| C[terraform-ci.yml]
B -->|Plan| D[terraform-plan.yml]
B -->|Apply| E[terraform-apply.yml]
A --> F[policy-validation.yml]
E --> G[GitHub Environment Approval]
G --> H[Terraform Apply]
```

## OIDC Federation (No Client Secrets)
- Configure Entra ID app + Federated Credential for GitHub repo/branch/environment claims.
- Store only `AZURE_CLIENT_ID` and `AZURE_TENANT_ID` as repo/environment secrets (subscription passed as input).
- Use `azure/login@v2` with `id-token: write` permissions.

Benefits:
- Short-lived credentials
- No long-lived client secret rotation burden
- Better blast-radius control and auditability

## Design Notes
- Centralized `terraform-dispatch.yml` gives one operator entrypoint.
- Reusable workflows (`workflow_call`) reduce duplication and separate CI/Plan/Apply concerns.
- Apply uses GitHub Environments for approval gates.
