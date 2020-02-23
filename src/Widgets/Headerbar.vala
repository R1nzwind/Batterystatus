public class Batterystatus.HeaderBar : Gtk.HeaderBar {

    public void open (){
        var w = Batterystatus.Settings.window;
        if (w is Gtk.ApplicationWindow){
            //w.destroy();
            return;
        }
        var app = new Batterystatus.Settings();
        app.run ();   
    }

    construct { 
        title = "";
        has_subtitle = false;
        show_close_button = false;

        var button = new Gtk.Button.from_icon_name ("view-list-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        button.valign = Gtk.Align.CENTER;
        button.clicked.connect (open);
        pack_start (button);
    }
}