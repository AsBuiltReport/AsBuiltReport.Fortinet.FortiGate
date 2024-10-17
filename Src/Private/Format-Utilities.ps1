<#
.SYNOPSIS
    Utility functions for formatting and processing data in AsBuiltReport.Fortinet.FortiGate.
.DESCRIPTION
    This file contains utility functions used throughout the AsBuiltReport.Fortinet.FortiGate module
    for formatting data, converting between different formats, and preparing data for output.
.LINK
    https://github.com/AsBuiltReport/AsBuiltReport.Fortinet.FortiGate
#>

function ConvertTo-CIDR {
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
                $cidr = ConvertFrom-SubnetMask -SubnetMask $subnetMask
                Write-PScriboMessage "Converted IP address $ipAddress and subnet mask $subnetMask to CIDR $ipAddress/$cidr."
                return "$ipAddress/$cidr"
            }
        } elseif ($parts.Count -eq 1) {
            if ($Input -match $subnetMaskRegex) {
                $cidr = ConvertFrom-SubnetMask -SubnetMask $Input
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

function ConvertFrom-SubnetMask {
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

function Get-ColumnWidth {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object]$InputObject,

        [Parameter(Mandatory = $false)]
        [hashtable]$CustomWidths = @{}
    )

    # Check if InputObject is an array or collection, and use only the first item
    if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject.Count -gt 0) {
        $InputObject = $InputObject[0]
    }

    $properties = $InputObject.PSObject.Properties.Name
    $columnCount = $properties.Count
    $totalWidth = 100
    $remainingWidth = $totalWidth
    $widths = [ordered]@{}

    Write-PScriboMessage "Initial state: Total width = $totalWidth, Column count = $columnCount"

    # Check if custom widths exceed total width
    $customWidthsSum = ($CustomWidths.Values | Measure-Object -Sum).Sum
    Write-PScriboMessage "Sum of custom widths: $customWidthsSum"
    if ($customWidthsSum -gt $totalWidth) {
        throw "The sum of custom widths ($customWidthsSum) exceeds the total available width of $totalWidth."
    }

    # Initialize widths with custom values or a marker for columns to assign
    foreach ($prop in $properties) {
        if ($CustomWidths.ContainsKey($prop)) {
            $widths[$prop] = $CustomWidths[$prop]
            $remainingWidth -= $CustomWidths[$prop]
            Write-PScriboMessage "Assigned custom width for '$prop': $($CustomWidths[$prop]). Remaining width: $remainingWidth"
        } else {
            $widths[$prop] = 'ToAssign'
        }
    }

    # Calculate and assign default width for remaining columns
    $columnsToAssign = ($widths.Values | Where-Object { $_ -eq 'ToAssign' }).Count
    Write-PScriboMessage "Columns to assign default width: $columnsToAssign"

    if ($columnsToAssign -eq 0 -and $remainingWidth -gt 0) {
        # All columns are in CustomWidths but total is less than 100%
        $additionalWidthPerColumn = [math]::Floor($remainingWidth / $columnCount)
        $leftoverWidth = $remainingWidth % $columnCount
        Write-PScriboMessage "Distributing remaining width: $remainingWidth among $columnCount columns"

        foreach ($prop in $properties) {
            $widths[$prop] += $additionalWidthPerColumn
            if ($leftoverWidth -gt 0) {
                $widths[$prop]++
                $leftoverWidth--
            }
            Write-PScriboMessage "Adjusted width for '$prop': $($widths[$prop])"
        }
    } elseif ($columnsToAssign -gt 0) {
        $defaultWidth = [math]::Floor($remainingWidth / $columnsToAssign)
        $leftoverWidth = $remainingWidth % $columnsToAssign
        Write-PScriboMessage "Calculated default width: $defaultWidth, Leftover width: $leftoverWidth"

        # Assign default width to remaining columns
        foreach ($prop in $properties) {
            if ($widths[$prop] -eq 'ToAssign') {
                $widths[$prop] = $defaultWidth
                if ($leftoverWidth -gt 0) {
                    $widths[$prop]++
                    $leftoverWidth--
                }
                $remainingWidth -= $widths[$prop]
                Write-PScriboMessage "Assigned width for '$prop': $($widths[$prop]). Remaining width: $remainingWidth"
            }
        }
    }

    # Return widths in the correct order based on property sequence in InputObject
    $widthsArray = @()
    foreach ($prop in $InputObject.PSObject.Properties) {
        $widthsArray += $widths[$prop.Name]
    }

    Write-PScriboMessage "Final widths: $($widthsArray -join ', ')"
    return $widthsArray
}

# Removes columns with empty values from tables of data
function Clear-EmptyColumn {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$InputObject
    )

    if ($InputObject.Count -eq 0) {
        Write-PScriboMessage "Empty input object passed to Clear-EmptyColumn."
        return @{
            ProcessedObject = @()
            FilteredColumns = @()
        }
    }

    $properties = $InputObject[0].PSObject.Properties.Name
    $filteredColumns = @()

    foreach ($prop in $properties) {
        $isBlank = $true
        foreach ($obj in $InputObject) {
            if (![string]::IsNullOrWhiteSpace($obj.PSObject.Properties[$prop].Value)) {
                $isBlank = $false
                break
            }
        }
        if ($isBlank) {
            $filteredColumns += $prop
        }
    }

    if ($filteredColumns.Count -gt 0) {
        $processedObject = $InputObject | Select-Object ($properties | Where-Object { $_ -notin $filteredColumns })
    } else {
        $processedObject = $InputObject
    }

    return @{
        ProcessedObject = $processedObject
        FilteredColumns = $filteredColumns
    }
}

function Write-FormattedTable {
    param (
        [Parameter(Mandatory = $true)]
        [Array]$InputObject,
        [Parameter(Mandatory = $true)]
        [string]$TableName,
        [Parameter(Mandatory = $false)]
        [hashtable]$TableParams = @{},
        [Parameter(Mandatory = $false)]
        [switch]$List = $false,
        [Parameter(Mandatory = $false)]
        [hashtable]$CustomColumnWidths = @{}
    )

    if ($InputObject.Count -eq 0) {
        Write-PScriboMessage "No data to display for table '$TableName'."
        return
    }

    $result = Clear-EmptyColumn -InputObject $InputObject
    $ProcessedObject = $result.ProcessedObject

    $TableParams['Name'] = $TableName
    $TableParams['List'] = $List

    if (-not $List) {
        $TableParams['ColumnWidths'] = Get-ColumnWidth -InputObject $ProcessedObject -CustomWidths $CustomColumnWidths
    }

    if ($Report.ShowTableCaptions) {
        $TableParams['Caption'] = "- $TableName"
    }

    $ProcessedObject | Table @TableParams

    if ($result.FilteredColumns.Count -gt 0) {
        Paragraph -Style Notation "The following column(s) were omitted from the table above due to being empty: $($result.FilteredColumns -join ', ')."
        BlankLine
    }
}
