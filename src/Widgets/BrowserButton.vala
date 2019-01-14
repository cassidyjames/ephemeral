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

public class BrowserButton : Gtk.Grid {
    public WebKit.WebView web_view { get; construct set; }

    public BrowserButton (WebKit.WebView _web_view) {
        Object (
            web_view: _web_view
        );
    }

    construct {
        var settings = new Settings ("com.github.cassidyjames.ephemeral");

        List<AppInfo> external_apps = GLib.AppInfo.get_all_for_type (Ephemeral.CONTENT_TYPES[0]);
        foreach (AppInfo app_info in external_apps) {
            if (app_info.get_id () == GLib.Application.get_default ().application_id + ".desktop") {
                external_apps.remove (app_info);
            }
        }

        if (external_apps.length () > 1) {
            var list_button = new Gtk.MenuButton ();
            Gtk.Button open_button;
            ulong last_browser_handler_id;

            if (settings.get_string ("last-used-browser") != "") {
                // Show the last-used browser
                foreach (AppInfo app_info in external_apps) {
                    if (app_info.get_id () == settings.get_string ("last-used-browser")) {
                        var browser_icon = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.LARGE_TOOLBAR);
                        browser_icon.pixel_size = 24;
        
                        open_button = new Gtk.Button ();
                        open_button.image = browser_icon;
                        open_button.tooltip_text = "Open page in %s".printf (app_info.get_name ());

                        var open_button_context = open_button.get_style_context ();
                        open_button_context.add_class (Gtk.STYLE_CLASS_RAISED);
                        open_button_context.add_class (Gtk.STYLE_CLASS_LINKED);
        
                        attach (open_button, 0, 0);
        
                        last_browser_handler_id = open_button.clicked.connect (() => {
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

                list_button.image = new Gtk.Image.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);

                var list_button_context = list_button.get_style_context ();
                list_button_context.add_class (Gtk.STYLE_CLASS_RAISED);
                list_button_context.add_class (Gtk.STYLE_CLASS_LINKED);

                attach (list_button, 1, 0);
            } else {
                // Show an export-icon
                list_button.image = new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);

                var list_button_context = list_button.get_style_context ();
                list_button_context.remove_class (Gtk.STYLE_CLASS_RAISED);
                list_button_context.remove_class (Gtk.STYLE_CLASS_LINKED);

                attach (list_button, 1, 0);
            }

            list_button.tooltip_text = "Open page in…";

            var list_popover = new Gtk.Popover (list_button);
            list_button.popover = list_popover;

            var list_grid = new Gtk.Grid ();
            list_grid.orientation = Gtk.Orientation.VERTICAL;

            list_popover.add (list_grid);

            // Create a list of installed browsers
            foreach (AppInfo app_info in external_apps) {
                var browser_icon = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.MENU);
                browser_icon.pixel_size = 16;

                var browser_grid = new Gtk.Grid ();
                browser_grid.margin = 3;
                browser_grid.column_spacing = 3;
                browser_grid.add (browser_icon);
                browser_grid.add (new Gtk.Label (app_info.get_name ()));

                var browser_item = new Gtk.Button ();
                browser_item.get_style_context ().add_class (Gtk.STYLE_CLASS_MENUITEM);
                browser_item.add (browser_grid);

                list_grid.add (browser_item);
                browser_item.visible = true;

                browser_item.clicked.connect (() => {
                    settings.set_string ("last-used-browser", app_info.get_id ());

                    var uris = new List<string> ();
                    uris.append (web_view.get_uri ());

                    try {
                        app_info.launch_uris (uris, null);
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }

                    list_popover.popdown ();
                });

                browser_grid.show_all ();
            }

            list_grid.show_all ();

            // Update open_button when the gsettings value has changed
            settings.changed["last-used-browser"].connect (() => {
                if (open_button == null) {
                    // Initialize the button if no browser has been used before
                    open_button = new Gtk.Button ();

                    var open_button_context = open_button.get_style_context ();
                    open_button_context.add_class (Gtk.STYLE_CLASS_RAISED);
                    open_button_context.add_class (Gtk.STYLE_CLASS_LINKED);

                    list_button.hide ();
                    list_button.image = new Gtk.Image.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);

                    var list_button_context = open_button.get_style_context ();
                    list_button_context.remove_class (Gtk.STYLE_CLASS_RAISED);
                    list_button_context.remove_class (Gtk.STYLE_CLASS_LINKED);

                    list_button.show_all ();
        
                    attach (open_button, 0, 0);
                } else {
                    open_button.hide ();
                }

                // Show the last-used browser
                foreach (AppInfo app_info in external_apps) {
                    if (app_info.get_id () == settings.get_string ("last-used-browser")) {
                        var browser_icon = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.LARGE_TOOLBAR);
                        browser_icon.pixel_size = 24;
        
                        open_button.image = browser_icon;
                        open_button.tooltip_text = "Open page in %s".printf (app_info.get_name ());
                        open_button.show_all ();
        
                        open_button.disconnect (last_browser_handler_id);
                        last_browser_handler_id = open_button.clicked.connect (() => {
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
            });
        } else {
            foreach (AppInfo app_info in external_apps) {
                var browser_icon = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.LARGE_TOOLBAR);
                browser_icon.pixel_size = 24;

                var open_single_browser_button = new Gtk.Button ();
                open_single_browser_button.image = browser_icon;
                open_single_browser_button.tooltip_text = "Open page in %s".printf (app_info.get_name ());

                add (open_single_browser_button);

                open_single_browser_button.clicked.connect (() => {
                    settings.set_string ("last-used-browser", app_info.get_id ());

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
    }
}

