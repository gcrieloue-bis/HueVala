using Gtk;
using Gee;
using Math;
using GLib;
using Soup;

public class RGB {
	public double red;
	public double green;
	public double blue;

	public RGB(double r, double g, double b){
		red = r;
		green = g;
		blue = b;
	} 

	public string toString(){
		return "rgb(%f,%f,%f)".printf(red,green,blue);
	}
}

public class HSL {
	public double hue;
	public double saturation;
	public double lightness;

	public HSL(double h, double s, double l){
		hue = h;
		saturation = s;
		lightness = l;
	}

	public string toString(){
		return "hsl(%f;%f;%f)".printf(hue,saturation,lightness);
	}
}


public class HueManager {

    public const string IP = "192.168.1.27";
	public const double MAX_HUE = 65535.0;
	public const double MAX_SAT_BRI = 255.0;

	public double convertToRangeZeroOne(double value, double max){
		return value/max;
	}

	public double convertToDefaultRange(double value, double max){
		return value*max;
	}

	public double hue2rgb(double p, double q, double t){
		//stdout.printf("pqt(%f,%f,%f)\n".printf(p,q,t));
		if(t < 0.0) t += 1.0;
		if(t > 1.0) t -= 1.0;
		if(t < 1.0/6.0) return p + (q - p) * 6 * t;
		if(t < 1.0/2.0) return q;
		if(t < 2.0/3.0) return p + (q - p) * (2.0/3.0 - t) * 6;
		return p;
	}

	/**
	 * Converts an RGB color value to HSL. Conversion formula
	 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
	 * Assumes r, g, and b are contained in the set [0, 255] and
		 * returns h, s, and l in the set [0, 1].
			 *
	 * @param   Number  r       The red color value
	 * @param   Number  g       The green color value
	 * @param   Number  b       The blue color value
	 * @return  Array           The HSL representation
	 */
	public HSL rgbToHsl(double r, double g, double b){
	
	    stdout.printf("r,g,b(%f;%f;%f)\n", r,g,b);
	
		r /= 255.0;
		g /= 255.0;
		b /= 255.0;
		var max = Math.fmax(Math.fmax(r, g),b);
		var min = Math.fmin(Math.fmin(r, g), b);

		double h, s, l = 0.0;
		h = s = l = (max + min) / 2.0;
		
		stdout.printf("max,min,l(%f,%f,%f)\n", max,min,l);

		if(max == min){
			h = s = 0.0; // achromatic
		}else{
			var d = max - min;
			s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min);
			if (max == r)
			{
				h = (g - b) / d + (g < b ? 6.0 : 0.0);
			}
			if (max == g)
			{
				h = (b - r) / d + 2.0; 
			}
			if (max == b)
			{
				h = (r - g) / d + 4.0;
			}
		}
		h /= 6.0;

        h = convertToDefaultRange(h, MAX_HUE);
	    s = convertToDefaultRange(s, MAX_SAT_BRI);
	    l = convertToDefaultRange(l, MAX_SAT_BRI);
	    
	    stdout.printf("h,s,l(%f,%f,%f)\n", h,s,l);

