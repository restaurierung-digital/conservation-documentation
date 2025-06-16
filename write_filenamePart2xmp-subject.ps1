# Write part of the file name to XMP:Subject with Powershell and ExifTool
# It must be possible to split the file name with a delimiter
# The keywords are added to existing keywords
#
# To use the script ExifTool <https://exiftool.org/> must be available
#
# Example: 
# Delimiter: _ (underscore)
# File naming scheme: ObjectID_LightingSituation_Index
#                     ________ _________________ _____
#                      Part 1       Part 2       Part 3
#
# Date: 2025-04-23 | Version 1.0

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
$defaultDelimiter = "_"

# Welcome Message
Write-Host "Write part of the file name to XMP:Subject"

# Check for ExifTool
try {
	exiftool -ver | Out-Null
} catch {
    print-error-end -error_message "ExifTool is not available"
}

# Prompt for the folder with the files
$filePath = Read-Host -Prompt "Path to the images"
if (-Not (Test-Path -Path "$filePath")) { print-error-end -error_message "Path not found" }

# Prompt for the delimiter 
$delimiter = Read-Host -Prompt "Delimiter (default: $defaultDelimiter)"
if ([string]::IsNullOrEmpty($delimiter)) { $delimiter = $defaultDelimiter }

# Prompt for the part to use
$filePartCount = Read-Host -Prompt "File name part to use"
if ($filePartCount -match "^[1-9]\d*$") {
	$filePartCount = [int]$filePartCount
} else {
	print-error-end -error_message "Not a positive whole number"
}

# Get all files in the image directory
$files = Get-ChildItem -File -Path $filePath

foreach ($file in $files) {	
	# Extract file name without extension
	$filenameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

	# Check whether the delimiter is present
	if ($filenameWithoutExtension -match $delimiter) { 
		# Split file name using the delimiter
		$nameParts = $filenameWithoutExtension -split "$delimiter"
		
		# Check whether enough parts are available
		if ($nameParts.Length -ge $filePartCount) {
			# Use the matching component as the subject
			$subject = $nameParts[$filePartCount-1]
			
			# Use exiftool to write the metadata from the filename to the file
			# The keywords are added to existing keywords. If these are to be replaced, the + sign must be removed from XMP:Subject+=
			$exifToolCommand = "exiftool -overwrite_original -XMP:Subject+=`"$subject`" '$($file.FullName)'"
			Write-Host "Setting XMP:Subject for file: $($file.Name) to '$subject'"
			Invoke-Expression $exifToolCommand
		} else {
			Write-Host "File '$($file.Name)' does not have enough file name parts"
		}
	} else {
			Write-Host "File '$($file.Name)' delimiter not found"
		}
    

}
