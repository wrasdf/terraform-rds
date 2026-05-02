#!/bin/bash

set -eou pipefail

terraform init \
  -backend-config="bucket=terraform-state-909149932173" \
  -backend-config="key=zip-au/terraform-modules/terraform-rds" \
  -backend-config="region=ap-southeast-2" \
  -backend-config="dynamodb_table=terraform-lock-909149932173" \
  -input=false

terraform workspace new labs-apse2-main || true
terraform workspace select labs-apse2-main
terraform workspace show

# terraform plan -out plan.tfplan
# terraform apply -input=false plan.tfplan

terraform plan -destroy -out=destroy.tfplan
terraform apply "destroy.tfplan"
