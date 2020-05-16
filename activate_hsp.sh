#!/bin/bash

#    activate_hsp.sh: activate hsp profile for bluetooth using ofono
#    Copyright (C) 2020 <gianluca@gurutech.it>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

export PATH=~/bin:/bin:/usr/bin:/usr/local/bin

function RequireBin {
[ "x$1" = "x" ] && return 1
hash "$1" 2> /dev/null
if ( [ $? -ne 0 ] ); then {
    echo "${1}: Not found"
    exit 1
  }
  else {
    echo "${1}: Found"
    return 0
  }
  fi
}

function PhonesimStatus() {
 local Online
 local Powered
 Online=0
 Powered=0
 for line in $(list-modems 2> /dev/null | strings | egrep -A5 "[[:blank:]]*\[ /phonesim \]" | egrep "(Online|Powered)" | tr -d '[:blank:]'); do {
    StatusName="$(echo $line | cut -d '=' -f 1)"
    StatusResult="$(echo $line | cut -d '=' -f 2)"
    case $StatusName in
    Online)
     Online=$StatusResult
    ;;
    Powered)
     Powered=$StatusResult
    ;;
    *)
     true
    ;;
    esac
 }
 done
 [ "x$1" = "xshow" ] && echo -e "PhoneSim Modem\nOnline: $Online Powered: $Powered"
 [ $Online -eq 1 ] && [ $Powered -eq 1 ] && return 0
 return 1
}

echo "Checking required binaries..."
RequireBin list-modems # https://github.com/rilmodem/ofono/blob/10cbabb4608c2e7ea166436b19bae54b184f382f/test/list-modems
RequireBin screen
RequireBin killall

echo "Checking phonesim status..."
screen -ls phonesim 2> /dev/null &> /dev/null
if ( [ $? -ne 0 ] ); then {
  killall -9 phonesim
  echo "Starting Phonesim..."
  screen -d -m -S phonesim /usr/bin/phonesim -p 12345 /usr/share/phonesim/default.xml
  sleep 1
}
fi
screen -ls phonesim 2> /dev/null &> /dev/null
if ( [ $? -ne 0 ] ); then {
 echo "ERROR: can't start phonesim!"
 exit 1
}
fi

PhonesimStatus
if ( [ $? -ne 0 ] ); then {
  echo "Power on modem"
  dbus-send --print-reply --system --dest=org.ofono /phonesim org.ofono.Modem.SetProperty string:"Powered" variant:boolean:true
  sleep 1
  echo "Put modem online"
  dbus-send --print-reply --system --dest=org.ofono /phonesim org.ofono.Modem.SetProperty string:"Online" variant:boolean:true
  sleep 1
  PhonesimStatus && pactl exit
}
fi

PhonesimStatus show || exit 1
