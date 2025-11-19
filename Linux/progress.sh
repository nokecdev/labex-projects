#!/bin/bash

# Function to show a simple progress bar
show_progress() {
  local duration=$1
  local steps=10
  local step_duration=$(echo "scale=2; $duration / $steps" | bc)

  echo "Starting process..."
  echo -n "Progress: ["
  for i in {1..10}; do
    sleep $step_duration
    echo -n "#"
  done
  echo "] Done!"
}

# Run a process that takes 5 seconds with a progress indicator
show_progress 5
echo "Process completed successfully."