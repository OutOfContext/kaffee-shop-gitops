# Modul 13: Repo-URL fuer alle Apps eines Projekts umstellen.
# ACHTUNG: nur fuer Apps, die NICHT aus Git (App of Apps / ApplicationSet) kommen - sonst dort aendern!
param([string]$Project = 'nordlicht', [string]$Old = 'github.com/alt', [string]$New = 'github.com/neu')
$ErrorActionPreference = "Continue"
$apps = argocd app list --project $Project -o json | ConvertFrom-Json
foreach ($a in $apps) {
  $url = $a.spec.source.repoURL
  if ($url -notlike "*$Old*") { continue }
  $newUrl = $url.Replace($Old, $New)
  Write-Host "$($a.metadata.name): $url -> $newUrl"
  argocd app set $a.metadata.name --repo $newUrl
  if ($LASTEXITCODE -ne 0) { Write-Warning "  fehlgeschlagen"; continue }
  argocd app get $a.metadata.name --hard-refresh | Out-Null
}
