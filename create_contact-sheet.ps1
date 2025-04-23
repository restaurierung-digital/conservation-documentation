# Create a contact sheet with Powershell and ImageMagick
#
# To use the script ImageMagick <https://imagemagick.org/> must be available
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

# Welcome Message
Write-Host "Create a contact sheet"

# Check for ImageMagick
try {
	magick identify --version | Out-Null
} catch {
    print-error-end -error_message "Imagemagick is not available"
}

# Prompt for the folder with the files
$filePath = Read-Host -Prompt "Path to the images"
if (-Not (Test-Path -Path "$filePath")) { print-error-end -error_message "Path not found" }

# Calculate possible dividers
$filecount = (Get-ChildItem -Path "$filePath" | Measure-Object).Count
$dividers = (1..[Math]::Sqrt($filecount) | Where-Object { $filecount % $_ -eq 0 } | ForEach-Object { $_; $filecount / $_ } | Sort-Object -Unique | Select-Object -Skip 1) -join ", " 

# Prompt for the number of files per row
$filesPerRow = Read-Host -Prompt "Files per row (suggestion: $dividers)"
if ($filesPerRow -match "^[1-9]\d*$") {
	$filesPerRow = [int]$filesPerRow
} else {
	print-error-end -error_message "Not a positive whole number"
}

# Create contact sheet
# The appearance of the contact sheet can be customized here
# See documentation at <https://imagemagick.org/script/montage.php>
# -label: assign a label, %f = filename (including suffix)
# -geometry: image geometry, widthxheight+offset-x+offset-y
# -tile: number of tiles per row
# -border: surround image with a border
# -bordercolor: set the border color
$magickCommand = "magick montage -label '%f' -geometry 200x200+10+10 -tile " + $filesPerRow + "x -border 1 -bordercolor black '$filePath/*' '$filePath/contact-sheet.png'"
Invoke-Expression $magickCommand

# Finish
Write-Host "The contact sheet was created at $filePath/contact-sheet.png"
