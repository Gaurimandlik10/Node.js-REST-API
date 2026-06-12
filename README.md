 Dockerized Node.js REST API on Kubernetes
Tools:  Docker  ·  Jenkins  ·  Kubernetes  ·  AWS ECR  ·  Helm  ·  Terraform
Build a simple TODO REST API in Node.js. Containerize it, push to AWS ECR, deploy to Kubernetes using a Helm chart with liveness and readiness probes configured. Use Terraform to provision the EKS cluster.
Pipeline:  Git push  →  Jenkins CI  →  Docker build  →  Push to ECR  →  Terraform EKS  →  Helm install  →  K8s deploy with probes
Skills covered:  ECR, Helm chart creation, K8s probes (liveness + readiness), Deployment + Service YAML, EKS provisioning
Additional learning points:
•    Add a startupProbe for slow container initialisation
•    Practice helm upgrade and helm rollback
•    Configure resource requests and limits on the container
