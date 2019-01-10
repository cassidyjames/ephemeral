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
    public string uri { get; construct set; }
    public SimpleActionGroup actions { get; construct; }

    public MainWindow (Gtk.Application application, string? _uri = null) {
        Object (
            application: application,
            border_width: 0,
            icon_name: "com.github.cassidyjames.ephemeral",
            resizable: true,
            title: "Ephemeral",
            uri: _uri,
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        default_height = 800;
        default_width = 1280;

        Regex protocol_regex;
        try {
            protocol_regex = new Regex (".*://.*");
        } catch (RegexError e) {
            critical (e.message);
        }

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;

        var web_context = new WebKit.WebContext.ephemeral ();
        web_context.get_cookie_manager ().set_accept_policy (WebKit.CookieAcceptPolicy.NO_THIRD_PARTY);

        var web_view = new WebKit.WebView.with_context (web_context);
        web_view.expand = true;
        web_view.height_request = 200;

        var back_button = new Gtk.Button.from_icon_name ("go-previous-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        back_button.sensitive = false;
        back_button.tooltip_text = "Back";
        back_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Alt>Left"}, back_button.tooltip_text);

        var forward_button = new Gtk.Button.from_icon_name ("go-next-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        forward_button.sensitive = false;
        forward_button.tooltip_text = "Forward";
        forward_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Alt>Right"}, forward_button.tooltip_text);

        var refresh_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        refresh_button.tooltip_text = "Reload page";
        refresh_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>r"}, refresh_button.tooltip_text);

        var stop_button = new Gtk.Button.from_icon_name ("process-stop-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        stop_button.tooltip_text = "Stop loading";

        var refresh_stop_stack = new Gtk.Stack ();
        refresh_stop_stack.add (refresh_button);
        refresh_stop_stack.add (stop_button);
        refresh_stop_stack.visible_child = refresh_button;

        var new_window_button = new Gtk.Button.from_icon_name ("window-new", Gtk.IconSize.LARGE_TOOLBAR);
        new_window_button.tooltip_text = "Open new window";
        new_window_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>n"}, new_window_button.tooltip_text);

        var url_entry = new Gtk.Entry ();
        url_entry.hexpand = true;
        url_entry.width_request = 100;
        url_entry.tooltip_text = "Enter a URL";
        url_entry.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>l"}, url_entry.tooltip_text);

        var erase_button = new Gtk.Button.from_icon_name ("edit-delete", Gtk.IconSize.LARGE_TOOLBAR);
        erase_button.tooltip_text = "Erase browsing history";
        erase_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>W"}, erase_button.tooltip_text);

        List<AppInfo> external_apps = GLib.AppInfo.get_all_for_type ("x-scheme-handler/http");
        foreach (AppInfo app_info in external_apps) {
            if (app_info.get_id () == GLib.Application.get_default ().application_id + ".desktop") {
                external_apps.remove (app_info);
            }
        }

        if (external_apps.length () > 1) {
            var open_button = new Gtk.MenuButton ();
            open_button.image = new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
            open_button.tooltip_text = "Open page in…";

            var open_popover = new Gtk.Popover (open_button);
            open_button.popover = open_popover;

            var open_grid = new Gtk.Grid ();
            open_grid.orientation = Gtk.Orientation.VERTICAL;

            open_popover.add (open_grid);

            header.pack_end (open_button);

            foreach (AppInfo app_info in external_apps) {
                var browser_icon = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.MENU);
                browser_icon.pixel_size = 16;

                var browser_grid = new Gtk.Grid ();
                browser_grid.margin = 3;
                browser_grid.column_spacing = 3;
                browser_grid.add (browser_icon);
                browser_grid.add (new Gtk.Label (app_info.get_name ()));

                var browser_button = new Gtk.Button ();
                browser_button.get_style_context ().add_class (Gtk.STYLE_CLASS_MENUITEM);
                browser_button.add (browser_grid);

                open_grid.add (browser_button);
                browser_button.visible = true;

                browser_button.clicked.connect (() => {
                    var uris = new List<string> ();
                    uris.append (web_view.get_uri ());

                    try {
                        app_info.launch_uris (uris, null);
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }

                    open_popover.popdown ();
                });

                browser_grid.show_all ();
            }

            open_grid.show_all ();
        } else {
            foreach (AppInfo app_info in external_apps) {
                var browser_icon = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.LARGE_TOOLBAR);
                browser_icon.pixel_size = 24;

                var open_button = new Gtk.Button ();
                open_button.image = browser_icon;
                open_button.tooltip_text = "Open page in %s".printf (app_info.get_name ());

                header.pack_end (open_button);

                open_button.clicked.connect (() => {
                    var uris = new List<string> ();
                    uris.append (web_view.get_uri ());

                    try {
                        app_info.launch_uris (uris, null);
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }
                });
            }
        }

        header.pack_start (back_button);
        header.pack_start (forward_button);
        header.pack_start (refresh_stop_stack);
        header.pack_end (new_window_button);
        header.pack_end (erase_button);

        header.custom_title = url_entry;

        var grid = new Gtk.Grid ();
        grid.add (web_view);

        set_titlebar (header);
        add (grid);

        if (uri != null && uri != "") {
            web_view.load_uri (uri);
        } else {
            web_view.load_uri (HOME);
        }

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

        new_window_button.clicked.connect (() => {
            new_window ();
        });

        erase_button.clicked.connect (() => {
            erase (this);
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

        web_view.decide_policy.connect ((decision, type) => {
            debug ("Decide policy");

            if (type == WebKit.PolicyDecisionType.NEW_WINDOW_ACTION) {
                debug ("New window");

                var nav_decision = (WebKit.NavigationPolicyDecision) decision;
                var uri = nav_decision.navigation_action.get_request ().uri;
                web_view.load_uri (uri);
            }

            return false;
        });

        url_entry.activate.connect (() => {
            // TODO: Search?
            var url = url_entry.text;
            if (!protocol_regex.match (url)) {
                url = "%s://%s".printf ("https", url);
            }
            web_view.load_uri (url);
        });

        var accel_group = new Gtk.AccelGroup ();

        accel_group.connect (
            Gdk.Key.Left,
            Gdk.ModifierType.MOD1_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                web_view.go_back ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.Right,
            Gdk.ModifierType.MOD1_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                web_view.go_forward ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.R,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                web_view.reload ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.L,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                url_entry.grab_focus ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.W,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                erase (this);
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.N,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                new_window ();
                return true;
            }
        );

        add_accel_group (accel_group);

        web_view.button_release_event.connect ((event) => {
            if (event.button == 8) {
                web_view.go_back ();
                return true;
            } else if (event.button == 9) {
                web_view.go_forward ();
                return true;
            }

            return false;
        });
    }

    private void erase (Gtk.Window window) {
        new_window ();
        window.close ();
    }

    private void new_window () {
        var app_window = new MainWindow (application);
        app_window.show_all ();
    }
}

