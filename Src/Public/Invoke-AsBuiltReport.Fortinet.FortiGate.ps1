function Invoke-AsBuiltReport.Fortinet.FortiGate {
    <#
    .SYNOPSIS
        PowerShell script to document the configuration of Fortinet FortiGate in Word/HTML/Text formats
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

    # Do not remove or add to these parameters
    param (
        [String[]] $Target,
        [PSCredential] $Credential
    )

    # Import Report Configuration
    $Report = $ReportConfig.Report
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options

    # Used to set values to TitleCase where required
    $TextInfo = (Get-Culture).TextInfo

    # Update/rename the $System variable and build out your code within the ForEach loop. The ForEach loop enables AsBuiltReport to generate an as built configuration against multiple defined targets.

    #region foreach loop
    foreach ($System in $Target) {

        try {
            #Connection to FortiGate (TODO: Add Parameter for Certificate Check and Port)
            Connect-FGT -Server $System -Credential $Credential -SkipCertificateCheck -Port $Options.Port -vdom $Options.vdom | Out-Null

            #Get Model
            $Model = (Get-FGTMonitorSystemFirmware).current.'platform-id'
            Write-PScriboMessage "Connect to $System : $Model ($($DefaultFGTConnection.serial)) "

            #Get firewall hostname(s) and serials (HA or standalone configurations supported)
            $haConfig = Get-FGTSystemHA
            if( $haConfig.mode -ne 'standalone' ) {
                $haPeers = Get-FGTMonitorSystemHAPeer
                #Get hostnames from HA config
                $hostnames = ($haPeers | ForEach-Object { $_.hostname }) -join ', '

                #Get serials for HA config
                $serials = ($haPeers | ForEach-Object { $_.serial_no }) -join ', '

            } else {
                #Get hostnames and serials for standalone config
                $globalSettings = Get-FGTSystemGlobal
                $hostnames = $globalSettings.hostname
                $serials = $DefaultFGTConnection.serial
            }

            Section -Style Heading1 "$hostnames Configuration" {
                Paragraph "The following provides as-built documentation for the Fortinet FortiGate $Model firewalls $hostnames ($serials)."
                BlankLine
                if ($InfoLevel.FortiGate.PSObject.Properties.Value -ne 0) {
                    Get-AbrFgtFortiCare
                }

                Get-AbrFgtSystem
                if ($InfoLevel.Route.PSObject.Properties.Value -ne 0) {
                    Get-AbrFgtRoute
                }

                if ($InfoLevel.SDWAN.PSObject.Properties.Value -ne 0) {
                    Get-AbrFgtSDWAN
                }

                if ($InfoLevel.Firewall.PSObject.Properties.Value -ne 0) {
                    Get-AbrFgtFirewall
                }

                if ($InfoLevel.User.PSObject.Properties.Value -ne 0) {
                    Get-AbrFgtUser
                }
                if ($InfoLevel.VPNIPsec.PSObject.Properties.Value -ne 0) {
                    Get-AbrFgtVPNIPsec
                }
                if ($InfoLevel.VPNSSL.PSObject.Properties.Value -ne 0) {
                    Get-AbrFgtVPNSSL
                }
            }
        }
        catch {
            Write-PScriboMessage -IsWarning $_.Exception.Message
        }


        #Disconnect
        Disconnect-FGT -Confirm:$false
    }
    #endregion foreach loop
}
