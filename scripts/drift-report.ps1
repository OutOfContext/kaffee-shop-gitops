# Modul 13: Drift-Report - OutOfSync/Degraded-Apps inkl. Dauer. Exit-Code 1, wenn etwas rot ist.
$ErrorActionPreference = "Continue"
$apps = argocd app list -o json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { Write-Error "argocd app list fehlgeschlagen - Login?"; exit 2 }

$problems = foreach ($a in $apps) {
  $sync = $a.status.sync.status; $health = $a.status.health.status
  if ($sync -eq 'Synced' -and $health -eq 'Healthy') { continue }
  $since = if ($a.status.operationState.finishedAt) {
             [math]::Round(((Get-Date) - [datetime]$a.status.operationState.finishedAt).TotalMinutes) } else { '?' }
  [pscustomobject]@{
    App = $a.metadata.name; Project = $a.spec.project; Sync = $sync; Health = $health
    MinutenSeitLetztemSync = $since
    Fehler = ($a.status.conditions | ForEach-Object message) -join '; '
  }
}
if (-not $problems) { Write-Host "Alle Apps Synced/Healthy" -ForegroundColor Green; exit 0 }
$problems | Sort-Object Health, Sync | Format-Table -AutoSize
exit 1
