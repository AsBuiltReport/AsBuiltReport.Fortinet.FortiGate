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
                    } else {
                        $reboot = "disable"
                    }

                    $OutObj = [pscustomobject]@{
                        "Nom" = $info.'hostname'
                        "Alias" = $info.'alias'
                        "Recurring Reboot" = $reboot
                        "Port SSH" = $info.'admin-ssh-port'
                        "Port HTTP" = $info.'admin-port'
                        "Port HTTPS" = $info.'admin-sport'
                        "HTTPS Redirect" = $info.'admin-https-redirect'
                    }

                    $TableParams = @{
                        Name = "Global"
                        List = $true
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
                        "OP Mode" = $settings.opmode
                        "Central NAT" = $settings.'central-nat'
                        "LLDP Reception" = $settings.'lldp-reception'
                        "LLDP Transmission" = $settings.'lldp-transmission'
                        "Comments" = $settings.comments
                    }

                    $TableParams = @{
                        Name = "Settings"
                        List = $true
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
                        "Language" = $info.language
                        "Theme" = $info.'gui-theme'
                        "IPv6" = $info.'gui-ipv6'
                        "Wireless Open Security" = $info.'gui-wireless-opensecurity'
                        "Implicit Policy" = $settings.'gui-implicit-policy'
                        "Dns Database" = $settings.'gui-dns-database'
                        "Load Balance" = $settings.'gui-load-balance'
                        "Explicit Proxy" = $settings.'gui-explicit-proxy'
                        "Dynamic Routing" = $settings.'gui-dynamic-routing'
                        "Application Control" = $settings.'gui-application-control'
                        "IPS" = $settings.'gui-ips'
                        "VPN" = $settings.'gui-vpn'
                        "Wireless Controller" = $settings.'gui-wireless-controller'
                        "Switch Controller" = $settings.'gui-switch-controller'
                        "WAN Load Balancing (SDWAN)" = $settings.'gui-wan-load-balancing'
                        "Antivirus" = $settings.'gui-antivirus'
                        "Web Filter" = $settings.'gui-webfilter'
                        "Video Filter" = $settings.'gui-videofilter'
                        "DNS Filter" = $settings.'gui-dnsfilter'
                        "WAF Profile" = $settings.'gui-waf-profile'
                        "Allow Unnamed Policy" = $settings.'gui-allow-unnamed-policy'
                        "Multiple Interface Policy" = $settings.'gui-multiple-interface-policy'
                        "ZTNA" = $settings.'gui-ztna'
                        "OT" = $settings.'gui-ot'
                    }

                    $TableParams = @{
                        Name = "Feature GUI visibility"
                        List = $true
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
                        "Primary" = $dns.primary
                        "Secondary" = $dns.secondary
                        "Domain" = $dns.domain.domain
                        "Protocol" = $dns.protocol
                    }

                    $TableParams = @{
                        Name = "DNS"
                        List = $true
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
                            "Name" = $DNSServer.name
                            "Mode" = $DNSServer.mode
                            "DNS Filter Profile" = $DNSServer.'dnsfilter-profile'
                            "DOH" = $DNSServer.doh
                        }
                    }

                    $TableParams = @{
                        Name = "DNS Server"
                        List = $false
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
                Section -Style Heading3 'Administrators' {
                    $OutObj = @()

                    foreach ($admin in $Admins) {

                        $trustedHosts = @()
                        for ($i = 1; $i -le 10; $i++) {
                            $hostProperty = "trusthost$i"
                            $hostValue = $admin.$hostProperty

                            if ($hostValue -and $hostValue -ne "0.0.0.0 0.0.0.0") {
                                $trustedHosts += $(if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $hostValue } else { $hostValue })
                            }
                        }

                        $trustedHostsString = if ($trustedHosts.Count -eq 0) {
                            "All" #TODO: Add Health Warning !
                        } else {
                            $trustedHosts -join "`n"
                        }
                        $OutObj += [pscustomobject]@{
                            "Name" = $admin.name
                            "Profile" = $admin.accprofile
                            "Trusted Hosts" = $trustedHosts
                            "MFA" = $admin.'two-factor'
                        }
                    }

                    $TableParams = @{
                        Name = "Administrator"
                        List = $false
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
                    Paragraph "The following section details FortiGate interfaces, grouped by interface type."

                    # Group interfaces by their 'type'
                    $groupedInterfaces = $interfaces | Group-Object -Property type

                    foreach ($group in $groupedInterfaces) {
                        $interfaceType = $group.Name

                        # Create a heading for each interface type
                        Section -Style Heading4 "$([char]::ToUpper($interfaceType[0]) + $interfaceType.Substring(1)) Interfaces" {
                            $OutObj = @()

                            foreach ($interface in $group.Group) {

                                # Standardise interface properties
                                if ($interface.alias) { $interface.name = $interface.name + "`n($($interface.alias))" }
                                $interface.role = if ($interface.role -eq 'undefined') { "" } else { ($interface.role).ToUpper() }
                                $interface.member = if ($interface.member.count -gt 0) { $interface.member.'interface-name' -join ', ' } else { "" }
                                $interface.mtu = if ($interface.'mtu-override' -eq 'disable') { '' } else { $interface.mtu }
                                $interface.mode = if ($interface.mode -eq 'static') { '' } else { $interface.mode }
                                $interface.ip = if ($interface.ip -eq '0.0.0.0 0.0.0.0') { '' } else { if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $interface.ip } else { $interface.ip } }
                                $interface.'secondaryip' = if ($interface.'secondary-ip' -eq 'enable' -and $null -ne $interface.'secondaryip') { ($interface.'secondaryip' | ForEach-Object { if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $_.ip } else { $_.ip } }) -join ', ' } else { "" }
                                $interface.mode = if ($interface.mode -eq 'static') { '' } else { $interface.mode }
                                $interface.vdom = if ($interface.vdom -eq 'root') { '' } else { $interface.vdom }
                                $interface.vlanid = if ($interface.vlanid -gt 0) { $interface.vlanid } else { "" }
                                $interface.speed = if ($interface.speed -eq 'auto') { '' } else { $interface.speed }
                                $interface.'remote-ip' = if ($interface.'remote-ip' -eq '0.0.0.0 0.0.0.0') { '' } else { if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $interface.'remote-ip' } else { $interface.'remote-ip' } }

                                switch ($interfaceType) {
                                    "Aggregate" {
                                        $OutObj += [pscustomobject]@{
                                            "Name" = $interface.name
                                            "VDOM" = $interface.vdom
                                            "Role" = $interface.role
                                            "Members" = $interface.member
                                            "LACP Mode" = $interface.'lacp-mode'
                                            #"MTU"                 = $interface.mtu   # Will be enabled next release when the TableWrite function is added
                                            "Addressing mode" = $interface.mode
                                            "IP Address" = $interface.ip
                                            #"Secondary IP"        = $interface.'secondaryip'   # Will be enabled next release when the TableWrite function is added
                                            "Allow Access" = $interface.allowaccess
                                            "Status" = $interface.status
                                            #"Comments"            = $interface.description   # Will be enabled next release when the TableWrite function is added
                                        }
                                    }
                                    "Hard-Switch" {
                                        $OutObj += [pscustomobject]@{
                                            "Name" = $interface.name
                                            "VDOM" = $interface.vdom
                                            "Role" = $interface.role
                                            "Members" = $interface.member
                                            "MTU" = $interface.mtu
                                            "Addressing mode" = $interface.mode
                                            "IP Address" = $interface.ip
                                            #"Secondary IP"        = $interface.'secondaryip'   # Will be enabled next release when the TableWrite function is added
                                            "Allow Access" = $interface.allowaccess
                                            "Status" = $interface.status
                                            #"Comments"            = $interface.description   # Will be enabled next release when the TableWrite function is added
                                        }
                                    }
                                    "Loopback" {
                                        $OutObj += [pscustomobject]@{
                                            "Name" = $interface.name
                                            "VDOM" = $interface.vdom
                                            "Role" = $interface.role
                                            "MTU" = $interface.mtu
                                            "IP Address" = $interface.ip
                                            "Secondary IP" = $interface.'secondaryip'
                                            "Allow Access" = $interface.allowaccess
                                            "Status" = $interface.status
                                            "Comments" = $interface.description
                                        }

                                    }
                                    "Physical" {
                                        $OutObj += [pscustomobject]@{
                                            "Name" = $interface.name
                                            "VDOM" = $interface.vdom
                                            "Role" = $interface.role
                                            "MTU" = $interface.mtu
                                            "Speed" = $interface.speed
                                            "Addressing mode" = $interface.mode
                                            "IP Address" = $interface.ip
                                            #"Secondary IP"        = $interface.'secondaryip'   # Will be enabled next release when the TableWrite function is added
                                            "Allow Access" = $interface.allowaccess
                                            "Status" = $interface.status
                                            #"Comments"            = $interface.description   # Will be enabled next release when the TableWrite function is added
                                        }

                                    }
                                    "Tunnel" {
                                        $OutObj += [pscustomobject]@{
                                            "Name" = $interface.name
                                            "Parent Interface" = $interface.interface
                                            "VDOM" = $interface.vdom
                                            "Role" = $interface.role
                                            "MTU" = $interface.mtu
                                            "IP Address" = $interface.ip
                                            #"Secondary IP"        = $interface.'secondaryip'   # Will be enabled next release when the TableWrite function is added
                                            "Remote IP" = $interface.'remote-ip'
                                            "Allow Access" = $interface.allowaccess
                                            "Status" = $interface.status
                                            #"Comments"            = $interface.description   # Will be enabled next release when the TableWrite function is added
                                        }
                                    }
                                    "Vlan" {
                                        $OutObj += [pscustomobject]@{
                                            "Name" = $interface.name
                                            "Parent Interface" = $interface.interface
                                            "VLAN ID" = $interface.vlanid
                                            "VDOM" = $interface.vdom
                                            "Role" = $interface.role
                                            #"MTU"                 = $interface.mtu   # Will be enabled next release when the TableWrite function is added
                                            "Mode" = $interface.mode
                                            "IP Address" = $interface.ip
                                            #"Secondary IP"        = $interface.'secondaryip'   # Will be enabled next release when the TableWrite function is added
                                            "Allow Access" = $interface.allowaccess
                                            "Status" = $interface.status
                                        }
                                    }
                                    # vap-switch falls under default
                                    Default {
                                        $OutObj += [pscustomobject]@{
                                            "Name" = $interface.name
                                            "VDOM" = $interface.vdom
                                            "Role" = $interface.role
                                            "MTU" = $interface.mtu
                                            "VLAN ID" = $interface.vlanid
                                            "Mode" = $interface.mode
                                            "IP Address" = $interface.ip
                                            #"Secondary IP"        = $interface.'secondaryip'   # Will be enabled next release when the TableWrite function is added
                                            "Allow Access" = $interface.allowaccess
                                            "Status" = $interface.status
                                        }
                                    }
                                }
                            }

                            # VLAN interfaces
                            if ($interfaceType -eq "vlan" -and $Options.ExcludeDownInterfaces ) {
                                $vlanUpCount = ($OutObj | Where-Object { $_.Status -eq 'up' }).Count
                                $vlanDownCount = ($OutObj | Where-Object { $_.Status -ne 'up' }).Count
                                $vlanUpIDs = ($OutObj | Where-Object { $_.Status -eq 'up' } | Select-Object -ExpandProperty 'VLAN ID' | Sort-Object)
                                $vlanDownIDs = ($OutObj | Where-Object { $_.Status -ne 'up' } | Select-Object -ExpandProperty 'VLAN ID' | Sort-Object)

                                $VlanSummaryObj = [PSCustomObject]@{
                                    'Up VLANs' = "$vlanUpCount ($($vlanUpIDs -join ', '))"
                                    'Down VLANs' = "$vlanDownCount ($($vlanDownIDs -join ', '))"
                                    'Total VLANs' = ($vlanUpCount + $vlanDownCount)
                                }

                                $TableParams = @{
                                    Name = "VLAN Summary"
                                    List = $true
                                    ColumnWidths = 20, 80
                                }

                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }

                                $VlanSummaryObj | Table @TableParams
                                BlankLine
                            }

                            $downInterfaces = @()
                            $upInterfaces = @()

                            foreach ($interface in $OutObj) {
                                if ($interface.PSObject.Properties.Name -contains 'Status') {
                                    if ($interface.Status -eq 'up') {
                                        $upInterfaces += $interface
                                    } else {
                                        $downInterfaces += $interface
                                    }
                                } else {
                                    $downInterfaces += $interface
                                }
                            }

                            if ($upInterfaces.Count -gt 0) {
                                $TableParams = @{
                                    Name = "$([char]::ToUpper($interfaceType[0]) + $interfaceType.Substring(1)) Interfaces"
                                    List = $false
                                    ColumnWidths = 12, 20, 7, 11, 6, 8, 20, 8, 8
                                }

                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }

                                # Only show interfaces based on ExcludeDownInterfaces setting
                                if ($Options.ExcludeDownInterfaces) {
                                    $upInterfaces | Table @TableParams
                                } else {
                                    $OutObj | Table @TableParams
                                }
                            }

                            if ($downInterfaces.Count -gt 0 -and $Options.ExcludeDownInterfaces) {
                                $downInterfaceNames = $downInterfaces | Select-Object -ExpandProperty Name
                                Paragraph -Style Notation "The following interface(s) were omitted due to being down: $(( $downInterfaceNames | Sort-Object ) -join ', ')."
                                BlankLine
                            }
                        }
                    }
                }
            }

            $zones = Get-FGTSystemZone

            if ($zones -and $InfoLevel.System -ge 1) {
                Section -Style Heading3 'Zone' {
                    $OutObj = @()

                    foreach ($zone in $zones) {
                        $OutObj += [pscustomobject]@{
                            "Name" = $zone.name
                            "Intrazone" = $zone.intrazone
                            "Interface" = $zone.interface.'interface-name'
                            "Description" = $zone.description
                        }
                    }

                    $TableParams = @{
                        Name = "Zone"
                        List = $false
                        ColumnWidths = 25, 25, 25, 25
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            #DHCP Server
            $dhcp_servers = Get-FGTSystemDHCPServer

            if ($dhcp_servers -and $InfoLevel.System -ge 1) {
                Section -Style Heading3 'DHCP Server' {
                    $OutObj = @()

                    foreach ($dhcp_server in $dhcp_servers) {
                        $OutObj += [pscustomobject]@{
                            "id" = $dhcp_server.id
                            "Status" = $dhcp_server.status
                            "Interface" = $dhcp_server.interface
                            "Range" = "$($dhcp_server.'ip-range'.'start-ip')-$($dhcp_server.'ip-range'.'end-ip')"
                            "Netmask" = $dhcp_server.netmask
                            "Gateway" = $dhcp_server.'default-gateway'
                        }
                    }

                    $TableParams = @{
                        Name = "DHCP Server"
                        List = $false
                        ColumnWidths = 5, 11, 15, 35, 17, 17
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }

                if ($InfoLevel.System -ge 2) {
                    #DHCP Server detail
                    foreach ($dhcp_server in $dhcp_servers) {
                        Section -Style NOTOCHeading4 -ExcludeFromTOC "DHCP: $($dhcp_server.id) - $($dhcp_server.interface)" {
                            BlankLine

                            $dns = ($dhcp_server.'dns-server1' -replace "0.0.0.0", "") + ($dhcp_server.'dns-server2' -replace "0.0.0.0", "") + ($dhcp_server.'dns-server3' -replace "0.0.0.0", "") + ($dhcp_server.'dns-server4' -replace "0.0.0.0", "")
                            $ntp = ($dhcp_server.'ntp-server1' -replace "0.0.0.0", "") + ($dhcp_server.'ntp-server2' -replace "0.0.0.0", "") + ($dhcp_server.'ntp-server3' -replace "0.0.0.0", "") + ($dhcp_server.'ntp-server4' -replace "0.0.0.0", "")
                            $OutObj = [pscustomobject]@{
                                "id" = $dhcp_server.id
                                "Status" = $dhcp_server.status
                                "Lease Time" = $dhcp_server.'lease-time'
                                "Interface" = $dhcp_server.interface
                                "Start IP" = $dhcp_server.'ip-range'.'start-ip'
                                "End IP" = $dhcp_server.'ip-range'.'end-ip'
                                "Netmask" = $dhcp_server.netmask
                                "Gateway" = $dhcp_server.'default-gateway'
                                "DNS" = $dns
                                "Domain" = $dhcp_server.domain
                                "NTP" = $ntp
                            }

                            $TableParams = @{
                                Name = "DHCP $($dhcp_server.id) - $($dhcp_server.interface)"
                                List = $true
                                ColumnWidths = 25, 75
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }
                            if ($OutObj.count) {
                                $OutObj | Table @TableParams
                            }
                        }
                    }

                    #DHCP Server Reservation
                    if ($null -ne $dhcp_servers.'reserved-address') {
                        Section -Style NOTOCHeading4 -ExcludeFromTOC "DHCP Server Reserved Address" {
                            $OutObj = @()
                            foreach ($reserved_address in ($dhcp_servers.'reserved-address')) {
                                $OutObj += [pscustomobject]@{
                                    "id" = $reserved_address.id
                                    "IP" = $reserved_address.ip
                                    "MAC" = $reserved_address.mac
                                    "Action" = $reserved_address.action
                                }
                            }

                            $TableParams = @{
                                Name = "DHCP Server Reserved Address"
                                List = $false
                                ColumnWidths = 5, 35, 35, 25
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }
                            if ($OutObj.count) {
                                $OutObj | Table @TableParams
                            }
                        }
                    }

                    #DHCP Leases (from Monitoring)
                    $dhcp_leases = Get-FGTMonitorSystemDHCP

                    if ($dhcp_leases) {
                        Section -Style NOTOCHeading4 -ExcludeFromTOC "DHCP Leases" {
                            $OutObj = @()
                            foreach ($dhcp_lease in $dhcp_leases) {
                                if ($PSVersionTable.PSEdition -eq "Core") {
                                    #PS 6 and after
                                    $expire_time = Get-Date -UnixTimeSeconds $dhcp_lease.expire_time
                                } else {
                                    #PS 5 and before
                                    $epoch = [datetime]"1970-01-01 00:00:00Z"
                                    $expire_time = $epoch.AddSeconds($dhcp_lease.expire_time)
                                }
                                $OutObj += [pscustomobject]@{
                                    "IP" = $dhcp_lease.ip
                                    "MAC" = $dhcp_lease.mac
                                    "Hostname" = $dhcp_lease.hostname
                                    "Status" = $dhcp_lease.status
                                    "Reserved" = $dhcp_lease.reserved
                                    "Expire Time" = $expire_time
                                }
                            }

                            $TableParams = @{
                                Name = "DHCP Server Reserved Address"
                                List = $false
                                ColumnWidths = 19, 19, 25, 8, 11, 18
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
                        }
                    }

                }

            }

            # Fetch HA Configuration
            $haConfig = Get-FGTSystemHA
            #Old release of FortiOS (Before 6.2.x) don't support SystemHAPeer and HAChecksum
            try {
                $haPeers = Get-FGTMonitorSystemHAPeer
                $haChecksums = Get-FGTMonitorSystemHAChecksum
            } catch {
                Write-Warning "HA Peer/Checksum are not available before FortiOS 6.2.x"
            }

            if ( $haConfig.mode -ne 'standalone' -and $infoLevel.System -ge 1) {
                Section -Style Heading3 'High Availability' {
                    Paragraph "The following section details HA settings."
                    BlankLine

                    Section -Style Heading4 'HA Configuration' {
                        $OutObj = @()

                        switch ($haConfig.mode) {
                            "a-p" { $mode = "Active/Passive" }
                            "a-a" { $mode = "Active/Active" }
                            Default {}
                        }
                        #API return multi same interface ?! (remove extra space, quote and )
                        $monitor = (($haConfig.monitor.trim() -replace '  ', ' ' -replace '"', '').Split(" ") | Sort-Object -Unique) -Join ", "

                        $OutObj = [pscustomobject]@{
                            "Group Name" = $haConfig.'group-name'
                            "Group ID" = $haConfig.'group-id'
                            "Mode" = $mode
                            "HB Device" = $haConfig.'hbdev'
                            "Monitor" = $monitor
                            "HA Override" = $haConfig.'override'
                            "Route TTL" = $haConfig.'route-ttl'
                            "Route Wait" = $haConfig.'route-wait'
                            "Route Hold" = $haConfig.'route-hold'
                            "Session sync (TCP)" = $haConfig.'session-pickup'
                            "Session sync (UDP)" = $haConfig.'session-pickup-connectionless'
                            "Session sync (Pinholes)" = $haConfig.'session-pickup-expectation'
                            "Uninterruptible Upgrade" = $haConfig.'uninterrup-upgrade'
                            "HA Management Status" = $haConfig.'ha-mgmt-status'
                            "HA Management Interfaces" = $haConfig.'ha-mgmt-interfaces'
                        }

                        $TableParams = @{
                            Name = "HA Configuration"
                            List = $true
                            ColumnWidths = 50, 50
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }

                    Section -Style Heading4 'HA Members' {
                        $OutObj = @()

                        foreach ($haPeer in $haPeers) {
                            $haChecksum = $haChecksums | Where-Object { $_.serial_no -eq $haPeer.serial_no }

                            # Correctly using the if statement for assignment
                            $manageMaster = if ($haChecksum.is_manage_master -eq 1) { "Yes" } else { "No" }
                            $rootMaster = if ($haChecksum.is_root_master -eq 1) { "Yes" } else { "No" }

                            # Correctly reference properties from $haPeer
                            $OutObj += [pscustomobject]@{
                                "Hostname" = $haPeer.hostname
                                "Serial" = $haPeer.serial_no
                                "Priority" = $haPeer.priority
                                "Manage Master" = $manageMaster
                                "Root Master" = $rootMaster
                            }
                        }

                        $TableParams = @{
                            Name = "HA Members"
                            List = $false
                            ColumnWidths = 35, 35, 10, 10, 10
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

    end {

    }

}