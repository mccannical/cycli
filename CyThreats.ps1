﻿<#
.SYNOPSIS
    Gets the threat list for the given device

.PARAMETER API
    Optional. API Handle (use only when not using session scope).

.PARAMETER Device
    The device to retrieve the threats for.
#>
function Get-CyDeviceThreats {
    Param (
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [CylanceAPIHandle]$API = $GlobalCyAPIHandle,
        [Parameter(Mandatory=$true,ParameterSetName="ByDevice",ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [object]$Device,
        [Parameter(Mandatory=$true,ParameterSetName="ByDeviceId")]
        [object]$DeviceId
        )

    Process {
        switch ($PSCmdlet.ParameterSetName) {
            "ByDevice" {
                $Uri = "$($API.BaseUri)/devices/v2/$($Device.id)/threats"
            }
            "ByDeviceId" {
                $Uri = "$($API.BaseUri)/devices/v2/$($DeviceId)/threats"
            }
        }
        
        Get-CyDataPages -API $API -Uri $Uri    
    }
}

<#
.SYNOPSIS
    Update a device threat.

.PARAMETER API
    Optional. API Handle (use only when not using session scope).

.PARAMETER Action
    The action to take (quarantine or waive the threat)

.PARAMETER Device
    The device object to apply this threat action to.
#>
function Update-CyDeviceThreat {
    Param (
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [CylanceAPIHandle]$API = $GlobalCyAPIHandle,
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [object[]]$DeviceThreat,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Quarantine", "Waive")]
        [String]$Action,
        [Parameter(Mandatory=$true,ParameterSetName="ByDevice")]
        [object]$Device,
        [Parameter(Mandatory=$true,ParameterSetName="ByDeviceId")]
        [object]$DeviceId

    )

    Begin {
        $headers = @{
            "Accept" = "application/json"
            "Authorization" = "Bearer $($API.AccessToken)"
        }
    }

    Process {
        $hash = $DeviceThreat.sha256
        if ($hash -eq $null) {
            $hash = $DeviceThreat
        }

        $updateMap = @{
            "threat_id" = $($hash)
            "event" = $Action
        }

        $json = $updateMap | ConvertTo-Json
        # remain silent
        switch ($PSCmdlet.ParameterSetName) {
            "ByDeviceId" {
                $output = Invoke-RestMethod -Method POST -Uri "$($API.BaseUri)/devices/v2/$($DeviceId)/threats" -ContentType "application/json; charset=utf-8" -Header $headers -UserAgent "" -Body $json
            }
            "ByDevice" {
                $output = Invoke-RestMethod -Method POST -Uri "$($API.BaseUri)/devices/v2/$($Device.id)/threats" -ContentType "application/json; charset=utf-8" -Header $headers -UserAgent "" -Body $json
            }
        }
        
    }
}

<#
.SYNOPSIS
    Retrieves the given threat's details from the console. Gets full data, not a shallow version.

.PARAMETER API
    Optional. API Handle (use only when not using session scope).

.PARAMETER SHA256
    A collection of SHA256 values (as strings) to retrieve the data for.
#>
function Get-CyThreatDetails {
    Param (
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [CylanceAPIHandle]$API = $GlobalCyAPIHandle,
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [String[]]$SHA256
        )

    Process {
        $headers = @{
            "Accept" = "application/json"
            "Authorization" = "Bearer $($API.AccessToken)"
        }
        Invoke-RestMethod -Method GET -Uri  "$($API.BaseUri)/threats/v2/$($SHA256)" -Header $headers -UserAgent "" | Convert-CyTypes
    }
}

<#
.SYNOPSIS
    Retrieves a download link for the given threat

.PARAMETER API
    Optional. API Handle (use only when not using session scope).

.PARAMETER SHA256
    The threat to retrieve the download link for.
#>
function Get-CyThreatDownloadLink {
    Param (
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [CylanceAPIHandle]$API = $GlobalCyAPIHandle,
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [String[]]$SHA256
        )

    Process {
        $headers = @{
            "Accept" = "application/json"
            "Authorization" = "Bearer $($API.AccessToken)"
        }
        Invoke-RestMethod -Method GET -Uri  "$($API.BaseUri)/threats/v2/download/$($SHA256)" -Header $headers -UserAgent ""
    }
}


<#
.SYNOPSIS
    Gets the devices affected by a particular threat.

.PARAMETER API
    Optional. API Handle (use only when not using session scope).

.PARAMETER SHA256
    The threat SHA256 hash
#>
function Get-CyThreatDevices {
    Param (
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [CylanceAPIHandle]$API = $GlobalCyAPIHandle,
        [Parameter(Mandatory=$true,ParameterSetName="ByDevice",ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [object]$SHA256
        )

    Process {
        Get-CyDataPages -API $API -Uri "$($API.BaseUri)/threats/v2/$($SHA256)/devices"
    }
}
