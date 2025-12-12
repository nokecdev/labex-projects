#!/bin/bash

add() {
    echo $(($1 + $2))
}

subtract() {
    echo $(($1 - $2))
}

multiply() {
    echo $(($1 * $2))
}

divide() {
    # Remember to handle division by zero
    if [ $2 -lt 1 ]; then
        echo "You can not divide by zero"
    else 
        echo $(($2 / $1))
    fi
}

echo "Enter first number: "
read num1
echo "Enter second number: "
read num2
echo "Enter operation (+, -, *, /): "
read op

case $op in
    "+") result=$(add $num1 $num2) ;;
    "-") result=$(subtract $num1 $num2) ;;
    "*") result=$(multiply $num1 $num2) ;;
    "/") result=$(divide $num1 $num2) ;;
    *) result="Error: Invalid operation" ;;
esac

echo "Result: $result"
