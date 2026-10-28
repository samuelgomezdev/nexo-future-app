# Roda os testes das regras do Firestore no emulador do Firebase.
# O emulador precisa do Java 21 ou mais novo; se o Java do computador for mais
# antigo, usa o JDK que vem com o Android Studio, só durante este comando.
# Uso, na raiz do projeto:  powershell -ExecutionPolicy Bypass -File tool\testar_regras.ps1

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot

function VersaoJava($java) {
    # O java -version escreve no stderr; o cmd junta as saídas sem virar erro.
    $saida = cmd /c "`"$java`" -version 2>&1" | Select-Object -First 1
    if ("$saida" -match 'version "(\d+)') { return [int]$Matches[1] }
    return 0
}

$candidatos = @()
if ($env:JAVA_HOME) { $candidatos += $env:JAVA_HOME }
$candidatos += "$env:ProgramFiles\Android\Android Studio\jbr"
$candidatos += "$env:LOCALAPPDATA\Programs\Android Studio\jbr"

$jdk = $null
foreach ($pasta in $candidatos) {
    $java = Join-Path $pasta 'bin\java.exe'
    if ((Test-Path $java) -and ((VersaoJava $java) -ge 21)) { $jdk = $pasta; break }
}
if (-not $jdk) {
    Write-Error 'Não achei um Java 21 ou mais novo. Instale o Android Studio ou um JDK 21+.'
}

$env:JAVA_HOME = $jdk
$env:PATH = "$jdk\bin;$env:PATH"
Write-Host "Usando o Java de $jdk"

Push-Location (Join-Path $raiz 'testes_regras')
try {
    if (-not (Test-Path 'node_modules')) { npm install }
    npx --yes firebase-tools@15 emulators:exec --only firestore --project demo-nexo-future 'npm test'
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
