try {
    # Define current directory
    $currentDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    Set-Location $currentDir

    # Define the URL and zip file path
    $zipUrl = "https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip"
    $zipFilePath = "$currentDir\main.zip"

    # Download the zip file
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($zipUrl, $zipFilePath)

    # Extract the zip file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFilePath, $currentDir)

    # Define extracted folder path
    $extractedFolderPath = "$currentDir\MaaResource-main"

    # Copy cache and resource folders, replacing existing files
    $cacheSourcePath = "$extractedFolderPath\cache"
    $resourceSourcePath = "$extractedFolderPath\resource"
    $cacheDestinationPath = "$currentDir"
    $resourceDestinationPath = "$currentDir"

    # Copy cache folder
    Copy-Item -Path $cacheSourcePath -Destination $cacheDestinationPath -Recurse -Force

    # Copy resource folder
    Copy-Item -Path $resourceSourcePath -Destination $resourceDestinationPath -Recurse -Force

    # Delete the zip file and extracted folder
    Remove-Item -Path $zipFilePath
    Remove-Item -Path $extractedFolderPath -Recurse

}
catch {
    Write-Host "An error occurred when downloading MaaResource: $_"
}