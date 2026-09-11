@echo off
REM ============================================================
REM  Monta o pacote de envio para a Hostinger com SO o que pode
REM  ficar publico. A lista e a mesma do .github/workflows/pages.yml.
REM
REM  Motivo: em 11/09/2026 o controle.stonni.com.br estava servindo
REM  docs/STATUS.md (o protocolo inteiro) e o testador de bancada,
REM  porque a pasta do projeto foi enviada por inteiro.
REM ============================================================
setlocal
cd /d "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "publicar\gerar.ps1"
endlocal
