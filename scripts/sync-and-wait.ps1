# Modul 13: Sync ausloesen und auf Healthy warten - mit Timeout und sauberem Exit-Code.
param([Parameter(Mandatory)][string]$App, [int]$TimeoutSec = 300)
$ErrorActionPreference = "Continue"

argocd app sync $App --prune --timeout 120
if ($LASTEXITCODE -ne 0) {
  Write-Host "Sync von $App fehlgeschlagen" -ForegroundColor Red
  argocd app get $App --show-operation
  exit 1
}

$deadline = (Get-Date).AddSeconds($TimeoutSec)
do {
  $a = argocd app get $App -o json | ConvertFrom-Json
  $h = $a.status.health.status; $s = $a.status.sync.status
  Write-Host ("{0:HH:mm:ss}  sync={1}  health={2}" -f (Get-Date), $s, $h)
  if ($s -eq 'Synced' -and $h -eq 'Healthy') { exit 0 }
  if ($h -eq 'Degraded') { Write-Host "Degraded - Abbruch" -ForegroundColor Red; exit 1 }
  Start-Sleep 5
} while ((Get-Date) -lt $deadline)
Write-Host "Timeout nach $TimeoutSec s" -ForegroundColor Red
exit 3
