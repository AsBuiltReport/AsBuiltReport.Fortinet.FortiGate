function Invoke-AsBuiltReport.Fortinet.Fortigate {
    <#
    .SYNOPSIS
        PowerShell script to document the configuration of Fortinet Fortigate in Word/HTML/Text formats
    .DESCRIPTION
        Documents the configuration of Fortinet Fortigate in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.1.0
        Author:         Alexis La Goutte
        Twitter:        @alagoutte
        Github:         alagoutte
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.Fortigate
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
            #Connection to Fortigate (TODO: Add Parameter for Certificate Check and Port)
            Connect-FGT -Server $System -Credential $Credential -SkipCertificateCheck | Out-Null #-Port $Options.ServerPort

            #Get Model
            $Model = (Get-FGTMonitorSystemFirmware).current.'platform-id'
            Write-PScriboMessage "Connect to $System : $Model ($($DefaultFGTConnection.serial)) "

            Section -Style Heading1 "Implementation Report $($DefaultFGTConnection.serial)" {
                Paragraph "The following section provides a summary of the implemented components on the Fortinet Fortigate Infrastructure"
                BlankLine
                Get-AbrFgtForticare
                Get-AbrFgtSystem
                if ($InfoLevel.Route.PSObject.Properties.Value -ne 0) {
                    Get-AbrFgtRoute
                }

                if ($InfoLevel.Firewall.PSObject.Properties.Value -ne 0) {
                    Get-AbrFgtFirewall
                }

                if ($InfoLevel.User.PSObject.Properties.Value -ne 0) {
                    Get-AbrFgtUser
                }
            }
        }
        catch {
            Write-PscriboMessage -IsWarning $_.Exception.Message
        }


        #Disconnect
        Disconnect-FGT -Confirm:$false
    }
    #endregion foreach loop
}
