
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
                    $TableName = "Summary"
                    Section -Style Heading3 $TableName {
                        Paragraph "The following section provides a summary of SD-WAN settings."
                        BlankLine
                        $OutObj = [pscustomobject]@{
                            "Zone"         = @($sdwan.zone).count
                            "Member"       = @($sdwan.members).count
                            "Health Check" = @($sdwan.'health-check').count
                            "Rules"        = @($sdwan.'service').count
                        }
                        Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                        }

                    $TableName = "Configuration"
                    Section -Style Heading3 $TableName {
                        Paragraph "The following section provides configuration of SD-WAN settings."
                        BlankLine
                        $OutObj = [pscustomobject]@{
                            "Status"             = $sdwan.'status'
                            "Load Balance Mode"  = $sdwan.'load-balance-mode'
                            "Neighbor Hold Down" = $sdwan.'neighbor-hold-down'
                            "Fail Detect"        = $sdwan.'fail-detect'
                        }
                        Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                        }

                    $TableName = "SD-WAN Zone"
                    Section -Style Heading3 $TableName {
                        $OutObj = @()

                        foreach ($zone in $sdwan.zone) {
                            $OutObj += [pscustomobject]@{
                                "Name"        = $zone.name
                                "Service SLA" = $zone.'service-sla-tie-break'
                            }
                        }
                        Write-FormattedTable -InputObject $OutObj -TableName $tableName
                    }

                    if ($sdwan.members) {
                        $TableName = "SD-WAN Members"
                        Section -Style Heading3 $TableName {
                            $OutObj = @()

                            foreach ($member in $sdwan.members) {
                                $OutObj += [pscustomobject]@{
                                    "Num"       = $member.'seq-num'
                                    "Interface" = $member.interface
                                    "Zone"      = $member.zone
                                    "Gateway"   = $member.gateway
                                    "Status"    = $member.status
                                    "Comment"   = $member.comment
                                }
                            }
                            Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Num" = 10; "Status" = 10;}
                        }
                    }

                    if ($sdwan.'health-check') {
                        $TableName = "SD-WAN Health Check"
                        Section -Style Heading3 $TableName {
                            $OutObj = @()

                            foreach ($hc in $sdwan.'health-check') {


                                $OutObj += [pscustomobject]@{
                                    "Name"                = $hc.name
                                    "Detect Mode"         = $hc.'detect-mode'
                                    "Protocol"            = $hc.protocol
                                    "Server"              = $hc.server -replace ('"', '')
                                    "Update Static Route" = $hc.'update-static-route'
                                    "Members"             = $hc.members.'seq-num'
                                }
                            }
                            Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Name" = 10; "Members" = 10;}
                        }
                    }

                    if ($sdwan.service) {
                        $TableName = "SD-WAN Rule"
                        Section -Style Heading3 $TableName {
                            $OutObj = @()

                            foreach ($service in $sdwan.service) {

                                $OutObj += [pscustomobject]@{
                                    "Name"             = $service.name
                                    "Source"           = $service.src.name
                                    "Destination"      = $service.dst.name
                                    "Mode"             = $service.mode
                                    "Health Check"     = $service.'health-check'.name
                                    "Priority Members" = $service.'priority-members'.'seq-num'
                                    "Status"           = $service.status
                                }
                            }
                            Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Name" = 10; "Members" = 10;}
                        }

                    }

                }
            }
        }
    }

    end {

    }

}