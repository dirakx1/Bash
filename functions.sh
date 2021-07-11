#!/bin/bash
## Example for a bash function script


# function1
function function1() {
    # do something here
}
# function2
function function2() {
    # do something else here
}

# function3
function function3() {
   # do something else here
}

if [ "$1" = "function1" ]; then #EVAL input from the user
 function1
fi

if [ "$1" = "function2" ]; then
 function2
fi

if [ "$1" = "function3" ]; then
 function3
fi

if [ "$1" != "function1" ] && [ "$1" != "function2" ] && [ "$1" != "function3" ]; then
    echo -e "You must provide a valid function name"
    exit
fi
