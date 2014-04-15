Philips Hue Controller

![ScreenShot](https://raw.githubusercontent.com/gcrielou/HueVala/master/hue_screenshot.png)

======================
Vala
GTK 3.12
======================


To compile this program :

valac --pkg gtk+-3.0 --pkg gmodule-2.0 --pkg libsoup-2.4 --pkg json-glib-1.0 main.vala hueManager.vala light.vala hueManagerUI.vala --pkg gee-1.0  -X -lm && ./main
