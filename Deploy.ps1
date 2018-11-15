[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
   [string]$sourceDir,

  [Parameter(Mandatory=$True)]
   [string]$deployDir,
   
  [Parameter(Mandatory=$True)]
   [string]$deployConfigName,

  [Parameter(Mandatory=$True)]
   [string]$buildNumber
)

try
{
    $addonCodePath = $sourceDir
    $destinationPath = $deployDir
    $deployConfigFile = Join-Path -Path $sourceDir -ChildPath $deployConfigName
    $configFile = Join-Path -Path $sourceDir -ChildPath "Config.xml"

    function updateXml($fileName, $buildVersion)
    {
        $exists = Test-Path($fileName) -ErrorAction Stop
        if ($exists -eq $false)
        {
            throw "inputfile does not exist"
        }
        Write-Host "XML Transform for file $fileName to add build number $buildVersion"
        $configXml = [xml](Get-Content $fileName)
        $configXml.Configuration.Version -match '[\d]*\.[\d]*'
        $version = $Matches[0] #magic variable for regex matches
        $version = $version, $buildVersion -join "."
        $configXml.Configuration.Version = $version.ToString() #Not sure why the type cast is required
        $configXml.Save($fileName);
    }

    if (Test-Path $destinationPath)
    {
        Write-Host "path exists"
        Remove-Item $destinationPath\*.* -Force
    }
    else
    {
        Write-Host "path does not exist"
        New-Item $destinationPath -ItemType Directory -Force
    }

    #Rename-Item $configFile "Config.xml.bak"
    #Rename-Item $deployConfigFile $configFile

    updateXml -fileName $deployConfigFile -buildVersion $buildNumber
    Copy-Item -Path $addonCodePath\*.* -include *.xml,*.lua,*.dbcx -Exclude Config.xml -Destination $destinationPath -ErrorAction Stop
    Copy-Item -Path $deployConfigFile -Destination $destinationPath\Config.xml -ErrorAction Stop

    Write-Host "copy complete"
    Exit 0
}
catch
{
        Write-Error( "Error returned during process" )
        $ErrorMessage = $_.Exception.Message
        Write-Error($ErrorMessage)
        throw $_
        Exit 1
}