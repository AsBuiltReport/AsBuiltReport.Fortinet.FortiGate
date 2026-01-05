function Get-AbrFgtVPNIPsec {
    <#
    .SYNOPSIS
        Used by As Built Report to returns VPN IPsec settings.
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
        Write-PScriboMessage "Discovering VPN IPsec settings information from $System."
    }

    process {

        Section -Style Heading2 'VPN IPsec' {
            Paragraph "The following section details VPN IPsec settings configured on FortiGate."
            BlankLine

            $vpn_ph1 = Get-FGTVpnIpsecPhase1Interface
            $vpn_ph1_schema = (Get-FGTVpnIpsecPhase1Interface -schema).children
            $vpn_ph2 = Get-FGTVpnIpsecPhase2Interface
            $vpn_ph2_schema = (Get-FGTVpnIpsecPhase2Interface -schema).children

            if ($InfoLevel.VPNIPsec -ge 1) {
                Section -Style Heading3 'Summary' {
                    Paragraph "The following section provides a summary of VPN IPsec settings."
                    BlankLine
                    $OutObj = [pscustomobject]@{
                        "VPN IPsec Phase 1" = @($vpn_ph1).count
                        "VPN IPsec Phase 2" = @($vpn_ph2).count
                    }

                    $TableParams = @{
                        Name = "Summary"
                        List = $true
                        ColumnWidths = 50, 50
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($vpn_ph1 -and $InfoLevel.VPNIPsec -ge 1) {
                Section -Style Heading3 'VPN IPsec Phase 1' {
                    Section -Style NOTOCHeading4 -ExcludeFromTOC 'Summary' {
                        $OutObj = @()

                        foreach ($v1 in $vpn_ph1) {

                            $OutObj += [pscustomobject]@{
                                "Name" = $v1.name
                                "Type" = $v1.type
                                "Interface" = $v1.interface
                                "Remote Gateway" = $v1.'remote-gw'
                                "Mode" = $v1.mode
                                "Auth method" = $v1.authmethod
                            }
                        }

                        $TableParams = @{
                            Name = "VPN IPsec Phase 1 Summary"
                            List = $false
                            ColumnWidths = 20, 16, 16, 16, 16, 16
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }

                    if ($vpn_ph1 -and $InfoLevel.VPNIPsec -ge 2) {

                        foreach ($v1 in $vpn_ph1) {
                            Section -Style Heading3 "Phase 1: $($v1.name)" {
                                BlankLine
                                $OutObj = @()

                                foreach ($properties in $v1.PSObject.properties) {
                                    $value = ""
                                    $name = $properties.name
                                    #Remove q_origin_key (the same of name and it is an internal parameter)
                                    if ($name -eq "q_origin_key") {
                                        continue
                                    }
                                    #Skip System Object array (display after with children)
                                    if ($properties.typeNameOfValue -ne "System.Object[]") {
                                        $value = [string]$properties.value
                                    }

                                    #Check the schema of $value
                                    if ($vpn_ph1_schema.PSObject.Properties.Name -contains $name) {
                                        if ($properties.typeNameOfValue -eq "System.Object[]") {
                                            $children = $vpn_ph1_schema.$name.children.PSObject.properties.name
                                            #Check if there is a value
                                            if ($v1.$name) {
                                                $value = $v1.$name.$children -join ", "
                                            }
                                        }
                                        #found the default value
                                        $default = $vpn_ph1_schema.$name.default
                                        if ($null -eq $default) {
                                            $default = ""
                                        }
                                    }

                                    #Format value (add comma) and default for specific parameters (dhgrp, proposal, signature-hash-alg)
                                    if ($name -eq "dhgrp" -or $name -eq "proposal" -or $name -eq "signature-hash-alg") {
                                        $value = $value -replace " ", ", "
                                        $default = $default -replace " ", ", "
                                    }

                                    $OutObj += [pscustomobject]@{
                                        "Name" = $name
                                        "Value" = $value
                                        "Default" = $default
                                    }
                                }

                                $TableParams = @{
                                    Name = "VPN IPsec Phase 1: $($v1.name)"
                                    List = $false
                                    ColumnWidths = 34, 33, 33
                                }

                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }

                                $OutObj | Where-Object { $_.value -ne $_.default } | Set-Style -Style Critical
                                $OutObj | Table @TableParams
                            }

                        }
                    }
                }

            }

            if ($vpn_ph2 -and $InfoLevel.VPNIPsec -ge 1) {
                Section -Style Heading3 'VPN IPsec Phase 2' {
                    Section -Style NOTOCHeading4 -ExcludeFromTOC 'Summary' {
                        $OutObj = @()

                        foreach ($v2 in $vpn_ph2) {
                            switch ($v2.'src-addr-type') {
                                "name" {
                                    $src = $v2.'src-name'
                                }
                                "subnet" {
                                    $src = $(if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $v2.'src-subnet' } else { $v2.'src-subnet' -replace " ", "/" })
                                }
                                default {}
                            }
                            switch ($v2.'dst-addr-type') {
                                "name" {
                                    $dst = $v2.'dst-name'
                                }
                                "subnet" {
                                    $dst = $(if ($Options.UseCIDRNotation) { Convert-AbrFgtSubnetToCIDR -Input $v2.'dst-subnet' } else { $v2.'dst-subnet' -replace " ", "/" })
                                }
                                default {}
                            }
                            $OutObj += [pscustomobject]@{
                                "Name" = $v2.name
                                "Phase 1 Name" = $v2.phase1name
                                "Source Address Type" = $v2.'src-addr-type'
                                "Source Address" = $src
                                "Destination Address Type" = $v2.'dst-addr-type'
                                "Destination Address" = $dst
                            }
                        }

                        $TableParams = @{
                            Name = "VPN IPsec Phase 1 Summary"
                            List = $false
                            ColumnWidths = 20, 16, 16, 16, 16, 16
                        }

                        if ($Report.ShowTableCaptions) {
                            $TableParams['Caption'] = "- $($TableParams.Name)"
                        }

                        $OutObj | Table @TableParams
                    }

                    if ($vpn_ph1 -and $InfoLevel.VPNIPsec -ge 2) {

                        foreach ($v2 in $vpn_ph2) {
                            Section -Style Heading3 "Phase 2: $($v2.name) ($($v2.phase1name))" {
                                BlankLine
                                $OutObj = @()

                                foreach ($properties in $v2.PSObject.properties) {
                                    $value = ""
                                    $name = $properties.name
                                    #Remove q_origin_key (the same of name and it is an internal parameter)
                                    if ($name -eq "q_origin_key") {
                                        continue
                                    }
                                    #Skip System Object array (display after with children)
                                    if ($properties.typeNameOfValue -ne "System.Object[]") {
                                        $value = [string]$properties.value
                                    }

                                    #Check the schema of $value
                                    if ($vpn_ph2_schema.PSObject.Properties.Name -contains $name) {
                                        if ($properties.typeNameOfValue -eq "System.Object[]") {
                                            $children = $vpn_ph2_schema.$name.children.PSObject.properties.name
                                            #Check if there is a value
                                            if ($v2.$name) {
                                                $value = $v2.$name.$children -join ", "
                                            }
                                        }
                                        #found the default value
                                        $default = $vpn_ph2_schema.$name.default
                                        if ($null -eq $default) {
                                            $default = ""
                                        }
                                    }

                                    #Format value (add comma) and default for specific parameters (dhgrp, proposal))
                                    if ($name -eq "dhgrp" -or $name -eq "proposal") {
                                        $value = $value -replace " ", ", "
                                        $default = $default -replace " ", ", "
                                    }

                                    $OutObj += [pscustomobject]@{
                                        "Name" = $name
                                        "Value" = $value
                                        "Default" = $default
                                    }
                                }

                                $TableParams = @{
                                    Name = "VPN IPsec Phase 2: $($v2.name)"
                                    List = $false
                                    ColumnWidths = 34, 33, 33
                                }

                                if ($Report.ShowTableCaptions) {
                                    $TableParams['Caption'] = "- $($TableParams.Name)"
                                }

                                $OutObj | Where-Object { $_.value -ne $_.default } | Set-Style -Style Critical
                                $OutObj | Table @TableParams
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