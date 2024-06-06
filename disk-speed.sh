#!/bin/bash

show_help() {
    echo "Disk Speed Help"
    echo
    echo "Options:"
    echo "  --path      Path of directory to read/write from."
    echo "  --size      Size of the temp file to write and read from to measure performance. Units are 10 for bytes, 10M for megabytes, 10G for gigabytes, 10T for terabytes"
    echo "  --sudo      Run the script with sudo."
    echo "  --no-sudo   Run the script without sudo (default)."
    echo "  --debug     Enable debug mode."
    echo "  --help      Show this help menu."
}

use_sudo=false
debug=false

# Parse the arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --path) path="$2"; shift ;;
        --size) size="$2"; shift ;;
        --sudo) use_sudo=true ;;
        --no-sudo) use_sudo=false ;;
        --debug) debug=true ;;
        --help) show_help; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
    esac
    shift
done

if [[ -z "$path" || -z "$size" ]]; then
    echo "Error: --path and --size are required."
    show_help
    exit 1
fi

if $debug; then
    set -x
fi

# Identify the device
device=$(df "$path" | tail -1 | awk '{print $1}')

# Determine the size in megabytes and bytes for calculations
case $size in
    *G) size_mb=$(( ${size%G} * 1024 )); size_bytes=$(( ${size%G} * 1024 * 1024 * 1024 )) ;;
    *M) size_mb=${size%M}; size_bytes=$(( ${size%M} * 1024 * 1024 )) ;;
    *K) size_mb=$(( ${size%K} / 1024 )); size_bytes=$(( ${size%K} * 1024 )) ;;
    *T) size_mb=$(( ${size%T} * 1024 * 1024 )); size_bytes=$(( ${size%T} * 1024 * 1024 * 1024 * 1024 )) ;;
    *) size_mb=$(( size / 1024 / 1024 )); size_bytes=$(( size )) ;;
esac

# Set the command prefix based on the sudo flag
cmd_prefix=""
if $use_sudo; then
    cmd_prefix="sudo"
fi

# Perform write speed test
start_time=$(date +%s.%N)
$cmd_prefix dd if=/dev/zero of="$path/testfile" bs=1M count="$size_mb" oflag=direct > /dev/null 2>&1
$cmd_prefix sync
end_time=$(date +%s.%N)
write_time=$(echo "$end_time - $start_time" | bc)

# Perform read speed test
start_time=$(date +%s.%N)
$cmd_prefix dd if="$path/testfile" of=/dev/null bs=1M iflag=direct > /dev/null 2>&1
end_time=$(date +%s.%N)
read_time=$(echo "$end_time - $start_time" | bc)

# Clean up
$cmd_prefix rm -f "$path/testfile"

# Calculate speeds in MB/s
write_speed_value=$(echo "scale=3; $size_bytes / $write_time / 1024 / 1024" | bc -l)
read_speed_value=$(echo "scale=3; $size_bytes / $read_time / 1024 / 1024" | bc -l)

# Output the results
echo "Path: $path"
echo "Device: $device"
echo
echo "Write Speed: ${write_speed_value} MB/s (took ${write_time}s to write $size)"
echo "Read Speed: ${read_speed_value} MB/s (took ${read_time}s to read $size)"
