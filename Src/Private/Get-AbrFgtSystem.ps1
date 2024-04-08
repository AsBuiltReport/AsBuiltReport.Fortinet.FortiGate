
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
                        "Nom"                       = $info.'hostname'
                        "Alias"                     = $info.'alias'
                        "Recurring Reboot"          = $reboot
                        "Port SSH"                  = $info.'admin-ssh-port'
                        "Port HTTP"                 = $info.'admin-port'
                        "Port HTTPS"                = $info.'admin-sport'
                        "HTTPS Redirect"            = $info.'admin-https-redirect'
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
                        $trustedHosts += $admin.trusthost3 +  "`n"
                        $trustedHosts += $admin.trusthost4 +  "`n"
                        $trustedHosts += $admin.trusthost5 +  "`n"
                        $trustedHosts += $admin.trusthost6 + "`n"
                        $trustedHosts += $admin.trusthost7 +  "`n"
                        $trustedHosts += $admin.trusthost8 +  "`n"
                        $trustedHosts += $admin.trusthost9 + "`n"
                        $trustedHosts += $admin.trusthost10 +  "`n"

                        $trustedHosts = $trustedHosts -replace "0.0.0.0 0.0.0.0`n", "" #Remove 'All Network'
                        if($trustedHosts -eq ""){
                            $trustedHosts = "All" #TODO: Add Health Warning !
                        }
                        $OutObj += [pscustomobject]@{
                            "Name"          = $admin.name
                            "Profile"       = $admin.accprofile
                            "Trusted Hosts" = $trustedHosts
                        }
                    }

                    $TableParams = @{
                        Name         = "Administrator"
                        List         = $false
                        ColumnWidths = 30, 30, 40
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            $interfaces = Get-FGTSystemInterface

            # Filter interfaces by VDOM if specified
            if ("" -ne $Options.vdom) {
                $interfaces = $interfaces | Where-Object { $_.vdom -eq $Options.vdom }
            }

            if ($interfaces -and $InfoLevel.System -ge 1) {
                Section -Style Heading3 'Interfaces' {
                    Paragraph "The following section details FortiGate interfaces, grouped by interface type."
                    BlankLine
                    Paragraph "Please note the following assumptions, where applicable:"
                    Paragraph "1. Roles and MTU are considered 'default' if not explicitly specified."
                    Paragraph "2. Interface IP Addressing mode is assumed to be Static if not explicitly specified."
                    Paragraph "3. Secondary IP addresses are not shown if not explicitly assigned."
                    Paragraph "4. Interfaces are assumed to be in the global/root VDOM if not explicitly specified."
                    Paragraph "5. Interface speed is assumed to be 'auto' if not explicitly specified." 
                    BlankLine                    
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
                                $interface.ip = $interface.ip -eq '0.0.0.0 0.0.0.0' ? '' : $interface.ip.Replace(' ', "`n/")
                                $interface.'secondaryip' = $interface.'secondary-ip' -ne 'disable' ? $($interface.'secondaryip').Replace(' ', '/') : ""
                                $interface.mode = $interface.mode -eq 'static' ? '' : $interface.mode              
                                $interface.vdom = $interface.vdom -eq 'root' ? '' : $interface.vdom
                                $interface.vlanid = ($interface.vlanid -gt 0 ) ? $interface.vlanid : ""
                                $interface.speed = $interface.speed -eq 'auto' ? '' : $interface.speed
                                $interface.'remote-ip' = $interface.'remote-ip' -eq '0.0.0.0 0.0.0.0' ? '' : $interface.'remote-ip'
                             

                                switch ($interfaceType) {
                                    "Aggregate" {
                                        $OutObj += [pscustomobject]@{
                                            "Name"                = $interface.name
                                            "VDOM"                = $interface.vdom
                                            "Role"                = $interface.role
                                            "Members"             = $interface.member
                                            "LACP Mode"           = $interface.'lacp-mode'
                                            "MTU"                 = $interface.mtu
                                            "Addressing mode"     = $interface.mode
                                            "IP Address"          = $interface.ip
                                            "Secondary IP"        = $interface.'secondaryip'                                       
                                            "Allow Access"        = $interface.allowaccess
                                            "Status"              = $interface.status
                                            "Comments"            = $interface.description
                                        }
                                    }
                                    "hard-switch" {
                                        $OutObj += [pscustomobject]@{
                                            "Name"                = $interface.name
                                            "VDOM"                = $interface.vdom                                            
                                            "Role"                = $interface.role
                                            "Members"             = $interface.member
                                            "MTU"                 = $interface.mtu
                                            "Addressing mode"     = $interface.mode
                                            "IP Address"          = $interface.ip
                                            "Secondary IP"        = $interface.'secondaryip'
                                            "Allow Access"        = $interface.allowaccess
                                            "Status"              = $interface.status
                                            "Comments"            = $interface.description
                                        }
                                    }
                                    "loopback" {
                                        $OutObj += [pscustomobject]@{
                                            "Name"                = $interface.name
                                            "VDOM"                = $interface.vdom                                            
                                            "Role"                = $interface.role
                                            "MTU"                 = $interface.mtu
                                            "IP Address"          = $interface.ip
                                            "Secondary IP"        = $interface.'secondaryip'
                                            "Allow Access"        = $interface.allowaccess
                                            "Status"              = $interface.status
                                            "Comments"            = $interface.description
                                        }                                        

                                    }
                                    "physical"{
                                        $OutObj += [pscustomobject]@{
                                            "Name"                = $interface.name
                                            "VDOM"                = $interface.vdom                                            
                                            "Role"                = $interface.role
                                            "MTU"                 = $interface.mtu
                                            "Speed"               = $interface.speed
                                            "Addressing mode"     = $interface.mode
                                            "IP Address"          = $interface.ip
                                            "Secondary IP"        = $interface.'secondaryip'
                                            "Allow Access"        = $interface.allowaccess
                                            "Status"              = $interface.status
                                            "Comments"            = $interface.description
                                        }                                        

                                    }
                                    "tunnel" {
                                        $OutObj += [pscustomobject]@{
                                            "Name"                = $interface.name
                                            "Parent Interface"    = $interface.interface
                                            "VDOM"                = $interface.vdom                                            
                                            "Role"                = $interface.role
                                            "MTU"                 = $interface.mtu
                                            "IP Address"          = $interface.ip
                                            "Secondary IP"        = $interface.'secondaryip'
                                            "Remote IP"           = $interface.'remote-ip'
                                            "Allow Access"        = $interface.allowaccess
                                            "Status"              = $interface.status
                                            "Comments"            = $interface.description
                                        }    
                                    }
                                    "vlan" {
                                        $OutObj += [pscustomobject]@{
                                            "Name"                = $interface.name
                                            "Parent Interface"    = $interface.interface
                                            "VLAN ID"             = $interface.vlanid
                                            "VDOM"                = $interface.vdom                                            
                                            "Role"                = $interface.role
                                            "MTU"                 = $interface.mtu
                                            "Mode"                = $interface.mode
                                            "IP Address"          = $interface.ip
                                            "Secondary IP"        = $interface.'secondaryip'                                            
                                            "Allow Access"        = $interface.allowaccess
                                            "Status"              = $interface.status
                                        }
                                    }
                                    # vap-switch falls under default
                                    Default {
                                        $OutObj += [pscustomobject]@{
                                            "Name"                = $interface.name
                                            "VDOM"                = $interface.vdom                                            
                                            "Role"                = $interface.role
                                            "MTU"                 = $interface.mtu
                                            "VLAN ID"             = $interface.vlanid
                                            "Mode"                = $interface.mode
                                            "IP Address"          = $interface.ip
                                            "Secondary IP"        = $interface.'secondaryip'                                            
                                            "Allow Access"        = $interface.allowaccess
                                            "Status"              = $interface.status
                                        }
                                    }
                                }
                            }

                            # Identify and remove empty columns
                            $propertiesToRemove = @()
                            foreach ($prop in ($OutObj | Get-Member -MemberType NoteProperty).Name) {
                                $allEmpty = $True
                                foreach ($obj in $OutObj) {
                                    if (![string]::IsNullOrWhiteSpace($obj.$prop)) {
                                        $allEmpty = $False
                                        break
                                    }
                                }
                                if ($allEmpty) {
                                    $propertiesToRemove += $prop
                                }
                            }

                            $OutObj = $OutObj | ForEach-Object {
                                $obj = $_
                                foreach ($prop in $propertiesToRemove) {
                                    $obj.PSObject.Properties.Remove($prop)
                                }
                                $obj
                            }

                            # Introduction section for VLAN interfaces
                            $vlanUpCount = 0
                            $vlanDownCount = 0
                            if ($interfaceType -eq "VLAN") {
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

                            $TableParams = @{
                                Name         = "$interfaceType Interfaces"
                                List         = $false
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $OutObj | Table @TableParams
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

            # Fetch HA Configuration
            $haConfig = Get-FGTSystemHA
            $haPeers = Get-FGTMonitorSystemHAPeer
            $haChecksums = Get-FGTMonitorSystemHAChecksum

            if( $haConfig.mode -ne 'standalone' -and $infoLevel.System -ge 1) {
                Section -Style Heading3 'High Availability' {
                    Paragraph "The following section details HA settings."
                    BlankLine
                
                    Section -Style Heading4 'HA Configuration' {
                        $OutObj = @()
    
                        $OutObj = [pscustomobject]@{
                            "Group Name / ID / Mode" = $haConfig.'group-name'+' / '+$haConfig.'group-id'+' / '+$haConfig.mode
                            "HB Device" = $haConfig.'hbdev'
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
                            Name         = "HA Configuration"
                            List         = $true
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
                                "Serial"   = $haPeer.serial_no
                                "Priority" = $haPeer.priority
                                "Manage Master" = $manageMaster
                                "Root Master" = $rootMaster
                            }
                        }
                    
                        $TableParams = @{
                            Name         = "HA Members"
                            List         = $false
                            ColumnWidths = 30, 30, 10, 10, 10, 10
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
