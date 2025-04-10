#!/bin/bash

# Input file containing hashes
HASHFILE="hashes.txt"
WORDLIST="merged_wordlist.txt"  # Specify your wordlist file here
LOGFILE="hashcat_log.txt"
ERRORLOG="hashcat_errors.txt"
GPU_LOG="gpu_usage_log.txt"

md5_hashes=()
sha1_hashes=()
sha256_hashes=()

# Read each hash and group them by type
while read -r hash; do
  # Remove any whitespace from the hash
  hash=$(echo "$hash" | tr -d '[:space:]')
  
  # Identify hash type by length and categorize them
  if [ ${#hash} -eq 32 ]; then
    md5_hashes+=("$hash")  # MD5 hashes (32 characters)
  elif [ ${#hash} -eq 40 ]; then
    sha1_hashes+=("$hash")  # SHA-1 hashes (40 characters)
  elif [ ${#hash} -eq 64 ]; then
    sha256_hashes+=("$hash")  # SHA-256 hashes (64 characters)
  else
    echo "Unknown hash type: $hash" | tee -a "$ERRORLOG"
  fi
done < "$HASHFILE"

# Function to run Hashcat and log results while displaying output in the terminal
run_hashcat () {
  hash_mode=$1
  hash_type=$2
  hashes=("${!3}")  # Get the array of hashes for the specified type

  if [ ${#hashes[@]} -gt 0 ]; then
    echo "Running Hashcat for $hash_type hashes..."
    
    # Start logging GPU usage and display it in the terminal
    nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used --format=csv -l 5 | tee -a "$GPU_LOG" & 
    GPU_LOG_PID=$!

    # Run Hashcat for this batch of hashes, display output in the terminal, and log results
    printf "%s\n" "${hashes[@]}" | ./hashcat -m $hash_mode -a 0 -w 3 $WORDLIST | tee -a "$LOGFILE"

    # Stop GPU logging after Hashcat finishes
    kill $GPU_LOG_PID
  fi
}

# Run Hashcat for MD5 hashes (mode -m 0)
run_hashcat 0 "MD5" md5_hashes[@]

# Run Hashcat for SHA-1 hashes (mode -m 100)
run_hashcat 100 "SHA-1" sha1_hashes[@]

# Run Hashcat for SHA-256 hashes (mode -m 1400)
run_hashcat 1400 "SHA-256" sha256_hashes[@]

echo "Hashcat processing complete."
