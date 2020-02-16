public class Application : Gtk.Application {

	public Application () {
		Object (
			application_id: "org.rinzwind.batterystatus",
			flags: ApplicationFlags.FLAGS_NONE
		);
	}

	protected override void activate () {
		var window = new Batterystatus.Window (this);
		
        window.set_keep_below (true);
		add_window (window);

	}
}