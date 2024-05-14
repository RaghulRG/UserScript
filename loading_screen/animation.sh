#!/bin/bash

func1() {
   #your script
    echo > num.txt
    for i in {1..100}; do
        echo $i >> num.txt
        sleep 0.3
    done
}

func2() {
   #your scripr
    echo > num1.txt
    for i in {1..100..2}; do
        echo $i >> num1.txt
        sleep 0.3
    done
}

loading_animation() {
    local load_style="Ooooo oOooo ooOoo oooOo ooooO"
    while kill -0 "$1" 2>/dev/null; do
        for i in ${load_style}; do
            echo -ne "\r Loading [ ${i} ]"
            sleep 0.3
        done
    done
    echo -ne "\r"  
}

echo ""
echo " Initiated process"
echo ""
func1 & f1_pid=$!
loading_animation $f1_pid
echo -ne "\r"
echo " proceeding to next.."
sleep 5
func2 & f2_pid=$!
loading_animation $f2_pid
echo -ne "\r"
echo "                                                 "
echo " done!"

