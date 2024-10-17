
function Get-AbrFgtVPNSSL {
    <#
    .SYNOPSIS
        Used by As Built Report to returns VPN SSL settings.
    .DESCRIPTION
        Documents the configuration of Fortinet FortiGate in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.2.0
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
        Write-PScriboMessage "Discovering VPN SSL settings information from $System."
    }

    process {

        $TableName = "VPN SSL"
        Section -Style Heading2 $TableName {
            Paragraph "The following section details VPN SSL settings configured on FortiGate."
            BlankLine

            $settings = Get-FGTVpnSSLSettings
            $portals = Get-FGTVPNSSLPortal
            $users = Get-FGTMonitorVpnSsl

            if ($InfoLevel.VPNSSL -ge 1) {
                $TableName = "Summary"
                Section -Style Heading3 $TableName {
                    Paragraph "The following section provides a summary of VPN SSL settings."
                    BlankLine
                    $OutObj = [pscustomobject]@{
                        "Portal"           = @($settings).count
                        "User (connected)" = @($users).Count
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                }
            }

            if ($settings -and $InfoLevel.VPNSSL -ge 1) {
                $TableName = "VPN SSL Settings"
                Section -Style Heading3 $TableName {
                    $OutObj = @()

                    $OutObj += [pscustomobject]@{
                        "Status"                = $settings.status
                        "Port"                  = $settings.port
                        "Source Interface"      = $settings.'source-interface'.name
                        "Source Address"        = $settings.'source-address'.name
                        "Default Portal"        = $settings.'default-portal'
                        "Certificate Server"    = $settings.servercert
                        "Algorithm"             = $settings.algorithm
                        "Idle Timeout"          = $settings.'idle-timeout'
                        "Auth Timeout"          = $settings.'auth-timeout'
                        "Force Two factor Auth" = $settings.'force-two-factor-auth'
                        "Tunnel IP Pool"        = $settings.'tunnel-ip-pools'.name
                        "DNS Suffix"            = $settings.'dns-suffix'
                        "DNS Server1"           = $settings.'dns-server1'
                        "DNS Server2"           = $settings.'dns-server2'
                    }

                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -List -TableParams @{ColumnWidths = 30, 70}

                    $OutObj | Table @TableParams

                    if ($settings.'authentication-rule' -and $InfoLevel.VPNSSL -ge 2) {

                        $TableName = "VPN SSL Settings: Authentication Rule"
                        Section -Style Heading3 $TableName {
                            BlankLine
                            $OutObj = @()
                            foreach ($ar in $settings.'authentication-rule') {

                                $OutObj += [pscustomobject]@{
                                    "id"     = $ar.id
                                    "users"  = $ar.users
                                    "groups" = $ar.groups.name
                                    "portal" = $ar.portal
                                    "realm"  = $ar.realm
                                    "auth"   = $ar.auth
                                }
                            }
                            Write-FormattedTable -InputObject $OutObj -TableName $tableName
                        }
                    }
                }
            }


            if ($portals -and $InfoLevel.VPNSSL -ge 1) {
                Section -Style Heading3 'VPN Portal' {
                    Section -Style NOTOCHeading4 -ExcludeFromTOC 'Summary' {
                        $OutObj = @()

                        foreach ($portal in $portals) {

                            $OutObj += [pscustomobject]@{
                                "Name"        = $portal.name
                                "Tunnel Mode" = $portal.'tunnel-mode'
                                "Web Mode"    = $portal.'web-mode'
                                "IP Pools"    = $portal.'ip-pools'.name
                            }
                        }
                        $TableName = "VPN SSL Portal Summary"
                        Write-FormattedTable -InputObject $OutObj -TableName $tableName
                    }

                    if ($InfoLevel.VPNSSL -ge 2) {

                        foreach ($portal in $portals) {
                            $TableName = "VPN SSL Portal: $($portal.name)"
                            Section -Style Heading3 $TableName {
                                BlankLine
                                $OutObj = @()

                                $OutObj += [pscustomobject]@{
                                    "Name"                            = $portal.name
                                    "Tunnel Mode"                     = $portal.'tunnel-mode'
                                    "Auto Connect"                    = $portal.'auto-connect'
                                    "Keep Alive"                      = $portal.'keep-alive'
                                    "Save Password "                  = $portal.'save-password'
                                    "IP Pools"                        = $portal.'ip-pools'.name
                                    "Split Tunneling"                 = $portal.'split-tunneling'
                                    "Split Tunneling Routing Address" = $portal.'split-tunneling-routing-address'.name
                                    "DNS Server1"                     = $portal.'dns-server1'
                                    "DNS Server2"                     = $portal.'dns-server2'
                                    "DNS Suffix"                      = $portal.'dns-suffix'
                                    "Web Mode"                        = $portal.'web-mode'
                                    "Display Bookmark"                = $portal.'display-bookmark'
                                    "User Bookmark"                   = $portal.'user-bookmark'
                                    "User Group Bookmark"             = $portal.'user-group-bookmark'
                                    "Allow User Access"               = $portal.'allow-user-access'
                                    "Heading"                         = $portal.heading
                                    "Theme"                           = $portal.theme
                                    "Custom Language"                 = $portal.'custom-lang'
                                    "Use SDWAN"                       = $portal.'use-sdwan'
                                    "Clipboard"                       = $portal.clipboard
                                    "Limit User Logins"               = $portal.'limit-user-logins'
                                    "Host Check"                      = $portal.'host-check'
                                    "MAC Address Check"               = $portal.'mac-addr-check'
                                    "OS Check"                        = $portal.'os-check'
                                    #>
                                }
                                Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                            }
                        }
                    }
                }

            }
            if ($users -and $InfoLevel.VPNSSL -ge 1) {
                $TableName = "VPN SSL Users Connected"
                Section -Style Heading3 $TableName {

                    $OutObj = @()

                    foreach ($user in $users) {

                        $OutObj += [pscustomobject]@{
                            "User Name"       = $user.user_name
                            "Remote Host"     = $user.remote_host
                            "Client IP "      = $user.subsessions.aip
                            "Last Login Time" = $user.last_login_time
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName
                }

            }

        }

    }

    end {

    }
}
