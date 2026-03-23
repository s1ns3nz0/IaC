# 1. Code Repository Structure
## 1) Single Repository(Mono Repository)
- Each team uses the Singleton Pattern for infrastructure
- Two teams want to update and reference configurations instead of copying and pasting
- Mono repo is the structure containing all IaC for each team or function
## 2) Multi Repository
- Network, Tag and Databases modules are seprated to each single repository
- Multi Repo manage IaC configurations and modules by seperating to distinct repository based on teams or functions
- By seperating them, Organize the lifecycle and management for each module
- Unify module file structures and formats
    + csp-resource-objective(gcp-server-module)
## 3) Version Control
- Version control is the process of assigning unique versions to code collections
    + `git tag v1.0.0`
    + `git push origin v1.0.0`
    + When ensuring all teams use the fixed 1.0.0 version, change the database configuration and tag v2.0.0
    + `git tag v2.0.0`
    + `git push origin v2.0.0`
    + `git log --oneline` (Compare the two versions)
- Semantic Versioning
- Version Control for Single Repo: Use prefixes (e.g., module-name-v2.0.0)
## 4) Release
- Release is the process of delivering software to users
### Release Steps
- Modify the database module to store secrets in Secret Manager service and push changes to the repository
- Test the database module in other environments such as different accounts and projects
    + Module changes released
    + Module tested
- Release modules for use
    + Tag modules as v2.0.0
    + Package the module and push it to artifact archives or buckets
    + Update documentation to reflect changes (Semantic-release)
## 5) Share Modules
- Configure default values that modules generally use. If teams require more flexible features, update modules or override default values
- If changes affect system architecture, security, or availability, request reviews from the appropriate subject matter experts
- Organizations can leverage modules as artifacts such as shared libraries, container images, and virtual machine images
### Example
- The 'Bean team' updates database modules to use PostgreSQL v12 and pushes modifications to the module repository
- The CI framework executes automated builds
- If database module tests succeed, the Module Administrator reviews the code and approves the modifications
- The CI framework assigns a new version and continues the release process
- The v2.0.0 release label is attached and PostgreSQL v12 is used
- The 'Bean team' modifies their configuration to use v2.0.0 database modules which include PostgreSQL v12
# 2. Testing Infrastructure as Code
- IaC testing validates that infrastructure behaves as expected
- Focus on verifying infrastructure functionality and compliance
## 1) Test Cycle
### Phase 1: Static Analysis (Pre-deployment)
- Analyze configurations before deploying infrastructure changes
- Verify naming conventions, dependencies, and policy compliance
### Phase 2: Dynamic Analysis (Post-deployment)
- Deploy changes to test environments
- Validate infrastructure functionality and system behavior
## 2) Infrastructure Test Environments
Test environments are isolated from production to enable safe testing and validation.
### Requirements
- **Production parity**: Highly similar to production configurations
- **Isolation**: Completely separated from production workloads
- **Availability**: Maintained continuously for ongoing testing
## 3) Unit Test
- What kinds of tests can be written for static analysis?
- Unit tests are executed in parallel and independently
- Unit tests statically verify infrastructure configurations, state, and metadata without requiring active infrastructure resources or dependencies
### Dry Run
- Dry run confirms changes without IaC deployments, identifying potential internal problems before applying them
### When Unit Tests Should Be Written
- Some unit tests overlap with formatting and linting when it comes to naming conventions
- Unit tests cannot identify problems that occur during change execution, but they prevent applying configurations with issues to operational environments
## 4) Contract Test
- Verify dependencies between modules
- Contract tests leverage static analysis to verify whether module inputs and outputs have the expected values and formats
- Contract testing is the most useful method for validating module inputs and outputs
## 5) Integration Test
- Integration tests verify module and configuration changes by dynamically analyzing infrastructure resources in test environments
- Module integration tests must be executed in separate module-testing environments within test accounts or projects, not in application test or operational environments
- Resources are named using specific module types, versions, and commit hashes
### Example
- Create configurations if possible
- Deploy changes to infrastructure resources
- Run tests and compare the results with those obtained by accessing the infrastructure provider API
- Remove resources if possible
## 6) End-to-End Test
- End-to-end tests dynamically analyze infrastructure resources and system-wide features to verify whether IaC changes are applied correctly
- End-to-end tests are necessary components for ensuring that changes do not break high-level functionalities
## 7) Other Tests
### Continuous Test
- Monitoring: Periodically check metrics over thresholds
- Continuous testing, such as monitoring, periodically verifies that current state values match expected values.
### Regresssion Test
- Regression Tests are periodically executed during specific periods to verify the states of infrastructures or features matched to expected those values
## 8) Test Removal
- TMaintain clean test suites by removing unreliable tests that fail consistently without indicating actual system failures.