. "$PSScriptRoot\..\..\lib\common.ps1"

#
# Uninstall bloat
#

Write-Info ":: Uninstalling bloat apps..."

# Cache installed and provisioned app lists just once
$installedPackages = Get-AppxPackage -AllUsers
$provisionedPackages = Get-AppxProvisionedPackage -Online

# List of app names or wildcard patterns to remove
$appNames = @(
    "Microsoft.3DBuilder",
    "AdobeSystemsIncorporated.AdobeCreativeCloudExpress",
    "AmazonVideo.PrimeVideo",
    "*.AutodeskSketchBook",
    "Microsoft.BingFinance",
    "Microsoft.BingNews",
    "Microsoft.BingSports",
    "Microsoft.BingWeather",
    "king.com.BubbleWitch3Saga",
    "king.com.CandyCrushSodaSaga",
    "Clipchamp.Clipchamp",
    "Microsoft.549981C3F5F10",  # Cortana
    "Disney.37853FC22B2CE",     # Disney+
    "*.DisneyMagicKingdoms",
    "Facebook.Facebook*",
    "Facebook.Instagram*",
    "Microsoft.WindowsMaps",
    "*.MarchofEmpires",
    "Microsoft.OneConnect",     # Mobile Plans
    "Microsoft.Office.OneNote",
    "Microsoft.SkypeApp",
    "*.SlingTV",
    "Microsoft.MicrosoftSolitaireCollection",
    "SpotifyAB.SpotifyMusic",
    "Microsoft.Office.Sway",
    "*.TikTok",
    "Microsoft.ToDos",
    "*.Twitter",
    "Microsoft.ZuneMusic",      # Groove
    "Microsoft.ZuneVideo"
)

foreach ($app in $appNames) {
    # Remove installed packages
    $matchedPackages = $installedPackages | Where-Object { $_.Name -like $app }
    foreach ($pkg in $matchedPackages) {
        Write-Info "Removing installed app: $($pkg.Name)" -ForegroundColor Yellow
        Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue
    }

    # Remove provisioned packages (for new users)
    $matchedProvisioned = $provisionedPackages | Where-Object { $_.DisplayName -like $app }
    foreach ($prov in $matchedProvisioned) {
        Write-Info "Removing provisioned app: $($prov.DisplayName)" -ForegroundColor DarkYellow
        Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -AllUsers -ErrorAction SilentlyContinue
    }
}

