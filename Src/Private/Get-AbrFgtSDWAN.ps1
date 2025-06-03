
function Get-AbrFgtSDWAN {
    <#
    .SYNOPSIS
        Used by As Built Report to returns SD-WAN settings.
    .DESCRIPTION
        Documents the configuration of Fortinet FortiGate in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.3.0
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
        Write-PScriboMessage "Discovering SD-WAN settings information from $System."
    }

    process {

        $sdwan = Get-fgtSystemSDWAN

        if ($sdwan) {
            Section -Style Heading2 'SD-WAN' {
                Paragraph "The following section details SD-WAN settings configured on FortiGate."
                BlankLine



                if ($sdwan -and $InfoLevel.SDWAN -ge 1) {
                    Section -Style Heading3 'Summary' {
                        Paragraph "The following section provides a summary of SD-WAN settings."
                        BlankLine
                        $OutObj = [pscustomobject]@{
                            "Zone" = @($sdwan.zone).count
                            "Member" = @($sdwan.members).count
                            "Health Check" = @($sdwan.'health-check').count
                            "Rules" = @($sdwan.'service').count
                        }

                        $TableParams = @{
                            Name = "Summary"
                            List = $true
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }

                    Section -Style Heading3 'Configuration' {
                        Paragraph "The following section provides configuration of SD-WAN settings."
                        BlankLine
                        $OutObj = [pscustomobject]@{
                            "Status" = $sdwan.'status'
                            "Load Balance Mode" = $sdwan.'load-balance-mode'
                            "Neighbor Hold Down" = $sdwan.'neighbor-hold-down'
                            "Fail Detect" = $sdwan.'fail-detect'
                        }

                        $TableParams = @{
                            Name = "Configuration"
                            List = $true
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }

                    Section -Style Heading3 'SD-WAN Zone' {
                        $OutObj = @()

                        foreach ($zone in $sdwan.zone) {
                            $OutObj += [pscustomobject]@{
                                "Name" = $zone.name
                                "Service SLA" = $zone.'service-sla-tie-break'
                            }
                        }

                        $TableParams = @{
                            Name = "SD-WAN Zone"
                            List = $false
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }

                    if ($sdwan.members) {
                        Section -Style Heading3 'SD-WAN Members' {
                            $OutObj = @()

                            foreach ($member in $sdwan.members) {
                                $OutObj += [pscustomobject]@{
                                    "Num" = $member.'seq-num'
                                    "Interface" = $member.interface
                                    "Zone" = $member.zone
                                    "Gateway" = $member.gateway
                                    "Status" = $member.status
                                    "Comment" = $member.comment
                                }
                            }

                            $TableParams = @{
                                Name = "SD-WAN Members"
                                List = $false
                                ColumnWidths = 10, 15, 20, 20, 10, 25
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
                        }
                    }

                    if ($sdwan.'health-check') {
                        Section -Style Heading3 'SD-WAN Health Check' {
                            $OutObj = @()

                            foreach ($hc in $sdwan.'health-check') {


                                $OutObj += [pscustomobject]@{
                                    "Name" = $hc.name
                                    "Detect Mode" = $hc.'detect-mode'
                                    "Protocol" = $hc.protocol
                                    "Server" = $hc.server -replace ('"', '')
                                    "Update Static Route" = $hc.'update-static-route'
                                    "Members" = $hc.members.'seq-num'
                                }
                            }

                            $TableParams = @{
                                Name = "SD-WAN Health Check"
                                List = $false
                                ColumnWidths = 14, 20, 20, 20, 15, 11
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
                        }
                    }

                    if ($sdwan.service) {
                        Section -Style Heading3 'SD-WAN Rule' {
                            $OutObj = @()

                            foreach ($service in $sdwan.service) {

                                $OutObj += [pscustomobject]@{
                                    "Name" = $service.name
                                    "Source" = $service.src.name
                                    "Destination" = $service.dst.name
                                    "Mode" = $service.mode
                                    "Health Check" = $service.'health-check'.name
                                    "Priority Members" = $service.'priority-members'.'seq-num'
                                    "Status" = $service.status
                                }
                            }

                            $TableParams = @{
                                Name = "SD-WAN Rule"
                                List = $false
                                ColumnWidths = 14, 20, 15, 15, 15, 11, 10
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
                        }

                    }

                }
            }
        }
    }

    end {

    }

}