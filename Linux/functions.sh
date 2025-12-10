#!/bin/bash

#Create function with parameter
greet() {
    echo "Hello $1"
}

calculate() {
    echo "The sum of $1 and $2 is $(($1 + $2))"
}

# Call functions with parameters
greet "Alice"
calculate 5 3

echo 
## Return variables from functions
get_square() {
    echo $(($1 * $1))
}

### Global variables
RESULT=0
set_global_result() {
    RESULT=$(($1 * $1))
}

square_of_5=$(get_square 5)
echo "The square of 5 is $square_of_5"

set_global_result 6
echo "The square of 6 is $RESULT"

echo "------ Global and local scope ------------"
# In shell scripts, variables are global by default. This means they can be accessed from anywhere in the script. 
# However, you can use the local keyword to create variables that are only accessible within a function. 
# This is called local scope.



GLOBAL_VAR="I'm global"

demonstrate_scope() {
    local LOCAL_VAR="I'm local"
    echo "Inside function: GLOBAL_VAR = $GLOBAL_VAR"
    echo "Inside function: LOCAL_VAR = $LOCAL_VAR"
}

# Call the function
demonstrate_scope

echo "Outside function: GLOBAL_VAR = $GLOBAL_VAR"
echo "Outside function: LOCAL_VAR = $LOCAL_VAR"


## ----------------------------
echo

ENGLISH_CALC() {
  local num1=$1
  local operation=$2
  local num2=$3
  local result

  case $operation in
    plus)
      result=$((num1 + num2))
      echo "$num1 + $num2 = $result"
      ;;
    minus)
      result=$((num1 - num2))
      echo "$num1 - $num2 = $result"
      ;;
    times)
      result=$((num1 * num2))
      echo "$num1 * $num2 = $result"
      ;;
    *)
      echo "Invalid operation. Please use 'plus', 'minus', or 'times'."
      return 1
      ;;
  esac
}

# Test the function
ENGLISH_CALC 3 plus 5
ENGLISH_CALC 5 minus 1
ENGLISH_CALC 4 times 6
ENGLISH_CALC 2 divide 2 # This should show an error message
