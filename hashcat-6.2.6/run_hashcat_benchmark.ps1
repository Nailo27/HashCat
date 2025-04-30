# Hashcat Windows GPU Benchmark Script
# Filename: run_hashcat_benchmark.ps1
# Usage: Right-click and "Run with PowerShell" or run from a PowerShell terminal

$hashcatPath = "C:\Users\tenso\Downloads\hashcat-6.2.6\hashcat.exe"
$benchmarkModes = @("0", "100", "1400", "1700", "1000", "3200", "22000")
$outputFile = "benchmark_results.txt"

# Create or overwrite the output file
"Hashcat GPU Benchmark Report - $(Get-Date)" | Out-File $outputFile
"Using: $hashcatPath" | Out-File $outputFile -Append

# Check GPU and environment info
"`n=== Device Info (hashcat -I) ===" | Out-File $outputFile -Append
& $hashcatPath -I | Out-File $outputFile -Append

# Run benchmarks
foreach ($mode in $benchmarkModes) {
    "`n=== Benchmarking mode -m $mode ===" | Out-File $outputFile -Append
    & $hashcatPath -m $mode -b --force -O -w 4 | Out-File $outputFile -Append
    Start-Sleep -Seconds 2
}

"`nBenchmark complete. Results saved to $outputFile" | Out-File $outputFile -Append
Start-Process notepad.exe $outputFile
