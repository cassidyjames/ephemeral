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
    public Gtk.Popover popover { get; construct set; }
    public Gtk.MenuButton export_button { get; construct set; }
    public Gtk.Button last_used_button { get; construct set; }
    public Gtk.MenuButton list_button { get; construct set; }
    public Gtk.Button single_button { get; construct set; }
    public Gtk.Stack stack { get; construct set; }

    public WebKit.WebView web_view { get; construct set; }

    public BrowserButton (WebKit.WebView _web_view) {
        Object (
            web_view: _web_view
        );
    }

    construct {
        var settings = new Settings ("com.github.cassidyjames.ephemeral");

        // Shown when there are many browsers, but no default/last-used
        export_button = new Gtk.MenuButton ();
        export_button.image = new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
        export_button.tooltip_text = "Open page in…";
        export_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>o"}, export_button.tooltip_text);

        // Shown when there's a last-used browser to open it directly
        last_used_button = new Gtk.Button ();

        var last_used_button_context = last_used_button.get_style_context ();
        last_used_button_context.add_class (Gtk.STYLE_CLASS_RAISED);
        last_used_button_context.add_class (Gtk.STYLE_CLASS_LINKED);

        // Shown when there's a last-used browser plus others, to list them
        list_button = new Gtk.MenuButton ();
        list_button.image = new Gtk.Image.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);
        list_button.tooltip_text = "Open page in…";
        list_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>o"}, list_button.tooltip_text);

        var list_button_context = list_button.get_style_context ();
        list_button_context.add_class (Gtk.STYLE_CLASS_RAISED);
        list_button_context.add_class (Gtk.STYLE_CLASS_LINKED);

        var last_used_grid = new Gtk.Grid ();
        last_used_grid.add (last_used_button);
        last_used_grid.add (list_button);

        // Shown when there's only one other browser
        single_button = new Gtk.Button ();

        // To toggle between the three states
        stack = new Gtk.Stack ();
        stack.add_named (export_button, "export");
        stack.add_named (last_used_grid, "last-used");
        stack.add_named (single_button, "single");

        add (stack);

        update_button ();

        settings.changed["last-used-browser"].connect (() => {
            update_button ();
        });
    }

    private void update_button () {
        var settings = new Settings ("com.github.cassidyjames.ephemeral");

        // Get all browsers, minus Ephemeral
        List<AppInfo> external_apps = GLib.AppInfo.get_all_for_type (Ephemeral.CONTENT_TYPES[0]);
        foreach (AppInfo app_info in external_apps) {
            if (app_info.get_id () == GLib.Application.get_default ().application_id + ".desktop") {
                external_apps.remove (app_info);
            }
        }

        // ulong last_used_handler_id;
        if (external_apps.length () > 1) {

            var popover_grid = new Gtk.Grid ();
            popover_grid.orientation = Gtk.Orientation.VERTICAL;

            popover = new Gtk.Popover (export_button);
            popover.add (popover_grid);

            export_button.popover = popover;
            list_button.popover = popover;

            // Build the popover
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

                popover_grid.add (browser_item);

                browser_item.clicked.connect (() => {
                    settings.set_string ("last-used-browser", app_info.get_id ());

                    var uris = new List<string> ();
                    uris.append (web_view.get_uri ());

                    try {
                        app_info.launch_uris (uris, null);
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }

                    popover.popdown ();
                });
            }

            popover_grid.show_all ();

            if (settings.get_string ("last-used-browser") == "") {
                // No last-used, so display the export icon
            } else {
                // There's a previous browser, so show it and the dropdown
                // last_used_button.disconnect (last_used_handler_id);

                var last_used_stack = new Gtk.Stack ();

                foreach (AppInfo app_info in external_apps) {

                    var browser_icon = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.LARGE_TOOLBAR);
                    browser_icon.pixel_size = 24;

                    last_used_button.image = browser_icon;
                    last_used_button.tooltip_text = "Open page in %s".printf (app_info.get_name ());
                    last_used_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>o"}, last_used_button.tooltip_text);

                    last_used_stack.add_named (last_used_button, app_info.get_id ());

                    if (app_info.get_id () == settings.get_string ("last-used-browser")) {
                        last_used_stack.visible_child = last_used_button;
                    }

                    /* last_used_handler_id = */ last_used_button.clicked.connect (() => {
                        var uris = new List<string> ();
                        uris.append (web_view.get_uri ());

                        try {
                            app_info.launch_uris (uris, null);
                        } catch (GLib.Error e) {
                            critical (e.message);
                        }
                    });
                }

                stack.visible_child_name = "last-used";
            }

        } else {
            // Show the other browser right in the headerbar
            foreach (AppInfo app_info in external_apps) {
                var browser_icon = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.LARGE_TOOLBAR);
                browser_icon.pixel_size = 24;

                single_button.image = browser_icon;
                single_button.tooltip_text = "Open page in %s".printf (app_info.get_name ());
                single_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>o"}, single_button.tooltip_text);

                single_button.clicked.connect (() => {
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

    // public virtual override new signal void activate () {
    //     if (open_button.visible && sensitive) {
    //         open_button.activate ();
    //     } else if (list_button.visible && sensitive) {
    //         list_button.activate ();
    //     }
    // }
}

