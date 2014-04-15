using Gtk;
using Gee;
using Math;
using GLib;
using Soup;

public class HueManagerUI {

	private HueManager hueManager;

	public Window window;
	public Switch switchAll;
	public Switch switchLight;
	public ColorButton colorButton;
	public Scale scale;
	public Scale scaleSat;
	public Scale scaleHue;
	public Button about;

	private string currentLightNumber = "0";

	public HueManagerUI(){
		window = buildWindow();
	}


	// Construit la fenêtre
	public Window buildWindow(){

		hueManager = new HueManager();

		//hueManager.GetLights();

		var builder = new Builder ();
		builder.add_from_file ("main.ui");
		window = builder.get_object ("window") as Window;
		var listLights = builder.get_object ("listLights") as TreeView;
		
		switchAll = builder.get_object ("switchAll") as Switch;
		switchAll.notify["active"].connect (on_switchAll_activated);
		
		switchLight = builder.get_object ("switchLight") as Switch;
		switchLight.notify["active"].connect (on_switchLight_activated);
		
		colorButton = builder.get_object ("colorButton") as ColorButton;
		colorButton.color_set.connect(on_colorSet);
		colorButton.set_title("Couleur de la lampe");
		
		scale = builder.get_object ("scale") as Scale;
		scale.value_changed.connect(on_scale_value_changed);
		
		scaleHue = builder.get_object ("scaleHue") as Scale;
		scaleHue.value_changed.connect(on_scaleHue_value_changed);
		
		scaleSat = builder.get_object ("scaleSat") as Scale;
		scaleSat.value_changed.connect(on_scaleSat_value_changed);
		
		about = builder.get_object ("about") as Button;
		about.clicked.connect(on_about_clicked);
		
		populateLightlist(listLights);
		builder.connect_signals (this);
		return window;
	}

    public void on_scale_value_changed () {
        double brightness = scale.get_value();
        hueManager.setBrightness(currentLightNumber, (int)Math.round(brightness));
        refreshColorButton();
    }

    public void on_scaleHue_value_changed () {
        double hue = scaleHue.get_value();
        hueManager.setHue(currentLightNumber, (int)Math.round(hue));
        refreshColorButton();
    }
    
    public void on_scaleSat_value_changed () {
        double saturation = scaleSat.get_value();
        hueManager.setSaturation(currentLightNumber, (int)Math.round(saturation));
        refreshColorButton();
    }

	public void on_about_clicked () {
	    var builder = new Builder ();
		builder.add_from_file ("about.ui");
		AboutDialog aboutDialog  = builder.get_object ("aboutDialog") as AboutDialog;
		aboutDialog.run();
		aboutDialog.destroy();
	}

	public void on_switchAll_activated () {
		hueManager.switchAllLights(switchAll.get_active());
		switchLight.set_active(switchAll.get_active());
	}

	public void on_switchLight_activated () {
		hueManager.switchLight(currentLightNumber, switchLight.get_active());
	}

	public void on_treeview_selection_changed (TreeSelection selection) {


		TreeIter iter;
		TreeModel model;

		string name = "";
		if (selection.get_selected (out model, out iter)) {
			model.get (iter, 0, out name);
		}
		
		if (name != "")
        {
		    stdout.printf("======================================================\n");
		    stdout.printf("%s\n", name);
		    stdout.printf("======================================================\n");

		
		    Light light = hueManager.getByName(name);
		    if (light != null)
		    {
			    hueManager.refreshData(light.number);
			    currentLightNumber = light.number;
			    refreshColorButton();
		        switchLight.set_sensitive(light.reachable);
		        switchLight.set_active(light.on);
		        stdout.printf("Light number %s : %s\n", light.number, light.on ? "on":"off");
		        scale.set_sensitive(light.reachable);
		        scaleHue.set_sensitive(light.reachable);
		        scaleSat.set_sensitive(light.reachable);
		        colorButton.set_sensitive(light.reachable);
			    scale.set_value((int)Math.round(light.hsl.lightness));
			    scaleHue.set_value((int)Math.round(light.hsl.hue));
			    scaleSat.set_value((int)Math.round(light.hsl.saturation));
		    }
		    else {
		         stdout.printf("%s : non trouvé\n", name);
		    }
		}
	}
	
	// alimente la liste des lampes
	public void populateLightlist(TreeView listLights) {

		var listmodel = new Gtk.ListStore (1, typeof (string));

		var selection = listLights.get_selection ();
		selection.changed.connect (this.on_treeview_selection_changed);

		var cell = new Gtk.CellRendererText ();
		listLights.set_model (listmodel);

		/// 'weight' refers to font boldness. 400 is normal. 700 is bold.  
			cell.set ("weight_set", true);
		cell.set ("weight", 700);

		ArrayList<Light> lights = hueManager.getLights();

		listLights.insert_column_with_attributes (-1, "Lampes",
		                                          cell, "text", 0);

		TreeIter iter;
		foreach (var light in lights)
		{
			listmodel.append (out iter);
			listmodel.set (iter, 0,
			               light.name);
		}
	}
	
	public void on_colorSet(){
	    Gdk.RGBA rgba = colorButton.get_rgba();
	    const double MAX_RGB = 255;
	    hueManager.setColor(currentLightNumber, new RGB(rgba.red*MAX_RGB,rgba.green*MAX_RGB,rgba.blue*MAX_RGB));
	    
	    Light light = hueManager.getByNumber(currentLightNumber);
    	scale.set_value((int)Math.round(light.hsl.lightness));
		scaleHue.set_value((int)Math.round(light.hsl.hue));
		scaleSat.set_value((int)Math.round(light.hsl.saturation));
	}
	
	public void refreshColorButton()
	{
	    Light light = hueManager.getByNumber(currentLightNumber);
	    RGB rgb = hueManager.hslToRgb(light.hsl);
	    stdout.printf("%s\n",light.hsl.toString());
	    var color = Gdk.RGBA ();
		int red = (int) Math.round(rgb.red);
		int green = (int) Math.round(rgb.green);
		int blue = (int) Math.round(rgb.blue);
		color.parse("rgb(%d,%d,%d)".printf(red,green,blue));
		stdout.printf("%s\n",rgb.toString());
		colorButton.rgba = color;
	}

}
