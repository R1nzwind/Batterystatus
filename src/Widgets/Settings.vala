
public class Batterystatus.Settings : Gtk.Application {

    public static Gtk.ApplicationWindow window;
    private int row = 1;
    private string key = "";
    private string schema = "org.rinzwind.batterystatus";
    GLib.Settings settings = new GLib.Settings ("org.rinzwind.batterystatus");
    Gtk.Grid grid = new Gtk.Grid ();

    void set_label (string text){
        Gtk.Label label = new Gtk.Label (text + ": ");
        label.set_xalign(0);      
        grid.attach (label, 0, row, 1, 1); 
    }

    void add_spinbutton (Gtk.SpinButton spinbutton){
        spinbutton.set_hexpand (true);
        spinbutton.value = settings.get_int(key);     
        grid.attach (spinbutton, 1, row, 1, 1);  
        row += 1;    
    }

    void add_switcher (Gtk.Switch switcher){
        switcher.set_active (settings.get_boolean(key));
        grid.attach (switcher, 1, row, 1, 1);
        row += 1;
    }

    void add_fontchooser (Gtk.FontButton fontchooser){
        fontchooser.set_font (settings.get_string(key));
        grid.attach (fontchooser, 1, row, 1, 1);
        row += 0;
    }

    void add_colorbutton (Gtk.ColorButton text_color){
        Gdk.RGBA current_color = Gdk.RGBA();
        current_color.parse(settings.get_string(key));
        text_color.set_rgba(current_color);        
        grid.attach (text_color, 3, row, 1, 1);
        row += 1;
    }

    public override void activate (){

        window = new Gtk.ApplicationWindow (this);
        window.title = "Settings";  // translation
        window.set_default_size (250, 150);
        window.set_border_width (10);
        
        var settings_schema = SettingsSchemaSource.get_default ().lookup (schema, false);
      
        grid.row_spacing = 10;

        if (settings_schema != null) {
            key = "xpos";
            if (settings_schema.has_key (key)) {
                set_label ("X position" );  // translation
                var spinbutton1 = new Gtk.SpinButton.with_range (50, 2000, 10); // options
                spinbutton1.value_changed.connect (() => {
                    settings.set_int("xpos", spinbutton1.get_value_as_int());
                });      
                add_spinbutton(spinbutton1);
            }
            key = "ypos";
            if (settings_schema.has_key (key)) {
                set_label ("Y position" );  // translation
                var spinbutton2 = new Gtk.SpinButton.with_range (50, 2000, 10); // options
                spinbutton2.value_changed.connect (() => {
                    settings.set_int("ypos", spinbutton2.get_value_as_int());
                });       
                add_spinbutton(spinbutton2);      
            }
            key = "timeout";
            if (settings_schema.has_key (key)) {
                set_label ("Timeout" );  // translation
                var spinbutton3 = new Gtk.SpinButton.with_range (10, 180, 10); // options
                spinbutton3.value_changed.connect (() => {
                    settings.set_int("timeout", spinbutton3.get_value_as_int());
                });
                add_spinbutton(spinbutton3);
            }
           
            key = "text-font";
            if (settings_schema.has_key (key)) {
                set_label ("Text font, size & color" );  // translation
                var fontchooser1 = new Gtk.FontButton ();
                fontchooser1.notify["font"].connect (() => {
                    settings.set_string("text-font", fontchooser1.get_font ().to_string ());
                });
                add_fontchooser(fontchooser1);    
          
                key = "text-color";  
                if (settings_schema.has_key (key)) {         
                    var text_color1 = new Gtk.ColorButton();
                    text_color1.color_set.connect (() => {
                        Gdk.RGBA color = text_color1.get_rgba();
                        settings.set_string("text-color", color.to_string());
                    }); 
                    add_colorbutton(text_color1); 
                }
            }
            key = "immovable";
            if (settings_schema.has_key (key)) {	
                set_label ("Immovable" ); // translation
                var switcher1 = new Gtk.Switch ();
                switcher1.notify["active"].connect (() => {
                    settings.set_boolean("immovable", switcher1.get_state());
                });
                add_switcher(switcher1);
            } 
            key = "decoration";
            if (settings_schema.has_key (key)) {
                set_label ("Decoration" ); // translation
                var switcher2 = new Gtk.Switch ();
                switcher2.notify["active"].connect (() => {
                    settings.set_boolean("decoration", switcher2.get_state());
                });
                add_switcher(switcher2);
            } 
            key = "titlebar";
            if (settings_schema.has_key (key)) {
                set_label ("Titlebar" ); // translation
                var switcher3 = new Gtk.Switch ();
                switcher3.notify["active"].connect (() => {
                    settings.set_boolean("titlebar", switcher3.get_state());
                });
                add_switcher(switcher3);
            }
        }     
        int xpos = 1200; // scaling
        int ypos = 700;  // scaling
        int ypos2 = 150; // scaling
        if (settings_schema != null) {
            key = "xpos";
			if (settings_schema.has_key (key)) {
				xpos = settings.get_int(key);
            }
            key = "ypos";
			if (settings_schema.has_key (key)) {
				ypos = settings.get_int(key);
            }
        }
        window.move(xpos, ypos + ypos2);
        window.add (grid);
        window.show_all ();
    }
}