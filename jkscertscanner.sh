#!/bin/bash

function check_status(){
  EXPIRYDATESECS=$(date --date "$1" +%s)
  NOW=$(date +%s)
  THEN=$(date --date '3 months' +%s)
  if [ $EXPIRYDATESECS -gt $THEN ]; then
    return 0
  elif [ $EXPIRYDATESECS -gt $NOW ]; then
    return 1
  else
    return 2
  fi
}

TMPFILE=$(mktemp)
java ChangeSourceKeystorePassword $1 $TMPFILE

keytool -list -v -keystore $TMPFILE -storepass secret | while read x; do
  case "$x" in
    Alias* ) ALIAS=$x ;;
    Valid* ) VALIDFROM=$(echo "$x" | sed 's/until.*//')
             EXPIRES=$(echo "$x" | sed 's/.*until:/Expires:/') ;;
    Owner* ) OWNER=$x ;;
    Issuer* ) ISSUER=$x ;;
    * ) continue ;;
  esac

  if [ -n "$ALIAS" ] && [ -n "$OWNER" ] && [ -n "$ISSUER" ] && [ -n "$VALIDFROM" ] && [ -n "$EXPIRES" ]; then
    EXPIRYDATE=$(echo $EXPIRES | sed 's/Expires: //')
    check_status "$EXPIRYDATE"
    STATUS=$?
    cat <<EOF
$ALIAS
$OWNER
$ISSUER
$VALIDFROM
EOF
    case "$STATUS" in
      0 ) echo "$EXPIRES" ;;
      1 ) echo "$EXPIRES (WARNING)" ;;
      2 ) echo "$EXPIRES (CRITICAL)" ;;
    esac
  fi
  echo
done
rm -f $TMPFILE
