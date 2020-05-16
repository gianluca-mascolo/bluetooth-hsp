# bluetooth-hsp
Activate Bluetooth HSP in pulseaudio

## Why?

A bluetooth headset is normally linked to pulseaudio in mode A2DP Sink (High Fidelity Playback).  
To use microphone in bluetooth headset, you need to switch bluetooth device in mode HSP/HFP (Headset Head Unit).  
If you try to switch in HSP/HFP and you get the error `failed to change profile to headset_head_unit` you may try to use this script. This is because

> Currently HFP support in pulseaudio is only available through oFono.
>
> -- <cite>[Source](https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Bluetooth/)</cite>

## Arch Linux

Howto source [here](https://wiki.archlinux.org/index.php/Bluetooth_headset#HFP_not_working_with_PulseAudio)  

`~]$ sudo pacman -S ofono phonesim psmisc screen`
Edit `/etc/ofono/phonesim.conf` (as root) and insert
```
[phonesim]
Address=127.0.0.1
Driver=phonesim
Port=12345
```
Now
```
~]$ sudo systemctl enable ofono && sudo systemctl start ofono
~]$ [ -d ~/bin ] || mkdir ~/bin
~]$ curl -s https://raw.githubusercontent.com/rilmodem/ofono/10cbabb4608c2e7ea166436b19bae54b184f382f/test/list-modems > ~/bin/list-modems
~]$ chmod 0755 ~/bin/list-modems
~]$ ~/bin/activate_hsp.sh
Checking required binaries...
list-modems: Found
screen: Found
killall: Found
Checking phonesim status...
phonesim: no process found
Starting Phonesim...
Power on modem
method return time=1589650544.355161 sender=:1.2 -> destination=:1.561 serial=686 reply_serial=2
Put modem online
method return time=1589650546.558265 sender=:1.2 -> destination=:1.562 serial=698 reply_serial=2
PhoneSim Modem
Online: 1 Powered: 1
~]$ 
```
Connect your bluetooth headset. You can now switch to HSP/HFP.
