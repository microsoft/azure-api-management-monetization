$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $PSCommandPath
$toolsDir = "$here/tools"

if ($IsWindows) {
    $os = "win"
}
elseif ($IsLinux) {
    $os = "linux"
}
elseif ($IsMacOS) {
    $os = "osx"
}
else {
    throw "Unsupported OS"
}

function installBicep {
    $version = "v0.3.126"
    $extension = $IsWindows ? ".exe" : ""
    $bicepUri = "https://github.com/Azure/bicep/releases/download/$version/bicep-$os-x64$extension"

    $dir = New-Item -Path $toolsDir/bicep/$version -ItemType Directory -Force
    $bicep = "$dir\bicep$extension"

    if (Test-Path $dir/* -Filter bicep*) {
        Write-Host "Bicep already installed."
    }
    else {    
        (New-Object Net.WebClient).DownloadFile($bicepUri, $bicep)
    }

    return $bicep
}

try {
    Write-Host "Installing Bicep..."
    $bicep = installBicep

    Write-Host "Building main Bicep template..."
    . $bicep build $here/templates/main.bicep --outdir $here/output
}
catch {
    Write-Warning $_.ScriptStackTrace
    Write-Warning $_.InvocationInfo.PositionMessage
    Write-Error ("Build error: `n{0}" -f $_.Exception.Message)
}