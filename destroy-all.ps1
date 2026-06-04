param(
    [string]$ResourceGroupPrefix = "rg-"
)

Write-Host "========================================" -ForegroundColor Red
Write-Host "DESTRUCTION SCRIPT" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red

$groups = az group list --query "[?starts_with(name, '$ResourceGroupPrefix')].name" --output tsv

if ($groups) {
    Write-Host "`nFound resource groups:" -ForegroundColor Cyan
    $groups | ForEach-Object { Write-Host "  - $_" }
    
    Write-Host "`nWARNING: This will delete ALL resources in these groups!" -ForegroundColor Red
    $confirm = Read-Host "Type 'DELETE' to confirm"
    
    if ($confirm -eq "DELETE") {
        $groups | ForEach-Object {
            Write-Host "Deleting $_..." -ForegroundColor Yellow
            # REMOVED --no-wait so deletion completes before continuing
            az group delete --name $_ --yes
        }
        Write-Host "`nAll resource groups deleted successfully." -ForegroundColor Green
    } else {
        Write-Host "Cancelled. No resources were deleted." -ForegroundColor Yellow
    }
} else {
    Write-Host "No resource groups found with prefix: $ResourceGroupPrefix" -ForegroundColor Yellow
}