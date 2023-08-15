#!/bin/bash

case "$1" in
  "codenames")
    awk '$1 == "Codename:" { print $2 }' conf/distributions
    ;;
  "sign_with")
    awk '$1 == "SignWith:" { print $2 }' conf/distributions | head -n 1
    ;;
esac
