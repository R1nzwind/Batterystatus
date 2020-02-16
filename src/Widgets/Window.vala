public class Batterystatus.Window : Gtk.ApplicationWindow {

	GLib.Settings settings = new GLib.Settings ("org.rinzwind.batterystatus");
	new Gdk.Screen screen;
    new Gdk.Display display;
	Gtk.CssProvider css_provider = new Gtk.CssProvider();   
	string stylesheet;
	Batterystatus.HeaderBar headerbar = new Batterystatus.HeaderBar ();
	Gtk.Label label = new Gtk.Label("");

	public Window (Application app) {
		Object (
			application: app
		);
	}

	public bool before_destroy () {
		int xpos, ypos;
		get_position (out xpos, out ypos);
		settings.set_int("xpos", xpos);
		settings.set_int("ypos", ypos);
		return false;
	}

	public void set_stylesheet () {
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
	}

	public int get_scale() {
        Gdk.Monitor defmon = display.get_primary_monitor();
        int scale = defmon.get_scale_factor();
		return scale;
    }
	
	public void update_windowproperties () {
		int xpos = settings.get_int("xpos");
		int ypos = settings.get_int("ypos");
		int fontsize = settings.get_int("font-size");  		
		bool immovable = settings.get_boolean("immovable"); 
		bool decoration = settings.get_boolean("decoration"); 
		int scale = get_scale();
		
		xpos = xpos * scale;
		ypos = ypos * scale;
		fontsize = fontsize * scale;
		string foregroundcolor = settings.get_string("foreground-color");
		
		stylesheet = """	
		.stylesheet {
		font-size: {font-size}px;
		color: {foreground-color};
		}""";
		if (!decoration){
			stylesheet += """
			headerbar {
				min-height: 0px;
				padding-left: 5px; 
				padding-right: 4px;
				box-shadow: none;
				background: rgba(0,0,0,0.5);
			}""";
		}
		stylesheet = stylesheet.replace("{font-size}", @"$fontsize");
		stylesheet = stylesheet.replace("{foreground-color}", @"$foregroundcolor");
		
		move(xpos, ypos);

		set_stylesheet();
		set_app_paintable(true); 
		set_resizable(false);
		var visual = screen.get_rgba_visual();
		set_visual(visual);
		if (decoration){
			draw.connect(on_draw);
		}
		if (immovable){
			set_type_hint(Gdk.WindowTypeHint.DESKTOP);		
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
		screen = this.get_screen();
		display = Gdk.Display.get_default();

		delete_event.connect (e => {
			return before_destroy ();
		});
	
	 	set_default_size (200, 80);
	
		screen.monitors_changed.connect((key) => {	
			update_windowproperties ();
		});

		settings.changed.connect ((key) => {
			set_title("");
			if(settings.get_boolean("titlebar")){
				set_title("Batterystatus");
			}
			headerbar.show_close_button = settings.get_boolean("decoration"); 
			update_windowproperties ();
		});

		
		add(label);
		update_label();
		update_windowproperties ();
		
		set_titlebar (headerbar);
		if (settings.get_boolean("titlebar")) {
			set_title((_("Batterystatus")));
		}
		headerbar.show_close_button = settings.get_boolean("decoration"); 
		
		GLib.Timeout.add_seconds(settings.get_int("timeout"), ()=> {
			update_label();
			return true;
		});
		
		show_all ();
	}
}