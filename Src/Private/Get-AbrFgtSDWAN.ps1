
function Get-AbrFgtSDWAN {
    <#
    .SYNOPSIS
        Used by As Built Report to returns SD WAN  settings.
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

        Section -Style Heading2 'SD-WAN' {
            Paragraph "The following section details SD-WAN settings configured on FortiGate."
            BlankLine

            #$sdwan = Get-fgtSystemSDWAN

            if ($sdwan -and $InfoLevel.SDWAN -ge 1) {
                Section -Style Heading3 'Summary' {
                    Paragraph "The following section provides a summary of SD-WAN settings."
                    BlankLine
                    $OutObj = [pscustomobject]@{
                        "Status"                = $sdwan.'status'
                        "Load Balance Mode"     = $sdwan.'load-balance-mode'
                        "Neighbor Hold Down"    = $sdwan.'neighbor-hold-down'
                        "Fail Detect "          = $sdwan.'fail-detect'
                    }

                    $TableParams = @{
                        Name         = "Summary"
                        List         = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($sdwan -and $InfoLevel.sdwan -ge 1) {
                Section -Style Heading3 'SD-WAN Zone' {
                    $OutObj = @()

                    foreach ($zone in $sdwan.zone) {
                        $OutObj += [pscustomobject]@{
                            "Name"                     = $zone.name
                            "Service SLA"    = $zone.'service-sla-tie-break'
                        }
                    }

                    $TableParams = @{
                        Name         = "SD-WAN Zone"
                        List         = $false
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }
<#
            if ($Statics -and $InfoLevel.sdwan -ge 1) {
                Section -Style Heading3 'Static sdwan' {
                    $OutObj = @()

                    foreach ($static in $statics) {
                        $OutObj += [pscustomobject]@{
                            "Status"                   = $static.status
                            "Destination"              = $static.dst
                            "Gateway"                  = $static.gateway
                            "Interface"                = $static.device
                            "Distance/Weight/Priority" = "$($static.distance) / $($static.weight) / $($static.priority)"
                        }
                    }

                    $TableParams = @{
                        Name         = "Static sdwan"
                        List         = $false
                        ColumnWidths = 15, 25, 20, 20, 20
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($PolicyBasedRouting -and $InfoLevel.sdwan -ge 1) {
                Section -Style Heading3 'Policy Based sdwan' {
                    $OutObj = @()

                    foreach ($pbr in $PolicyBasedRouting) {

                        if ($pbr.src) {
                            $src = $pbr.src.subnet
                        }
                        else {
                            $src = $pbr.srcaddr.name
                        }
                        if ($pbr.dst) {
                            $dst = $pbr.dst.subnet
                        }
                        else {
                            $dst = $pbr.dstaddr.name
                        }

                        $OutObj += [pscustomobject]@{
                            "Status"      = $pbr.status
                            "Protocol"    = $pbr.protocol
                            "From"        = $pbr.'input-device'.name
                            "To"          = $pbr.'ouput-device'
                            "Source"      = $src
                            "Destination" = $dst
                            "Gateway"     = $pbr.gateway
                            "Action"      = $pbr.action
                        }
                    }

                    $TableParams = @{
                        Name         = "Policy Based sdwan"
                        List         = $false
                        ColumnWidths = 10, 12, 13, 13, 13, 13, 13, 13
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }
  #>
        }

    }

    end {

    }

}