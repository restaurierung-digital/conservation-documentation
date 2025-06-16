# conservation-documentation
Scripts to support the documentation in conservation

# create_contact-sheet.ps1
Creates a contact sheet of the images in a folder using Powershell and [ImageMagick](https://imagemagick.org/)  

# create_filenameparts2csv.ps1
Write the parts of a file name as a CSV file using Powershell
* It must be possible to split the file name with a delimiter
* Helpful to check whether the file names follow your naming convention

# write_filename2metadata.ps1
Using the file name as metadata using Powershell and [ExifTool](https://exiftool.org/)  
The following options are available: 
* Write filename without extension to title (XMP-dc:Title) and preserve the complete file name (xmpMM:PreservedFileName)
* Write filename with extension to title (XMP-dc:Title) and preserve the complete file name (xmpMM:PreservedFileName)
* Show metadata, if available (FileName, Title, PreservedFileName)
* Rename files using the data from xmpMM:PreservedFileName
* Delete the title (XMP-dc:Title)
* Delete the preserved file name (xmpMM:PreservedFileName)

# write_filenamePart2xmp-subject.ps1
Write part of the file name to XMP:Subject with Powershell and [ExifTool](https://exiftool.org/) 
* It must be possible to split the file name with a delimiter
* The keywords are added to existing keywords
