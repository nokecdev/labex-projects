#!/bin/bash

echo "Enter the current temperature in Celsius: "
read temp

# Use the following temperature ranges:
# Below 0°C: "It's freezing! Wear a heavy coat and gloves."
# 0°C to 10°C: "It's cold. A warm jacket is recommended."
# 11°C to 20°C: "It's cool. A light jacket should suffice."
# Above 20°C: "It's warm. Enjoy the pleasant weather!"

if [ "$temp" -lt 0 ]; then
    echo "It's freezing! Wear a heavy coat and gloves."
elif [ "$temp" -le 10 ]; then
    echo "It's cool. A warm jacket is recommended"
elif [ "$temp" -le 20 ]; then
    echo "A light jacket should suffice."
else
    echo "It's warm. Enjoy the pleasant weather!"
fi