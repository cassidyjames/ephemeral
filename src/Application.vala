/*
* Copyright © 2019–2021 Cassidy James Blaede (https://cassidyjames.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
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

public class Ephemeral.Application : Gtk.Application {
    public const string[] CONTENT_TYPES = {
        "x-scheme-handler/http",
        "x-scheme-handler/https",
        "text/html",
        "application/x-extension-htm",
        "application/x-extension-html",
        "application/x-extension-shtml",
        "application/xhtml+xml",
        "application/x-extension-xht"
    };

    // Once a month
    public const int64 NOTICE_SECS = 60 * 60 * 24 * 30;
    public const string DONATE_URL = "https://cassidyjames.com/pay";
    public const string STARTPAGE = "https://www.startpage.com/do/search?q=%s&prfh=enable_stay_controlEEE0N1N";
    public const string DDG = "https://duckduckgo.com/?q=%s&kp=1&t=elementary";

    public static GLib.Settings settings;
    public Gtk.IconSize icon_size = Gtk.IconSize.LARGE_TOOLBAR;
    public int icon_pixel_size = 24;

    public bool ask_default_for_session = true;
    public bool opening_link = false;
    public bool warn_native_for_session = true;
    public bool warn_paid_for_session = true;
    public int64 last_external_open = int64.MIN;

    public Application () {
        Object (
            application_id: "com.github.cassidyjames.ephemeral",
            flags: ApplicationFlags.HANDLES_OPEN
        );
    }

    public static Application _instance = null;
    public static Application instance {
        get {
            if (_instance == null) {
                _instance = new Application ();
            }
            return _instance;
        }
    }

    static construct {
        settings = new Settings (Application.instance.application_id);
    }

    protected override void activate () {
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/cassidyjames/ephemeral/styles/global.css");
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        switch (stylesheet ()) {
            case -1:
                Application.instance.icon_size = Gtk.IconSize.SMALL_TOOLBAR;
                Application.instance.icon_pixel_size = 16;

                var non_native_provider = new Gtk.CssProvider ();
                non_native_provider.load_from_resource ("/com/github/cassidyjames/ephemeral/styles/non-native.css");
                Gtk.StyleContext.add_provider_for_screen (
                    Gdk.Screen.get_default (),
                    non_native_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
                break;
            case 5:
                var hera_provider = new Gtk.CssProvider ();
                hera_provider.load_from_resource ("/com/github/cassidyjames/ephemeral/styles/hera.css");
                Gtk.StyleContext.add_provider_for_screen (
                    Gdk.Screen.get_default (),
                    hera_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
                break;
            case 6:
                var odin_provider = new Gtk.CssProvider ();
                odin_provider.load_from_resource ("/com/github/cassidyjames/ephemeral/styles/odin.css");
                Gtk.StyleContext.add_provider_for_screen (
                    Gdk.Screen.get_default (),
                    odin_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                );
                break;
            default:
                break;
        }

        if (!opening_link) {
            var app_window = new MainWindow (this);
            app_window.show_all ();
        }

        var quit_action = new SimpleAction ("quit", null);
        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Ctrl>Q"});

        quit_action.activate.connect (() => {
            quit ();
        });
    }

    public override void open (File[] files, string hint) {
        opening_link = true;
        activate ();
        opening_link = false;

        foreach (var file in files) {
            // TODO: check if local file first, fix protocol handling
            var uri = file.get_uri ();
            var uris = new List<string> ();
            uris.append (uri);
            string? domain = new Soup.URI (file.get_uri ()).get_host ();

            if (domain != null && domain != "") {
                critical (domain);

                if (domain in settings.get_strv ("external-websites")) {
                    foreach (AppInfo app_info in AppInfo.get_all ()) {
                        if (app_info.get_id () == settings.get_string ("last-used-browser")) {
                            try {
                                app_info.launch_uris (uris, null);
                            } catch (Error e) {
                                critical (e.message);
                            }
                        }
                    }
                } else {
                    var app_window = new MainWindow (this, uri);
                    app_window.show_all ();
                }
            } else {
                critical ("Could not open %s; it doesn't look like a website.", uri);
            }
        }
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run (args);
    }

    public static int stylesheet () {
        var full_stylesheet = Gtk.Settings.get_default ().gtk_theme_name;

        if (full_stylesheet.has_prefix ("elementary")) {
            // Juno/Hera
            return 5;
        } else if (full_stylesheet.has_prefix ("io.elementary.stylesheet")) {
            // Odin
            return 6;
        }

        return -1;
    }

    public static bool native () {
        string os = "";
        var file = File.new_for_path ("/etc/os-release");
        try {
            var map = new Gee.HashMap<string, string> ();
            var stream = new DataInputStream (file.read ());
            string line;
            // Read lines until end of file (null) is reached
            while ((line = stream.read_line (null)) != null) {
                var component = line.split ("=", 2);
                if (component.length == 2) {
                    map[component[0]] = component[1].replace ("\"", "");
                }
            }

            os = map["ID"];
        } catch (GLib.Error e) {
            critical ("Couldn't read /etc/os-release: %s", e.message);
        }

        string session = Environment.get_variable ("DESKTOP_SESSION");

        return (
            os == "elementary" &&
            session == "pantheon" &&
            (stylesheet () > 0 )
        );
    }

    public static void new_window (string? uri = null) {
        var app_info = new DesktopAppInfo (Ephemeral.Application.instance.application_id + ".desktop");
        var uris = new List<string> ();
        uris.append (uri);

        try {
            app_info.launch_uris (uris, null);
        } catch (GLib.Error e) {
            critical (e.message);
        }
    }
}
