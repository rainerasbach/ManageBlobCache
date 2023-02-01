<#
.SYNOPSIS
    Enables and configures the SharePoint BLOB Cache. 

    based upon
    http://blog.kuppens-switsers.net/sharepoint/enabling-blob-cache-sharepoint-using-powershell/
    
.DESCRIPTION
    Enables and configures the SharePoint BLOB Cache. 

.NOTES
    File Name: Enable-BlobCache.ps1
    Author   : Bart Kuppens
    Version  : 2.0

    Allow to enable the blobcach and specify the file location 

    File Name: ManageBlobCache.PS1
    Author   : Rainer Asbach
    Version  : 3.2

    Add support for enable/Disable, Change size, Update existing configuration

    File Name: ManageBlobCache.PS1
    Author   : Rainer Asbach
    Version  : 3.3

    Add support for changing the extensions in the BlobCache


.PARAMETER Url
    [String] Specifies the URL of the Web Application for which the BLOB cache should be enabled. 

.PARAMETER Location
    [String] Specifies the location of the BLOB Cache. 	 

.Parameter BlobCacheMaxSizeInGB
    [Integer] Specifies the Maximum Size of the BlobCache for this Web Application in GB (default: 10 GB)
    
.Parameter MaxAgeInSeconds
    [Integer] Specifies the value for the Max-Age attribute all items that are serv (default: 86400  = 24 hours)
    
.Parameter WebConfigModificationOwner
    [String] Specify your own WebConfigModificationOwner (default:BlobCacheMod)
    
.Parameter DisableBlobCache
    [Switch] Sets the Value for Enabled  back to the default "false"
    Only Reset Or DisableBlobCache set the value for Enabled to false, all other changes enable the blobcache while making a cahn
    
.Parameter Reset
    [Switch]  Resets the default values (Disables the BlobCache and reverts all other settings)

.Parameter AddExtension
    [Switch] Sets the Value for Enabled  back to the default "false"
    
.Parameter RemoveExtension
    [Switch] Sets the Value for Enabled  back to the default "false"

.Parameter Extension
    [String] Specifies a single Extension to be added to or Removed from the BlobCache
    
.EXAMPLE
    PS > .\ManageBlobCache.ps1 -Url http://intranet.westeros.local -Location d:\BlobCache\Intranet
    
   Description
   -----------
   This script enables the BLOB cache for the http://intranet.westeros.local web application and stores
   it under d:\blobcache\intranet

.EXAMPLE
    PS > .\ManageBlobCache.ps1 -Url http://intranet.westeros.local -EnableBlobCache
    
   Description
   -----------
   This script enables the BLOB cache for the http://intranet.westeros.local web application and stores
   it in the Default location c:\BlobCache\14

.EXAMPLE
    PS > .\ManageBlobCache.ps1 -Url http://intranet.westeros.local -AddExtension -Extension ABC 
    and enables the BloCache
    
   Description
   -----------
   This script adds the Extension ABC to the Cached Extensions for the WebApplicaiton http://intranet.westeros.local


.EXAMPLE
    PS > .\ManageBlobCache.ps1 -Url http://intranet.westeros.local -Reset

   Description
   -----------
   This resets the BlobCache configuration for the web application http://intranet.westeros.local web application to the SharePoint Defaults


.ToDo
   Add a parameter for the file extensions
   Add a parameter to add or remove file extensions
   Add a parameter that shows the current values

.Versions
   3.0
     Added the option to set the file extensions
     Added the option to overwrite the settings
   3.1
     Added parameters for DisableBlobCache, BlobCacheSize,MaxAge,WebConfigModifcationOwner with proper defaults
     Added  -reset parameter to set the defaults
   3.2
     Documented Parameters
     Added ParameterSets
   
#>

[CmdletBinding(DefaultParameterSetName = 'Get')]
param( 
   <#[Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1, ParameterSetName = "Set")] 
   [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1, ParameterSetName = "Disable")] 
   [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1, ParameterSetName = "Reset")]
   [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1, ParameterSetName = "AddExt")] 
   [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1, ParameterSetName = "RemoveExt")] 
   #>
   [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=0)] 
   [string]$Url,

   [Parameter(Mandatory=$false, ValueFromPipeline=$false, Position=1, ParameterSetName = "Get")] 
   [switch]$Get=$true,
   
   [Alias("Enable")]
   [Parameter(Mandatory=$false, ValueFromPipeline=$false, Position=1, ParameterSetName = "Set")] 
   [switch]$EnableBlobCache,
   
   [Parameter(Mandatory=$false, ValueFromPipeline=$false, Position=2, ParameterSetName = "Set")] 
   [string]$Location="C:\BlobCache\14",
   
   [Parameter(Mandatory=$false, ValueFromPipeline=$false, Position=3, ParameterSetName = "Set")]
   [int]$BlobCacheMaxSizeInGB=10,
   
   [Parameter(Mandatory=$false, ValueFromPipeline=$false, Position=4, ParameterSetName = "Set")]
   [int]$MaxAgeInSeconds=86400, 
   
   [Parameter(Mandatory=$false, ValueFromPipeline=$false, Position=5, ParameterSetName = "Set")]
   [string]$WebConfigModificationOwner="BlobCacheMod", 
   
   [Alias("Disable")]
   [Parameter(Mandatory=$false, ValueFromPipeline=$false, Position=1, ParameterSetName = "Disable")] 
   [switch]$DisableBlobCache,
   
   [Alias("Reset")]
   [Parameter(Mandatory=$false, ValueFromPipeline=$false, Position=1, ParameterSetName = "Reset")]
   [switch]$ResetBlobCache,

   [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1, ParameterSetName = "AddExt")] 
   [switch]$AddExtension,

   [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=1, ParameterSetName = "RemoveExt")] 
   [switch]$RemoveExtension,

   [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=2, ParameterSetName = "AddExt")] 
   [Parameter(Mandatory=$true, ValueFromPipeline=$false, Position=2, ParameterSetName = "RemoveExt")] 
   [string]$Extension="abc"
) 

