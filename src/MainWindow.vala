/*
* Copyright ⓒ 2019 Cassidy James Blaede (https://cassidyjames.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Cassidy James Blaede <c@ssidyjam.es>
*/

public class MainWindow : Gtk.Window {
    private const string HOME = "https://start.duckduckgo.com/";

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            border_width: 0,
            icon_name: "com.github.cassidyjames.ephemeral",
            resizable: true,
            title: "Ephemeral",
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        default_height = 640;
        default_width = 960;

        var protocol_regex = new Regex (".*://.*");

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;

        var web_context = new WebKit.WebContext.ephemeral ();
        web_context.get_cookie_manager ().set_accept_policy (WebKit.CookieAcceptPolicy.NO_THIRD_PARTY);

        var web_view = new WebKit.WebView.with_context (web_context);
        web_view.expand = true;
        web_view.height_request = 200;
        web_view.load_uri (HOME);

        var back_button = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        back_button.sensitive = false;
        back_button.tooltip_text = "Back";

        var forward_button = new Gtk.Button.from_icon_name ("go-next-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        forward_button.sensitive = false;
        forward_button.tooltip_text = "Forward";

        var refresh_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        refresh_button.tooltip_text = "Reload page";

        var stop_button = new Gtk.Button.from_icon_name ("process-stop-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        stop_button.tooltip_text = "Stop loading";

        var refresh_stop_stack = new Gtk.Stack ();
        refresh_stop_stack.add (refresh_button);
        refresh_stop_stack.add (stop_button);
        refresh_stop_stack.visible_child = refresh_button;

        var url_entry = new Gtk.Entry ();
        url_entry.hexpand = true;
        url_entry.width_request = 100;

        var erase_button = new Gtk.Button.from_icon_name ("edit-delete", Gtk.IconSize.LARGE_TOOLBAR);
        erase_button.tooltip_text = "Erase browsing history";

        // TODO: Menu with other installed browsers?
        var open_button = new Gtk.Button.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
        open_button.tooltip_text = "Open page in default browser";

        header.pack_start (back_button);
        header.pack_start (forward_button);
        header.pack_start (refresh_stop_stack);
        header.pack_end (open_button);
        header.pack_end (erase_button);

        header.custom_title = url_entry;

        var grid = new Gtk.Grid ();
        grid.add (web_view);

        set_titlebar (header);
        add (grid);
        show_all ();

        back_button.clicked.connect (() => {
            web_view.go_back ();
        });

        forward_button.clicked.connect (() => {
            web_view.go_forward ();
        });

        refresh_button.clicked.connect (() => {
            web_view.reload ();
        });

        stop_button.clicked.connect (() => {
            web_view.stop_loading ();
        });

        open_button.clicked.connect (() => {
            Gtk.show_uri (null, web_view.get_uri (), 0);
        });

        erase_button.clicked.connect (() => {
            var new_window = new MainWindow (application);
            new_window.show_all ();

            close ();
        });

        web_view.load_changed.connect ((source, evt) => {
            url_entry.text = source.get_uri ();
            back_button.sensitive = web_view.can_go_back ();
            forward_button.sensitive = web_view.can_go_forward ();

            if (web_view.is_loading) {
                refresh_stop_stack.visible_child = stop_button;
                web_view.bind_property ("estimated-load-progress", url_entry, "progress-fraction");
            } else {
                refresh_stop_stack.visible_child = refresh_button;
                url_entry.progress_fraction = 0;
            }
        });

        url_entry.activate.connect (() => {
            // TODO: Search?
            var url = url_entry.text;
            if (!protocol_regex.match (url)) {
                url = "%s://%s".printf ("https", url);
            }
            web_view.load_uri (url);
        });
    }
}

