public class Incognito : Gtk.Application {

    public Incognito () {
        Object (
            application_id: "com.github.cassidyjames.incognito",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this);
        main_window.default_height = 400;
        main_window.default_width = 800;

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;

        var open = new Gtk.Button.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
        open.tooltip_text = "Open in…";

        header.pack_end (open);

        var grid = new Gtk.Grid ();

        main_window.set_titlebar (header);
        main_window.add (grid);
        main_window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Incognito ();
        return app.run (args);
    }
}

