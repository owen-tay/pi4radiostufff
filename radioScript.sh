#!/bin/bash

# FM Frequency
FREQ=107  # Changed to a legal FM frequency in the UK (adjust as needed)

# Lapfox Radio Stream
STREAM_URL="https://radio.lapfoxradio.com/radio/8000/stream-mp3-320.mp3"

# Store process IDs to clean up later
RDS_PID=""
STREAM_PID=""

# Function to start the RDS broadcast (runs once, no infinite loop)
start_rds() {
    echo "Starting persistent RDS broadcast: Lapfox Radio"
    sudo ./pi_fm_rds -freq "$FREQ" -ps "AAAAAAAAAAAA" -rt "AAAAAAAA" &
    RDS_PID=$!
}

# Function to clean up all background processes before exiting
cleanup() {
    echo "Stopping all transmissions..."
    [[ ! -z "$STREAM_PID" ]] && kill "$STREAM_PID" 2>/dev/null
    [[ ! -z "$RDS_PID" ]] && kill "$RDS_PID" 2>/dev/null
    exit 0
}

# Trap Ctrl+C (SIGINT) to run the cleanup function
trap cleanup SIGINT

# Start the RDS process in the background (runs once)
start_rds

# Function to play the live stream and auto-restart if it crashes
play_stream() {
    while true; do
        echo "Streaming Lapfox Radio..."
        sox -t mp3 "$STREAM_URL" -c 1 -t wav - | sudo ./pi_fm_rds -freq "$FREQ" -audio - &
        STREAM_PID=$!
        wait $STREAM_PID  # Wait until stream process stops
        echo "Stream stopped. Restarting..."
        sleep 2  # Short delay before restarting
    done
}

# Start streaming Lapfox Radio in a background process
play_stream
done


 #dobe!