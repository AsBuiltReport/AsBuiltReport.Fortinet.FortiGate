
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

                    $OutObj = [pscustomobject]@{
                        "Address"    = $address_text
                        "Group"      = $group_text
                        "IP Pool"    = $ippool_text
                        "Virtual IP" = $vip_text
                        "Policy"     = $policy_text
                    }

                    $TableParams = @{
                        Name         = "Summary"
                        List         = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
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

                    $OutObj | Table @TableParams
                }
            }

            if ($Address -and $InfoLevel.Firewall -ge 1) {
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
                            "Comment"   = $add.comment
                            "ref"       = $add.q_ref
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

                    $policy_comments = @($Policy | Where-Object { $_.comments -ne '' }).count
                    $comments_text = "$policy_comments"
                    if ($policy_count) {
                        $comments_pourcentage = [math]::Round(($policy_comments / $policy_count * 100), 2)
                        $comments_text += " ($comments_pourcentage%)"
                    }

                    $policy_no_inspection = @($Policy | Where-Object { $_.'ssl-ssh-profile' -eq '' -or $_.'ssl-ssh-profile' -eq 'no-inspection' }).count
                    $policy_inspection = $policy_count - $policy_no_inspection
                    $inspection_text = "$policy_inspection"
                    if ($policy_count) {
                        $inspection_pourcentage = [math]::Round(($policy_inspection / $policy_count * 100), 2)
                        $inspection_text += " ($inspection_pourcentage%)"
                    }

                    $OutObj = [pscustomobject]@{
                        "Policy"             = $policy_count
                        "Enabled"            = $status_text
                        "Deny"               = $deny_text
                        "NAT"                = $nat_text
                        "Logging"            = $log_text
                        "Unnamed"            = $unnamed_text
                        "Comments"           = $comments_text
                        "SSH/SSH Inspection" = $inspection_text
                    }

                    $TableParams = @{
                        Name         = "Policy Summary"
                        List         = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
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
                                
                                $OutObj | Table @TableParams
                            }
                        }
                    }

                    #Policy sorted by default (id)
                    if ($Options.PolicyLayout -eq "all" -or $Options.PolicyLayout -eq "normal" ) {
                        Section -Style Heading3 'Policy - Normal' {

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

                                            $OutObj += [pscustomobject]@{
                                                "Name"        = $rule.name
                                                "Source"      = $rule.srcaddr.name -join ", "
                                                "Destination" = $rule.dstaddr.name -join ", "
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
                                            
                                            $OutObj | Table @TableParams
                                        }
                                    }
                                }
                            }
                        }

                    }
                }
            }

        }
    }

    end {

    }

}
