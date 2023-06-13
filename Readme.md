# AWS First-timer Setup

1. Install aws CLI
2. Configure region
```
aws configure
```
3. Login with docker
```
aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
```
4. hi 🙈