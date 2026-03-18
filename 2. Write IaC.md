# 1. Principles of Infrastructure as Code
## 4 Principles
- Reproducibility, Idempotency, Composability, Evolvability
### Reproducibility
- Create infrastructure resources and environments leveraging the same configurations
### Idempotency
- IaC has strict requirements
- The objective of automation is to achieve the same results regardless of how many times it is executed (if-statement)
- Idempotency ensures that repeated executions do not affect infrastructure or cause configuration drift
### Composability
- Any infrastructure components can be combined regardless of tools and configurations
- Individual configurations must be updatable without affecting the entire system
### Evolvability
- Minimize the risks and likelihood of failure, and ensure the extension and growth of the system
    + Avoid using tags; use global variables instead
    + Consider using HBase, which is available on both GCP and AWS, when migrating your infrastructure from GCP to AWS
## Questions to verify your configuration and tools fit these principles
- Can you reproduce the entire environment using these tools?
- What happens when you re-execute these tools to change configurations?
- Can you create new infrastructure component sets by combining many configuration snippets?
- Do the tools provide features that allow infrastructure resources to evolve without affecting other systems?
# 2. Writing Infrastructure as Code
## 1) Why It's Hard to Build Production Without a Development Environment
**Improving Reproducibility and Evolutionary Potential**
- Difficult to reproduce infrastructure resources
- Difficult to integrate infrastructure resources with new ones
- Difficult to change production environments to meet specific requirements
## 2) Presentation of Infrastructure Changes
### Imperative Style
- Automate each stage of infrastructure provisioning
- Describes *how* to configure infrastructure
### Declarative Style₩
- Describes the final state of infrastructure without requiring knowledge of the tools and automation involved
- Configurations stored in version control become the source of truth
- All changes must be executed from the source of truth
## 3) Understanding Immutability
- How can we prevent configuration drift and quickly reproduce infrastructure?
- Mutable infrastructure: instead of rebooting a server, directly modify it
- Immutable infrastructure: terminate the server and recreate it with new, updated packages
- **Immutability**: Do not change resources after creating them; remove obsolete ones and create new, updated ones instead
- IaC is the appropriate method for applying immutability to resources when changes are needed
- **When servers are immutable, all dependent resources are also affected by immutability due to their dependencies**
- Therefore, you must decide how to handle each piece of infrastructure — mutable or immutable
### Out-of-band Change
- Makes immutable infrastructure temporarily mutable for quick changes
- How do we start the restoration process to return to an immutable infrastructure state after updating the source of truth?
    + After modifying a resource directly, you must reflect those changes back in version control
- **The most critical thing is to maintain integrity between the actual infrastructure state and the source of truth**
## 4) Write Clean Infrastructure as Code
- Code Hygiene: A set of practices to improve readability and structure

### Version Control Delivers Context
- Ref: https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control

#### Commit Messages
- Explain **why** changes were made and their **impact** on other infrastructure resources
- Don't explain the configuration itself—changes show what was modified
- Include ticket/issue numbers for traceability
- Example: "TICKET-002: Allow network access to shared services network so the app can use the queue. All ports are permitted."

#### Linting and Formatting
- **Linting**: Automatically detects non-compliant configurations by verifying code style
- **Formatting**: Automatically aligns code to ensure proper spacing and structure
- Add formatting checks to version control hooks before committing code

#### Resource Naming
- Resource names should include **environment, resource type, and purpose**
    + Example: `dev-firewall-rule-allow-hello-world-to-database`
        - `dev`: environment
        - `firewall-rule`: resource type
        - `allow-hello-world-to-database`: purpose
    + If resource type can be identified through metadata, it doesn't need to be included in the name
- Provider-specific naming can be used; however, consider portability when migrating between providers
    + Example: AWS uses `CidrBlock`, Azure uses `address_space` — you might miss configuration if you don't know the exact provider-specific names

#### Variables and Constants
- **Variable**: Values that infrastructure configuration references. These must be changed when creating new resources or environments
- **Constant**: Common values shared across all resources, rarely changed regardless of environment or purpose

## 5) Dependency Parameterization
- When creating a server, you must specify which network it uses
- If you provide `network` as a parameter, you don't need to manually update server and network names when environments change

## 6) Separate Secrets from IaC
- Secrets should **never** be stored in IaC code
- Even during code audits, secrets should remain inaccessible from IaC files