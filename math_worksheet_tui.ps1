<#
.SYNOPSIS
    Interactive TUI for generating math worksheets and converting to Braille (BRF).

.DESCRIPTION
    This script provides a menu-driven interface to:
    - Generate addition, subtraction, mixed, or multiplication worksheets
    - Convert worksheets to individual BRF files or a single combined BRF file
    - Automatically check for lou_translate availability

.EXAMPLE
    .\MathWorksheetTUI.ps1

.NOTES
    Author: Ryan Hunsaker
    Date: October 2025
#>

# Accept a switch for automated testing (non-interactive)
param(
    [switch]$AutoTest
)

# Get the folder where the script is located
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputFolder = Join-Path $scriptDirectory "math_worksheets"

# Configuration for lou_translate
$louTranslatePath = "C:\liblouis-3.35.0-win64\bin\lou_translate.exe"
$tablePath = "C:\liblouis-3.35.0-win64\share\liblouis\tables\en-ueb-g2.ctb"

# Check if lou_translate is available
function Test-LouTranslate {
    if (Test-Path $louTranslatePath) {
        return $true
    }
    
    # Try to find it in PATH
    $pathResult = Get-Command lou_translate.exe -ErrorAction SilentlyContinue
    if ($pathResult) {
        $script:louTranslatePath = $pathResult.Source
        return $true
    }
    
    return $false
}

function Show-Menu {
    Clear-Host
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "    MATH WORKSHEET GENERATOR & BRF CONVERTER" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Generate Addition Worksheets" -ForegroundColor Green
    Write-Host "2. Generate Subtraction Worksheets" -ForegroundColor Green
    Write-Host "3. Generate Mixed Add/Subtract Worksheets" -ForegroundColor Green
    Write-Host "4. Generate Multiplication Worksheets (standard)" -ForegroundColor Green
    Write-Host "5. Generate Multiplication (fixed first factor)" -ForegroundColor Green
    Write-Host "6. Generate Multiplication XxY grid" -ForegroundColor Green
    Write-Host "7. Generate Division (no remainders)" -ForegroundColor Green
    Write-Host "8. Generate Mixed Multiplication/Division" -ForegroundColor Green
    Write-Host ""
    Write-Host "9. Convert Existing Worksheets to Individual BRF Files" -ForegroundColor Yellow
    Write-Host "10. Convert Existing Worksheets to Single Combined BRF" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "11. Generate AND Convert to Individual BRF Files" -ForegroundColor Magenta
    Write-Host "12. Generate AND Convert to Single Combined BRF" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "13. Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "" 
    Write-Host "================================================" -ForegroundColor Cyan
}

function Get-RandomNumber {
    param (
        [int]$Digits
    )
    $min = [int][math]::Pow(10, $Digits - 1)
    $max = [int][math]::Pow(10, $Digits) - 1
    return Get-Random -Minimum $min -Maximum ($max + 1)
}

function Generate-Problem {
    param (
        [int]$Digits,
        [string]$Operation
    )
    $num1 = Get-RandomNumber -Digits $Digits
    $num2 = Get-RandomNumber -Digits $Digits

    # Use Unicode minus (U+2212) for subtraction, multiplication cross '×' for multiplication, '÷' for division
    if ($Operation -eq '−') {
        if ($num1 -lt $num2) {
            $temp = $num1
            $num1 = $num2
            $num2 = $temp
        }
    }

    return "$num1$Operation$num2"
}

# Generate a multiplication problem with a fixed first factor
function Generate-MultiplicationFixed {
    param(
        [int]$Fixed,
        [int]$OtherMax
    )
    $other = Get-Random -Minimum 1 -Maximum ($OtherMax + 1)
    return "$Fixed×$other"
}

# Generate an XxY multiplication grid problem (both factors limited)
function Generate-MultiplicationXY {
    param(
        [int]$X,
        [int]$Y
    )
    $a = Get-Random -Minimum 1 -Maximum ($X + 1)
    $b = Get-Random -Minimum 1 -Maximum ($Y + 1)
    return "$a×$b"
}

