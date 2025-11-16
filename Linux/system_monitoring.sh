#!/bin/bash

CPU_TRESHOLD=80
MEM_TRESHOLD=80
DISK_TRESHOLD=80

while true; do
    # Monitor CPU usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    cpu_usage=${cpu_usage%.*} # Convert to integer
    echo "Current CPU usage: $cpu_usage%"

    #Monitor Memory usage
    #free = provides memory usage stats
    memory_usage=$(free | awk '/Mem/ {printf("%3.1f", ($3/$2) * 100)}')
    echo "Current memory usage: $memory_usage%"
    memory_usage=${memory_usage%.*}

    #Monitor disk usage
    #df -h / fetch disk usage stats for the root dir
    #echo "$(df -h / | awk '/\// {printf $(NF-1)}')"
    #This writes out also the total and used disk size:
    #echo "$(df -h | awk 'NR==2 {print "Size: "$2", Used: "$3}')"
    #overlay          20G  127M   20G   1% /

    disk_usage=$(df -h / | awk '/\// {printf $(NF-1)}')
    disk_usage=${disk_usage%?} #Remove the % sign
    echo "Current disk usage: $disk_usage%"

    if ((cpu_usage >= CPU_TRESHOLD )); then
        send_alert "CPU" "$cpu_usage"
    fi
    if ((memory_usage >= MEM_TRESHOLD)); then
        send_alert "Memory" "$memory_usage"
    fi
    if ((disk_usage >= DISK_TRESHOLD)); then
        send_alert "Disk" "$disk_usage"
    fi
    
    # Display current stats
    clear
    echo "Resource Usage:"
    echo "CPU: $cpu_usage%"
    echo "Memory: $memory_usage%"
    echo "Disk: $disk_usage%"

    #Optional:
    #Extend with logging:
    
    # Use the current date and time, along with CPU, memory, and disk usage values.
    date=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$date CPU: $cpu_usage% Memory: $memory_usage% Disk: $disk_usage%" >> resource_usage.log
    
    sleep 2
   
done

send_alert() {
    echo "$(tput setaf 1)ALERT: $1 usage exceeded treshold! Current value: $2%$(tput sgr0)"
}
