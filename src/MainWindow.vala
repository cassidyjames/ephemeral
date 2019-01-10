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
        var settings = new Settings ("com.github.cassidyjames.ephemeral");

        default_height = 800;
        default_width = 1280;

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

        var url_entry = new UrlEntry (web_view);

        var erase_button = new Gtk.Button.from_icon_name ("edit-delete", Gtk.IconSize.LARGE_TOOLBAR);
        erase_button.tooltip_text = "Erase browsing history";
        erase_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>W"}, erase_button.tooltip_text);

        var browser_button = new BrowserButton (web_view);

        header.pack_start (back_button);
        header.pack_start (forward_button);
        header.pack_start (refresh_stop_stack);
        header.pack_end (browser_button);
        header.pack_end (new_window_button);
        header.pack_end (erase_button);

        header.custom_title = url_entry;

        var default_label = new Gtk.Label ("<b>Make privacy a habit.</b> Set Ephemeral as your default browser?");
        default_label.use_markup = true;

        var default_app_info = GLib.AppInfo.get_default_for_type (Ephemeral.CONTENT_TYPES[0], false);
        var app_info = new GLib.DesktopAppInfo (GLib.Application.get_default ().application_id + ".desktop");

        var info_bar = new Gtk.InfoBar ();
        info_bar.message_type = Gtk.MessageType.QUESTION;
        info_bar.show_close_button = true;

        info_bar.get_content_area ().add (default_label);
        info_bar.add_button ("Never Ask Again", Gtk.ResponseType.REJECT);
        info_bar.add_button ("Set as Default", Gtk.ResponseType.ACCEPT);

        info_bar.revealed =
            !default_app_info.equal (app_info) &&
            settings.get_boolean ("ask-default") &&
            Ephemeral.instance.ask_default_for_session;

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.add (info_bar);
        grid.add (web_view);

        set_titlebar (header);
        add (grid);

        if (uri != null && uri != "") {
            web_view.load_uri (uri);
        } else {
            web_view.load_uri (HOME);
        }

        show_all ();
        url_entry.grab_focus ();

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
            new_window (application);
        });

        erase_button.clicked.connect (() => {
            erase (this);
        });

        info_bar.response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.ACCEPT:
                    try {
                        for (int i = 0; i < Ephemeral.CONTENT_TYPES.length; i++) {
                            app_info.set_as_default_for_type (Ephemeral.CONTENT_TYPES[i]);
                        }
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }
                case Gtk.ResponseType.REJECT:
                    settings.set_boolean ("ask-default", false);
                case Gtk.ResponseType.CLOSE:
                    Ephemeral.instance.ask_default_for_session = false;
                    info_bar.revealed = false;
                    break;
                default:
                    assert_not_reached ();
            }
        });

        web_view.load_changed.connect ((source, event) => {
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
                new_window (application);
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
        new_window (application);
        window.close ();
    }

    private void new_window (Gtk.Application application) {
        var app_window = new MainWindow (application);
        app_window.show_all ();
    }
}