		return new HSL(h,s,l);
	}

	/**
	 * Converts an HSL color value to RGB. Conversion formula
	 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
	 * Assumes h, s, and l are contained in the set [0, 1] and
		 * returns r, g, and b in the set [0, 255].
			 *
	 * @param   Number  h       The hue
	 * @param   Number  s       The saturation
	 * @param   Number  l       The lightness
	 * @return  Array           The RGB representation
	 */
	public RGB hslToRgb(HSL hsl){
	
	    double hue = this.convertToRangeZeroOne(hsl.hue, MAX_HUE);
	    double lightness = this.convertToRangeZeroOne(hsl.lightness,MAX_SAT_BRI);
	    double saturation =  this.convertToRangeZeroOne(hsl.saturation,MAX_SAT_BRI);
	
		double r, g, b;

		if (hsl.saturation == 0.0){
			r = g  = b  = lightness; // achromatic
		} else {    
			var q = lightness < 0.5 ? 
				lightness * (1.0 + saturation) : 
				lightness + saturation - lightness * saturation;
				var p = 2.0 * lightness - q;
				r = hue2rgb(p, q, hue + 1.0/3.0);
				g = hue2rgb(p, q, hue);
				b  = hue2rgb(p, q, hue - 1.0/3.0);
		}

		r = Math.round(r * 255.0);
		g = Math.round(g * 255.0);
		b  = Math.round(b * 255.0);

		return new RGB(r,g,b);
	}

	public 	ArrayList<Light> lights = new ArrayList<Light>();

	
	//public const string USERNAME = "hellsdarkHue";

	/// récupère les lampes disponibles
	public ArrayList<Light> getLights (){

		var uri = "http://%s/api/hellsdarkHUE/lights/".printf(IP);

		stdout.printf ("API = %s\n",uri);

		var session = new Soup.Session();
		var message = new Soup.Message("GET",uri);
		session.send_message (message);

		try {
			var parser = new Json.Parser ();
			parser.load_from_data ((string) message.response_body.flatten ().data, -1);

			var root_object = parser.get_root ().get_object ();
			foreach (var element in root_object.get_members()){
				var response = root_object.get_object_member (element);
				var results = response.get_string_member ("name");
				Light light = new Light();
				light.name = results;
				light.number = element;
				//stdout.printf ("%s = %s\n",element,results);
				lights.add(light);
			} 
		} catch (Error e) {
			stderr.printf (e.message);
		}

		return lights;
	}

	public void switchAllLights(bool on)
	{
		var uri = "http://%s/api/hellsdarkHUE/groups/0/action".printf(IP);

		stdout.printf ("API = %s\n",uri);
		string mycontent = "test";
		var session = new Soup.Session();
		var message = new Soup.Message("PUT",uri);
		var body = "";
		if (on) {
			body = "{\"on\":true}";
		}
		else {
			body = "{\"on\":false}";
		}
		stdout.printf("%s\n", body);
		message.set_request("application/json", Soup.MemoryUse.COPY, body.data);
		session.send_message (message);
	}

	public void switchLight(string number, bool on)
	{
		var uri = "http://%s/api/hellsdarkHUE/lights/%s/state".printf(IP,number);

		stdout.printf ("API = %s\n",uri);
		string mycontent = "test";
		var session = new Soup.Session();
		var message = new Soup.Message("PUT",uri);
		var body = "";
		if (on) {
			body = "{\"on\":true}";
		}
		else {
			body = "{\"on\":false}";
		}
		stdout.printf("%s\n", body);
		message.set_request("application/json", Soup.MemoryUse.COPY, body.data);
		session.send_message (message);
	}
	
	public void setColor(string number, RGB rgb)
	{
	stdout.printf("setColor_r,g,b(%f;%f;%f)\n", rgb.red, rgb.green, rgb.blue);
        HSL hsl = rgbToHsl(rgb.red, rgb.green, rgb.blue);
		var uri = "http://%s/api/hellsdarkHUE/lights/%s/state".printf(IP,number);

        HSL lightHsl = getByNumber(number).hsl;
        lightHsl.hue = hsl.hue;
        lightHsl.saturation = hsl.saturation;
        lightHsl.lightness = hsl.lightness;

		stdout.printf ("API = %s\n",uri);
		string mycontent = "test";
		var session = new Soup.Session();
		var message = new Soup.Message("PUT",uri);
		var body = "{\"hue\":%d,\"sat\":%d,\"bri\":%d}".printf(
		    (int)Math.round(hsl.hue), 
		    (int)Math.round(hsl.saturation),
		    (int)Math.round(hsl.lightness));
		
		stdout.printf(body);
		message.set_request("application/json", Soup.MemoryUse.COPY, body.data);
		session.send_message (message);
	}

	public Light getByName(string name){
		foreach (var light in this.lights){
			if (light.name == name)
			{
				return light;
			}
		}
		return null;
	}

	public Light getByNumber(string number){
		foreach (var light in this.lights){
			if (light.number == number)
			{
				return light;
			}
		}
		return null;
	}
	
	public void setBrightness(string number, int brightness)
	{  
		var uri = "http://%s/api/hellsdarkHUE/lights/%s/state".printf(IP,number);
		
		getByNumber(number).hsl.lightness = brightness;

		stdout.printf ("API = %s\n",uri);
		var session = new Soup.Session();
		var message = new Soup.Message("PUT",uri);
		var body = "{\"bri\":%d}".printf(brightness);
		
		stdout.printf(body);
		message.set_request("application/json", Soup.MemoryUse.COPY, body.data);
		session.send_message (message);
	}
	
	public void setSaturation(string number, int saturation)
	{  
		var uri = "http://%s/api/hellsdarkHUE/lights/%s/state".printf(IP,number);
		
		getByNumber(number).hsl.saturation = saturation;

		stdout.printf ("API = %s\n",uri);
		var session = new Soup.Session();
		var message = new Soup.Message("PUT",uri);
		var body = "{\"sat\":%d}".printf(saturation);
		
		stdout.printf("%s\n",body);
		message.set_request("application/json", Soup.MemoryUse.COPY, body.data);
		session.send_message (message);
	}
	
	public void setHue(string number, int hue)
	{  
		var uri = "http://%s/api/hellsdarkHUE/lights/%s/state".printf(IP,number);

        getByNumber(number).hsl.hue = hue;

		stdout.printf ("API = %s\n",uri);
		var session = new Soup.Session();
		var message = new Soup.Message("PUT",uri);
		var body = "{\"hue\":%d}".printf(hue);
		
		stdout.printf("%s\n",body);
		message.set_request("application/json", Soup.MemoryUse.COPY, body.data);
		session.send_message (message);
	}

	public Light refreshData(string number)
	{
		var uri = "http://%s/api/hellsdarkHUE/lights/%s".printf(IP,number);

		stdout.printf ("API = %s\n",uri);

		Light light = this.getByNumber(number);

		var session = new Soup.Session();
		var message = new Soup.Message("GET",uri);
		session.send_message (message);

		try {
			var parser = new Json.Parser ();
			parser.load_from_data ((string) message.response_body.flatten ().data, -1);

			var root_object = parser.get_root ().get_object ();

			var response = root_object.get_object_member ("state");
			light.hsl = new HSL(response.get_int_member ("hue"),
			                    response.get_int_member ("sat"),
			                    response.get_int_member ("bri"));
            light.on = response.get_boolean_member("on")  ;
            light.reachable = response.get_boolean_member("reachable")  ;

		} catch (Error e) {
			stderr.printf (e.message);
		}

		return light;
		return new Light();
	}
}
