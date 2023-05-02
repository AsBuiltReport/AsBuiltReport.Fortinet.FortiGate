
function Get-AbrFgtUser {
    <#
    .SYNOPSIS
        Used by As Built Report to returns User settings.
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
        Write-PScriboMessage "Discovering user settings information from $System."
    }

    process {

        Section -Style Heading2 'User' {
            Paragraph "The following section details user settings configured on FortiGate."
            BlankLine

            $Users = Get-FGTUserLocal
            $Groups = Get-FGTUserGroup
            $LDAPS = Get-FGTUserLDAP
            $RADIUS = Get-FGTUserRADIUS
            $SAML = Get-FGTUserSAML

            if ($InfoLevel.User -ge 1) {
                Section -Style Heading3 'Summary' {
                    Paragraph "The following section provides a summary of user settings."
                    BlankLine
                    $OutObj = [pscustomobject]@{
                        "User"   = $Users.count
                        "Group"  = $Groups.count
                        "LDAP"   = $LDAPS.count
                        "RADIUS" = $RADIUS.count
                        "SAML"   = $SAML.count
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

            if ($Users -and $InfoLevel.User -ge 1) {
                Section -Style Heading3 'User Local' {
                    $OutObj = @()

                    foreach ($user in $Users) {

                        $OutObj += [pscustomobject]@{
                            "Name"          = $user.name
                            "Status"        = $user.status
                            "Password Time" = $user.'passwd-time'
                        }
                    }

                    $TableParams = @{
                        Name         = "User"
                        List         = $false
                        ColumnWidths = 34, 33, 33
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($Groups -and $InfoLevel.User -ge 1) {
                Section -Style Heading3 'User Group' {
                    $OutObj = @()

                    foreach ($grp in $Groups) {

                        $OutObj += [pscustomobject]@{
                            "Name"   = $grp.name
                            "Type"   = $grp.'group-type'
                            "Member" = $grp.member.name -join ", "
                            "Match"  = $grp.match.'group-name' -join ", "
                        }
                    }

                    $TableParams = @{
                        Name         = "User Group"
                        List         = $false
                        ColumnWidths = 25, 25, 25, 25
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($LDAPS -and $InfoLevel.User -ge 1) {
                Section -Style Heading3 'LDAP' {
                    $OutObj = @()

                    foreach ($ldap in $LDAPS) {

                        $OutObj += [pscustomobject]@{
                            "Name"   = $ldap.name
                            "Server" = $ldap.server + "/" + $ldap.'secondary-server'
                            "Port"   = $ldap.port
                            "CN"     = $ldap.cnid
                            "DN"     = $ldap.dn
                            "Type"   = $ldap.type
                            "User"   = $ldap.username
                        }
                    }

                    $TableParams = @{
                        Name         = "LDAP"
                        List         = $false
                        ColumnWidths = 14, 26, 12, 12, 12, 12, 12
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($RADIUS -and $InfoLevel.User -ge 1) {
                Section -Style Heading3 'RADIUS' {
                    $OutObj = @()

                    foreach ($rad in $RADIUS) {

                        $OutObj += [pscustomobject]@{
                            "Name"      = $rad.name
                            "Server"    = $rad.server + "/" + $rad.'secondary-server'
                            "Auth Type" = $rad.'auth-type'
                            "NAS-IP"    = $rad.'nas-ip'
                        }
                    }

                    $TableParams = @{
                        Name         = "RADIUS"
                        List         = $false
                        ColumnWidths = 20, 40, 20, 20
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams
                }
            }

            if ($SAML -and $InfoLevel.User -ge 1) {
                Section -Style Heading3 'SAML' {
                    $OutObj = @()

                    foreach ($sml in $SAML) {

                        $OutObj += [pscustomobject]@{
                            "Name"           = $sml.name
                            "Certificate"    = $sml.cert
                            "IdP Entity-ID"  = $sml.'idp-entity-id'
                            "IdP Certificat" = $sml.'idp-cert'
                        }

                    }

                    $TableParams = @{
                        Name         = "SAML"
                        List         = $false
                        ColumnWidths = 20, 20, 40, 20
                    }

                    if ($Report.ShowTableCaptions) {
                        $TableParams['Caption'] = "- $($TableParams.Name)"
                    }

                    $OutObj | Table @TableParams

                    if ($SAML -and $InfoLevel.User -ge 2) {
                        foreach ($sml in $SAML) {
                            Section -Style Heading4 "SAML: $($sml.name)" {
                                BlankLine
                                $OutObj = [pscustomobject]@{
                                    "Name"                   = $sml.name
                                    "Certificate"            = $sml.cert
                                    "Entity Id"              = $sml.'entity-id'
                                    "Single Sign On URL"     = $sml.'single-sign-on-url'
                                    "Single Logout URL"      = $sml.'single-logout-url'
                                    "IdP Single Sign On URM" = $sml.'idp-single-sign-on-url'
                                    "IdP Single Logout URL"  = $sml.'idp-single-logout-url'
                                    "IdP Certificate"        = $sml.'idp-cert'
                                    "User Name"              = $sml.'user-name'
                                    "Group Name"             = $sml.'group-name'
                                }

                                $TableParams = @{
                                    Name         = "SAML $($sml.name)"
                                    List         = $true
                                    ColumnWidths = 25, 75
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

    end {

    }

}