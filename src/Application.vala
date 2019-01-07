public class Ephemeral : Gtk.Application {

    public Ephemeral () {
        Object (
            application_id: "com.github.cassidyjames.ephemeral",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this);
        main_window.default_height = 400;
        main_window.default_width = 800;

        var protocol_regex = new Regex (".*://.*");

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;

        var header_context = header.get_style_context ();
        header_context.add_class ("titlebar");
        header_context.add_class ("default-decoration");

        var web_context = new WebKit.WebContext.ephemeral ();
        web_context.get_default ().set_preferred_languages (GLib.Intl.get_language_names ());

        var web_view = new WebKit.WebView.with_context (web_context);
        web_view.expand = true;
        web_view.height_request = 200;
        web_view.load_uri ("https://cassidyjames.com");

        var back_button = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        // back_button.sensitive = false;
        back_button.tooltip_text = "Back";

        var forward_button = new Gtk.Button.from_icon_name ("go-next-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        // forward_button.sensitive = false;
        forward_button.tooltip_text = "Forward";

        var refresh_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        // refresh_button.sensitive = false;
        refresh_button.tooltip_text = "Reload page";

        var url_entry = new Gtk.Entry ();
        url_entry.hexpand = true;
        url_entry.width_request = 100;

        // TODO: Menu with other installed browsers?
        var open_button = new Gtk.Button.from_icon_name ("internet-web-browser", Gtk.IconSize.SMALL_TOOLBAR);
        open_button.tooltip_text = "Open page in Epiphany";

        header.pack_start (back_button);
        header.pack_start (forward_button);
        header.pack_start (refresh_button);
        header.pack_end (open_button);

        header.custom_title = url_entry;

        var grid = new Gtk.Grid ();
        grid.add (web_view);

        main_window.set_titlebar (header);
        main_window.add (grid);
        main_window.show_all ();

        back_button.clicked.connect (() => {
            web_view.go_back ();
        });

        forward_button.clicked.connect (() => {
            web_view.go_forward ();
        });

        refresh_button.clicked.connect (() => {
            web_view.reload ();
        });

        open_button.clicked.connect (() => {
            critical ("Not implemented");
        });

        // web_view.load_changed.connect (() => {
        //     if (web_view.can_go_back ()) {
        //         back_button.sensitive = true;
        //     }
        //
        //     if (web_view.can_go_forward ()) {
        //         forward_button.sensitive = true;
        //     }
        // });

        web_view.load_changed.connect ((source, evt) => {
            url_entry.text = source.get_uri ();
            back_button.sensitive = web_view.can_go_back ();
            forward_button.sensitive = web_view.can_go_forward ();
        });

        url_entry.activate.connect (() => {
            var url = url_entry.text;
            if (!protocol_regex.match (url)) {
                url = "%s://%s".printf ("https", url);
            }
            web_view.load_uri (url);
        });
    }

    public static int main (string[] args) {
        var app = new Ephemeral ();
        return app.run (args);
    }
}

