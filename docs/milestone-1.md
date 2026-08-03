# M1: Foundation & Pipeline

**M1.1 As a platform engineer, I want the core networking and compute infrastructure, so that services can be deployed to EKS Fargate.**
- Given the networking and compute-eks Terraform modules are applied
- When I inspect the AWS ap-south-1 region
- Then a VPC, NAT Gateway, subnets, and an EKS Fargate cluster exist
- Size: L
- Type: Infrastructure
- Status: done

**M1.2 As a platform engineer, I want API Gateway and ALB configured, so that external traffic can reach the EKS cluster.**
- Given the api-gateway Terraform module is applied
- When I send an HTTPS request to the ALB
- Then it routes traffic to the EKS cluster and terminates TLS 1.2+
- Size: M
- Type: Infrastructure
- Status: done

**M1.3 As a platform engineer, I want secrets management configured, so that services can securely access credentials.**
- Given the secrets Terraform module is applied
- When services start up
- Then they can securely fetch MongoDB URI and Okta client parameters via IAM IRSA
- Size: S
- Type: Infrastructure
- Status: done

**M1.4 As a developer on this team, I want CI/CD pipeline scaffolding, so that I have automated builds and deployments.**
- Given a push to the main branch
- When the CI pipeline triggers
- Then it runs unit tests and static analysis
- And blocks deployment if tests fail
- Size: M
- Type: CI/CD
- Status: done

**M1.5 As a developer on this team, I want automated build/deploy for the Orchestrator and Model Gateway, so that changes safely reach dev environments.**
- Given a successful CI build for Orchestrator or Model Gateway
- When the deploy step runs
- Then Docker images are pushed to ECR and deployed to the dev EKS namespace
- Size: M
- Type: CI/CD
- Status: tbd

**M1.6 As a developer on this team, I want automated build/deploy for MCP Tool Servers, so that domain tools can be deployed independently.**
- Given a successful CI build for the stdio or HTTP MCP Tool Servers
- When the deploy step runs
- Then they are deployed to their respective EKS namespaces
- Size: M
- Type: CI/CD
- Status: tbd
