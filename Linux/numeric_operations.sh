#!/bin/bash

# There are other operators:
# -le less than or equal to
# -ge greater than or equal to
# -ne not equal to
# -lt less than
# -eq equal to
# -gt greater than
# MongoDB is also uses these kind of operators.

NUMBER=10

if [ $NUMBER -lt 5 ]; then
  echo "The number is less than 5"
elif [ $NUMBER -eq 10 ]; then
  echo "The number is exactly 10"
elif [ $NUMBER -gt 15 ]; then
  echo "The number is greater than 15"
else
  echo "The number is between 5 and 15, but not 10"
fi
