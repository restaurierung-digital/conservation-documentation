# Write the parts of a file name as a CSV file
#
# Date: 2025-06-16 | Version 1.0

# Functions
function print-error-end {
	[CmdletBinding()]
	param(
		[Parameter()]
		[string]$error_message = "Unknown error"
	)

	Write-Host -ForegroundColor White -BackgroundColor Red "ERROR: $error_message"
	exit
}

# Initialize variables
$defaultDelimiter = "_"	# The default delimiter
$csvData = @{}	# Stores the data for the CSV file
$partsList = @()	# List of all parts
$maxParts = 0	# Maximum number of parts across all file names

# Welcome Message
Write-Host "Write the parts of a file name as a CSV file"

# Prompt for the folder with the files
$filePath = Read-Host -Prompt "Path to the files"
if (-Not (Test-Path -Path "$filePath")) { print-error-end -error_message "Path not found" }
$csvPath = $filePath + "\filenameparts.csv"

# Prompt for the delimiter 
$delimiter = Read-Host -Prompt "Delimiter (default: $defaultDelimiter)"
if ([string]::IsNullOrEmpty($delimiter)) { $delimiter = $defaultDelimiter }

# Get all files in the directory
$files = Get-ChildItem -Path $filePath -File

foreach ($file in $files) {
    # Extract file name without extension
    $filenameWithoutExtension =  $file.BaseName

    # Split file name using the delimiter
    $parts = $filenameWithoutExtension -split [regex]::Escape($delimiter)

    # Check maximum number of parts
    if ($parts.Length -gt $maxParts) {
        $maxParts = $parts.Length
    }

    # Save the parts in their original order
    $partsList += ,$parts
}

# Generate CSV rows (each entry is stored in an object with fixed columns)
$csvData = foreach ($parts in $partsList) {
    $obj = [ordered]@{}
    for ($i = 0; $i -lt $maxParts; $i++) {
        $obj["part_$($i + 1)"] = if ($i -lt $parts.Length) { $parts[$i] } else { $null }
    }
    [pscustomobject]$obj
}

# Save the CSV data in a file
try {
	$csvData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding utf8 -NoClobber -UseCulture
	Write-Host "CSV file was created at $csvPath"
} catch {
	print-error-end -error_message "The CSV file $($csvPath) could not be created"
}

