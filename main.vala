using Gtk;
using Gee;
using Math;
using GLib;
using Soup;

// pkg gmodule-2.0
// pkg gtk+3.0
// pkg libsoup-2.4
// pkg json-glib-1.0
// pkg Gee-1.0
// pour les maths : -X -lm

//http://192.168.1.27/api/hellsdarkHUE/lights

// Lance l'application
public static int main (string[] args) {

	Gtk.init (ref args);
	try{
		var hueManagerUI = new HueManagerUI();
		hueManagerUI.window.show_all ();
		Gtk.main ();
	} catch (Error e) {
		stderr.printf ("Could not load UI: %s\n", e.message);
		return 1;
	}

	return 0;
}