#Default is to show values
if ($ResetBlobCache -or $AddExtension -or $RemoveExtension -or $DisableBlobCache -or $EnableBlobCache)
{ $get = $false } 
 

 $DefaultFilePath = "\.(gif|jpg|jpeg|jpe|jfif|bmp|dib|tif|tiff|themedbmp|themedcss|themedgif|themedjpg|themedpng|ico|png|wdp|hdp|css|js|asf|avi|flv|m4v|mov|mp3|mp4|mpeg|mpg|rm|rmvb|wma|wmv|ogg|ogv|oga|webm|xap)$"

# Load the SharePoint PowerShell snapin if needed
if ((Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null)
{
   Add-PSSnapin Microsoft.SharePoint.PowerShell
}
 
$webApp = Get-SPWebApplication $Url
$modifications = $webApp.WebConfigModifications | ? { $_.Owner -eq $WebConfigModificationOwner }

if ($get)
{
    $modifications
    $modifications.count.tostring() + " web config modifications found for owner " + $WebConfigModificationOwner
    return 
}


$OldExtensions = ($modifications | ? {$_. name -eq "path"}).value


if ($ResetBlobCache)
{
   $Location="C:\BlobCache\14"
   $BlobCacheMaxSizeInGB="10"
   $DisableBlobCache=$true
   $MaxAgeInSeconds="86400"
   $WebConfigModificationOwner="BlobCacheMod"
   $path=$DefaultFilePath
} else {
    $path=$OldExtensions
}


if ($DisableBlobCache)
{
    $BlobCacheEnabled="false"
}
else
{
    $BlobCacheEnabled="true"
}

#region ModifyExtensions
[System.Collections.ArrayList]$ExtensionList=@{}
if ($AddExtension -or $RemoveExtension)
{
    $ExtensionList = $OldExtensions.trimStart('\.(').TrimEnd(')$').split('|')
    
    if ($AddExtension)
    {
        if ($ExtensionList.Contains($Extension))
        {
            write-host -f Yellow "Extension $Extension is already included in the BlobCache"
            return
        } else {
            $ExtensionList.add($Extension)
        }
    }

    if ($RemoveExtension)
    {
        if ($ExtensionList.Contains($Extension))
        {
            $ExtensionList.RemoveAt($Extensionlist.IndexOf($Extension))
        } else {
            write-host -f Yellow "Extension was not included in the BlobCache"
            return
        }
    }
    $path = '\.(' + (($ExtensionList | sort) -join '|') + ')$'
    #$OldExtensions
    #$path
}
#endregion

#$modifications
if ($modifications.Count -ne $null -and $modifications.Count -gt 0)
{
    Write-Host -ForegroundColor Yellow "Modifications have already been added!"
    $a= read-Host "Re-Create Entries? (Y/N)"
    if ($a -ne 'y')
    {
        write-host "Canceled"
        break
    }

    for ($i=$modifications.count-1;$i -ge 0;$i--)
    {
        $c = ($webApp.WebConfigModifications | ? {$_.Owner -eq $WebConfigModificationOwner})[$i] 
        $r = $webApp.WebConfigModifications.Remove($c)
    }

    $webApp.update()
    $webApp.Parent.ApplyWebConfigModifications()
}
 
# Enable/Disable Blob cache
[Microsoft.SharePoint.Administration.SPWebConfigModification] $config1 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
$config1.Path = "configuration/SharePoint/BlobCache" 
$config1.Name = "enabled"
$config1.Value = $BlobCacheEnabled
$config1.Sequence = 0
$config1.Owner = $WebConfigModificationOwner 
$config1.Type = 1 
 
# add max-age attribute
[Microsoft.SharePoint.Administration.SPWebConfigModification] $config2 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
$config2.Path = "configuration/SharePoint/BlobCache" 
$config2.Name = "max-age"
$config2.Value = $MaxAgeInSeconds
$config2.Sequence = 0
$config2.Owner = $WebConfigModificationOwner 
$config2.Type = 1 
 
# Set the location
[Microsoft.SharePoint.Administration.SPWebConfigModification] $config3 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
$config3.Path = "configuration/SharePoint/BlobCache" 
$config3.Name = "location"
$config3.Value = $Location
$config3.Sequence = 0
$config3.Owner = $WebConfigModificationOwner 
$config3.Type = 1

# Set the File Types
[Microsoft.SharePoint.Administration.SPWebConfigModification] $config4 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
$config4.Path = "configuration/SharePoint/BlobCache" 
$config4.Name = "path"
$config4.Value = $Path
$config4.Sequence = 0
$config4.Owner = $WebConfigModificationOwner 
$config4.Type = 1

# Set the size of the BlobCache in GB
[Microsoft.SharePoint.Administration.SPWebConfigModification] $config5 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
$config5.Path = "configuration/SharePoint/BlobCache" 
$config5.Name = "maxSize"
$config5.Value = $BlobCacheMaxSizeInGB
$config5.Sequence = 0
$config5.Owner = $WebConfigModificationOwner 
$config5.Type = 1
 

#Add mods to webapp and apply to web.config
$webApp.WebConfigModifications.Add($config1)
$webApp.WebConfigModifications.Add($config2)
$webApp.WebConfigModifications.Add($config3)
$webApp.WebConfigModifications.Add($config4)
$webApp.WebConfigModifications.Add($config5)
$webApp.update()
$webApp.Parent.ApplyWebConfigModifications()

#$webApp.WebConfigModifications