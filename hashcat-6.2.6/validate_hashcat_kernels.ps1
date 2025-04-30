# Validate Hashcat Modified Kernel Output Script
# Filename: validate_hashcat_kernels.ps1
# Usage: Run inside your Hashcat "build/Release" directory after building.

$hashcatPath = "C:\dev\hashcat-build\build\Release\hashcat.exe"
$outputFile = "kernel_validation_results.txt"
$hashModes = @("0", "100", "1400", "1700", "1000", "3200", "22000")

# Start new results file
"Hashcat Kernel Validation Report - $(Get-Date)" | Out-File $outputFile
"Using: $hashcatPath" | Out-File $outputFile -Append

# Basic Device Info
"`n=== Device Info ===" | Out-File $outputFile -Append
& $hashcatPath -I | Out-File $outputFile -Append

# Validate kernels with example hashes
foreach ($mode in $hashModes) {
    "`n=== Validating Kernel for Mode -m $mode ===" | Out-File $outputFile -Append
    try {
        & $hashcatPath -m $mode --example-hashes | Out-File $outputFile -Append
        Start-Sleep -Seconds 1
    } catch {
        "[!] Error running mode $mode" | Out-File $outputFile -Append
    }
}

"`nValidation complete. Results saved to $outputFile" | Out-File $outputFile -Append
Start-Process notepad.exe $outputFile