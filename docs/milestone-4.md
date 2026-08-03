# M4: Prod Readiness & Observability

**M4.1 As a compliance officer, I want advanced PII redaction using Amazon Comprehend, so that complex named entities are caught.**
- Given a user message contains a person's name and physical address
- When the Model Gateway processes the egress payload
- Then Comprehend identifies and redacts the entities alongside standard regex redaction
- Size: M
- Type: Feature
- Status: tbd

**M4.2 As a platform engineer, I want the CDN and Widget module deployed, so that static assets are delivered globally.**
- Given the `cdn-widget` Terraform module is applied
- When a user loads the chat widget
- Then assets are served via AWS CloudFront backed by an S3 origin
- Size: S
- Type: Infrastructure
- Status: tbd

**M4.3 As a platform engineer, I want observability and logging setup, so that we can monitor latency and error rates.**
- Given the `monitoring` Terraform module is applied
- When traffic flows through the system
- Then CloudWatch dashboards display p50/p99 latencies, and X-Ray traces end-to-end requests
- Size: M
- Type: Infrastructure
- Status: tbd

**M4.4 As an on-call engineer, I want a rollback mechanism, so that bad deployments can be reverted quickly.**
- Given a new deployment causes an elevated error rate
- When I trigger a rollback via the CI/CD pipeline
- Then the previous known-good ECR image tag is immediately redeployed to the EKS cluster
- Size: S
- Type: CI/CD
- Status: tbd
