#!/bin/bash

echo "=== CRIAÇÃO DE REPOSITÓRIOS NO AZURE DEVOPS ===" && echo ""

[[ ${REPO_NAME} == *"srv"* ]] && export STACK="java"
[[ ${REPO_NAME} == *"bff"* ]] && export STACK="java"
[[ ${REPO_NAME} == *"fed"* ]] && export STACK="nodejs"
[[ ${REPO_NAME} == *"lib"* ]] && export STACK="python"
[[ ${REPO_NAME} == *"automacao"* ]] && export STACK="java"

[[ -z ${STACK} ]] && export STACK="other"

# Terraform
export AZDO_PERSONAL_ACCESS_TOKEN=${AZ_TOKEN}
export AZDO_ORG_SERVICE_URL=${AZ_ORG}

rm -rf tfplan terraform.tfstate terraform.tfstate.backup

echo "=== REPOSITORY NAME ===" && echo "" && echo "${REPO_NAME}"
echo "" && echo "=== STACK ===" && echo "" && echo "${STACK}"

echo "" && echo "=== INIT ===" && terraform init -upgrade -reconfigure -input=false && terraform fmt
echo "" && echo "=== VALIDATE ===" && echo "" && terraform validate
echo "=== PLAN ===" && echo "" && terraform plan -var="project_name=${AZ_PRJ}" -var="repo_name=${REPO_NAME}" -var="stack=${STACK}" -out=tfplan -input=false
echo "" && echo "=== APPLY ===" && echo "" && terraform apply -input=false tfplan

# Azure CLI
export AZURE_DEVOPS_EXT_PAT=${AZ_TOKEN}

az devops configure -d organization="${AZ_ORG}"
az devops configure -d project="${AZ_PRJ}"

BRANCH_LIST=$(az repos ref list --repository "${REPO_NAME}" | jq ".[].name" | tr -d '"') && export BRANCH_LIST
echo "" && echo "=== BRANCH LIST ===" && echo "" && echo "${BRANCH_LIST}"

if [[ ! ${BRANCH_LIST} == *"refs/heads/develop"* ]]; then
  OBJECT_ID=$(az repos ref list --repository "${REPO_NAME}" | jq ".[].objectId" | tr -d '"') && export OBJECT_ID
  echo "" && echo "=== GET OBJECT ID ===" && echo "" && echo "${OBJECT_ID}"

  echo "" && echo "=== CREATE BRANCH ==="
  echo "" && az repos ref create --name "heads/develop" --repository "${REPO_NAME}" --object-id "${OBJECT_ID}"

  echo "" && echo "=== SET DEFAULT BRANCH ==="
  echo "" && az repos update --default-branch "develop" --repository "${REPO_NAME}"
fi