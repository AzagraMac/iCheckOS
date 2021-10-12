#!/bin/sh

AMARILLO="\033[1;33m"
ROJO="\033[0;31m"
VERDE="\033[1;32m"
FIN="\033[0m"
AZUL="\033[1;34m"

VERSION=v0.1.1
SYSTEM=`sw_vers | grep ProductVersion | awk '{print $2}'`
VOLUME="/"
MSG_COMPLETE=$VERDE"Complete! ;-)"
MSG_ERROR=$ROJO"Error!"
MSG_WAIT=$VERDE"Working..."

## Clear screen
clear

if [ `whoami` != "root" ]
then
  echo $ROJO"Permission denied, necessary user root"
  echo $AMARILLO"Exit..."$FIN
  exit 1
else
  sync
  ## Tittle
  echo $VERDE"##############################################"$FIN
  echo $VERDE"#####  iCheckOS $VERSION for MacOS $SYSTEM  #####"$FIN
  echo $VERDE"##############################################\n"$FIN
  echo $AMARILLO"System Volume for repair permissions: $VOLUME"
  echo $AMARILLO"Information system:"$FIN
  sw_vers
  echo "\n"

  ## Verify volume
  echo $AZUL">> Checking packages in $VOLUME"$FIN
  echo $MSG_WAIT
  /usr/libexec/repair_packages --verify --standard-pkgs --debug --volume $VOLUME &> /dev/null
  sleep 3

  ## Repair permissions
  echo $AZUL">> Repairing permissions in $VOLUME"$FIN
  echo $MSG_WAIT
  /usr/libexec/repair_packages --repair --standard-pkgs --debug --volume $VOLUME &> /dev/null
  sleep 3

  if [ -d ~/Library/Caches/com.apple.Safari ]
  then
    echo $AMARILLO"Clear cache Safari?  [yes/NO]"$FIN
    read CLEARSAFARI

    if [ $CLEARSAFARI = "yes" ]
    then
      rm -rf ~/Library/Caches/com.apple.Safari/*
      echo $MSG_COMPLETE
      if [ $? != 0 ]
      then
        echo $MSG_ERROR
      fi
    fi
  fi

  if [ -d ~/Library/Caches/Google/Chrome ]
  then
    echo $AMARILLO"Clear cache Google Chrome?  [yes/NO]"$FIN
    read CLEARGOOGLE

    if [ $CLEARGOOGLE = "yes" ]
    then
      rm -rf ~/Library/Caches/Google/Chrome/Default/Cache/*
      echo $MSG_COMPLETE
      if [ $? != 0 ]
      then
        echo $MSG_ERROR
      fi
    fi
  fi

  if [ -d /Users/$USER/.Trash ]
  then
    echo $AMARILLO"Empty trash?  [yes/NO]"$FIN
    read EMPTYTRASH

    if [ $EMPTYTRASH = "yes" ]
    then
      rm -rf /Users/$USER/.Trash/*
      echo $MSG_COMPLETE
      if [ $? != 0 ]
      then
        echo $MSG_ERROR
      fi
    fi
  fi

  echo $AMARILLO"Flushing DNS Cache?  [yes/NO]"$FIN
  read CLEARDNS

  if [ $CLEARDNS = "yes" ]
  then
    ## Flushing DNS Cache
    echo $AZUL">> Flushing DNS Cache in Mac OS $SYSTEM"
    /usr/bin/dscacheutil -flushcache
    /usr/bin/killall -HUP mDNSResponder
    sync
    echo $MSG_COMPLETE
    if [ $? != 0 ]
    then
      echo $MSG_ERROR
    fi
  fi

  echo $AMARILLO"Order applications alphabetically 'Launchpad'? [yes/NO]"$FIN
  read LAUNCHPAD

  if [ $LAUNCHPAD = "yes" ]
  then
     su $USER defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock
    echo $MSG_COMPLETE
    if [ $? != 0 ]
    then
      echo $MSG_ERROR
    fi
  fi

  echo $AMARILLO"Reboot system now?  [yes/NO]"$FIN
  read REBOOT

  if [ $REBOOT = "yes" ]
  then
    sync; reboot
  else
    exit 0
  fi
fi
