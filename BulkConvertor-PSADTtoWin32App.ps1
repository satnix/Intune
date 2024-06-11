#############################################################################################
## SCRIPT For Bulk Migration Script			 					                           ##
## Description:  Bulk Convertor from PSADT to Intune Win32App        					   ##
## Author: Satyam Krishna                                                                  ##
## Date: 06.10.2024                  		                                               ##
#############################################################################################

# Define the base directories
$automationBaseDir = "E:\PSADTPackageSource"
$outputBaseDir = "E:\OUTPUT"

# Define the path to IntuneWinAppUtil executable
$intuneWinAppUtilPath = "E:\IntuneWinAppUtil\IntuneWinAppUtil.exe"

# Define colors for Write-Host output
$colors = @("Cyan", "Green", "Yellow", "Magenta", "Blue", "Red", "White")

# Function to clear temporary files
function Clear-TempFiles {
    Write-Host "Clearing temporary files..." -ForegroundColor "Yellow"
    Remove-Item -Path "$env:TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
}

# Function to free memory
function Free-Memory {
    Write-Host "Freeing memory..." -ForegroundColor "Yellow"
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    [System.GC]::Collect()
}

# Traverse the automation base directory
Get-ChildItem -Path $automationBaseDir -Directory | ForEach-Object {
    $applicationNameDir = $_.FullName
    $applicationName = $_.Name
    $colorIndex = 0

    Get-ChildItem -Path $applicationNameDir -Directory | ForEach-Object {
        $versionNumberDir = $_.FullName
        $versionNumber = $_.Name
        $psadtFolder = "$versionNumberDir\PSADT"

        if (Test-Path $psadtFolder) {
            # Define the output directory for the IntuneWinApp package
            $outputDir = "$outputBaseDir\$applicationName\$versionNumber\Win32App"

            # Create the output directory if it doesn't exist
            if (-not (Test-Path $outputDir)) {
                New-Item -ItemType Directory -Path $outputDir -Force
            }

            # Define the source setup file (assuming the main PSADT script is Deploy-Application.exe)
            $sourceSetupFile = "Deploy-Application.exe"

            # Construct the command to run
            $command = "`"$intuneWinAppUtilPath`" -c `"$psadtFolder`" -s `"$sourceSetupFile`" -o `"$outputDir`" -q"
            Write-Host "Running command: $command" -ForegroundColor "Gray"

            # Run the IntuneWinAppUtil command in a new PowerShell process
            $powershellCommand = "Start-Process powershell -ArgumentList '-NoProfile -NoLogo -Command `"$command`"' -Wait -NoNewWindow"
            Invoke-Expression $powershellCommand

            # Clear temporary files and free memory
            Clear-TempFiles
            Free-Memory

            # Print the folder processing information
            Write-Host "Processed: $applicationName - $versionNumber" -ForegroundColor $colors[$colorIndex % $colors.Count]

            # Increment the color index
            $colorIndex++
        }
    }
}

Write-Host "Conversion process completed." -ForegroundColor "Green"
