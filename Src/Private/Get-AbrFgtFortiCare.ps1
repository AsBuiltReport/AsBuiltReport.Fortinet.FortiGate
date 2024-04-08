
function Get-AbrFgtForticare {
    <#
    .SYNOPSIS
        Used by As Built Report to returns FortiCare settings.
    .DESCRIPTION
        Documents the configuration of Fortinet FortiGate in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.1.0
        Author:         Alexis La Goutte
        Twitter:        @alagoutte
        Github:         alagoutte
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate
    #>
    [CmdletBinding()]
    param (

    )

    begin {
        Write-PScriboMessage "Discovering FortiCare settings information from $System."
    }

    process {

        $LicenseStatus = Get-FGTMonitorLicenseStatus
        if ($LicenseStatus -and $InfoLevel.Forticare -ge 1) {

            $FortiGuardservicesDescriptions = @{
                "forticare" = "FortiCare Support Services"
                "forticloud" = "FortiCloud Management"
                "security_rating" = "Security Fabric Rating and Compliance Service"
                "antivirus" = "Antivirus Service"
                "mobile_malware" = "Mobile Malware Service"
                "ai_malware_detection" = "AI-based Inline Malware Prevention"
                "ips" = "Intrusion Prevention System (IPS)"
                "industrial_db" = "OT Industrial Signatures Database"
                "appctrl" = "Application Control"
                "internet_service_db" = "Internet Service (SaaS) Database"
                "device_os_id" = "Device/OS Detection"
                "botnet_ip" = "Botnet IP Reputation Service"
                "botnet_domain" = "Botnet Domain Reputation Service"
                "psirt_security_rating" = "Attack Surface Security Rating"
                "outbreak_security_rating" = "Outbreak Security Rating Service"
                "icdb" = "OT Industrial Signatures Database"
                "inline_casb" = "Inline SaaS Application Security (CASB)"
                "local_in_virtual_patching" = "OT Virtual Patching"
                "malicious_urls" = "Malicious URL Database"
                "blacklisted_certificates" = "Blacklisted Certificates Service"
                "firmware_updates" = "Firmware Updates"
                "web_filtering" = "Web Filtering Service"
                "outbreak_prevention" = "Outbreak Prevention"
                "antispam" = "Antispam Service"
                "iot_detection" = "IoT Detection Service"
                "ot_detection" = "OT Detection Service"
                "forticloud_sandbox" = "FortiCloud Sandbox"
                "forticonverter" = "FortiConverter Service"
                "fortiguard" = "FortiGuard Services"
                "data_leak_prevention" = "Data Leak Prevention"
                "sdwan_network_monitor" = "SD-WAN Network Monitor"
                "forticloud_logging" = "FortiCloud Logging"
                "fortianalyzer_cloud" = "FortiAnalyzer Cloud"
                "fortianalyzer_cloud_premium" = "FortiAnalyzer Cloud Premium"
                "fortimanager_cloud" = "FortiManager Cloud"
                "fortisandbox_cloud" = "FortiSandbox Cloud"
                "fortiguard_ai_based_sandbox" = "FortiGuard AI-based Sandbox"
                "sdwan_overlay_aas" = "SD-WAN Overlay-as-a-Service"
                "fortisase_private_access" = "FortiSASE Private Access"
                "fortisase_lan_extension" = "FortiSASE LAN Extension"
                "fortiems_cloud" = "FortiEMS Cloud"
                "fortimanager_cloud_alci" = "FortiManager Cloud ALCI"
                "fortisandbox_cloud_alci" = "FortiSandbox Cloud ALCI"
                "vdom" = "Virtual Domains (platform capability)"
                "sms" = "SMS Service"
            }
            $licenseSummary = @()

            $typeDescriptions = @{
                downloaded_fds_object = 'Update Feed'
                live_fortiguard_service = 'Real-time Services'
                live_cloud_service = 'Cloud Services'
                functionality_enabling = 'Feature'
            }
            
            $excludeServices = @(
                'fortiguard', 'forticare', 'forticloud', 'sms', 'vdom', 
                'forticloud_logging', 'fortianalyzer_cloud', 'fortianalyzer_cloud_premium', 
                'fortimanager_cloud', 'fortisandbox_cloud', 'fortiguard_ai_based_sandbox', 
                'forticonverter', 'fortiems_cloud', 'fortimanager_cloud_alci', 'fortisandbox_cloud_alci'
            )
            
            $FortiGuardSvcOrder = @(
                'internet_service_db', 'device_os_id', 'firmware_updates', 'ips', 
                'blacklisted_certificates', 'appctrl', 'antivirus', 'botnet_ip', 'botnet_domain', 
                'mobile_malware', 'antispam', 'outbreak_prevention', 'forticloud_sandbox', 
                'ai_malware_detection', 'web_filtering', 'malicious_urls', 'security_rating', 
                'psirt_security_rating', 'outbreak_security_rating', 'inline_casb', 
                'data_leak_prevention', 'ot_detection', 'iot_detection', 'local_in_virtual_patching', 
                'industrial_db', 'icdb', 'sdwan_network_monitor', 'sdwan_overlay_aas', 
                'fortisase_private_access', 'fortisase_lan_extension'
            )
            
            $licenseSummaryUnordered = @()
            
            foreach ($property in $LicenseStatus.PSObject.Properties) {
                if ($excludeServices -contains $property.Name) {
                    continue
                }
                
                $feature = $property.Value
                $status = $feature.status
                $description = $FortiGuardservicesDescriptions[$property.Name]
                $expires = if ($null -ne $feature.expires) { 
                    (Get-Date '01/01/1970').AddSeconds($feature.expires) | Get-Date -Format "dd/MM/yyyy"
                } else { 
                    $null 
                }
                $type = $feature.type
                $entitlement = $feature.entitlement
                $typeDescription = $typeDescriptions[$type]
                
                $licenseSummaryUnordered += [PSCustomObject]@{
                    name = $property.Name
                    description = $description
                    status = $status
                    expiration = $expires
                    type = $type
                    typeDescription = $typeDescription
                    entitlement = $entitlement
                }
            }
            
            # Ordering $licenseSummary based on the specified order
            $licenseSummary = $FortiGuardSvcOrder | ForEach-Object {
                $serviceName = $_
                $licenseSummaryUnordered | Where-Object { $_.Name -eq $serviceName }
            }
            
            $Forticare = $LicenseStatus.forticare
            Section -Style Heading2 'FortiCare' {
                Paragraph "The following table details FortiCare settings configured on FortiGate."
                BlankLine

                $OutObj = @()

                $Serial = $DefaultFGTConnection.serial

                $OutObj = [pscustomobject]@{
                    "Model"   = $Model
                    "Serial"  = $Serial
                    "Status"  = $Forticare.status
                    "Account" = $Forticare.account.ToLower()
                    "Company" = $Forticare.company
                }

                $TableParams = @{
                    Name         = "FortiCare"
                    List         = $true
                    ColumnWidths = 50, 50
                }

                if ($Report.ShowTableCaptions) {
                    $TableParams['Caption'] = "- $($TableParams.Name)"
                }

                $OutObj | Table @TableParams


                Paragraph "The following table details FortiGuard subscriptions and services on FortiGate."
                BlankLine
                
                $OutObj = @()
                foreach ($lincese in $licenseSummary) {
                    $licenseStatus = $lincese.status -eq 'licensed' ? 'Licensed' : 'Unlicensed'
                    $OutObj += [pscustomobject]@{
                        "Name" = $lincese.description
                        "Type" = $lincese.typeDescription
                        "Status"   = $licenseStatus
                        "Expiration" = $lincese.expiration
                    }
                }

                $TableParams = @{
                    Name         = "FortiGuard Services"
                    List         = $false
                    ColumnWidths = 50, 20, 15, 15
                }                

                if ($Report.ShowTableCaptions) {
                    $TableParams['Caption'] = "- $($TableParams.Name)"
                }

                $OutObj | Table @TableParams


                Paragraph "The following section details support settings configured on FortiGate."
                BlankLine
                $ExpiresHW = (($Forticare | Select-Object -ExpandProperty support).hardware).expires
                $SupportHW = [pscustomobject]@{
                    "Type"            = "Hardware"
                    "Level"           = $Forticare.support.hardware.support_level
                    "Status"          = $Forticare.support.hardware.status
                    "Expiration Date" = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($ExpiresHW)) | Get-Date -Format dd/MM/yyyy
                }
                $ExpiresEn = (($Forticare | Select-Object -ExpandProperty support).enhanced).expires
                $SupportEn = [pscustomobject]@{
                    "Type"            = "Enhanced"
                    "Level"           = $Forticare.support.enhanced.support_level
                    "Status"          = $Forticare.support.enhanced.status
                    "Expiration Date" = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($ExpiresEn)) | Get-Date -Format dd/MM/yyyy
                }

                $TableParams = @{
                    Name         = "Support"
                    List         = $false
                    ColumnWidths = 25, 25, 25, 25
                }

                if ($Report.ShowTableCaptions) {
                    $TableParams['Caption'] = "- $($TableParams.Name)"
                }

                $Support = @()
                $Support += $SupportHW
                $Support += $SupportEn
                $Support | Table @TableParams
            }

        }


        $firmware = Get-FGTMonitorSystemFirmware
        try {
            $firmware_upgrade_paths = Get-FGTMonitorSystemFirmware -upgrade_paths
        }
        catch {
            $firmware_upgrade_paths = $null
        }


        if ($firmware -and $firmware_upgrade_paths -and $InfoLevel.Forticare -ge 1) {
            Paragraph "The following section details firmware information on FortiGate."
            BlankLine

            $FortiOS = $firmware.current
            $CurrentVersion = [version]"$($firmware.current.major).$($firmware.current.minor).$($firmware.current.patch)"

            $FullUpdate = $firmware.available | Select-Object version -First 1
            if ($FullUpdate) {

                $FullUpdateVersion = [version]"$(($firmware.available | Select-Object -First 1).major).$(($firmware.available | Select-Object -First 1).minor).$(($firmware.available | Select-Object -First 1).patch)"

                #Same (or greater) version, No Update Available
                if ($CurrentVersion -ge $FullUpdateVersion) {
                    $tab_upgradePath = [pscustomobject]@{
                        "Installed"    = $($FortiOS.version)
                        "Update"       = "No Update Available"
                        "Upgrade Path" = "N/A"
                    }
                }
                else {
                    <# Search only last firmware on the same Branch
                $BranchUpdate = $firmware.available | Where-Object { $_.major -eq $CurrentVersion.Major -and $_.minor -eq $CurrentVersion.Minor } | Select-Object version -First 1
                if ($CurrentVersion -lt $BranchUpdateVersion) {
                    $upgradePath = "v$($CurrentVersion.Major).$($CurrentVersion.Minor).$($CurrentVersion.Build)"
                    $major = $CurrentVersion.Major
                    $minor = $CurrentVersion.Minor
                    $patch = $CurrentVersion.Build
                    Do {
                        $nextFirmware = $firmware_upgrade_paths | Where-Object { $_.from.major -eq $major -and $_.from.minor -eq $minor -and $_.from.patch -eq $patch -and $_.to.major -eq $BranchUpdateVersion.Major -and $_.to.minor -eq $BranchUpdateVersion.Minor } | Select-Object -First 1
                        $major = $nextFirmware.to.major
                        $minor = $nextFirmware.to.minor
                        $patch = $nextFirmware.to.patch
                        $upgradePath = $upgradePath + " -> v$($major).$($minor).$($patch)"
                    }Until($major -eq $BranchUpdateVersion.Major -and $minor -eq $BranchUpdateVersion.Minor -and $patch -eq $BranchUpdateVersion.Build)
                    $tab_upgradePath = [pscustomobject]@{
                        "Installed"    = $($FortiOS.version)
                        "Update"       = $($BranchUpdate.version)
                        "Upgrade Path" = $upgradePath
                    }
                }
                #>
                    #$BranchUpdateVersion = [version]"$(($firmware.available | Where-Object { $_.major -eq $CurrentVersion.Major -and $_.minor -eq $CurrentVersion.Minor } | Select-Object -First 1).major).$(($firmware.available | Where-Object { $_.major -eq $CurrentVersion.Major -and $_.minor -eq $CurrentVersion.Minor } | Select-Object -First 1).minor).$(($firmware.available | Where-Object { $_.major -eq $CurrentVersion.Major -and $_.minor -eq $CurrentVersion.Minor } | Select-Object -First 1).patch)"
                    #if (($CurrentVersion -lt $FullUpdateVersion)) {
                    $upgradePath = "v$($CurrentVersion.Major).$($CurrentVersion.Minor).$($CurrentVersion.Build)"
                    $major = $CurrentVersion.Major
                    $minor = $CurrentVersion.Minor
                    $patch = $CurrentVersion.Build
                    Do {
                        $nextFirmware = $firmware_upgrade_paths | Where-Object { $_.from.major -eq $major -and $_.from.minor -eq $minor -and $_.from.patch -eq $patch } | Select-Object -First 1
                        $major = $nextFirmware.to.major
                        $minor = $nextFirmware.to.minor
                        $patch = $nextFirmware.to.patch
                        $upgradePath = $upgradePath + " -> v$($major).$($minor).$($patch)"
                    }Until($major -eq $FullUpdateVersion.Major -and $minor -eq $FullUpdateVersion.Minor -and $patch -eq $FullUpdateVersion.Build)
                    $tab_upgradePath = [pscustomobject]@{
                        "Installed"    = $($FortiOS.version)
                        "Update"       = "Available ($($FullUpdate.version))"
                        "Upgrade Path" = $upgradePath
                    }
                    #}
                }
            }
            else {

                #No $firmware.available info (no FortiCare/FortiGuard ?)
                $tab_upgradePath = [pscustomobject]@{
                    "Installed"    = $($FortiOS.version)
                    "Update"       = "N/A"
                    "Upgrade Path" = "N/A"
                }
            }

            $TableParams = @{
                Name         = "Firmware"
                List         = $true
                ColumnWidths = 50, 50
            }

            if ($Report.ShowTableCaptions) {
                $TableParams['Caption'] = "- $($TableParams.Name)"
            }

            $tab_upgradePath | Table @TableParams
        }

    }

    end {

    }

}
