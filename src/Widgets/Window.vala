public class Batterystatus.Window : Gtk.ApplicationWindow {

	GLib.Settings settings = new GLib.Settings ("org.rinzwind.batterystatus");
	new Gdk.Screen screen;
    new Gdk.Display display;
	Gtk.CssProvider css_provider = new Gtk.CssProvider();   
	Batterystatus.HeaderBar headerbar = new Batterystatus.HeaderBar ();
	Gtk.Label label = new Gtk.Label(""); 
	public string window_title = "Batterystatus"; // translation
	
	public Window (Application app) {
		Object (
			application: app
		);
	}

	public bool update_location () {
		int xpos, ypos;
		get_position (out xpos, out ypos);
		settings.set_int("xpos", xpos);
		settings.set_int("ypos", ypos);
		return false;
	}

	public int get_scale() {
        Gdk.Monitor defmon = display.get_primary_monitor();
        int scale = defmon.get_scale_factor();
		return scale;
    }
	
	public void update_windowproperties () {
		int xpos = 1200; // scaling
		int ypos = 700; // scaling
		string textfont = "monospace 30";
		bool immovable = false;
		bool decoration = true;
		bool titlebar = true;
		string textcolor = "red";
			
		var settings_schema = SettingsSchemaSource.get_default ().lookup ("org.rinzwind.batterystatus", false);
		
		if (settings_schema != null) {
			if (settings_schema.has_key ("xpos")) {
				xpos = settings.get_int("xpos");
			}
			if (settings_schema.has_key ("ypos")) {
				ypos = settings.get_int("ypos");
			}
			if (settings_schema.has_key ("text-font")) {
				textfont = settings.get_string("text-font");
			}  	
			if (settings_schema.has_key ("immovable")) {	
				immovable = settings.get_boolean("immovable");
			} 
			if (settings_schema.has_key ("decoration")) {
				decoration = settings.get_boolean("decoration");
			} 
			if (settings_schema.has_key ("titlebar")) {
				titlebar = settings.get_boolean("titlebar");
			}
			if (settings_schema.has_key ("text-color")) {
				textcolor = settings.get_string("text-color");
			}	
		}	
		
		string[] array = textfont.split(" ");
		string titletextfont = array[0];
		int titletextsize = int.parse(array[array.length - 1]) - 5;

		string stylesheet = """	
		.stylesheet {
		color: {text-color};
		}""";
		if (!decoration){
			stylesheet += """
			headerbar {
				padding-left: 5px; 
				padding-right: 5px;
				box-shadow: none;
				color: {text-color};
				font-family: {text-font}px;
				font-size: {text-size}px;
				background: rgba(0,0,0,0.5);
			}""";
		}
		
		stylesheet = stylesheet.replace("{text-color}", @"$textcolor");
		stylesheet = stylesheet.replace("{text-font}", @"$titletextfont");
		stylesheet = stylesheet.replace("{text-size}", @"$titletextsize");
		
		headerbar.show_close_button = decoration; 

		try {
			css_provider.load_from_data(stylesheet);
			Gtk.StyleContext.add_provider_for_screen(
				screen, css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER
			);
			label.get_style_context().add_class("stylesheet");
		}                
		catch (Error e) {
			stderr.printf("Problem loading stylesheet\n");
		}
		
		
		var font = new Pango.FontDescription().from_string(textfont); // font size scaling?
		var attributes_list = new Pango.AttrList();
        Pango.Attribute attributes = new Pango.AttrFontDesc (font);          
        attributes_list.insert ((owned) attributes);       
		label.set_attributes(attributes_list);
	
// 		int scale = get_scale(); 

		move(xpos, ypos);

		set_app_paintable(true); 
		set_resizable(false);
		var visual = screen.get_rgba_visual();
		set_visual(visual);
		if (decoration){
			draw.connect(on_draw);
		}
		if (immovable){
			set_type_hint(Gdk.WindowTypeHint.DESKTOP);		
		} else {
			set_type_hint(Gdk.WindowTypeHint.NORMAL);
		}
	}

	public bool on_draw (Gtk.Widget da, Cairo.Context ctx) {
		ctx.set_source_rgba(0, 0, 0, 0);
		ctx.set_operator(Cairo.Operator.SOURCE);
		ctx.paint();
		ctx.set_operator(Cairo.Operator.OVER);
		return false;
	}

	public void update_label () {
		string message = UPower.DeviceStatistics ();
		GLib.Idle.add( () => {
			label.set_text(@"$message");
			return false;
		});
	}

	construct {
		var settings_schema = SettingsSchemaSource.get_default ().lookup ("org.rinzwind.batterystatus", false);
		int timeout = 10;
		bool titlebar = true;
		if (settings_schema != null) {
			if (settings_schema.has_key ("timeout")) {
				timeout = settings.get_int("timeout");
			}
			if (settings_schema.has_key ("titlebar")) {
				titlebar = settings.get_boolean("titlebar");
			}  	
		}

		screen = get_screen();
		display = Gdk.Display.get_default();

		delete_event.connect (e => {
			Gtk.ApplicationWindow w = Batterystatus.Settings.window;
			if (w is Gtk.ApplicationWindow){
				w.destroy();
			}
			return update_location ();
		});
	
	 	set_default_size (200, 80);
	
		screen.monitors_changed.connect((key) => {	
			update_windowproperties ();
		});

		settings.changed.connect ((key) => {
			if (key == "titlebar"){
				if(settings.get_boolean("titlebar")){
					set_title(window_title); 
				} else {
					set_title("");
				}
			}
			update_windowproperties ();
		});

		add(label);
		update_label();
		update_windowproperties ();		
		set_titlebar (headerbar);
		if (titlebar) {
			set_title(window_title); 
		} else {
			set_title("");
		}
		
		GLib.Timeout.add_seconds(timeout, ()=> {
			update_label();
			if (settings_schema != null && settings_schema.has_key ("timeout")) {
				timeout = settings.get_int("timeout");
			}
			return true;
		});

		show_all ();
	}
}