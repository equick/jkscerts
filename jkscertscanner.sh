#!/bin/bash

function reset_vars(){
  unset ALIAS OWNER ISSUER VALIDFROM EXPIRES STATUS
}

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


while getopts "chk:mw" arg; do
  case $arg in
    c) show_critical=1
       ;;
    h) echo "usage" 
       ;;
    k) KEYSTORE=$OPTARG
       ;;
    m) check_mk=1
       ;;
    w) show_warning=1
       ;;
  esac
done

TMPFILE=$(mktemp)
java ChangeSourceKeystorePassword $KEYSTORE $TMPFILE
#check keystore here

declare -A CERTLIST

while read -r x; do
  case "$x" in
    Alias* ) ALIAS=$(echo "$x" | sed 's/Alias name: //')
             ;;
    Valid* ) VALIDFROM=$(echo "$x" | sed -e 's/until.*//;s/Valid from: //')
             EXPIRES=$(echo "$x" | sed -e 's/.*until:/Expires:/;s/Expires: //')
             ;;
    Owner* ) OWNER=$(echo "$x" | sed 's/Owner: //')
             CN=$(echo $OWNER | sed -e 's/.*CN=//;s/,.*//')
             ;;
    Issuer* ) ISSUER=$(echo "$x" | sed 's/Issuer: //')
             ;;
    * ) continue
        ;;
  esac

  if [[ -n "$ALIAS" && -n "$OWNER" && -n "$ISSUER" && -n "$VALIDFROM" ]]; then
    check_status "$EXPIRES"
    STATUS=$?

    case "$STATUS" in
      0 ) [[ -n $show_warning || -n $show_critical ]] && reset_vars && continue
          CERTSTATUS="OK"
          ;;
      1 ) [[ -n $show_critical ]] && [[ -z $show_warning ]] && reset_vars && continue
          CERTSTATUS="WARNING"
          ;;
      2 ) [[ -n $show_warning ]] && [[ -z $show_critical ]] && reset_vars && continue 
          CERTSTATUS="CRITICAL"
          ;;
      3 ) CERTSTATUS="UNKNOWN"
          ;;
    esac

    if [[ -n $check_mk ]]; then
      CERTLIST["$ALIAS"]="$CERTSTATUS - ALIAS: $ALIAS, CN: $CN, EXPIRES: $EXPIRES, KEYSTORE: $KEYSTORE"
    else
      CERTLIST["$ALIAS"]=$(cat <<EOF
ALIAS: $ALIAS
OWNER: $OWNER
ISSUER: $ISSUER
VALID FROM: $VALIDFROM
EXPIRES: $EXPIRES
STATUS: $CERTSTATUS
EOF
)
    fi
    reset_vars
  fi
done < <(keytool -list -v -keystore $TMPFILE -storepass secret)

# remove the keystore copy
rm -f $TMPFILE

# render the output
if [[ -n $check_mk ]]; then
  for K in "${!CERTLIST[@]}"; do 
    echo "${CERTLIST[$K]}"
  done | sort -k 3
else
  for K in "${!CERTLIST[@]}"; do
    echo "${CERTLIST[$K]}"
    echo
  done
fi