# Generate a division problem with no remainder (a ÷ b = whole number)
function Generate-WholeDivision {
    param(
        [int]$MaxDivisor,
        [int]$MaxQuotient
    )
    $divisor = Get-Random -Minimum 1 -Maximum ($MaxDivisor + 1)
    $quotient = Get-Random -Minimum 1 -Maximum ($MaxQuotient + 1)
    $dividend = $divisor * $quotient
    return "$dividend÷$divisor"
}

function Generate-Worksheets {
    param (
        [int]$Digits,
        [string]$Type,
        [int]$Count = 50,
        [int]$ProblemsPerSheet = 20
    )

    # Create the output folder if it doesn't exist
    if (-not (Test-Path $outputFolder)) {
        New-Item -ItemType Directory -Path $outputFolder | Out-Null
    }

    $operationLabel = switch ($Type) {
        "addition" { "addition" }
        "subtraction" { "subtraction" }
        "mixed" { "mixed_addsubtract" }
        "multiplication" { "multiplication" }
    }

    Write-Host "`nGenerating $Count worksheets..." -ForegroundColor Cyan

    for ($sheet = 1; $sheet -le $Count; $sheet++) {
        $problems = @()

        switch ($Type) {
            "addition" {
                for ($i = 1; $i -le $ProblemsPerSheet; $i++) {
                    $problems += Generate-Problem -Digits $Digits -Operation '+'
                }
            }
                "subtraction" {
                for ($i = 1; $i -le $ProblemsPerSheet; $i++) {
                    $problems += Generate-Problem -Digits $Digits -Operation '−'
                }
            }
            "mixed" {
                for ($i = 1; $i -le ($ProblemsPerSheet / 2); $i++) {
                    $problems += Generate-Problem -Digits $Digits -Operation '+'
                }
                for ($i = 1; $i -le ($ProblemsPerSheet / 2); $i++) {
                    $problems += Generate-Problem -Digits $Digits -Operation '−'
                }
                $problems = $problems | Get-Random -Count $problems.Count
            }
            "multiplication" {
                for ($i = 1; $i -le $ProblemsPerSheet; $i++) {
                    $problems += Generate-Problem -Digits $Digits -Operation '×'
                }
            }
        }

        # Number and format the problems
        $lines = @()
        for ($i = 0; $i -lt $problems.Count; $i++) {
            $lines += "$($i + 1). $($problems[$i])"
        }

        $filename = "${operationLabel}_practice_(${Digits}x${Digits})_{0:D2}.txt" -f $sheet
        $filepath = Join-Path $outputFolder $filename
        $lines | Out-File -FilePath $filepath -Encoding UTF8

        if ($sheet % 10 -eq 0) {
            Write-Host "  Generated $sheet worksheets..." -ForegroundColor Gray
        }
    }

    Write-Host "Successfully generated $Count worksheets in: $outputFolder" -ForegroundColor Green
    return $outputFolder
}

