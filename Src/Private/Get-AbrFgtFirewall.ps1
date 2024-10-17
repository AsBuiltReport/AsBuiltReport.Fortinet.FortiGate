
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
                $TableName = "Summary"
                Section -Style Heading3 $TableName {
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
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                }
            }

            if ($Address -and $InfoLevel.Firewall -ge 1) {
                $TableName = "Address"
                Section -Style Heading3 $TableName {
                    $OutObj = @()

                    foreach ($add in $Address) {

                        switch ( $add.type ) {
                            "ipmask" {
                                $value = $($add.subnet | ConvertTo-CIDR)
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
                            "Ref"       = $add.q_ref
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Type" = 10; "Ref" = 5;}
                }
            }

            if ($Group -and $InfoLevel.Firewall -ge 1) {
                $TableName = "Address Group"
                Section -Style Heading3 $TableName {
                    $OutObj = @()

                    foreach ($grp in $Group) {

                        $OutObj += [pscustomobject]@{
                            "Name"    = $grp.name
                            "Member"  = $grp.member.name -join ", "
                            "Comment" = $grp.comment
                            "Ref"     = $grp.q_ref
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Name" = 15; "Ref" = 5;}
                }
            }

            if ($IPPool -and $InfoLevel.Firewall -ge 1) {
                $TableName = "IP Pool"
                Section -Style Heading3 $TableName {
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
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Ref" = 5;}
                }
            }

            if ($VIP -and $InfoLevel.Firewall -ge 1) {
                $TableName = "Virtual IP"
                Section -Style Heading3 $TableName {
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
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Protocol" = 7; "Mapped Port" = 7; "Ref" = 5;}
                }
            }

            if ($Policy -and $InfoLevel.Firewall -ge 1) {
                $TableName = "Policy Summary"
                Section -Style Heading3 $TableName {
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

                    $OutObj = [pscustomobject]@{
                        "Policy"                                 = $policy_count
                        "Enabled"                                = $status_text
                        "Deny"                                   = $deny_text
                        "NAT"                                    = $nat_text
                        "Logging"                                = $log_text
                        "Unnamed"                                = $unnamed_text
                        "Comments"                               = $comments_text
                        "Comments (with Copy, Clone or Reverse)" = $comments_ccr_text
                        "SSH/SSH Inspection"                     = $inspection_text
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                    }

                $TableName = "Policy"
                Section -Style Heading3 $TableName{
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
                                        $tableName = "Policy - $label"
                                        Section -Style NOTOCHeading4 -ExcludeFromTOC  $tableName {
                                            Write-FormattedTable -InputObject $OutObj -TableName $tableName
                                        }
                                    }
                                    #Reset the table and set label for next table
                                    $OutObj = @()
                                    $label = $rule.'global-label'
                                }

                                #Using ISDB for Destination ?
                                if ($rule.'internet-service' -eq "enable") {

                                    $dst = $rule.'internet-service-name'.name -join ", "
                                }
                                else {
                                    $dst = $rule.dstaddr.name -join ", "
                                }

                                #Using ISDB for Source ?
                                if ($rule.'internet-service-src ' -eq "enable") {

                                    $src = $rule.'internet-service-src-name'.name -join ", "
                                }
                                else {
                                    $src = $rule.srcaddr.name -join ", "
                                }

                                $OutObj += [pscustomobject]@{
                                    "ID"          = $rule.policyid
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
                            $tableName = "Policy - $label"
                            Section -Style NOTOCHeading4 -ExcludeFromTOC  $tableName {
                                Write-FormattedTable -InputObject $OutObj -TableName $tableName
                            }
                        }
                    }

                    #Policy sorted by default (id)
                    if ($Options.PolicyLayout -eq "all" -or $Options.PolicyLayout -eq "normal" ) {
                        $TableName = "Policy - Normal"
                        Section -Style Heading3 $TableName {

                            $OutObj = @()

                            foreach ($rule in $Policy) {

                                #Using ISDB for Destination ?
                                if ($rule.'internet-service' -eq "enable") {
                                    $dst = $rule.'internet-service-name'.name -join ", "
                                }
                                else {
                                    $dst = $rule.dstaddr.name -join ", "
                                }

                                #Using ISDB for Source ?
                                if ($rule.'internet-service-src ' -eq "enable") {

                                    $src = $rule.'internet-service-src-name'.name -join ", "
                                }
                                else {
                                    $src = $rule.srcaddr.name -join ", "
                                }

                                $OutObj += [pscustomobject]@{
                                    "ID"          = $rule.policyid
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
                            Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"ID" = 5;}
                        }
                    }

                    #Policy sorted by interface pair
                    if ($Options.PolicyLayout -eq "all" -or $Options.PolicyLayout -eq "interfacepair" ) {
                        $TableName = "Policy - Interface Pair"
                        Section -Style Heading3 $TableName {
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
                                            }
                                            else {
                                                $dst = $rule.dstaddr.name -join ", "
                                            }

                                            #Using ISDB for Source ?
                                            if ($rule.'internet-service-src ' -eq "enable") {

                                                $src = $rule.'internet-service-src-name'.name -join ", "
                                            }
                                            else {
                                                $src = $rule.srcaddr.name -join ", "
                                            }

                                            $OutObj += [pscustomobject]@{
                                                "ID"          = $rule.policyid
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
                                            Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"ID" = 5;}
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