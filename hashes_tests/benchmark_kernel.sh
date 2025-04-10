#!/bin/bash

# ================================
# Benchmarking Script for Hashcat
# Author: Nailo27 (Template by ChatGPT)
# Purpose: Automates performance tests on custom hash modes
# ================================

HASH_MODE=$1
TEST_TYPE=$2
MASK='?l?l?l?l?l'
EXAMPLE_HASHES="test.hash"
HASHCAT_PATH="hashcat"

OUT_DIR="benchmarks"
mkdir -p "$OUT_DIR"
OUT_FILE="$OUT_DIR/m${HASH_MODE}_results.md"
DATESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "🔧 Running benchmark for mode $HASH_MODE..."
if [ "$TEST_TYPE" == "benchmark" ]; then
    BENCH_OUTPUT=$($HASHCAT_PATH -b -m $HASH_MODE --quiet 2>/dev/null)
elif [ "$TEST_TYPE" == "test" ]; then
    echo "password" | $HASHCAT_PATH -a 3 -m $HASH_MODE -O $MASK --potfile-disable --quiet --status 2>/dev/null > /tmp/hashcat_out.txt
    BENCH_OUTPUT=$(cat /tmp/hashcat_out.txt)
else
    echo "Usage: $0 <mode> <benchmark|test>"
    exit 1
fi

HPS=$(echo "$BENCH_OUTPUT" | grep -i "Speed" | awk -F ':' '{print $2}' | xargs)
BUILD_TIME=$(echo "$BENCH_OUTPUT" | grep -i "Build" | awk -F ':' '{print $2}' | xargs)
UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n 1)

cat > "$OUT_FILE" <<EOF
## 🔒 Mode m${HASH_MODE}

**Date:** $DATESTAMP  
**Test Type:** \`$TEST_TYPE\`  
**Hash Mode ID:** \`$HASH_MODE\`

---

### 📊 Benchmark Results

| Metric              | Value             |
|---------------------|-------------------|
| Hashes/sec          | \`$HPS\`          |
| Kernel Build Time   | \`$BUILD_TIME\`   |
| GPU Utilization     | \`$UTIL%\`        |

---

> ⚙️ Run command: \`hashcat -m $HASH_MODE -a 3 -O $MASK\`
EOF
