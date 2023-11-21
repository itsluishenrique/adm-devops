echo "=== CRIAÇÃO DE PIPELINES NO AZURE DEVOPS ===" && echo ""

export AZURE_DEVOPS_EXT_PAT=${AZ_TOKEN}

[[ ${PIPE_NAME} == *".yml"* ]] && export PIPE_NAME="${PIPE_NAME%%.*}"

if [[ $(find ./*"${PIPE_NAME}"*.yml -maxdepth 1 2>/dev/null | wc -l) -eq 0 ]]; then
  echo "Nenhum arquivo YAML com o nome '${PIPE_NAME}.yml' foi encontrado na raiz do repositório."
  exit 1
else
  echo "PIPE_NAME: ${PIPE_NAME}.yml"
fi

az devops configure -d organization="${AZ_ORG}"
az devops configure -d project="${AZ_PRJ}"

if [[ ${PIPE_NAME} == *"release"* ]]; then
  export BRANCH_NAME="master"
  export FOLDER_NAME="RELEASE"

  echo "BRANCH_NAME: ${BRANCH_NAME}"
else
  export BRANCH_NAME="develop"
  export FOLDER_NAME="SNAPSHOT"

  echo "BRANCH_NAME: ${BRANCH_NAME}"
fi

[[ ${PIPE_NAME} == *"lib"* ]] && export FOLDER_NAME="INGESTÃO/${FOLDER_NAME}"

[[ ${PIPE_NAME} == *"automacao"* ]] && export FOLDER_NAME="AUTOMAÇÃO"

echo "FOLDER_NAME: ${FOLDER_NAME}" && echo ""

az pipelines create \
  --name "${PIPE_NAME}" \
  --repository "${REPO_NAME}" \
  --branch "${BRANCH_NAME}" \
  --yaml-path "${PIPE_NAME}.yml" \
  --folder-path "${FOLDER_NAME}" \
  --skip-first-run true \
  --repository-type "tfsgit" \
  --description "[AUTOMATION] Este pipeline foi gerado automaticamente pela equipe DevOps."