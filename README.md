# Matrix Inverse Lambda

AWS Lambda function that inverts matrices using NumPy.

## Deployment

### First time setup

1. Deploy the ECR repository:
   ```bash
   cd infra/ecr
   terraform init
   terraform apply
   ```

2. Build and push the container image:
   ```bash
   ./publish.sh
   ```

3. Deploy the Lambda function:
   ```bash
   cd infra/lambda
   terraform init
   terraform apply -var="image_tag=<version>" -var="ecr_repository_url=<ecr_repo_url>"
   ```
   (The `publish.sh` script will print the exact command to run.)

### Updating the Lambda code

Just run `./publish.sh` from the project root. This will:
- Build the container image for arm64
- Push it to ECR

Then run the terraform apply command printed by the script to update the Lambda function.

### Usage

```json
{
  "matrix": [[1, 2], [3, 4]]
}
```

Returns:
```json
{
  "inverse": [[-2.0, 1.0], [1.5, -0.5]]
}
```
