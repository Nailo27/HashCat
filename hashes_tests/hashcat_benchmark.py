#!/usr/bin/env python3
# hashcat_benchmark.py

import subprocess
import argparse
import os
import time
import csv
import matplotlib.pyplot as plt
from datetime import datetime

# ========== Configuration Defaults ==========
HASHES_DIR = "hashes"
OUTPUT_DIR = "benchmarks"
CSV_FILE = os.path.join(OUTPUT_DIR, "benchmark_results.csv")
HASHCAT_BIN = "hashcat"
DEVICE_LOG = True  # Toggle GPU stats (NVIDIA only)
REPEATS_DEFAULT = 3

# ========== Utility Functions ==========
def run_command(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT).decode()
    except subprocess.CalledProcessError as e:
        return e.output.decode()

def read_hash_and_plaintext(mode):
    hfile = os.path.join(HASHES_DIR, f"m{mode:05}.hash")
    pfile = os.path.join(HASHES_DIR, f"m{mode:05}.plaintext")
    hashes = open(hfile).read().splitlines() if os.path.exists(hfile) else []
    plains = open(pfile).read().splitlines() if os.path.exists(pfile) else []
    return hashes, plains

def get_gpu_utilization():
    try:
        out = subprocess.check_output("nvidia-smi --query-gpu=utilization.gpu,memory.used --format=csv,noheader,nounits", shell=True)
        usage = out.decode().strip().split("\n")[0].split(',')
        return int(usage[0]), int(usage[1])
    except:
        return None, None

def plot_performance_chart(results):
    modes = [f"m{r['mode']:05}" for r in results]
    speeds = [float(r['hashrate'].split()[0]) if r['hashrate'] != '-' else 0 for r in results]
    plt.figure(figsize=(10, 5))
    plt.bar(modes, speeds)
    plt.xlabel("Hash Mode")
    plt.ylabel("Speed (H/s)")
    plt.title("Hashrate by Mode")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, "performance_chart.png"))
    plt.close()

# ========== Core Benchmarking ==========
def benchmark_mode(mode):
    output = run_command(f"{HASHCAT_BIN} -b -m {mode} --quiet")
    speed = "N/A"
    build = "N/A"
    for line in output.splitlines():
        if "Speed." in line:
            speed = line.split(':')[1].strip()
        if "Build." in line:
            build = line.split(':')[1].strip()
    return speed, build

def test_mode(mode, hashes, plains):
    hash_file = os.path.join(OUTPUT_DIR, f"temp_m{mode}.hash")
    plain_file = os.path.join(OUTPUT_DIR, f"temp_m{mode}.dict")

    with open(hash_file, 'w') as f:
        f.write("\n".join(hashes))
    with open(plain_file, 'w') as f:
        f.write("\n".join(plains))

    potfile = os.path.join(OUTPUT_DIR, f"potfile_m{mode}.pot")
    output = run_command(f"{HASHCAT_BIN} -a 0 -m {mode} {hash_file} {plain_file} -O --potfile-path {potfile} --quiet --status")

    cracked = 0
    if os.path.exists(potfile):
        with open(potfile) as f:
            pot = f.read()
            for plain in plains:
                if plain in pot:
                    cracked += 1
    acc = (cracked / len(plains)) * 100 if plains else 0
    return cracked, acc

# ========== Reporting ==========
def write_markdown(mode, speed, build, util, vram, accuracy, repeats):
    path = os.path.join(OUTPUT_DIR, f"m{mode:05}.md")
    with open(path, 'w') as f:
        f.write(f"## 🔐 Hash Mode m{mode:05}\n\n")
        f.write(f"**Date:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"**Repeats:** {repeats}\n\n")
        f.write("### 📊 Benchmark Results\n\n")
        f.write("| Metric | Value |\n")
        f.write("|--------|-------|\n")
        f.write(f"| Hashes/sec | {speed} |\n")
        f.write(f"| Build Time | {build} |\n")
        f.write(f"| GPU Utilization | {util}% |\n")
        f.write(f"| VRAM Used | {vram} MB |\n")
        f.write(f"| Accuracy | {accuracy}% |\n")

def append_csv(results):
    fieldnames = ["mode", "hashrate", "build_time", "gpu_util", "vram", "accuracy"]
    with open(CSV_FILE, 'w', newline='') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for result in results:
            writer.writerow(result)

# ========== Main ==========
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--modes', nargs='+', type=int, required=True, help='Hash modes to test (e.g. 0 1000 1400)')
    parser.add_argument('--benchmark', action='store_true', help='Run in benchmark mode')
    parser.add_argument('--test', action='store_true', help='Run in test mode with .hash and .plaintext')
    parser.add_argument('--repeats', type=int, default=REPEATS_DEFAULT)
    args = parser.parse_args()

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    all_results = []

    for mode in args.modes:
        print(f"\n[+] Processing Hash Mode: {mode}")
        total_speed = []
        total_build = []
        total_accuracy = []

        hashes, plains = read_hash_and_plaintext(mode)

        for r in range(args.repeats):
            print(f"    - Run {r+1}/{args.repeats}")
            speed, build = ("N/A", "N/A")
            if args.benchmark:
                speed, build = benchmark_mode(mode)

            acc = 0
            if args.test and hashes:
                _, acc = test_mode(mode, hashes, plains)

            total_speed.append(speed)
            total_build.append(build)
            total_accuracy.append(acc)

        avg_speed = total_speed[-1] if total_speed[-1] != "N/A" else "-"
        avg_build = total_build[-1] if total_build[-1] != "N/A" else "-"
        avg_acc = round(sum(total_accuracy) / len(total_accuracy), 2) if args.test else "-"
        util, vram = get_gpu_utilization() if DEVICE_LOG else ("-", "-")

        write_markdown(mode, avg_speed, avg_build, util, vram, avg_acc, args.repeats)

        all_results.append({
            "mode": mode,
            "hashrate": avg_speed,
            "build_time": avg_build,
            "gpu_util": util,
            "vram": vram,
            "accuracy": avg_acc
        })

    append_csv(all_results)
    plot_performance_chart(all_results)

if __name__ == '__main__':
    main()
