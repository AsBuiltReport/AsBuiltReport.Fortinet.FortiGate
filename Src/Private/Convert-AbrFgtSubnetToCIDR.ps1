function Convert-AbrFgtSubnetToCIDR {
    <#
    .SYNOPSIS
        Used by As Built Report to convert IP/Subnet to CIDR notation.
    .DESCRIPTION
        Converts IP addresses and subnet masks to CIDR notation format for Fortinet FortiGate As Built Report.
    .NOTES
        Version:        0.1.0
        Author:         Alexis La Goutte
        Twitter:        @alagoutte
        Github:         alagoutte
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .EXAMPLE
        Convert-AbrFgtSubnetToCIDR "192.168.1.0 255.255.255.0"
        Returns: 192.168.1.0/24

    .EXAMPLE
        Convert-AbrFgtSubnetToCIDR "10.0.0.0/8"
        Returns: 10.0.0.0/8

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string]$Input
    )

    process {
        $subnetMaskRegex = '^(0|128|192|224|240|248|252|254|255)\.0\.0\.0$|^(255\.(0|128|192|224|240|248|252|254|255)\.0\.0)$|^(255\.255\.(0|128|192|224|240|248|252|254|255)\.0)$|^(255\.255\.255\.(0|128|192|224|240|248|252|254|255))$'
        $ipAddressRegex = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

        $parts = $Input -split '\s+'

        if ($parts.Count -eq 2) {
            # IP address and subnet mask
            $ipAddress = $parts[0]
            $subnetMask = $parts[1]

            if ($ipAddress -match $ipAddressRegex -and $subnetMask -match $subnetMaskRegex) {
                $cidr = Convert-AbrFgtSubnetMaskToCIDR -SubnetMask $subnetMask
                Write-PScriboMessage "Converted IP address $ipAddress and subnet mask $subnetMask to CIDR $ipAddress/$cidr."
                return "$ipAddress/$cidr"
            }
        } elseif ($parts.Count -eq 1) {
            if ($Input -match $subnetMaskRegex) {
                $cidr = Convert-AbrFgtSubnetMaskToCIDR -SubnetMask $Input
                Write-PScriboMessage "Converted subnet mask $Input to CIDR /$cidr."
                return "/$cidr"
            } elseif ($Input -match $ipAddressRegex) {
                Write-PScriboMessage "Input is a single IP address, assuming /32 CIDR."
                return "$Input/32"
            } elseif ($Input -match "^$ipAddressRegex/\d{1,2}$") {
                Write-PScriboMessage "Input is already in CIDR notation."
                return $Input
            }
        }

        Write-Error "Invalid input format. Expected IP address with subnet mask, IP address, subnet mask, or IP address in CIDR notation."
        return $Input
    }
}

function Convert-AbrFgtSubnetMaskToCIDR {
    <#
    .SYNOPSIS
        Used by As Built Report to convert subnet mask to CIDR prefix.
    .DESCRIPTION
        Converts subnet mask to CIDR prefix number for Fortinet FortiGate As Built Report.
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
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory=$true)]
        [string]$SubnetMask
    )

    $cidr = [System.Net.IPAddress]::Parse($SubnetMask).GetAddressBytes() |
            ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') } |
            ForEach-Object { $_.ToCharArray() } |
            Where-Object { $_ -eq '1' } |
            Measure-Object |
            Select-Object -ExpandProperty Count

    if ($cidr -lt 0 -or $cidr -gt 32) {
        Write-Error "Invalid CIDR value. Expected a value between 0 and 32, but got $cidr."
        return $SubnetMask
    }

    return $cidr
}