
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

        $TableName = "User"
        Section -Style Heading2 $TableName {
            Paragraph "The following section details user settings configured on FortiGate."
            BlankLine

            $Users = Get-FGTUserLocal
            $Groups = Get-FGTUserGroup
            $LDAPS = Get-FGTUserLDAP
            $RADIUS = Get-FGTUserRADIUS
            if ($DefaultFGTConnection.version -ge "6.2.0") {
                $SAML = Get-FGTUserSAML
            }

            if ($InfoLevel.User -ge 1) {
                Section -Style Heading3 'Summary' {
                    Paragraph "The following section provides a summary of user settings."
                    BlankLine
                    $OutObj = [pscustomobject]@{
                        "User"   = @($Users).count
                        "Group"  = @($Groups).count
                        "LDAP"   = @($LDAPS).count
                        "RADIUS" = @($RADIUS).count
                        "SAML"   = @($SAML).count
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -List
                }
            }

            if ($Users -and $InfoLevel.User -ge 1) {
                $TableName = "User Local"
                Section -Style Heading3 $TableName {
                    $OutObj = @()

                    foreach ($user in $Users) {

                        $OutObj += [pscustomobject]@{
                            "Name"          = $user.name
                            "Type"          = $user.type
                            "Status"        = $user.status
                            "Password Time" = $user.'passwd-time'
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName
                }
            }

            if ($Groups -and $InfoLevel.User -ge 1) {
                $TableName = "User Group"
                Section -Style Heading3 $TableName {
                    $OutObj = @()

                    foreach ($grp in $Groups) {

                        $OutObj += [pscustomobject]@{
                            "Name"   = $grp.name
                            "Type"   = $grp.'group-type'
                            "Member" = $grp.member.name -join ", "
                            "Match"  = $grp.match.'group-name' -join ", "
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName
                }
            }

            if ($LDAPS -and $InfoLevel.User -ge 1) {
                $TableName = "LDAP"
                Section -Style Heading3 $TableName {
                    $OutObj = @()

                    foreach ($ldap in $LDAPS) {
                        $server = $ldap.server
                        if ($ldap.'secondary-server') {
                            $server += "/" + $ldap.'secondary-server'
                        }
                        if ($ldap.'tertiary-server') {
                            $server += "/" + $ldap.'tertiary-server'
                        }

                        $OutObj += [pscustomobject]@{
                            "Name"      = $ldap.name
                            "Server(s)" = $server
                            "Port"      = $ldap.port
                            "CN"        = $ldap.cnid
                            "DN"        = $ldap.dn
                            "Type"      = $ldap.type
                            "User"      = $ldap.username
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Server(s)"=26;}

                    if ($InfoLevel.User -ge 2) {
                        foreach ($ldap in $LDAPS) {
                            $TableName = "LDAP $($ldap.name)"
                            Section -Style NOTOCHeading4 -ExcludeFromTOC $TableName {
                                $OutObj = [pscustomobject]@{
                                    "Name"                = $ldap.name
                                    "Server"              = $ldap.server
                                    "Secondary Server"    = $ldap.'secondary-server'
                                    "Tertiary Server"     = $ldap.'tertiary-server'
                                    "Port"                = $ldap.port
                                    "Secure"              = $ldap.secure
                                    "Source IP"           = $ldap.'source-ip'
                                    "Interface"           = $ldap.interface
                                    "Cnid"                = $ldap.cnid
                                    "DN"                  = $ldap.dn
                                    "Type"                = $ldap.type
                                    "Username"            = $ldap.username
                                    "Group Member Check"  = $ldap.'group-member-check'
                                    "Group Search Base"   = $ldap.'group-search-base'
                                    "Group Object Filter" = $ldap.'group-object-filter'
                                }
                                Write-FormattedTable -InputObject $OutObj -TableName $tableName -List -TableParams @{ColumnWidths = 25, 75}
                            }
                        }
                    }
                }
            }

            if ($RADIUS -and $InfoLevel.User -ge 1) {
                $TableName = "RADIUS"
                Section -Style Heading3 $TableName {
                    $OutObj = @()

                    foreach ($rad in $RADIUS) {
                        $server = $rad.server
                        if ($rad.'secondary-server') {
                            $server += "/" + $rad.'secondary-server'
                        }
                        if ($rad.'tertiary-server') {
                            $server += "/" + $rad.'tertiary-server'
                        }
                        $OutObj += [pscustomobject]@{
                            "Name"      = $rad.name
                            "Server(s)" = $server
                            "Auth Type" = $rad.'auth-type'
                            "NAS-IP"    = $rad.'nas-ip'
                        }
                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"Server(s)"=40;}

                    if ($InfoLevel.User -ge 2) {
                        foreach ($rad in $RADIUS) {
                            $TableName = "RADIUS $($rad.name)"
                            Section -Style NOTOCHeading4 -ExcludeFromTOC $TableName {
                                $OutObj = [pscustomobject]@{

                                    "Name"                    = $rad.name
                                    "Server"                  = $rad.server
                                    "Secondary Server"        = $rad.'secondary-server'
                                    "Tertiary Server"         = $rad.'tertiary-server'
                                    "Port"                    = $rad.'radius-port'
                                    "Timeout"                 = $rad.timeout
                                    "Source IP"               = $rad.'source-ip'
                                    "Interface"               = $rad.interface
                                    "Interface Select Method" = $rad.'interface-select-method'
                                    "Use Management VDOM"     = $rad.'use-management-vdom'
                                    "All Usergroup"           = $rad.'all-usergroup'
                                    "NAS IP"                  = $rad.'nas-ip'
                                    "NAS ID Type"             = $rad.'nas-id-type'
                                    "NAS ID"                  = $rad.'nas-id'
                                    "Acct Interim Interval"   = $rad.'acct-interim-interval'
                                    "RADIUS CoA"              = $rad.'radius-coa'
                                    "Auth Type"               = $rad.'auth-type'
                                    "Username Case Sensitive" = $rad.'username-case-sensitive'
                                    "Accounting Server"       = $rad.'accounting-server'
                                    "RSSO"                    = $rad.rsso
                                    "Class"                   = $rad.class
                                    "Password Renewal"        = $rad.'password-renewal'
                                    "MAC Username Delimiter"  = $rad.'mac-username-delimiter'
                                    "MAC Password Delimiter"  = $rad.'mac-password-delimiter"'
                                    "MAC Case"                = $rad.'mac-case'
                                    "Delimiter"               = $rad.delimiter
                                }
                                Write-FormattedTable -InputObject $OutObj -TableName $tableName -List -TableParams @{ColumnWidths = 30, 70}
                            }
                        }
                    }
                }
            }

            if ($SAML -and $InfoLevel.User -ge 1) {
                $TableName = "SAML"
                Section -Style Heading3 $TableName {
                    $OutObj = @()

                    foreach ($sml in $SAML) {

                        $OutObj += [pscustomobject]@{
                            "Name"           = $sml.name
                            "Certificate"    = $sml.cert
                            "IdP Entity-ID"  = $sml.'idp-entity-id'
                            "IdP Certificat" = $sml.'idp-cert'
                        }

                    }
                    Write-FormattedTable -InputObject $OutObj -TableName $tableName -CustomColumnWidths @{"IdP Entity-ID" = 40;}


                    if ($SAML -and $InfoLevel.User -ge 2) {
                        foreach ($sml in $SAML) {
                            $TableName = "SAML $($sml.name)"
                            Section -Style NOTOCHeading4 -ExcludeFromTOC $TableName {
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
                                Write-FormattedTable -InputObject $OutObj -TableName $tableName -List -TableParams @{ColumnWidths = 25, 75}
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