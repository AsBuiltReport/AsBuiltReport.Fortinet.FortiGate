
function Get-AbrFgtFirewall {
    <#
    .SYNOPSIS
        Used by As Built Report to returns Firewall settings.
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
        Write-PScriboMessage "Discovering firewall settings information from $System."
    }

    process {

        Section -Style Heading2 'Firewall' {
            Paragraph "The following section details firewall settings configured on FortiGate."
            BlankLine

            $Address = Get-FGTFirewallAddress
            $Group = Get-FGTFirewallAddressGroup
            $IPPool = Get-FGTFirewallIPPool
            $VIP = Get-FGTFirewallVip
            $Policy = Get-FGTFirewallPolicy

            if ($InfoLevel.Firewall.Summary -ge 1) {
                Section -Style Heading3 'Summary' {
                    Paragraph "The following section provides a summary of firewall settings."
                    BlankLine
                    $OutObj = [pscustomobject]@{
                        "Address"    = $Address.count
                        "Group"      = $Group.count
                        "IP Pool"    = $IPPool.count
                        "Virtual IP" = $VIP.count
                        "Policy"     = $Policy.count
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

            if ($Address -and $InfoLevel.Firewall.Address -ge 1) {
                Section -Style Heading3 'Address' {
                    $OutObj = @()

                    foreach ($add in $Address) {

                        switch ( $add.type ) {
                            "ipmask" {
                                $value = $add.subnet.Replace(' ', '/')
                            }
                            "ipprange" {
                                $value = $add.'start-ip' + "-" + $add.'end-ip'
                            }
                            "geography" {
                                $value = $add.country
                            }
                            "fqdn" {
                                $value = $add.fqdn
                            }

                        }

                        $OutObj += [pscustomobject]@{
                            "Name"      = $add.name
                            "Type"      = $add.type
                            "Value"     = $value
                            "Interface" = $add.'associated-interface'
                        }
                    }

                    $TableParams = @{
                        Name         = "Address"
                        List         = $false
                        ColumnWidths = 25, 25, 25, 25
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($Group -and $InfoLevel.Firewall.Group -ge 1) {
                Section -Style Heading3 'Address Group' {
                    $OutObj = @()

                    foreach ($grp in $Group) {

                        $OutObj += [pscustomobject]@{
                            "Name"    = $grp.name
                            "Member"  = $grp.member.name -join ", "
                            "Comment" = $grp.comment
                        }
                    }

                    $TableParams = @{
                        Name         = "Address Group"
                        List         = $false
                        ColumnWidths = 20, 60, 20
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($IPPool -and $InfoLevel.Firewall.IPPool -ge 1) {
                Section -Style Heading3 'IP Pool' {
                    $OutObj = @()

                    foreach ($ip in $IPPool) {

                        $OutObj += [pscustomobject]@{
                            "Name"            = $ip.name
                            "Interface"       = $ip.'associated-interface'
                            "Type"            = $ip.type
                            "Start IP"        = $ip.startip
                            "End IP"          = $ip.endip
                            "Source Start IP" = $ip.'source-startip'
                            "Source End IP"   = $ip.'source-endip'
                            "Comments"        = $ip.comments
                        }
                    }

                    $TableParams = @{
                        Name         = "Virtual IP"
                        List         = $false
                        ColumnWidths = 14, 14, 12, 12, 12, 12, 12, 12
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($VIP -and $InfoLevel.Firewall.VIP -ge 1) {
                Section -Style Heading3 'Virtual IP' {
                    $OutObj = @()

                    foreach ($virtualip in $VIP) {

                        $OutObj += [pscustomobject]@{
                            "Name"          = $virtualip.name
                            "Interface"     = $virtualip.extintf
                            "External IP"   = $virtualip.extip
                            "Mapped IP"     = $virtualip.mappedip.range -join ", "
                            "Protocol"      = $virtualip.'protocol'
                            "External Port" = $virtualip.'extport'
                            "Mapped Port"   = $virtualip.'mappedport'
                            "Comment"       = $virtualip.comment
                        }
                    }

                    $TableParams = @{
                        Name         = "Virtual IP"
                        List         = $false
                        ColumnWidths = 14, 14, 12, 12, 12, 12, 12, 12
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($Policy -and $InfoLevel.Firewall.Policy -ge 1) {
                Section -Style Heading3 'Policy' {
                    $OutObj = @()

                    foreach ($rule in $Policy) {

                        $OutObj += [pscustomobject]@{
                            "Name"        = $rule.name
                            "From"        = $rule.srcintf.name -join ", "
                            "To"          = $rule.dstintf.name -join ", "
                            "Source"      = $rule.srcaddr.name -join ", "
                            "Destination" = $rule.dstaddr.name -join ", "
                            "Service"     = $rule.service.name -join ", "
                            "Action"      = $rule.action
                            "NAT"         = $rule.nat
                            "Log"         = $rule.logtraffic
                            "Comments"    = $rule.comments
                        }
                    }

                    $TableParams = @{
                        Name         = "Policy"
                        List         = $false
                        ColumnWidths = 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

        }
    }

    end {

    }

}