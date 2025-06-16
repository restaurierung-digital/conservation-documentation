# Use the file name as metadata
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

# Welcome Message
Write-Host "Use the file name as metadata"

# Check for ExifTool
try {
	exiftool -ver | Out-Null
} catch {
    print-error-end -error_message "ExifTool is not available"
}

# Options
Write-Host "You can choose from the following options:"
Write-Host "1`tWrite filename without extension to title (XMP-dc:Title) and preserve the complete file name (xmpMM:PreservedFileName)"
Write-Host "2`tWrite filename with extension to title (XMP-dc:Title) and preserve the complete file name (xmpMM:PreservedFileName)"
Write-Host "3`tShow metadata, if available (FileName, Title, PreservedFileName)"
Write-Host "4`tRename files using the data from xmpMM:PreservedFileName"
Write-Host "5`tDelete the title (XMP-dc:Title)"
Write-Host "6`tDelete the preserved file name (xmpMM:PreservedFileName)"

# Prompt for the folder with the files
$option = Read-Host -Prompt "Please select your option"
if ($option -lt 1 -or $option -gt 6) {
    print-error-end -error_message "The selected option is not available"
}

# Prompt for the folder with the files
$filePath = Read-Host -Prompt "Path to the files"
if (-Not (Test-Path -Path "$filePath")) { print-error-end -error_message "Path not found" }
$csvPath = $filePath + "\filenameparts.csv"

# Get all files in the directory
$files = Get-ChildItem -Path $filePath -File

foreach ($file in $files) {
	switch ($option) {
		1 { 
			# Write filename without extension to XMP-dc:Title
			$exifToolCommand = "-XMP-dc:Title=`"$($file.BaseName)`" -XMP-xmpMM:PreservedFileName=`"$($file.Name)`""
			break 
		}
		2 { 
			# Write filename with extension to XMP-dc:Title
			$exifToolCommand = "-XMP-dc:Title=`"$($file.Name)`" -XMP-xmpMM:PreservedFileName=`"$($file.Name)`""
			break 
		}
		3 { 
			# Show the data from xmpMM:PreservedFileName
			$exifToolCommand = "-FileName -XMP-dc:Title -XMP-xmpMM:PreservedFileName"
			break 
		}
		4 { 
			# Rename files using the data from xmpMM:PreservedFileName
			$exifToolCommand = "`"-FileName<XMP-xmpMM:PreservedFileName`""
			break 
		}
		5 { 
			# Delete xmpMM:PreservedFileName
			$exifToolCommand = "-XMP-dc:Title="
			break 
		}
		6 { 
			# Delete xmpMM:PreservedFileName
			$exifToolCommand = "-XMP-xmpMM:PreservedFileName="
			break 
		}
	}

	# Execute ExifTool command
	try {
		Invoke-Expression "exiftool -overwrite_original $($exifToolCommand) `"$($file.FullName)`""
	} catch {
		Write-Host $_
	}
}



