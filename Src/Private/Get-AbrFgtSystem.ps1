
function Get-AbrFgtSystem {
    <#
    .SYNOPSIS
        Used by As Built Report to returns System settings.
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
        Write-PScriboMessage "Discovering system settings information from $System."
    }

    process {

        Section -Style Heading2 'System' {
            Paragraph "The following section details system settings configured on FortiGate."
            BlankLine

            $info = Get-FGTSystemGlobal

            if ($info -and $InfoLevel.System -ge 1) {
                Section -Style Heading3 'Global' {
                    $OutObj = @()

                    if ($info.'daily-restart' -eq "enable") {
                        $reboot = "Everyday at $($info.'restart-time')"
                    }
                    else {
                        $reboot = "disable"
                    }

                    $OutObj = [pscustomobject]@{
                        "Nom"            = $info.'hostname'
                        "Alias"          = $info.'alias'
                        "Recurring Reboot"         = $reboot
                        "Port SSH"       = $info.'admin-ssh-port'
                        "Port HTTP"      = $info.'admin-port'
                        "Port HTTPS"     = $info.'admin-sport'
                        "HTTPS Redirect" = $info.'admin-https-redirect'
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

            if ($settings -and $InfoLevel.System -ge 1) {
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

            if ($info -and $settings -and $InfoLevel.System -ge 1) {
                Section -Style Heading3 'Feature GUI visibility' {
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
                        Name         = "Feature GUI visibility"
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

            if ($dns -and $InfoLevel.System -ge 1) {
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

            if ($DNSServers -and $InfoLevel.System -ge 1) {
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

            if ($Admins -and $InfoLevel.System -ge 1) {
                Section -Style Heading3 'Admin' {
                    $OutObj = @()

                    foreach ($admin in $Admins) {

                        $trustedHosts = $admin.trusthost1 + "`n"
                        $trustedHosts += $admin.trusthost2 + "`n"
                        $trustedHosts += $admin.trusthost3 + "`n"
                        $trustedHosts += $admin.trusthost4 + "`n"
                        $trustedHosts += $admin.trusthost5 + "`n"
                        $trustedHosts += $admin.trusthost6 + "`n"
                        $trustedHosts += $admin.trusthost7 + "`n"
                        $trustedHosts += $admin.trusthost8 + "`n"
                        $trustedHosts += $admin.trusthost9 + "`n"
                        $trustedHosts += $admin.trusthost10 + "`n"

                        $trustedHosts = $trustedHosts -replace "0.0.0.0 0.0.0.0`n", "" #Remove 'All Network'
                        if ($trustedHosts -eq "") {
                            $trustedHosts = "All" #TODO: Add Health Warning !
                        }
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
                        ColumnWidths = 25, 25, 35, 15
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            $interfaces = Get-FGTSystemInterface

            #By 'API' design, it is always return all interfaces (not filtering by vdom)
            if ("" -ne $Options.vdom) {
                $interfaces = $interfaces | Where-Object { $_.vdom -eq $Options.vdom }
            }

            if ($interfaces -and $InfoLevel.System -ge 1) {
                Section -Style Heading3 'Interfaces' {
                    $OutObj = @()

                    foreach ($interface in $interfaces) {

                        if ($interface.role -eq "undefined") {
                            $interface.role = "n/a"
                        }
                        $alias_description = $interface.alias
                        if ($interface.description) {
                            $alias_description += "($($interface.description))"
                        }
                        $OutObj += [pscustomobject]@{
                            "Name"                = $interface.name
                            "Alias (Description)" = $alias_description
                            "Role"                = $interface.role
                            "Type"                = $interface.type
                            "Vlan ID"             = $interface.vlanid
                            "Mode"                = $interface.mode
                            "IP Address"          = $interface.ip.Replace(' ', '/')
                            #"Allow Access"        = $interface.allowaccess
                            #'DHCP Relais'        = $interface.'dhcp-relay-ip'
                            "Status"              = $interface.status
                            #"Speed"              = $interface.speed
                        }
                    }

                    $TableParams = @{
                        Name         = "Interface"
                        List         = $false
                        ColumnWidths = 12, 20, 7, 11, 6, 8, 28, 8
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            $zones = Get-FGTSystemZone

            if ($zones -and $InfoLevel.System -ge 1) {
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