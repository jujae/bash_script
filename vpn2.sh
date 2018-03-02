#!/bin/sh
#
# vpn2 - connect to vpn2.tue.nl
#
# $Id: vpn2 1294 2017-12-21 15:45:05Z rp $

# originally by Guus Bertens

set -e

PATH=/usr/sbin:/usr/bin:/bin
export PATH

me=`basename "$0"`

# to obtain the following value, do e.g.
# : |
# openssl s_client -connect vpn2.tue.nl:443 2>/dev/null |
# perl -ne '/^-.*CERTIFICATE/ ... /^-.*CERTIFICATE/ and print' > /tmp/vpn2.crt;
# openssl x509 -in /tmp/vpn2.crt -noout -fingerprint |
# perl -ne 's/.*=//; s/://g; print'
VPN2_CERT=A1C058FAB9A7650BF26CB50385EEE31E623F5C0F

PIDFILE=/var/run/tuevpn.pid

if [ ! -w /etc/passwd ]
then
  ### We are not root. ###
  exec sudo "$0" "$@"
fi

### We are root. ###

Warn() { echo $me: $@ >&2; }
Die() { Warn fatal error: $@, aborting; exit 1; }

DieIfMissing()
{
  type $1 >/dev/null 2>/dev/null ||
    Die please install the $1 package
}

StopVpn2()
{  
  if [ ! -f $PIDFILE ]
  then
    Warn no pidfile for openconnect, no need to stop it
    return
  fi

  PID=`cat $PIDFILE`
  CMD=`ps -o cmd= -p $PID | awk '{print $1}'`

  case "$CMD" in
  openconnect)
    DieIfMissing openconnect
    Warn pidfile $PIDFILE found for running $CMD, killing it
    kill $PID
    if [ $? -ne 0 ]; then
      Die could not kill process $PID.  Check pidfile $PIDFILE.
    fi
    rm $PIDFILE
    ;;
  "")
    Warn pidfile $PIDFILE found, but no process, remove the file
    rm $PIDFILE
    ;;
  *)
    Die pidfile $PIDFILE found for non-openconnect process $CMD
    ;;
  esac
}

StartVpn2()
{
  if [ -f $PIDFILE ]
  then
    Die pidfile $PIDFILE already exists
  fi

  DieIfMissing openconnect

  openconnect \
    --authgroup '2: Tunnel TU/e traffic' \
    --servercert ${VPN2_CERT} \
    --background --pid-file "$PIDFILE" \
    vpn2.tue.nl
}

Help()
{
  cat >&2 <<ZZ
Usage:

  $me
  $me start
  $me on

    to start a VPN connection to vpn2.tue.nl;
    this requires sudo root permissions;
    first sudo will be invoked (usually asking you for your local password),
    then the VPN connection asks you for your TUE username and password.

  $me stop
  $me off

    to stop the existing VPN connection, if any

  $me restart
  $me offon

    to stop and then start

ZZ
}

case "$1" in
stop|off) StopVpn2;;
start|on|'') StartVpn2;;
restart|offon) StopVpn2; StartVpn2;;
help) Help;;
*) Warn Usage: $me '[start|stop|restart|help]';;
esac
