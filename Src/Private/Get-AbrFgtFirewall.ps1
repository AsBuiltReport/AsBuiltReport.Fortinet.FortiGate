
function Get-AbrFgtFirewall {
    <#
    .SYNOPSIS
        Used by As Built Report to returns Firewall settings.
    .DESCRIPTION
        Documents the configuration of Fortinet Fortigate in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.1.0
        Author:         Alexis La Goutte
        Twitter:        @alagoutte
        Github:         alagoutte
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.Fortigate
    #>
    [CmdletBinding()]
    param (

    )

    begin {
        Write-PscriboMessage "Discovering Firewall settings information from $System."
    }

    process {

        Section -Style Heading2 'Firewall' {
            Paragraph "The following section details Firewall settings configured on Fortigate."
            BlankLine

            $Address = Get-FGTFirewallAddress
            $Group = Get-FGTFirewallAddressGroup
            $IPPool = Get-FGTFirewallIPPool
            $VIP = Get-FGTFirewallVip
            $Policy = Get-FGTFirewallPolicy

            if ($InfoLevel.Firewall.Summary -ge 1) {
                Section -Style Heading3 'Summary' {
                    Paragraph "The following section make a summary of Firewall settings."
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


            if ($Address -and $InfoLevel.Firewall.Address -ge 1) {
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

        }
    }

    end {

    }

}