function Convert-ToIndividualBRF {
    param (
        [string]$SourceFolder
    )

    if (-not (Test-LouTranslate)) {
        Write-Host "`nERROR: lou_translate not found!" -ForegroundColor Red
        Write-Host "Expected location: $louTranslatePath" -ForegroundColor Yellow
        Write-Host "Please install liblouis or update the path in the script." -ForegroundColor Yellow
        return $false
    }

    $txtFiles = Get-ChildItem -Path $SourceFolder -Filter *.txt
    if ($txtFiles.Count -eq 0) {
        Write-Host "`nNo .txt files found in: $SourceFolder" -ForegroundColor Yellow
        return $false
    }

    Write-Host "`nConverting $($txtFiles.Count) files to individual BRF files..." -ForegroundColor Cyan

    $converted = 0
    foreach ($file in $txtFiles) {
        $inputFile = $file.FullName
        $outputFile = [System.IO.Path]::ChangeExtension($inputFile, ".brf")

        try {
            Get-Content $inputFile | & $louTranslatePath --forward $tablePath | Out-File -FilePath $outputFile -Encoding UTF8
            $converted++
            
            if ($converted % 10 -eq 0) {
                Write-Host "  Converted $converted files..." -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "  ERROR converting $($file.Name): $_" -ForegroundColor Red
        }
    }

    Write-Host "Successfully converted $converted files to BRF format" -ForegroundColor Green
    return $true
}

function Convert-ToSingleBRF {
    param (
        [string]$SourceFolder,
        [string]$OutputFileName = "combined_worksheets.brf"
    )

    if (-not (Test-LouTranslate)) {
        Write-Host "`nERROR: lou_translate not found!" -ForegroundColor Red
        Write-Host "Expected location: $louTranslatePath" -ForegroundColor Yellow
        Write-Host "Please install liblouis or update the path in the script." -ForegroundColor Yellow
        return $false
    }

    $txtFiles = Get-ChildItem -Path $SourceFolder -Filter *.txt | Sort-Object Name
    if ($txtFiles.Count -eq 0) {
        Write-Host "`nNo .txt files found in: $SourceFolder" -ForegroundColor Yellow
        return $false
    }

    $outputFile = Join-Path $SourceFolder $OutputFileName
    "" | Out-File -FilePath $outputFile -Encoding UTF8

    Write-Host "`nCombining $($txtFiles.Count) files into single BRF file..." -ForegroundColor Cyan

    $processed = 0
    foreach ($file in $txtFiles) {
        $inputFile = $file.FullName

        try {
            $braille = Get-Content $inputFile | & $louTranslatePath --forward $tablePath
            Add-Content -Path $outputFile -Value $braille
            Add-Content -Path $outputFile -Value "`f"  # Form feed character
            
            $processed++
            if ($processed % 10 -eq 0) {
                Write-Host "  Processed $processed files..." -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "  ERROR processing $($file.Name): $_" -ForegroundColor Red
        }
    }

    Write-Host "Successfully created combined BRF file: $outputFile" -ForegroundColor Green
    return $true
}

function Get-UserInput {
    param (
        [string]$Prompt,
        [int]$Default
    )
    
    $rawInput = Read-Host "$Prompt (default: $Default)"
    if ([string]::IsNullOrWhiteSpace($rawInput)) {
        return $Default
    }

    $value = 0
    if ([int]::TryParse($rawInput, [ref]$value)) {
        return $value
    }
    
    return $Default
}

function Get-WorksheetType {
    Write-Host "`nSelect worksheet type:" -ForegroundColor Cyan
    Write-Host "1. Addition"
    Write-Host "2. Subtraction"
    Write-Host "3. Mixed (Add/Subtract)"
    Write-Host "4. Multiplication"
    
    $choice = Read-Host "`nEnter choice (1-4)"
    
    switch ($choice) {
        "1" { return "addition" }
        "2" { return "subtraction" }
        "3" { return "mixed" }
        "4" { return "multiplication" }
        default { return "mixed" }
    }
}

# Main program: interactive or AutoTest
if ($AutoTest) {
    # Non-interactive test: generate one small worksheet and attempt conversion if available
    Write-Host "AutoTest: generating one sample worksheet..." -ForegroundColor Cyan
    Generate-Worksheets -Digits 1 -Type addition -Count 1 -ProblemsPerSheet 6
    if (Test-LouTranslate) {
        Convert-ToIndividualBRF -SourceFolder $outputFolder
    }
    else {
        Write-Host 'lou_translate not found; skipping conversion.' -ForegroundColor Yellow
    }
}
else {
    # Interactive menu loop
    do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-13)"
        
        switch ($choice) {
            {$_ -in "1", "2", "3", "4", "5", "6", "7", "8"} {
                    $selection = $_
                    switch ($selection) {
                        "1" { $type = "addition" }
                        "2" { $type = "subtraction" }
                        "3" { $type = "mixed" }
                        "4" { $type = "multiplication" }
                        "5" { $type = "mul_fixed" }
                        "6" { $type = "mul_xy" }
                        "7" { $type = "division_whole" }
                        "8" { $type = "mixed_muldiv" }
                    }

                    $problemsPerSheet = Get-UserInput -Prompt "`nEnter number of problems per sheet" -Default 20
                    $count = Get-UserInput -Prompt "Enter number of worksheets to generate" -Default 50

                    switch ($type) {
                        "addition" { $digits = Get-UserInput -Prompt "Enter number of digits per operand" -Default 2; Generate-Worksheets -Digits $digits -Type addition -Count $count -ProblemsPerSheet $problemsPerSheet }
                        "subtraction" { $digits = Get-UserInput -Prompt "Enter number of digits per operand" -Default 2; Generate-Worksheets -Digits $digits -Type subtraction -Count $count -ProblemsPerSheet $problemsPerSheet }
                        "mixed" { $digits = Get-UserInput -Prompt "Enter number of digits per operand" -Default 2; Generate-Worksheets -Digits $digits -Type mixed -Count $count -ProblemsPerSheet $problemsPerSheet }
                        "multiplication" { $digits = Get-UserInput -Prompt "Enter number of digits per operand" -Default 1; Generate-Worksheets -Digits $digits -Type multiplication -Count $count -ProblemsPerSheet $problemsPerSheet }
                        "mul_fixed" {
                            $fixed = Get-UserInput -Prompt "Enter the fixed first factor (e.g., 2 for 2xN)" -Default 2
                            $otherMax = Get-UserInput -Prompt "Enter the maximum other factor" -Default 12
                            # generate custom sheets
                            if (-not (Test-Path $outputFolder)) { New-Item -ItemType Directory -Path $outputFolder | Out-Null }
                            for ($s=1; $s -le $count; $s++) {
                                $lines = @()
                                for ($i=1; $i -le $problemsPerSheet; $i++) {
                                    $lines += Generate-MultiplicationFixed -Fixed $fixed -OtherMax $otherMax
                                }
                                $filename = "mul_fixed_${fixed}_(${0:D2}).txt" -f $s
                                $filepath = Join-Path $outputFolder $filename
                                $lines | Out-File -FilePath $filepath -Encoding UTF8
                            }
                            Write-Host "Generated $count fixed-factor multiplication worksheets in: $outputFolder" -ForegroundColor Green
                        }
                        "mul_xy" {
                            $x = Get-UserInput -Prompt "Enter X (max for first factor)" -Default 12
                            $y = Get-UserInput -Prompt "Enter Y (max for second factor)" -Default 12
                            if (-not (Test-Path $outputFolder)) { New-Item -ItemType Directory -Path $outputFolder | Out-Null }
                            for ($s=1; $s -le $count; $s++) {
                                $lines = @()
                                for ($i=1; $i -le $problemsPerSheet; $i++) {
                                    $lines += Generate-MultiplicationXY -X $x -Y $y
                                }
                                $filename = "mul_${x}x${y}_(${0:D2}).txt" -f $s
                                $filepath = Join-Path $outputFolder $filename
                                $lines | Out-File -FilePath $filepath -Encoding UTF8
                            }
                            Write-Host "Generated $count ${x}x${y} multiplication worksheets in: $outputFolder" -ForegroundColor Green
                        }
                        "division_whole" {
                            $maxDivisor = Get-UserInput -Prompt "Enter maximum divisor" -Default 12
                            $maxQuotient = Get-UserInput -Prompt "Enter maximum quotient" -Default 12
                            if (-not (Test-Path $outputFolder)) { New-Item -ItemType Directory -Path $outputFolder | Out-Null }
                            for ($s=1; $s -le $count; $s++) {
                                $lines = @()
                                for ($i=1; $i -le $problemsPerSheet; $i++) {
                                    $lines += Generate-WholeDivision -MaxDivisor $maxDivisor -MaxQuotient $maxQuotient
                                }
                                $filename = "division_whole_(${0:D2}).txt" -f $s
                                $filepath = Join-Path $outputFolder $filename
                                $lines | Out-File -FilePath $filepath -Encoding UTF8
                            }
                            Write-Host "Generated $count division worksheets (no remainders) in: $outputFolder" -ForegroundColor Green
                        }
                        "mixed_muldiv" {
                            $maxDivisor = Get-UserInput -Prompt "Enter maximum divisor" -Default 12
                            $maxQuotient = Get-UserInput -Prompt "Enter maximum quotient" -Default 12
                            if (-not (Test-Path $outputFolder)) { New-Item -ItemType Directory -Path $outputFolder | Out-Null }
                            for ($s=1; $s -le $count; $s++) {
                                $lines = @()
                                for ($i=1; $i -le ($problemsPerSheet / 2); $i++) {
                                    $lines += Generate-MultiplicationXY -X $maxDivisor -Y $maxQuotient
                                }
                                for ($i=1; $i -le ($problemsPerSheet / 2); $i++) {
                                    $lines += Generate-WholeDivision -MaxDivisor $maxDivisor -MaxQuotient $maxQuotient
                                }
                                $lines = $lines | Get-Random -Count $lines.Count
                                $filename = "mixed_muldiv_(${0:D2}).txt" -f $s
                                $filepath = Join-Path $outputFolder $filename
                                $lines | Out-File -FilePath $filepath -Encoding UTF8
                            }
                            Write-Host "Generated $count mixed multiplication/division worksheets in: $outputFolder" -ForegroundColor Green
                        }
                    }

                Write-Host "`nPress any key to continue..." -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            
            "9" {
                if (Test-Path $outputFolder) {
                    Convert-ToIndividualBRF -SourceFolder $outputFolder
                } else {
                    Write-Host "`nNo worksheets folder found. Generate worksheets first." -ForegroundColor Yellow
                }
                
                Write-Host "`nPress any key to continue..." -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            
            "10" {
                if (Test-Path $outputFolder) {
                    $filename = Read-Host "`nEnter output filename (default: combined_worksheets.brf)"
                    if ([string]::IsNullOrWhiteSpace($filename)) {
                        $filename = "combined_worksheets.brf"
                    }
                    Convert-ToSingleBRF -SourceFolder $outputFolder -OutputFileName $filename
                } else {
                    Write-Host "`nNo worksheets folder found. Generate worksheets first." -ForegroundColor Yellow
                }
                
                Write-Host "`nPress any key to continue..." -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            
            "11" {
                $type = Get-WorksheetType
                $digits = Get-UserInput -Prompt "`nEnter number of digits per operand" -Default 2
                $count = Get-UserInput -Prompt "Enter number of worksheets to generate" -Default 50
                
                Generate-Worksheets -Digits $digits -Type $type -Count $count
                Convert-ToIndividualBRF -SourceFolder $outputFolder
                
                Write-Host "`nPress any key to continue..." -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            
            "12" {
                $type = Get-WorksheetType
                $digits = Get-UserInput -Prompt "`nEnter number of digits per operand" -Default 2
                $count = Get-UserInput -Prompt "Enter number of worksheets to generate" -Default 50
                $filename = Read-Host "Enter output filename (default: combined_worksheets.brf)"
                if ([string]::IsNullOrWhiteSpace($filename)) {
                    $filename = "combined_worksheets.brf"
                }
                
                Generate-Worksheets -Digits $digits -Type $type -Count $count
                Convert-ToSingleBRF -SourceFolder $outputFolder -OutputFileName $filename
                
                Write-Host "`nPress any key to continue..." -ForegroundColor Gray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            
            "13" {
                Write-Host "`nExiting... Goodbye!" -ForegroundColor Green
                break
            }
            
            default {
                Write-Host "`nInvalid choice. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    } while ($choice -ne "13")
}
