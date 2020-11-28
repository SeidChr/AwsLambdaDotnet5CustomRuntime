param([switch]$win, [switch]$container)

if ($container) {
    & docker run -it --rm -v "$($PSScriptRoot):/project" -w "/project" --entrypoint pwsh mcr.microsoft.com/dotnet/sdk:5.0
    return
}

$trimmed = "true"
$singleFile = "true"
$config = "Release"

$lnx = -not $win
$runtime = $win ? "win-x64" : "linux-x64"
$path = "bootstrap/bin/$config/net5.0/$runtime/publish"

Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
& dotnet publish bootstrap --configuration $config -p:RuntimeIdentifier=$runtime /p:PublishTrimmed=$trimmed /p:TrimMode=link /p:PublishReadyToRun=true /p:PublishSingleFile=$singleFile

if ($lnx) {
    & Push-Location $path
    try {
        & apt update
        & apt install -y zip

        & chmod +x bootstrap
        & zip package.zip bootstrap
    } finally {
        Pop-Location
    }
} 