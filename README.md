#Philips Hue Controller

![ScreenShot](https://raw.githubusercontent.com/gcrielou/HueVala/master/hue_screenshot.png)

======================

##Developed for Gnome 3.12+ with :
* Vala
* GTK 3.12

##Features
* All lights on/off
* specific light on/off
* specific light brightness change
* specific light hue change
* specific light saturation change
* specific light color change

##TODO
* Bridge discovery
* User auto-creation
* Add colorloop effect
* Add group management
* Add scheduler 

##To compile this program :

```Shell
valac --pkg gtk+-3.0 --pkg gmodule-2.0 --pkg libsoup-2.4 --pkg json-glib-1.0 main.vala hueManager.vala light.vala hueManagerUI.vala --pkg gee-1.0  -X -lm && ./main
```
