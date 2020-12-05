param([string] $suffix = "", [switch]$win, [switch]$container, [switch]$restore)

if ($restore) {
    & dotnet restore bootstrap
    return
}

if ($container) {
    & docker run -it --rm -v "$($PSScriptRoot):/project" -w "/project" --entrypoint pwsh mcr.microsoft.com/dotnet/sdk:5.0 .\build.ps1 $suffix
    return
}

# trimming is risky and not really needed
# also really a bad idea if this executable shall be deplloyed standalone and load other assemblies ont he fly
$trimmed = "true"

# single file seems to require a little more startup time in the lambda
$singleFile = "false"

# always release for performance!
$config = "Release"

$lnx = -not $win
$runtime = $win ? "win-x64" : "linux-x64"

$trimmedName = $trimmed -eq "true" ? "_trimmed" : ""
$singleFileName = $singleFile -eq "true" ? "_singleFile" : ""
$suffixName = $suffix ? "_$suffix" : ""

$fileName = "package$($trimmedName)$($singleFileName)$($suffixName).zip"

$startLocation = Get-Location;
$artifactsLocation = Join-Path $startLocation "artifacts"
$publishLocation = Join-Path $startLocation "bootstrap" "bin" $config "net5.0" $runtime "publish"
$destinationPath = Join-Path $artifactsLocation $fileName

Remove-Item $destinationPath -Force -ErrorAction SilentlyContinue
Remove-Item $publishLocation -Recurse -Force -ErrorAction SilentlyContinue

& dotnet publish bootstrap `
    --configuration $config `
    /p:RuntimeIdentifier=$runtime `
    /p:PublishTrimmed=$trimmed `
    /p:TrimMode=link `
    /p:PublishReadyToRun=true `
    /p:PublishSingleFile=$singleFile

if ($lnx) {
    & Push-Location $publishLocation
    try {
        & apt update
        & apt install -y zip
        # make boostrap file executable for the linux system
        & chmod +x bootstrap

        New-Item -ItemType Directory -Path $artifactsLocation -Force
        
        & zip $destinationPath *

        # this compression method wont keep the executable flag
        #Compress-Archive * -DestinationPath $destinationPath
    } finally {
        Pop-Location
    }
} 