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

            $Address = Get-FGTFirewallAddress -meta
            $Group = Get-FGTFirewallAddressGroup -meta
            $IPPool = Get-FGTFirewallIPPool -meta
            $VIP = Get-FGTFirewallVip -meta
            $Policy = Get-FGTFirewallPolicy -meta
            $fqdn = (invoke-FGTRestMethod -uri "api/v2/monitor/firewall/address-fqdns").results.psobject.properties.value

            if ($InfoLevel.Firewall -ge 1) {
                Section -Style Heading3 'Summary' {
                    Paragraph "The following section provides a summary of firewall settings."
                    BlankLine
                    $address_count = @($Address).count
                    $address_text = "$address_count"
                    if ($address_count) {
                        $address_no_ref = ($address | Where-Object { $_.q_ref -eq 0 }).count
                        $address_no_ref_pourcentage = [math]::Round(($address_no_ref / $address_count * 100), 2)
                        $address_text += " (Not use: $address_no_ref / $address_no_ref_pourcentage%)"
                    }

                    $group_count = @($group).count
                    $group_text = "$group_count"
                    if ($group_count) {
                        $group_no_ref = ($group | Where-Object { $_.q_ref -eq 0 }).count
                        $group_no_ref_pourcentage = [math]::Round(($group_no_ref / $group_count * 100), 2)
                        $group_text += " (Not use: $group_no_ref / $group_no_ref_pourcentage%)"
                    }

                    $ippool_count = @($ippool).count
                    $ippool_text = "$ippool_count"
                    if ($ippool_count) {
                        $ippool_no_ref = ($ippool | Where-Object { $_.q_ref -eq 0 }).count
                        $ippool_no_ref_pourcentage = [math]::Round(($ippool_no_ref / $ippool_count * 100), 2)
                        $ippool_text += " (Not use: $ippool_no_ref / $ippool_no_ref_pourcentage%)"
                    }

                    $vip_count = @($vip).count
                    $vip_text = "$vip_count"
                    if ($vip_count) {
                        $vip_no_ref = ($vip | Where-Object { $_.q_ref -eq 0 }).count
                        $vip_no_ref_pourcentage = [math]::Round(($vip_no_ref / $vip_count * 100), 2)
                        $vip_text += " (Not use: $vip_no_ref / $vip_no_ref_pourcentage%)"
                    }
                    $policy_count = @($policy).count
                    $policy_text = "$policy_count"
                    if ($policy_count) {
                        $policy_disable = ($policy | Where-Object { $_.status -eq "disable" }).count
                        $policy_text += " (Disabled: $policy_disable)"
                    }

                    $fqdn_count = @($fqdn).count
                    $fqdn_text = "$fqdn_count"
                    if ($fqdn_count) {
                        $fqdn_unresolved = ($fqdn | Where-Object { $_.addrs.count -eq 0 }).count
                        $fqdn_text += " (Unresolved: $fqdn_unresolved)"
                    }

                    $OutObj = [pscustomobject]@{
                        "Address"    = $address_text
                        "Group"      = $group_text
                        "IP Pool"    = $ippool_text
                        "Virtual IP" = $vip_text
                        "Policy"     = $policy_text
                        "FQDN"       = $fqdn_text
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

            if ($Address -and $InfoLevel.Firewall -ge 1) {
                Section -Style Heading3 'Address' {
                    $OutObj = @()

                    foreach ($add in $Address) {

                        switch ( $add.type ) {
                            "ipmask" {
                                $value = $(if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $add.subnet } else { $add.subnet.Replace(' ', '/') })
                            }
                            "iprange" {
                                $value = $add.'start-ip' + "-" + $add.'end-ip'
                            }
                            "geography" {
                                $value = $add.country
                            }
                            "fqdn" {
                                $value = $add.fqdn
                            }
                            "mac" {
                                $value = $add.macaddr.macaddr -join ", "
                            }
                            "dynamic" {
                                $value = $add.filter
                            }
                            "interface-subnet" {
                                $value = $(if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $add.subnet } else { $add.subnet.Replace(' ', '/') })
                            }
                            default {
                                $value = "Unknown Type"
                            }

                        }

                        $OutObj += [pscustomobject]@{
                            "Name"      = $add.name
                            "Type"      = $add.type
                            "Value"     = $value
                            "Interface" = $add.'associated-interface'
                            "Comment"   = $add.comment
                            "ref"       = $add.q_ref
                        }
                    }

                    $TableParams = @{
                        Name         = "Address"
                        List         = $false
                        ColumnWidths = 25, 10, 30, 10, 20, 5
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($Group -and $InfoLevel.Firewall -ge 1) {
                Section -Style Heading3 'Address Group' {
                    $OutObj = @()

                    foreach ($grp in $Group) {

                        $OutObj += [pscustomobject]@{
                            "Name"    = $grp.name
                            "Member"  = $grp.member.name -join ", "
                            "Comment" = $grp.comment
                            "Ref"     = $grp.q_ref
                        }
                    }

                    $TableParams = @{
                        Name         = "Address Group"
                        List         = $false
                        ColumnWidths = 20, 55, 20, 5
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($IPPool -and $InfoLevel.Firewall -ge 1) {
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
                            "Ref"             = $ip.q_ref
                        }
                    }

                    $TableParams = @{
                        Name         = "Virtual IP"
                        List         = $false
                        ColumnWidths = 14, 14, 12, 11, 11, 11, 11, 11, 5
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($VIP -and $InfoLevel.Firewall -ge 1) {
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
                            "Ref"           = $virtualip.q_ref
                        }
                    }

                    $TableParams = @{
                        Name         = "Virtual IP"
                        List         = $false
                        ColumnWidths = 14, 14, 12, 11, 11, 11, 11, 11, 5
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($fqdn -and $InfoLevel.Firewall -ge 1) {
                Section -Style Heading3 'FQDN' {
                    $OutObj = @()

                    foreach ($f in $fqdn) {

                        if ($f.addrs.count -eq 0) {
                            $addr = "Unresolved"
                        } else {
                            $addr = $f.addrs -join ", "
                        }
                        $OutObj += [pscustomobject]@{
                            "Name"      = $f.fqdn
                            "Addresses" = $addr
                            "wildcard"  = $f.wildcard
                        }
                    }

                    $TableParams = @{
                        Name         = "FQDN"
                        List         = $false
                        ColumnWidths = 25, 65, 10
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($Policy -and $InfoLevel.Firewall -ge 1) {
                Section -Style Heading3 'Policy Summary' {
                    Paragraph "The following section provides a policy summary of firewall settings."
                    BlankLine
                    $policy_count = @($Policy).count

                    $policy_status = @($Policy | Where-Object { $_.status -eq 'enable' }).count
                    $status_text = "$policy_status"
                    if ($policy_count) {
                        $status_pourcentage = [math]::Round(($policy_status / $policy_count * 100), 2)
                        $status_text += " ($status_pourcentage%)"
                    }

                    $policy_deny = @($Policy | Where-Object { $_.action -eq 'deny' }).count
                    $deny_text = "$policy_deny"
                    if ($policy_count) {
                        $deny_pourcentage = [math]::Round(($policy_deny / $policy_count * 100), 2)
                        $deny_text += " ($deny_pourcentage%)"
                    }

                    $policy_nat = @($Policy | Where-Object { $_.nat -eq 'enable' }).count
                    $nat_text = "$policy_nat"
                    if ($policy_count) {
                        $nat_pourcentage = [math]::Round(($policy_nat / $policy_count * 100), 2)
                        $nat_text += " ($nat_pourcentage%)"
                    }

                    $policy_log_all = @($Policy | Where-Object { $_.logtraffic -eq 'all' }).count
                    $log_text = "All: $policy_log_all"
                    if ($policy_count) {
                        $log_pourcentage = [math]::Round(($policy_log_all / $policy_count * 100), 2)
                        $log_text += " ($log_pourcentage%)"
                    }

                    $policy_log_utm = @($Policy | Where-Object { $_.logtraffic -eq 'utm' }).count
                    $log_text += " UTM: $policy_log_utm"
                    if ($policy_count) {
                        $log_pourcentage = [math]::Round(($policy_log_utm / $policy_count * 100), 2)
                        $log_text += " ($log_pourcentage%)"
                    }

                    $policy_log_disable = @($Policy | Where-Object { $_.logtraffic -eq 'disable' }).count
                    $log_text += " Disable: $policy_log_disable"
                    if ($policy_count) {
                        $log_pourcentage = [math]::Round(($policy_log_disable / $policy_count * 100), 2)
                        $log_text += " ($log_pourcentage%)"
                    }

                    $policy_unnamed = @($Policy | Where-Object { $_.name -eq '' }).count
                    $unnamed_text = "$policy_unnamed"
                    if ($policy_count) {
                        $unnamed_pourcentage = [math]::Round(($policy_unnamed / $policy_count * 100), 2)
                        $unnamed_text += " ($unnamed_pourcentage%)"
                    }

                    $policy_comments = @($Policy | Where-Object { $_.comments -ne '' }).count
                    $comments_text = "$policy_comments"
                    if ($policy_count) {
                        $comments_pourcentage = [math]::Round(($policy_comments / $policy_count * 100), 2)
                        $comments_text += " ($comments_pourcentage%)"
                    }

                    #Policy with comments contains Copy, Clone or Reverse
                    $policy_comments_ccr = @($Policy | Where-Object { $_.comments -like "*copy*" -or $_.comments -like "*clone*" -or $_.comments -like "*reverse*" }).count
                    $comments_ccr_text = "$policy_comments_ccr"
                    if ($policy_comments) {
                        $comments_ccr_pourcentage = [math]::Round(($policy_comments_ccr / $policy_comments * 100), 2)
                        $comments_ccr_text += " ($comments_ccr_pourcentage%)"
                    }

                    $policy_no_inspection = @($Policy | Where-Object { $_.'ssl-ssh-profile' -eq '' -or $_.'ssl-ssh-profile' -eq 'no-inspection' }).count
                    $policy_inspection = $policy_count - $policy_no_inspection
                    $inspection_text = "$policy_inspection"
                    if ($policy_count) {
                        $inspection_pourcentage = [math]::Round(($policy_inspection / $policy_count * 100), 2)
                        $inspection_text += " ($inspection_pourcentage%)"
                    }

                    $from_ssl = @($Policy | Where-Object { $_.srcintf.name -like 'ssl.*' }).count
                    $from_ssl_with_nat = @($Policy | Where-Object { $_.srcintf.name -like 'ssl.*' -and $_.nat -eq "enable" }).count
                    $from_ssl_disabled = @($Policy | Where-Object { $_.srcintf.name -like 'ssl.*' -and $_.status -eq "disable" }).count
                    $from_ssl_text = "$from_ssl"
                    if ($policy_count) {
                        $from_ssl_pourcentage = [math]::Round(($from_ssl / $policy_count * 100), 2)
                        $from_ssl_text += " ($from_ssl_pourcentage%)"
                    }
                    $from_ssl_text += " (With NAT: $from_ssl_with_nat, Disabled: $from_ssl_disabled)"

                    $to_ssl = @($Policy | Where-Object { $_.dstintf.name -like 'ssl.*' }).count
                    $to_ssl_with_nat = @($Policy | Where-Object { $_.dstintf.name -like 'ssl.*' -and $_.nat -eq "enable" }).count
                    $to_ssl_disabled = @($Policy | Where-Object { $_.dstintf.name -like 'ssl.*' -and $_.status -eq "disable" }).count
                    $to_ssl_text = "$to_ssl"
                    if ($policy_count) {
                        $to_ssl_pourcentage = [math]::Round(($to_ssl / $policy_count * 100), 2)
                        $to_ssl_text += " ($to_ssl_pourcentage%)"
                    }
                    $to_ssl_text += " (With NAT: $to_ssl_with_nat, Disabled: $to_ssl_disabled)"


                    $OutObj = [pscustomobject]@{
                        "Policy"                                 = $policy_count
                        "Enabled"                                = $status_text
                        "Deny"                                   = $deny_text
                        "NAT"                                    = $nat_text
                        "Logging"                                = $log_text
                        "Unnamed"                                = $unnamed_text
                        "Comments"                               = $comments_text
                        "Comments (with Copy, Clone or Reverse)" = $comments_ccr_text
                        "SSL/SSH Inspection"                     = $inspection_text
                        "From VPN SSL"                           = $from_ssl_text
                        "To VPN SSL"                             = $to_ssl_text
                    }

                    $TableParams = @{
                        Name         = "Policy Summary"
                        List         = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }

                Section -Style Heading3 'Policy' {
                    #get Sequence Grouping (global-label) if there is no label don't display by Sequence Grouping... (it is the same like normal)
                    $labels = $Policy.'global-label'
                    #Policy With Sequence Grouping (Global Label)
                    if ($Options.PolicyLayout -eq "all" -or $Options.PolicyLayout -eq "sequencegrouping" -and (($labels | Get-Unique).count -ge "2") ) {
                        Section -Style Heading3 'Policy - Sequence Grouping' {
                            $OutObj = @()

                            foreach ($rule in $Policy) {

                                # There is a global-label (Sequence), Create a new table
                                if ($rule.'global-label') {
                                    #If there is already label before add the end of table
                                    if ($label) {
                                        Section -Style NOTOCHeading4 -ExcludeFromTOC  "Policy - $label" {
                                            $TableParams = @{
                                                Name         = "Policy - $label"
                                                List         = $false
                                                ColumnWidths = 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
                                            }

                                            if ($Report.ShowTableCaptions) {
                                                $TableParams['Caption'] = "- $($TableParams.Name)"
                                            }

                                            $OutObj | Table @TableParams
                                        }
                                    }
                                    #Reset the table and set label for next table
                                    $OutObj = @()
                                    $label = $rule.'global-label'
                                }

                                #Using ISDB for Destination ?
                                if ($rule.'internet-service' -eq "enable") {

                                    $dst = $rule.'internet-service-name'.name -join ", "
                                } else {
                                    $dst = $rule.dstaddr.name -join ", "
                                }

                                #Using ISDB for Source ?
                                if ($rule.'internet-service-src ' -eq "enable") {

                                    $src = $rule.'internet-service-src-name'.name -join ", "
                                } else {
                                    $src = $rule.srcaddr.name -join ", "
                                }

                                $OutObj += [pscustomobject]@{
                                    "Name"        = $rule.name
                                    "From"        = $rule.srcintf.name -join ", "
                                    "To"          = $rule.dstintf.name -join ", "
                                    "Source"      = $src
                                    "Destination" = $dst
                                    "Service"     = $rule.service.name -join ", "
                                    "Action"      = $rule.action
                                    "NAT"         = $rule.nat
                                    "Log"         = $rule.logtraffic
                                    "Comments"    = $rule.comments
                                }
                            }

                            #last Table
                            Section -Style NOTOCHeading4 -ExcludeFromTOC  "Policy - $label" {
                                $TableParams = @{
                                    Name         = "Policy - $label"
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

                    #Policy sorted by default (id)
                    if ($Options.PolicyLayout -eq "all" -or $Options.PolicyLayout -eq "normal" ) {
                        Section -Style Heading3 'Policy - Normal' {

                            $OutObj = @()

                            foreach ($rule in $Policy) {

                                #Using ISDB for Destination ?
                                if ($rule.'internet-service' -eq "enable") {
                                    $dst = $rule.'internet-service-name'.name -join ", "
                                } else {
                                    $dst = $rule.dstaddr.name -join ", "
                                }

                                #Using ISDB for Source ?
                                if ($rule.'internet-service-src ' -eq "enable") {

                                    $src = $rule.'internet-service-src-name'.name -join ", "
                                } else {
                                    $src = $rule.srcaddr.name -join ", "
                                }

                                $OutObj += [pscustomobject]@{
                                    "Name"        = $rule.name
                                    "From"        = $rule.srcintf.name -join ", "
                                    "To"          = $rule.dstintf.name -join ", "
                                    "Source"      = $src
                                    "Destination" = $dst
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

                    #Policy sorted by interface pair
                    if ($Options.PolicyLayout -eq "all" -or $Options.PolicyLayout -eq "interfacepair" ) {

                        Section -Style Heading3 'Policy - Interface Pair ' {
                            $srcintf = $Policy.srcintf.name | Sort-Object | Get-Unique
                            $dstintf = $Policy.dstintf.name | Sort-Object | Get-Unique

                            foreach ($int_src in $srcintf) {
                                foreach ($int_dst in $dstintf) {
                                    $OutObj = @()

                                    foreach ($rule in $Policy) {

                                        if ($rule.srcintf.name -eq $int_src -and $rule.dstintf.name -eq $int_dst) {
                                            #Using ISDB for Destination ?
                                            if ($rule.'internet-service' -eq "enable") {
                                                $dst = $rule.'internet-service-name'.name -join ", "
                                            } else {
                                                $dst = $rule.dstaddr.name -join ", "
                                            }

                                            #Using ISDB for Source ?
                                            if ($rule.'internet-service-src ' -eq "enable") {

                                                $src = $rule.'internet-service-src-name'.name -join ", "
                                            } else {
                                                $src = $rule.srcaddr.name -join ", "
                                            }

                                            $OutObj += [pscustomobject]@{
                                                "Name"        = $rule.name
                                                "Source"      = $src
                                                "Destination" = $dst
                                                "Service"     = $rule.service.name -join ", "
                                                "Action"      = $rule.action
                                                "NAT"         = $rule.nat
                                                "Log"         = $rule.logtraffic
                                                "Comments"    = $rule.comments
                                            }
                                        }

                                    }

                                    #if there is OutObj
                                    if ($OutObj) {
                                        $interfacepair = "$($int_src) => $($int_dst)"
                                        Section -Style Heading4 "Policy: $interfacepair" {
                                            $TableParams = @{
                                                Name         = "Policy - $interfacepair"
                                                List         = $false
                                                ColumnWidths = 15, 15, 15, 10, 10, 10, 10, 15
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

                    }
                }
            }

            $MonitorRules = Get-FGTMonitorFirewallPolicy
            if ($MonitorRules -and $InfoLevel.Firewall -ge 1) {

                $monitor_result = @()
                $now = [int64](Get-Date -UFormat %s)
                $one_day = 86400        # 1 day en seconds
                $seven_days = 604800    # 7 day en seconds
                $thirty_days = 2592000  # 30 day en seconds

                foreach ($monitor in $MonitorRules) {

                    #Skip the policy id 0 (Implicit Deny)
                    if ($monitor.policyid -eq "0 ") {
                        continue;
                    }
                    $last_policy_use = "Never"
                    $now_minus_one_day = $now - $one_day
                    $now_minus_seven_days = $now - $seven_days
                    $now_minus_thirty_days = $now - $thirty_days
                    if ($monitor.last_used -ge $now_minus_thirty_days) {
                        $last_policy_use = "Last Month"
                    }
                    if ($monitor.last_used -ge $now_minus_seven_days) {
                        $last_policy_use = "Last Week"
                    }
                    if ($monitor.last_used -ge $now_minus_one_day) {
                        $last_policy_use = "Last Day"
                    }

                    $rule = $policy | Where-Object { $_.policyid -eq $monitor.policyid }

                    #Using ISDB for Destination ?
                    if ($rule.'internet-service' -eq "enable") {

                        $dst = $rule.'internet-service-name'.name -join ", "
                    } else {
                        $dst = $rule.dstaddr.name -join ", "
                    }

                    $dst += " (To $($rule.dstintf.name -join ", "))"

                    #Using ISDB for Source ?
                    if ($rule.'internet-service-src ' -eq "enable") {

                        $src = $rule.'internet-service-src-name'.name -join ", "
                    } else {
                        $src = $rule.srcaddr.name -join ", "
                    }
                    $src += " (From $($rule.srcintf.name -join ', '))"

                    $monitor_result += [pscustomobject]@{
                        "Id"          = $rule.policyid
                        "Name"        = $rule.name
                        "Source"      = $src
                        "Destination" = $dst
                        "Service"     = $rule.service.name -join ", "
                        "Action"      = $rule.action
                        "Hit"         = $monitor.hit_count
                        "Usage"       = $last_policy_use
                    }
                }

                Section -Style Heading3 'Usage Policy Summary' {
                    Paragraph "The following section provides an usage policy summary of firewall."
                    BlankLine
                    $usage_count = @($monitor_result).count

                    $never_status = @($monitor_result | Where-Object { $_.usage -eq 'Never' }).count
                    $never_text = "$never_status"
                    if ($usage_count) {
                        $never_pourcentage = [math]::Round(($never_status / $usage_count * 100), 2)
                        $never_text += " ($never_pourcentage%)"
                    }

                    $thirty_status = @($monitor_result | Where-Object { $_.usage -eq 'Last Month' }).count
                    $thirty_text = "$thirty_status"
                    if ($usage_count) {
                        $thirty_pourcentage = [math]::Round(($thirty_status / $usage_count * 100), 2)
                        $thirty_text += " ($thirty_pourcentage%)"
                    }

                    $seven_status = @($monitor_result | Where-Object { $_.usage -eq 'Last Week' }).count
                    $seven_text = "$seven_status"
                    if ($usage_count) {
                        $seven_pourcentage = [math]::Round(($seven_status / $usage_count * 100), 2)
                        $seven_text += " ($seven_pourcentage%)"
                    }

                    $one_status = @($monitor_result | Where-Object { $_.usage -eq 'Last Day' }).count
                    $one_text = "$one_status"
                    if ($usage_count) {
                        $one_pourcentage = [math]::Round(($one_status / $usage_count * 100), 2)
                        $one_text += " ($one_pourcentage%)"
                    }

                    $OutObj = [pscustomobject]@{
                        "Never"       = $never_text
                        "Last 30 Day" = $thirty_text
                        "Last 7 Day"  = $seven_text
                        "Last 1 day"  = $one_text
                    }

                    $TableParams = @{
                        Name         = "Usage Policy Summary"
                        List         = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }

                $usages = $monitor_result | Where-Object { $_.usage -eq 'Never' }

                if ($usages) {
                    Section -Style Heading3 'Usage Policy (Never)' {
                        $OutObj = @()


                        foreach ($usage in $usages) {
                            $OutObj += [pscustomobject]@{
                                "Id"          = $usage.id
                                "Name"        = $usage.name
                                "Source"      = $usage.source
                                "Destination" = $usage.destination
                                "Service"     = $usage.service
                                "Action"      = $usage.action
                                "Hit"         = $usage.hit
                            }
                        }

                        $TableParams = @{
                            Name         = "Usage Policy (Never)"
                            List         = $false
                            ColumnWidths = 5, 10, 29, 29, 10, 8, 9
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }
                }

                $usages = $monitor_result | Where-Object { $_.usage -eq 'Last Month' }

                if ($usages) {
                    Section -Style Heading3 'Usage Policy (1 Month)' {
                        $OutObj = @()

                        foreach ($usage in $usages) {
                            $OutObj += [pscustomobject]@{
                                "Id"          = $usage.id
                                "Name"        = $usage.name
                                "Source"      = $usage.source
                                "Destination" = $usage.destination
                                "Service"     = $usage.service
                                "Action"      = $usage.action
                                "Hit"         = $usage.hit
                            }
                        }

                        $TableParams = @{
                            Name         = "Usage Policy (1 Month)"
                            List         = $false
                            ColumnWidths = 5, 10, 29, 29, 10, 8, 9
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }
                }

                $usages = $monitor_result | Where-Object { $_.usage -eq 'Last Week' }

                if ($usages) {
                    Section -Style Heading3 'Usage Policy (1 Week)' {
                        $OutObj = @()

                        foreach ($usage in $usages) {
                            $OutObj += [pscustomobject]@{
                                "Id"          = $usage.id
                                "Name"        = $usage.name
                                "Source"      = $usage.source
                                "Destination" = $usage.destination
                                "Service"     = $usage.service
                                "Action"      = $usage.action
                                "Hit"         = $usage.hit
                            }
                        }

                        $TableParams = @{
                            Name         = "Usage Policy (1 Week)"
                            List         = $false
                            ColumnWidths = 5, 10, 29, 29, 10, 8, 9
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }
                }

                $usages = $monitor_result | Where-Object { $_.usage -eq 'Last Day' }

                if ($usages) {
                    Section -Style Heading3 'Usage Policy (1 Day)' {
                        $OutObj = @()

                        foreach ($usage in $usages) {
                            $OutObj += [pscustomobject]@{
                                "Id"          = $usage.id
                                "Name"        = $usage.name
                                "Source"      = $usage.source
                                "Destination" = $usage.destination
                                "Service"     = $usage.service
                                "Action"      = $usage.action
                                "Hit"         = $usage.hit
                            }
                        }

                        $TableParams = @{
                            Name         = "Usage Policy (1 day)"
                            List         = $false
                            ColumnWidths = 5, 10, 29, 29, 10, 8, 9
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