
function Get-AbrFgtSystem {
    <#
    .SYNOPSIS
        Used by As Built Report to returns System settings.
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
        Write-PscriboMessage "Discovering System settings information from $System."
    }

    process {

        Section -Style Heading2 'System' {
            Paragraph "The following section details System settings configured on Fortigate."
            BlankLine

            $info = Get-FGTSystemGlobal

            if ($info) {
                Section -Style Heading3 'Global' {
                    $OutObj = @()

                    if ($info.'daily-restart' -eq "enable") {
                        $reboot = "Everyday at $($info.'restart-time')"
                    }
                    else {
                        $reboot = "disable"
                    }

                    $OutObj = [pscustomobject]@{
                        "Nom"           = $info.'hostname'
                        "Alias"         = $info.'alias'
                        "Reboot"        = $reboot
                        "Port SSH"      = $info.'admin-ssh-port'
                        "Port HTTP"     = $info.'admin-port'
                        "Port HTTPS"    = $info.'admin-sport'
                        "HTTPS Rediect" = $info.'admin-https-redirect'
                    }

                    $TableParams = @{
                        Name         = "Global"
                        List         = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            $settings = Get-FGTSystemSettings

            if ($settings) {
                Section -Style Heading3 'Settings' {
                    $OutObj = @()

                    $OutObj = [pscustomobject]@{
                        "OP Mode"           = $settings.opmode
                        "Central NAT"       = $settings.'central-nat'
                        "LLDP Reception"    = $settings.'lldp-reception'
                        "LLDP Transmission" = $settings.'lldp-transmission'
                        "Comments"          = $settings.comments
                    }

                    $TableParams = @{
                        Name         = "Settings"
                        List         = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($info -and $settings) {
                Section -Style Heading3 'GUI Settings' {
                    $OutObj = @()

                    $OutObj = [pscustomobject]@{
                        "Language"                   = $info.language
                        "Theme"                      = $info.'gui-theme'
                        "IPv6"                       = $info.'gui-ipv6'
                        "Wireless Open Security"     = $info.'gui-wireless-opensecurity'
                        "Implicit Policy"            = $settings.'gui-implicit-policy'
                        "Dns Database"               = $settings.'gui-dns-database'
                        "Load Balance"               = $settings.'gui-load-balance'
                        "Explicit Proxy"             = $settings.'gui-explicit-proxy'
                        "Dynamic Routing"            = $settings.'gui-dynamic-routing'
                        "Application Control"        = $settings.'gui-application-control'
                        "IPS"                        = $settings.'gui-ips'
                        "VPN"                        = $settings.'gui-vpn'
                        "Wireless Controller"        = $settings.'gui-wireless-controller'
                        "Switch Controller"          = $settings.'gui-switch-controller'
                        "WAN Load Balancing (SDWAN)" = $settings.'gui-wan-load-balancing'
                        "Antivirus"                  = $settings.'gui-antivirus'
                        "Web Filter"                 = $settings.'gui-webfilter'
                        "Video Filter"               = $settings.'gui-videofilter'
                        "DNS Filter"                 = $settings.'gui-dnsfilter'
                        "WAF Profile"                = $settings.'gui-waf-profile'
                        "Allow Unnamed Policy"       = $settings.'gui-allow-unnamed-policy'
                        "Multiple Interface Policy"  = $settings.'gui-multiple-interface-policy'
                        "ZTNA"                       = $settings.'gui-ztna'
                        "OT"                         = $settings.'gui-ot'
                    }

                    $TableParams = @{
                        Name         = "Settings"
                        List         = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            $dns = Get-FGTSystemDns

            if ($dns) {
                Section -Style Heading3 'DNS' {
                    $OutObj = @()

                    $OutObj = [pscustomobject]@{
                        "Primary"   = $dns.primary
                        "Secondary" = $dns.secondary
                        "Domain"    = $dns.domain.domain
                        "Protocol"  = $dns.protocol
                    }

                    $TableParams = @{
                        Name         = "DNS"
                        List         = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            $DNSServers = Get-FGTSystemDnsServer

            if ($DNSServers) {
                Section -Style Heading3 'DNS Server' {
                    $OutObj = @()

                    foreach ($DNSServer in $DNSServers) {
                        $OutObj += [pscustomobject]@{
                            "Name"               = $DNSServer.name
                            "Mode"               = $DNSServer.mode
                            "DNS Filter Profile" = $DNSServer.'dnsfilter-profile'
                            "DOH"                = $DNSServer.doh
                        }
                    }

                    $TableParams = @{
                        Name         = "DNS Server"
                        List         = $false
                        ColumnWidths = 25, 25, 25, 25
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            $Admins = Get-FGTSystemAdmin

            if ($Admins) {
                Section -Style Heading3 'Admin' {
                    $OutObj = @()

                    foreach ($admin in $Admins) {

                        $trustedHosts = $admin.trusthost1
                        $trustedHosts += $admin.trusthost2
                        $trustedHosts += $admin.trusthost3
                        $trustedHosts += $admin.trusthost4
                        $trustedHosts += $admin.trusthost5
                        $trustedHosts += $admin.trusthost6
                        $trustedHosts += $admin.trusthost7
                        $trustedHosts += $admin.trusthost8
                        $trustedHosts += $admin.trusthost9
                        $trustedHosts += $admin.trusthost10

                        $OutObj += [pscustomobject]@{
                            "Name"          = $admin.name
                            "Profile"       = $admin.accprofile
                            "Trusted Hosts" = $trustedHosts
                            "MFA"           = $admin.'two-factor'
                        }
                    }

                    $TableParams = @{
                        Name         = "Administrator"
                        List         = $false
                        ColumnWidths = 25, 25, 25, 25
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            $interfaces = Get-FGTSystemInterface

            if ($interfaces) {
                Section -Style Heading3 'Interfaces' {
                    $OutObj = @()

                    foreach ($interface in $interfaces) {
                        $OutObj += [pscustomobject]@{
                            "Name"         = $interface.name
                            "Alias"        = $interface.alias
                            "Role"         = $interface.role
                            "Description"  = $interface.description
                            "Type"         = $interface.type
                            "Vlan ID"      = $interface.vlanid
                            "Mode"         = $interface.mode
                            "IP Address"   = $interface.ip.Replace(' ', '/')
                            "Allow Access" = $interface.allowaccess
                            'DHCP Relais'  = $interface.'dhcp-relay-ip'
                            "Status"       = $interface.status
                            "Speed"        = $interface.speed
                        }
                    }

                    $TableParams = @{
                        Name         = "Interface"
                        List         = $false
                        ColumnWidths = 10, 10, 10, 10, 10, 5, 5, 10, 10, 10, 5, 5
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            $zones = Get-FGTSystemZone

            if ($zones) {
                Section -Style Heading3 'Zone' {
                    $OutObj = @()

                    foreach ($zone in $zones) {
                        $OutObj += [pscustomobject]@{
                            "Name"        = $zone.name
                            "Intrazone"   = $zone.intrazone
                            "Interface"   = $zone.interface.'interface-name'
                            "Description" = $zone.description
                        }
                    }

                    $TableParams = @{
                        Name         = "Zone"
                        List         = $false
                        ColumnWidths = 25, 25, 25, 25
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