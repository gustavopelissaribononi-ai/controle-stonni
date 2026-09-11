# ============================================================
#  Pacote de envio para a Hostinger: SO o que pode ficar publico.
#  Mesma lista do .github/workflows/pages.yml, de proposito -- os
#  dois enderecos tem que servir a mesma coisa.
#
#  As entradas sao gravadas com barra normal ("icons/x.png"), e nao
#  com a barra invertida que o Compress-Archive do Windows usa: o
#  descompactador do servidor Linux criaria um arquivo chamado
#  "icons\x.png" no lugar da pasta, e o app ficaria sem icone.
# ============================================================
$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location $raiz

$itens = @(
  @{ origem = 'index.html';          destino = 'index.html' },
  @{ origem = 'manifest.json';       destino = 'manifest.json' },
  @{ origem = 'sw.js';               destino = 'sw.js' },
  @{ origem = 'publicar\.htaccess';  destino = '.htaccess' }
)
Get-ChildItem 'icons\*.png' | ForEach-Object {
  $itens += @{ origem = "icons\$($_.Name)"; destino = "icons/$($_.Name)" }
}

foreach ($i in $itens) {
  if (-not (Test-Path $i.origem)) { throw "faltando: $($i.origem)" }
}

$zip = Join-Path $raiz 'publicar\controle-stonni.zip'
if (Test-Path $zip) { Remove-Item $zip -Force }

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$fs = [System.IO.File]::Open($zip, 'Create')
$ar = New-Object System.IO.Compression.ZipArchive($fs, 'Create')
try {
  foreach ($i in $itens) {
    $e  = $ar.CreateEntry($i.destino, 'Optimal')
    $es = $e.Open()
    $bytes = [System.IO.File]::ReadAllBytes((Join-Path $raiz $i.origem))
    $es.Write($bytes, 0, $bytes.Length)
    $es.Dispose()
    '{0,10:N0}  {1}' -f $bytes.Length, $i.destino
  }
} finally {
  $ar.Dispose()
  $fs.Dispose()
}

$versao = (Select-String -Path 'index.html' -Pattern "const VERSAO_APP = '([^']*)'").Matches[0].Groups[1].Value
$sw     = (Select-String -Path 'sw.js'      -Pattern "const VERSAO = '([^']*)'").Matches[0].Groups[1].Value

Write-Output ''
Write-Output "Pacote pronto: publicar\controle-stonni.zip"
Write-Output "  app: $versao"
Write-Output "  sw : $sw"
if ($sw -notlike "*$versao-*") {
  Write-Output ''
  Write-Output "  !! ATENCAO: VERSAO_APP e a VERSAO do sw.js nao batem."
}
Write-Output ''
Write-Output 'ANTES de enviar, apague no servidor: docs/  bancada/  arte/  supabase/  README.md'
Write-Output 'Enviar o pacote NAO apaga nada -- so sobrescreve.'
