#!/bin/sh

VALOR=$(dolar | grep 'Cotação')

printf "$VALOR"
