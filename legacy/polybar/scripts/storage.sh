#!/bin/sh

storage() {
    TOTAL=$(df -h / | grep '/'| awk '{print $2}')
    FREE=$(df -h / | grep '/'| awk '{print $3}')
    PERCENT=$(df -h / | grep '/'| awk '{print $5}')

    printf " $FREE/$TOTAL $PERCENT%"
}

storage
