param (
    $Path = $null,
    $DpiOption = $null,
    [switch] $Delete = $false
)

# Make all errors terminating
$ErrorActionPreference = "Stop"
$regPath = "HKCU:Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"

# Directly send delete request and may expecting a error
if ($Delete) {
    Remove-ItemProperty -Name $Path -Path $regPath
    exit
}

# Input check
$dpiValue = $null
Switch ($DpiOption) {
    "App" { $dpiValue = "HIGHDPIAWARE"; break }
    "Sys" { $dpiValue = "DPIUNAWARE"; break }
    "Sys2" { $dpiValue = "GDIDPISCALING DPIUNAWARE"; break }
    # Or no available operation
    default { Write-Error "Wrong dpi option"; exit; break }
}

if ($null -eq $Path) {
    Write-Error "No file specified"
    exit
}

# eXe or EXE will work, like have no Aa case check
if ($Path -like "*.exe" -eq $false) {
    Write-Error "Not a exe"
    exit
}

# Start execute
$readExistValue = $null
$exportValue = $null
try {
    $readExistValue = Get-ItemProperty -Name $Path -Path $regPath
    $exportValue = $readExistValue.$Path
}
# If can't find exist then create new
catch {
    New-ItemProperty -Name "$Path" -Value "~ $dpiValue" -PropertyType "String" -Path $regPath
    exit
}

# To update a exist value
#
# Remove exist dpi value
$exportValue = $exportValue.Replace("HIGHDPIAWARE", "")
$exportValue = $exportValue.Replace("DPIUNAWARE", "")
$exportValue = $exportValue.Replace("GDIDPISCALING DPIUNAWARE", "")

# Add new dpi value by replace "~ " to "~ $dpiValue"
$exportValue = $exportValue.Replace("~ ", "~ $dpiValue")

# Update exist
Set-ItemProperty -Name $Path -Value $exportValue -Path $regPath