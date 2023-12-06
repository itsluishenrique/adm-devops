####### Crendenciais da VM onde vai ser feito o processo

$pwd_deploy = convertto-securestring -AsPlainText -Force -String "SENHA_DA_VM"

$deploy = new-object -typename System.Management.Automation.PSCredential -argumentlist "USUARIO_DA_VM",$pwd_deploy

####### Variáveis auxiliares

$ip = ""

$mydate = Get-Date -Format "dd-MM-yyyy"

####### Processo de deploy

Write-Host "======================================================================="
Write-Host "======================== Verificando conectividade ===================="
Write-Host "======================================================================="

try {
    ping $ip

    if($?) {
        Write-Host "Conectividade com servidor remoto está ok!"
    }
    else {
        Write-Host "Por favor verifique a conectividade com o servidor remoto!"

        exit 1
    }
}
catch {
    Write-Host "=============== Ocorreu um erro ao realizar o processo ============"
    Write-Host "=============== Detalhamento do erro: ============================="
    
    Write-Host $_.Exception.Message

    exit 1
}

Write-Host "======================================================================="
Write-Host "======================== Extrair pacote de deploy ====================="
Write-Host "======================================================================="

try {
    Invoke-Command -ComputerName $ip -ScriptBlock { /templates/01-extrair-zip.ps1 } -Credential $deploy
}
catch {
    Write-Host "=============== Ocorreu um erro ao realizar o processo ============"
    Write-Host "=============== Detalhamento do erro: ============================="
    
    Write-Host $_.Exception.Message

    exit 1
}

Write-Host "======================================================================="
Write-Host "======================== Gerar backup ================================="
Write-Host "======================================================================="

try {
    Invoke-Command -ComputerName $ip -ScriptBlock { /templates/02-gerar-backup.bat } -Credential $deploy
}
catch {
    Write-Host "=============== Ocorreu um erro ao realizar o processo ============"
    Write-Host "=============== Detalhamento do erro: ============================="
    
    Write-Host $_.Exception.Message

    exit 1
}

Write-Host "======================================================================="
Write-Host "======================== Parar IIS ===================================="
Write-Host "======================================================================="

try {
    Invoke-Command -ComputerName $ip -ScriptBlock { /templates/03-parar-iis.bat } -Credential $deploy
}
catch {
    Write-Host "=============== Ocorreu um erro ao realizar o processo ============"
    Write-Host "=============== Detalhamento do erro: ============================="
    
    Write-Host $_.Exception.Message

    exit 1
}

Write-Host "======================================================================="
Write-Host "======================== Copiar arquivos =============================="
Write-Host "======================================================================="

try {
    Invoke-Command -ComputerName $ip -ScriptBlock { /templates/04-copiar-arquivos.bat } -Credential $deploy
}
catch {
    Write-Host "=============== Ocorreu um erro ao realizar o processo ============"
    Write-Host "=============== Detalhamento do erro: ============================="
    
    Write-Host $_.Exception.Message

    exit 1
}

Write-Host "======================================================================="
Write-Host "======================== Atualizar app ================================"
Write-Host "======================================================================="

try {
    Invoke-Command -ComputerName $ip -ScriptBlock { /templates/05-atualizar-app.bat } -Credential $deploy
}
catch {
    Write-Host "=============== Ocorreu um erro ao realizar o processo ============"
    Write-Host "=============== Detalhamento do erro: ============================="
    
    Write-Host $_.Exception.Message

    exit 1
}

Write-Host "======================================================================="
Write-Host "======================== Atualizar banco de dados ====================="
Write-Host "======================================================================="

try {
    Invoke-Command -ComputerName $ip -ScriptBlock { /templates/06-atualizar-banco-de-dados.bat } -Credential $deploy
}
catch {
    Write-Host "=============== Ocorreu um erro ao realizar o processo ============"
    Write-Host "=============== Detalhamento do erro: ============================="
    
    Write-Host $_.Exception.Message

    exit 1
}

Write-Host "======================================================================="
Write-Host "======================== Iniciar IIS =================================="
Write-Host "======================================================================="

try {
    Invoke-Command -ComputerName $ip -ScriptBlock { /templates/07-iniciar-iis.bat } -Credential $deploy
}
catch {
    Write-Host "=============== Ocorreu um erro ao realizar o processo ============"
    Write-Host "=============== Detalhamento do erro: ============================="
    
    Write-Host $_.Exception.Message

    exit 1
}

Write-Host "======================================================================="
Write-Host "======================== Excluir pacote de deploy ====================="
Write-Host "======================================================================="

try {
    Invoke-Command -ComputerName $ip -ScriptBlock { /templates/08-excluir-zip.ps1 } -Credential $deploy
}
catch {
    Write-Host "=============== Ocorreu um erro ao realizar o processo ============"
    Write-Host "=============== Detalhamento do erro: ============================="
    
    Write-Host $_.Exception.Message

    exit 1
}