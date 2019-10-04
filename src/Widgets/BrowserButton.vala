/*
* Copyright © 2019 Cassidy James Blaede (https://cassidyjames.com)
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

public class Ephemeral.BrowserButton : Gtk.Grid {
    public Gtk.Window main_window { get; construct set; }
    public WebView web_view { get; construct set; }
    public Gtk.MenuButton list_button {get; construct set; }
    public Gtk.Button open_button {get; construct set; }

    public BrowserButton (Gtk.Window _main_window, WebView _web_view) {
        Object (
            main_window: _main_window,
            web_view: _web_view
        );
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);

        List<AppInfo> external_apps = GLib.AppInfo.get_all_for_type (Application.CONTENT_TYPES[0]);
        foreach (AppInfo app_info in external_apps) {
            if (app_info.get_id () == GLib.Application.get_default ().application_id + ".desktop") {
                external_apps.remove (app_info);
            }
        }

        if (external_apps.length () > 1) {
            list_button = new Gtk.MenuButton ();
            // TRANSLATORS: Includes an ellipsis (…) in English to signify the action will be performed in another menu
            list_button.tooltip_text = _("Open page in…");

            open_button = new Gtk.Button ();

            ulong last_browser_handler_id;

            attach (open_button, 0, 0);
            attach (list_button, 1, 0);
            var last_used_browser_shown = false;

            if (Application.settings.get_string ("last-used-browser") != "") {
                foreach (AppInfo app_info in external_apps) {
                    if (app_info.get_id () == Application.settings.get_string ("last-used-browser")) {
                        var browser_icon = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.LARGE_TOOLBAR);
                        browser_icon.pixel_size = 24;

                        open_button.image = browser_icon;
                        open_button.tooltip_text = _("Open page in %s").printf (app_info.get_name ());
                        open_button.tooltip_markup = Granite.markup_accel_tooltip (
                          {"<Ctrl>o"},
                          open_button.tooltip_text
                        );

                        open_button.get_style_context ().add_class (Gtk.STYLE_CLASS_RAISED);

                        last_used_browser_shown = true;

                        last_browser_handler_id = open_button.clicked.connect (() => {
                            try_opening (app_info, web_view.get_uri ());
                        });
                    }
                }

                list_button.image = new Gtk.Image.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);

                list_button.get_style_context ().add_class (Gtk.STYLE_CLASS_RAISED);
            } else {
                open_button.show.connect (() => { // Needed because of show_all () being executed after this constructor
                    if (!last_used_browser_shown) {
                        open_button.hide ();
                    }
                });

                list_button.image = new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);

                list_button.get_style_context ().remove_class (Gtk.STYLE_CLASS_RAISED);
            }

            var list_popover = new Gtk.Popover (list_button);
            list_button.popover = list_popover;

            var list_grid = new Gtk.Grid ();
            list_grid.orientation = Gtk.Orientation.VERTICAL;

            var close_check = new Gtk.CheckButton.with_label (_("Close Window When Opening Externally"));
            close_check.margin_bottom = 3;

            var close_check_context = close_check.get_style_context ();
            close_check_context.add_class (Gtk.STYLE_CLASS_MENUITEM);
            close_check_context.add_class (Gtk.STYLE_CLASS_FLAT);

            Application.settings.bind (
                "close-when-opening-externally",
                close_check,
                "active",
                SettingsBindFlags.DEFAULT
            );

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
                browser_item.add (browser_grid);

                var browser_item_context = browser_item.get_style_context ();
                browser_item_context.add_class (Gtk.STYLE_CLASS_MENUITEM);
                browser_item_context.add_class (Gtk.STYLE_CLASS_FLAT);

                list_grid.add (browser_item);
                browser_item.visible = true;

                browser_item.clicked.connect (() => {
                    Application.settings.set_string ("last-used-browser", app_info.get_id ());
                    try_opening (app_info, web_view.get_uri ());
                    list_popover.popdown ();
                });

                browser_grid.show_all ();
            }

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            separator.margin_top = separator.margin_bottom = 3;

            list_grid.add (separator);
            list_grid.add (close_check);
            list_grid.show_all ();

            // Update open_button when the gsettings value has changed
            Application.settings.changed["last-used-browser"].connect (() => {
                if (Application.settings.get_string ("last-used-browser") != "") {
                    if (!last_used_browser_shown) {
                        // Add style classes if no browser has been used before
                        last_used_browser_shown = true;
                        open_button.get_style_context ().add_class (Gtk.STYLE_CLASS_RAISED);

                        list_button.hide ();
                        list_button.image = new Gtk.Image.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);
                        // TRANSLATORS: Includes an ellipsis (…) in English to signify the action will be performed in another menu
                        list_button.tooltip_text = _("Open page in…");

                        list_button.get_style_context ().add_class (Gtk.STYLE_CLASS_RAISED);

                        list_button.show_all ();
                    } else {
                        open_button.hide ();
                    }

                    // Show the last-used browser
                    foreach (AppInfo app_info in external_apps) {
                        if (app_info.get_id () == Application.settings.get_string ("last-used-browser")) {
                            var browser_icon = new Gtk.Image.from_gicon (
                                app_info.get_icon (),
                                Gtk.IconSize.LARGE_TOOLBAR
                            );
                            browser_icon.pixel_size = 24;

                            open_button.image = browser_icon;
                            open_button.tooltip_text = _("Open page in %s").printf (app_info.get_name ());
                            open_button.tooltip_markup = Granite.markup_accel_tooltip (
                                {"<Ctrl>o"},
                                open_button.tooltip_text
                            );
                            open_button.show_all ();

                            open_button.disconnect (last_browser_handler_id);
                            last_browser_handler_id = open_button.clicked.connect (() => {
                                try_opening (app_info, web_view.get_uri ());
                            });
                        }
                    }
                } else {
                    last_used_browser_shown = false;
                    open_button.hide ();
                    list_button.hide ();
                    list_button.image = new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
                    // TRANSLATORS: Includes an ellipsis (…) in English to signify the action will be performed in another menu
                    list_button.tooltip_text = _("Open page in…");
                    list_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>o"}, list_button.tooltip_text);

                    list_button.get_style_context ().remove_class (Gtk.STYLE_CLASS_RAISED);

                    list_button.show_all ();
                }
            });
        } else {
            foreach (AppInfo app_info in external_apps) {
                var browser_icon = new Gtk.Image.from_gicon (app_info.get_icon (), Gtk.IconSize.LARGE_TOOLBAR);
                browser_icon.pixel_size = 24;

                var open_single_browser_button = new Gtk.Button ();
                open_single_browser_button.image = browser_icon;
                open_single_browser_button.tooltip_text = _("Open page in %s").printf (app_info.get_name ());
                open_single_browser_button.tooltip_markup = Granite.markup_accel_tooltip (
                    {"<Ctrl>o"},
                    open_single_browser_button.tooltip_text
                );

                add (open_single_browser_button);

                open_single_browser_button.clicked.connect (() => {
                    Application.settings.set_string ("last-used-browser", app_info.get_id ());
                    try_opening (app_info, web_view.get_uri ());
                });
            }
        }
    }

    private void try_opening (AppInfo app_info, string uri) {
        var uris = new List<string> ();
        uris.append (uri);

        try {
            app_info.launch_uris (uris, null);
            if (Application.settings.get_boolean ("close-when-opening-externally")) {
                main_window.close ();
            }
        } catch (GLib.Error e) {
            critical (e.message);
        }
    }

    public virtual override new signal void activate () {
        if (open_button.visible && sensitive) {
            open_button.activate ();
        } else if (list_button.visible && sensitive) {
            list_button.activate ();
        }
    }
}
