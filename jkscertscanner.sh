#!/bin/bash

function usage(){
  cat <<EOF
Usage: $0 -k <keystore>
                        Display all certificates and status
      -v                Display all certificates and status (verbose)
      -w                Display all certificates due to expire (default: in next 3 months)
      -w -t '1 week'    Display all certificates due to expire in 1 week
      -w -t '2 weeks'   Display all certificates due to expire in 2 weeks
      -w -t '2 months'  Display all certificates due to expire in 2 months
      -c                Display all certificates that have already expired
EOF
  exit
}

function reset_vars(){
  unset ALIAS OWNER ISSUER VALIDFROM EXPIRES STATUS
}

function check_status(){
  EXPIRYDATESECS=$(date --date "$1" +%s)
  NOW=$(date +%s)
  THEN=$(date --date "$WARNING_PERIOD" +%s)
  if [ $EXPIRYDATESECS -gt $THEN ]; then
    return 0
  elif [ $EXPIRYDATESECS -gt $NOW ]; then
    return 1
  else
    return 2
  fi
}

while getopts "chk:t:wv" arg; do
  case $arg in
    c) show_critical=1
       ;;
    h) usage
       ;;
    k) KEYSTORE=$OPTARG
       ;;
    t) WARNING_PERIOD=$OPTARG
       ;;
    v) verbose=1
       ;;
    w) show_warning=1
       ;;
    *) usage
       ;;
  esac
done

[[ -z $KEYSTORE ]] && usage

[[ -z $WARNING_PERIOD ]] && WARNING_PERIOD='3 months'

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

    if [[ -z $verbose ]]; then
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
if [[ -z $verbose ]]; then
  for K in "${!CERTLIST[@]}"; do 
    echo "${CERTLIST[$K]}"
  done | sort -k 3
else
  for K in "${!CERTLIST[@]}"; do
    echo "${CERTLIST[$K]}"
    echo
  done
fi
