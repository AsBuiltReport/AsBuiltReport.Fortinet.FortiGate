
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

            #Global settings
            $info = Get-FGTSystemGlobal

            if ($info -and $InfoLevel.System -ge 1) {
                $tableName = 'Global'
                Section -Style Heading3 $tableName {
                    $OutObj = @()

                    if ($info.'daily-restart' -eq "enable") {
                        $reboot = "Everyday at $($info.'restart-time')"
                    }
                    else {
                        $reboot = "disable"
                    }

                    $OutObj = [pscustomobject]@{
                        "Nom"              = $info.'hostname'
                        "Alias"            = $info.'alias'
                        "Recurring Reboot" = $reboot
                        "Port SSH"         = $info.'admin-ssh-port'
                        "Port HTTP"        = $info.'admin-port'
                        "Port HTTPS"       = $info.'admin-sport'
                        "HTTPS Redirect"   = $info.'admin-https-redirect'
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                }
            }

            #System Settings
            $settings = Get-FGTSystemSettings

            if ($settings -and $InfoLevel.System -ge 1) {
                $tableName = 'Settings'
                Section -Style Heading3 $tableName {
                    $OutObj = @()

                    $OutObj = [pscustomobject]@{
                        "OP Mode"           = $settings.opmode
                        "Central NAT"       = $settings.'central-nat'
                        "LLDP Reception"    = $settings.'lldp-reception'
                        "LLDP Transmission" = $settings.'lldp-transmission'
                        "Comments"          = $settings.comments
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                }
            }

            if ($info -and $settings -and $InfoLevel.System -ge 1) {
                $tableName = 'Feature GUI visibility'
                Section -Style Heading3 $tableName {
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
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                }
            }

            #DNS
            $dns = Get-FGTSystemDns

            if ($dns -and $InfoLevel.System -ge 1) {
                $tableName = 'DNS'
                Section -Style Heading3 $tableName {
                    $OutObj = @()

                    $OutObj = [pscustomobject]@{
                        "Primary"   = $dns.primary
                        "Secondary" = $dns.secondary
                        "Domain"    = $dns.domain.domain
                        "Protocol"  = $dns.protocol
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                }
            }

            #DNS Servers
            $DNSServers = Get-FGTSystemDnsServer

            if ($DNSServers -and $InfoLevel.System -ge 1) {
                $tableName = 'DNS Server'
                Section -Style Heading3 $tableName {
                    $OutObj = @()

                    foreach ($DNSServer in $DNSServers) {
                        $OutObj += [pscustomobject]@{
                            "Name"               = $DNSServer.name
                            "Mode"               = $DNSServer.mode
                            "DNS Filter Profile" = $DNSServer.'dnsfilter-profile'
                            "DOH"                = $DNSServer.doh
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName
                }
            }

            #Admin accounts
            $Admins = Get-FGTSystemAdmin

            if ($Admins -and $InfoLevel.System -ge 1) {
                $tableName = 'Administrators'
                Section -Style Heading3 $tableName {
                    $OutObj = @()

                    foreach ($admin in $Admins) {
                        $trustedHosts = @()

                        for ($i = 1; $i -le 10; $i++) {
                            $hostProperty = "trusthost$i"
                            $hostValue = $admin.$hostProperty

                            if ($hostValue -and $hostValue -ne "0.0.0.0 0.0.0.0") {
                                $trustedHosts += $($hostValue | ConvertTo-CIDR)
                            }
                        }

                        $trustedHostsString = if ($trustedHosts.Count -eq 0) {
                            "All" #TODO: Add Health Warning !
                        }
                        else {
                            $trustedHosts -join "`n"
                        }

                        $OutObj += [pscustomobject]@{
                            "Name"          = $admin.name
                            "Profile"       = $admin.accprofile
                            "Trusted Hosts" = $trustedHostsString
                            "MFA"           = $admin.'two-factor'
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Trusted Hosts" = 20; "MFA" = 10; }
                }
            }

            #Interfaces
            $interfaces = Get-FGTSystemInterface

            #By 'API' design, it is always return all interfaces (not filtering by vdom)
            if ("" -ne $Options.vdom) {
                $interfaces = $interfaces | Where-Object { $_.vdom -eq $Options.vdom }
            }

            if ($interfaces -and $InfoLevel.System -ge 1) {
                $tableName = 'Interfaces'
                Section -Style Heading3 $tableName {
                    Paragraph "The following section details FortiGate interfaces, grouped by interface type."

                    # Group interfaces by their 'type'
                    $groupedInterfaces = $interfaces | Group-Object -Property type

                    foreach ($group in $groupedInterfaces) {
                        $interfaceType = $group.Name

                        # Create a heading for each interface type
                        Section -Style Heading4 "$interfaceType Interfaces" {
                            $OutObj = @()

                            foreach ($interface in $group.Group) {

                                # Standardise interface properties
                                $interface.name = $interface.name + $($interface.alias ? "`n($($interface.alias))" : "")
                                $interface.role = $interface.role -eq 'undefined' ? "" : ($interface.role).ToUpper()
                                $interface.member = $interface.member.count -gt 0 ? $interface.member.'interface-name' -join ', ' : ""
                                $interface.mtu = $interface.'mtu-override' -eq 'disable' ? '' : $interface.mtu
                                $interface.mode = $interface.mode -eq 'static' ? '' : $interface.mode
                                $interface.ip = $interface.ip -eq '0.0.0.0 0.0.0.0' ? '' : $($interface.ip | ConvertTo-CIDR)
                                $interface.'secondaryip' = if ($interface.'secondary-ip' -eq 'enable' -and $null -ne $interface.'secondaryip') {
                                    ($interface.'secondaryip' | ForEach-Object {
                                        $($_.ip | ConvertTo-CIDR)
                                    }) -join ', '
                                }
                                else {
                                    ""
                                }
                                $interface.mode = $interface.mode -eq 'static' ? '' : $interface.mode
                                $interface.vdom = $interface.vdom -eq 'root' ? '' : $interface.vdom
                                $interface.vlanid = ($interface.vlanid -gt 0 ) ? $interface.vlanid : ""
                                $interface.speed = $interface.speed -eq 'auto' ? '' : $interface.speed
                                $interface.'remote-ip' = $interface.'remote-ip' -eq '0.0.0.0 0.0.0.0' ? '' : $($interface.'remote-ip' | ConvertTo-CIDR)


                                switch ($interfaceType) {
                                    "Aggregate" {
                                        $OutObj += [pscustomobject]@{
                                            "Name"            = $interface.name
                                            "VDOM"            = $interface.vdom
                                            "Role"            = $interface.role
                                            "Members"         = $interface.member
                                            "LACP Mode"       = $interface.'lacp-mode'
                                            "MTU"             = $interface.mtu
                                            "Addressing mode" = $interface.mode
                                            "IP Address"      = $interface.ip
                                            "Secondary IP"    = $interface.'secondaryip'
                                            "Allow Access"    = $interface.allowaccess
                                            "Status"          = $interface.status
                                            "Comments"        = $interface.description
                                        }
                                    }
                                    "hard-switch" {
                                        $OutObj += [pscustomobject]@{
                                            "Name"            = $interface.name
                                            "VDOM"            = $interface.vdom
                                            "Role"            = $interface.role
                                            "Members"         = $interface.member
                                            "MTU"             = $interface.mtu
                                            "Addressing mode" = $interface.mode
                                            "IP Address"      = $interface.ip
                                            "Secondary IP"    = $interface.'secondaryip'
                                            "Allow Access"    = $interface.allowaccess
                                            "Status"          = $interface.status
                                            "Comments"        = $interface.description
                                        }
                                    }
                                    "loopback" {
                                        $OutObj += [pscustomobject]@{
                                            "Name"         = $interface.name
                                            "VDOM"         = $interface.vdom
                                            "Role"         = $interface.role
                                            "MTU"          = $interface.mtu
                                            "IP Address"   = $interface.ip
                                            "Secondary IP" = $interface.'secondaryip'
                                            "Allow Access" = $interface.allowaccess
                                            "Status"       = $interface.status
                                            "Comments"     = $interface.description
                                        }

                                    }
                                    "physical" {
                                        $OutObj += [pscustomobject]@{
                                            "Name"            = $interface.name
                                            "VDOM"            = $interface.vdom
                                            "Role"            = $interface.role
                                            "MTU"             = $interface.mtu
                                            "Speed"           = $interface.speed
                                            "Addressing mode" = $interface.mode
                                            "IP Address"      = $interface.ip
                                            "Secondary IP"    = $interface.'secondaryip'
                                            "Allow Access"    = $interface.allowaccess
                                            "Status"          = $interface.status
                                            "Comments"        = $interface.description
                                        }

                                    }
                                    "tunnel" {
                                        $OutObj += [pscustomobject]@{
                                            "Name"             = $interface.name
                                            "Parent Interface" = $interface.interface
                                            "VDOM"             = $interface.vdom
                                            "Role"             = $interface.role
                                            "MTU"              = $interface.mtu
                                            "IP Address"       = $interface.ip
                                            "Secondary IP"     = $interface.'secondaryip'
                                            "Remote IP"        = $interface.'remote-ip'
                                            "Allow Access"     = $interface.allowaccess
                                            "Status"           = $interface.status
                                            "Comments"         = $interface.description
                                        }
                                    }
                                    "vlan" {
                                        $OutObj += [pscustomobject]@{
                                            "Name"             = $interface.name
                                            "Parent Interface" = $interface.interface
                                            "VLAN ID"          = $interface.vlanid
                                            "VDOM"             = $interface.vdom
                                            "Role"             = $interface.role
                                            "MTU"              = $interface.mtu
                                            "Mode"             = $interface.mode
                                            "IP Address"       = $interface.ip
                                            "Secondary IP"     = $interface.'secondaryip'
                                            "Allow Access"     = $interface.allowaccess
                                            "Status"           = $interface.status
                                        }
                                    }
                                    # vap-switch falls under default
                                    Default {
                                        $OutObj += [pscustomobject]@{
                                            "Name"         = $interface.name
                                            "VDOM"         = $interface.vdom
                                            "Role"         = $interface.role
                                            "MTU"          = $interface.mtu
                                            "VLAN ID"      = $interface.vlanid
                                            "Mode"         = $interface.mode
                                            "IP Address"   = $interface.ip
                                            "Secondary IP" = $interface.'secondaryip'
                                            "Allow Access" = $interface.allowaccess
                                            "Status"       = $interface.status
                                        }
                                    }
                                }
                            }

                            #Introduction section for VLAN interfaces
                            if ($interfaceType -eq "vlan") {
                                $vlanUpCount = ($OutObj | Where-Object { $_.Status -eq 'up' }).Count
                                $vlanDownCount = ($OutObj | Where-Object { $_.Status -ne 'up' }).Count
                                Paragraph "Total number of unique VLANs found: $($vlanUpCount + $vlanDownCount), of which $vlanUpCount are up and $vlanDownCount are down."
                                if ($vlanUpCount -gt 0) {
                                    $vlanUpIDs = ($OutObj | Where-Object { $_.Status -eq 'up' } | Select-Object -ExpandProperty 'VLAN ID' -Unique)
                                    Paragraph "- Up VLANs are: $($vlanUpIDs -join ', ')."
                                }
                                if ($vlanDownCount -gt 0) {
                                    $vlanDownIDs = ($OutObj | Where-Object { $_.Status -ne 'up' } | Select-Object -ExpandProperty 'VLAN ID' -Unique)
                                    Paragraph "- Down VLANs are: $($vlanDownIDs -join ', ')."
                                }
                                BlankLine
                            }

                            $downInterfaces = @()
                            $upInterfaces = @()

                            foreach ($interface in $OutObj) {
                                if ($interface.PSObject.Properties.Name -contains 'Status') {
                                    if ($interface.Status -eq 'up') {
                                        $upInterfaces += $interface
                                    }
                                    else {
                                        $downInterfaces += $interface
                                    }
                                }
                                else {
                                    $downInterfaces += $interface
                                }
                            }

                            if ($upInterfaces.Count -gt 0) {
                                Write-FormattedTable -InputObject $upInterfaces -TableName $tableName -CustomColumnWidths @{"Name" = 15; "VLAN ID" = 8; "Status" = 10; "IP Address" = 18; "Secondary IP" = 18; "Role" = 8; "Parent Interface" = 12 }
                            }


                            if ($downInterfaces.Count -gt 0) {
                                $downInterfaceNames = $downInterfaces | Select-Object -ExpandProperty Name
                                Paragraph -Style Notation "The following interface(s) were omitted from the table above due to being down: $($downInterfaceNames -join ', ')."
                                BlankLine
                            }
                        }
                    }
                }
            }

            #Zones
            $zones = Get-FGTSystemZone

            if ($zones -and $InfoLevel.System -ge 1) {
                $tableName = 'Zones'
                Section -Style Heading3 $tableName {
                    $OutObj = @()

                    foreach ($zone in $zones) {
                        $OutObj += [pscustomobject]@{
                            "Name"        = $zone.name
                            "Intrazone"   = $zone.intrazone
                            "Interface"   = $zone.interface.'interface-name'
                            "Description" = $zone.description
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName

                }
            }

            #DHCP Server
            $dhcp_servers = Get-FGTSystemDHCPServer

            if ($null -ne $dhcp_servers -and $dhcp_servers.Count -gt 0 -and $InfoLevel.System -ge 1) {
                $tableName = 'DHCP Server'
                Section -Style Heading3 $tableName {
                    $OutObj = @()

                    foreach ($dhcp_server in $dhcp_servers) {
                        $OutObj += [pscustomobject]@{
                            "id"        = $dhcp_server.id
                            "Status"    = $dhcp_server.status
                            "Interface" = $dhcp_server.interface
                            "Range"     = "$($dhcp_server.'ip-range'.'start-ip')-$($dhcp_server.'ip-range'.'end-ip')"
                            "Netmask"   = $dhcp_server.netmask
                            "Gateway"   = $dhcp_server.'default-gateway'
                        }
                    }

                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"id" = 5; "Status" = 10; "Range" = 35; }
                }

                if ($InfoLevel.System -ge 2) {
                    #DHCP Server detail
                    foreach ($dhcp_server in $dhcp_servers) {
                        $tableName = "DHCP $($dhcp_server.id) - $($dhcp_server.interface)"
                        Section -Style NOTOCHeading4 -ExcludeFromTOC $tableName {

                            $dns = ($dhcp_server.'dns-server1' -replace "0.0.0.0", "") + ($dhcp_server.'dns-server2' -replace "0.0.0.0", "") + ($dhcp_server.'dns-server3' -replace "0.0.0.0", "") + ($dhcp_server.'dns-server4' -replace "0.0.0.0", "")
                            $ntp = ($dhcp_server.'ntp-server1' -replace "0.0.0.0", "") + ($dhcp_server.'ntp-server2' -replace "0.0.0.0", "") + ($dhcp_server.'ntp-server3' -replace "0.0.0.0", "") + ($dhcp_server.'ntp-server4' -replace "0.0.0.0", "")
                            $OutObj = [pscustomobject]@{
                                "id"         = $dhcp_server.id
                                "Status"     = $dhcp_server.status
                                "Lease Time" = $dhcp_server.'lease-time'
                                "Interface"  = $dhcp_server.interface
                                "Start IP"   = $dhcp_server.'ip-range'.'start-ip'
                                "End IP"     = $dhcp_server.'ip-range'.'end-ip'
                                "Netmask"    = $dhcp_server.netmask
                                "Gateway"    = $dhcp_server.'default-gateway'
                                "DNS"        = $dns
                                "Domain"     = $dhcp_server.domain
                                "NTP"        = $ntp
                            }
                            Write-FormattedTable -InputObject $OutObj -TableName $tableName -list -TableParams @{ColumnWidths = 25, 75 }
                        }
                    }

                    #DHCP Server Reservation
                    if ($null -ne $dhcp_servers.'reserved-address' -and $dhcp_servers.'reserved-address'.Count -gt 0) {
                        $tableName = "DHCP Server Reserved Address"
                        Section -Style NOTOCHeading4 -ExcludeFromTOC "DHCP Server Reserved Address" {
                            $OutObj = @()
                            foreach ($reserved_address in ($dhcp_servers.'reserved-address')) {
                                $OutObj += [pscustomobject]@{
                                    "id"     = $reserved_address.id
                                    "IP"     = $reserved_address.ip
                                    "MAC"    = $reserved_address.mac
                                    "Action" = $reserved_address.action
                                }
                            }

                            Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"id" = 5; "IP" = 35; "MAC" = 35; }
                        }
                    }

                    #DHCP Leases (from Monitoring) => no yet Get-FGTMonitorDHCP cmdlet on PowerFGT...
                    $dhcp_leases = (Invoke-FGTRestMethod -uri api/v2/monitor/system/dhcp).results

                    if ($dhcp_leases) {
                        $tableName = "DHCP Leases"
                        Section -Style NOTOCHeading4 -ExcludeFromTOC $tableName {
                            $OutObj = @()
                            foreach ($dhcp_lease in $dhcp_leases) {
                                $OutObj += [pscustomobject]@{
                                    "IP"          = $dhcp_lease.ip
                                    "MAC"         = $dhcp_lease.mac
                                    "Hostname"    = $dhcp_lease.hostname
                                    "Status"      = $dhcp_lease.status
                                    "Reserved"    = $dhcp_lease.reserved
                                    "Expire Time" = ( Get-Date -UnixTimeSeconds $dhcp_lease.expire_time)
                                }
                            }

                            Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"IP" = 18; "MAC" = 18; }
                        }
                    }

                }

            }

            #HA Configuration
            $haConfig = Get-FGTSystemHA
            $haPeers = Get-FGTMonitorSystemHAPeer
            $haChecksums = Get-FGTMonitorSystemHAChecksum

            if ( $haConfig.mode -ne 'standalone' -and $infoLevel.System -ge 1) {
                Section -Style Heading3 'High Availability' {
                    Paragraph "The following section details HA settings."
                    BlankLine
                    $tableName = 'HA Configuration'
                    Section -Style Heading4 $tableName {
                        $OutObj = @()

                        switch ($haConfig.mode) {
                            "a-p" { $mode = "Active/Passive" }
                            "a-a" { $mode = "Active/Active" }
                            Default {}
                        }
                        #API return multi same interface ?! (remove extra space, quote and )
                        $monitor = (($haConfig.monitor.trim() -replace '  ', ' ' -replace '"', '').Split(" ") | Sort-Object -Unique) -Join ", "

                        $OutObj = [pscustomobject]@{
                            "Group Name"               = $haConfig.'group-name'
                            "Group ID"                 = $haConfig.'group-id'
                            "Mode"                     = $mode
                            "HB Device"                = $haConfig.'hbdev'
                            "Monitor"                  = $monitor
                            "HA Override"              = $haConfig.'override'
                            "Route TTL"                = $haConfig.'route-ttl'
                            "Route Wait"               = $haConfig.'route-wait'
                            "Route Hold"               = $haConfig.'route-hold'
                            "Session sync (TCP)"       = $haConfig.'session-pickup'
                            "Session sync (UDP)"       = $haConfig.'session-pickup-connectionless'
                            "Session sync (Pinholes)"  = $haConfig.'session-pickup-expectation'
                            "Uninterruptible Upgrade"  = $haConfig.'uninterrup-upgrade'
                            "HA Management Status"     = $haConfig.'ha-mgmt-status'
                            "HA Management Interfaces" = $haConfig.'ha-mgmt-interfaces'
                        }

                        Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                    }

                    $tableName = 'HA Members'
                    Section -Style Heading4 $tableName {
                        $OutObj = @()

                        foreach ($haPeer in $haPeers) {
                            $haChecksum = $haChecksums | Where-Object { $_.serial_no -eq $haPeer.serial_no }

                            # Correctly using the if statement for assignment
                            $manageMaster = if ($haChecksum.is_manage_master -eq 1) { "Yes" } else { "No" }
                            $rootMaster = if ($haChecksum.is_root_master -eq 1) { "Yes" } else { "No" }

                            # Correctly reference properties from $haPeer
                            $OutObj += [pscustomobject]@{
                                "Hostname"      = $haPeer.hostname
                                "Serial"        = $haPeer.serial_no
                                "Priority"      = $haPeer.priority
                                "Manage Master" = $manageMaster
                                "Root Master"   = $rootMaster
                            }
                        }
                        Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Hostname" = 30; "Serial" = 20; }
                    }


                }
            }

        }
    }

    end {

    }

}