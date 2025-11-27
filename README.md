# Matrix Inverse Lambda

Minimal example of an AWS Lambda in Python with `uv` dependency management.

This is a working Lambda that inverts matrices using NumPy. I keep this repository as a reference for myself when setting up new Python Lambdas with proper dependency management, containerized deployment, and Terraform infrastructure.

## Rationale

### Why containers?

AWS Lambda zip deployments are limited to 50 MB compressed (250 MB uncompressed). This is easy to exceed with Python dependencies. Container images can be up to 10 GB, so you don't have to worry about it.

### Target architecture

Some Python packages (like NumPy) include compiled C or Fortran code, so the installed package is architecture-specific. The Lambda runs on `arm64` (cheaper than `x86`), which may differ from your development machine. Container images solve this — the `publish.sh` script uses `--platform=linux/arm64` to build for the right architecture regardless of where you're building.

### Provenance

Docker BuildKit adds provenance attestations by default, which creates a manifest list instead of a simple image manifest - but Lambda doesn't handle this well and fails. The `publish.sh` script avoids this with `--provenance=false`.

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

### Testing

Run `./test.sh` to invoke the deployed Lambda with a sample matrix and verify the response:
```bash
./test.sh
```

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
