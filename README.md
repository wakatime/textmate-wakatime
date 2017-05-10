textmate-wakatime
=================

Quantify your coding inside TextMate 1 & 2.

Installation
------------

1. Download [textmate-wakatime-v1.0.2.tmplugin](https://github.com/wakatime/textmate-wakatime/releases/download/1.0.2/textmate-wakatime-v1.0.2.tmplugin.zip)

2. Unzip and open the downloaded tmplugin file to install the plugin in TextMate.

3. Enter your [api key](https://wakatime.com/settings#apikey), then click `OK`. (Use two-finger click to paste)

4. Use TextMate like you normally do and your time will be tracked for you automatically.

5. Visit https://wakatime.com to see your logged time.

Screen Shots
------------

![Project Overview](https://wakatime.com/static/img/ScreenShots/ScreenShot-2014-10-29.png)


Configuring
-----------

WakaTime plugins share a common config file `.wakatime.cfg` located in your user home directory with [these options](https://github.com/wakatime/wakatime#configuring) available.


Troubleshooting
---------------

Try running this Terminal command:

```
curl -fsSL https://raw.githubusercontent.com/wakatime/textmate-wakatime/master/install_dependencies.sh | sh
```

That will re-download the [wakatime-cli dependency](https://github.com/wakatime/wakatime).

If that doesn't work, turn on debug mode and check your wakatime cli log file (`~/.wakatime.log`).

If there are no errors in your `~/.wakatime.log` file, [Enable logging](https://github.com/textmate/textmate/wiki/Enable-Logging) then run TextMate from Terminal to see any error messages.

For more general troubleshooting information, see [wakatime/wakatime#troubleshooting](https://github.com/wakatime/wakatime#troubleshooting).
