# Create zip -Force overwrites the existing zip
Compress-Archive -Path dsc/DSCInstallWindowsFeatures.ps1 -DestinationPath dsc/dscinstallwindowsfeatures.zip -Force

# Extract zip
Expand-Archive -Path dsc/dscinstallwindowsfeatures.zip -DestinationPath dsc/

# List item in zip without extracting
# https://devblogs.microsoft.com/scripting/powertip-use-powershell-to-read-the-content-of-a-zip-file/
[io.compression.zipfile]::OpenRead('c:/git/trainymotion/nestedvirtualization/dsc/dscinstallwindowsfeatures.zip').Entries.Name