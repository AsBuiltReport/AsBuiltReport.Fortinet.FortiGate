
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

        Section -Style Heading2 'VPN SSL' {
            Paragraph "The following section details VPN SSL settings configured on FortiGate."
            BlankLine

            $settings = Get-FGTVpnSSLSettings
            $portals = Get-FGTVPNSSLPortal
            $users = Get-FGTMonitorVpnSsl

            if ($InfoLevel.VPNSSL -ge 1) {
                Section -Style Heading3 'Summary' {
                    Paragraph "The following section provides a summary of VPN SSL settings."
                    BlankLine
                    $OutObj = [pscustomobject]@{
                        "Portal"           = $settings.count
                        "User (connected)" = $users.Count
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

            if ($settings -and $InfoLevel.VPNSSL -ge 1) {
                Section -Style Heading3 'VPN SSL Settings' {
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


                    $TableParams = @{
                        Name         = "VPN SSL Settings"
                        List         = $true
                        ColumnWidths = 30, 70
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams

                    if ($settings.'authentication-rule' -and $InfoLevel.VPNSSL -ge 2) {

                        Section -Style Heading3 "VPN SSL Settings: Authentication Rule" {
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

                            $TableParams = @{
                                Name         = "VPN SSL Settings: Authentication Rule"
                                List         = $false
                                ColumnWidths = 10, 20, 20, 20, 15, 15
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
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

                        $TableParams = @{
                            Name         = "VPN SSL Portal Summary"
                            List         = $false
                            ColumnWidths = 30, 20, 20, 40
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }

                    if ($InfoLevel.VPNSSL -ge 2) {

                        foreach ($portal in $portals) {
                            Section -Style Heading3 "VPN SSL Portal: $($portal.name)" {
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


                                $TableParams = @{
                                    Name         = "VPN SSL Portal: $($portal.name)"
                                    List         = $true
                                    ColumnWidths = 50, 50
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
            if ($users -and $InfoLevel.VPNSSL -ge 1) {
                Section -Style Heading3 'VPN SSL Users Connected' {

                    $OutObj = @()

                    foreach ($user in $users) {

                        $OutObj += [pscustomobject]@{
                            "User Name"       = $user.user_name
                            "Remote Host"     = $user.remote_host
                            "Client IP "      = $user.subsessions.aip
                            "Last Login Time" = $user.last_login_time
                        }
                    }

                    $TableParams = @{
                        Name         = "VPN SSL Users Connected"
                        List         = $false
                        ColumnWidths = 30, 20, 20, 40
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
