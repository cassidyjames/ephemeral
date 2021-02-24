/*
* Copyright © 2019–2021 Cassidy James Blaede (https://cassidyjames.com)
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
    public Gtk.CheckButton external_check { get; set;}

    public Gtk.Window main_window { get; construct set; }
    public WebView web_view { get; construct set; }

    private Gtk.Button open_button { get; set; }
    private List<AppInfo> external_apps = AppInfo.get_all_for_type (Application.CONTENT_TYPES[0]);

    public BrowserButton (Gtk.Window _main_window, WebView _web_view) {
        Object (
            main_window: _main_window,
            web_view: _web_view
        );
    }

    construct {
        // Prune Ephemeral from the list of apps
        foreach (AppInfo app_info in external_apps) {
            if (app_info.get_id () == GLib.Application.get_default ().application_id + ".desktop") {
                external_apps.remove (app_info);
            }
        }

        unowned Gtk.StyleContext context = get_style_context ();
        context.add_class (Gtk.STYLE_CLASS_LINKED);
        context.add_class ("browser-button");

        var list_button = new Gtk.MenuButton ();
        list_button.image = new Gtk.Image.from_icon_name ("pan-down-symbolic", Gtk.IconSize.BUTTON);
        // TRANSLATORS: Includes an ellipsis (…) in English to signify the action will be performed in another menu
        list_button.tooltip_text = _("Open page in…");
        list_button.get_style_context ().add_class (Gtk.STYLE_CLASS_RAISED);

        open_button = new Gtk.Button ();
        open_button.get_style_context ().add_class (Gtk.STYLE_CLASS_RAISED);

        var list_popover = new Gtk.Popover (list_button);
        list_button.popover = list_popover;

        var list_grid = new Gtk.Grid ();
        list_grid.orientation = Gtk.Orientation.VERTICAL;

        external_check = new Gtk.CheckButton.with_label (_("Automatically Open This Site Externally")) {
            active = new Soup.URI (web_view.get_uri ()).get_host () in Application.settings.get_strv ("external-websites")
        };

        unowned Gtk.StyleContext external_check_context = external_check.get_style_context ();
        external_check_context.add_class (Gtk.STYLE_CLASS_MENUITEM);
        external_check_context.add_class (Gtk.STYLE_CLASS_FLAT);

        var close_check = new Gtk.CheckButton.with_label (_("Close Window When Opening Externally"));
        close_check.margin_bottom = 3;

        unowned Gtk.StyleContext close_check_context = close_check.get_style_context ();
        close_check_context.add_class (Gtk.STYLE_CLASS_MENUITEM);
        close_check_context.add_class (Gtk.STYLE_CLASS_FLAT);

        list_popover.add (list_grid);

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

            unowned Gtk.StyleContext browser_item_context = browser_item.get_style_context ();
            browser_item_context.add_class (Gtk.STYLE_CLASS_MENUITEM);
            browser_item_context.add_class (Gtk.STYLE_CLASS_FLAT);

            list_grid.add (browser_item);
            browser_item.visible = true;

            browser_grid.show_all ();

            browser_item.clicked.connect (() => {
                Application.settings.set_string ("last-used-browser", app_info.get_id ());
                try_opening (app_info, web_view.get_uri ());
                list_popover.popdown ();
            });
        }

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.margin_top = separator.margin_bottom = 3;

        list_grid.add (separator);
        list_grid.add (external_check);
        list_grid.add (close_check);
        list_grid.show_all ();

        setup_preferred_browser ();

        attach (open_button, 0, 0);
        attach (list_button, 1, 0);

        Application.settings.changed["last-used-browser"].connect (() => {
            setup_preferred_browser ();
        });

        external_check.toggled.connect (() => {
            string domain = new Soup.URI (web_view.get_uri ()).get_host ();
            var external_websites = Application.settings.get_strv ("external-websites");

            if (external_check.active) {
                if (! (domain in external_websites)) {
                    external_websites += domain;
                }
            } else {
                if (domain in external_websites) {
                   string[] pruned_domains = {};
                    foreach (string existing_domain in external_websites) {
                        if (existing_domain != domain) {
                            pruned_domains += existing_domain;
                        }
                    }

                    external_websites = pruned_domains;
                }
            }

            Application.settings.set_strv ("external-websites", external_websites);
        });

        Application.settings.bind (
            "close-when-opening-externally",
            close_check,
            "active",
            SettingsBindFlags.DEFAULT
        );
    }

    private void setup_preferred_browser () {
        string preferred_browser = Application.settings.get_string ("last-used-browser");
        if (preferred_browser == "") {
            // Just grab the first browser
            preferred_browser = external_apps.first ().data.get_id ();
        }

        foreach (AppInfo app_info in external_apps) {
            if (app_info.get_id () == preferred_browser) {
                var browser_icon = new Gtk.Image.from_gicon (
                    app_info.get_icon (),
                    Application.instance.icon_size
                );
                browser_icon.pixel_size = Application.instance.icon_pixel_size;

                open_button.image = browser_icon;
                open_button.tooltip_text = _("Open page in %s").printf (app_info.get_name ());
                open_button.tooltip_markup = Granite.markup_accel_tooltip (
                  {"<Ctrl>o"},
                  open_button.tooltip_text
                );

                open_button.clicked.connect (() => {
                    try_opening (app_info, web_view.get_uri ());
                });
            }
        }
    }

    public void try_opening (AppInfo app_info, string uri) {
        var uris = new List<string> ();
        uris.append (uri);

        try {
            app_info.launch_uris (uris, null);

            if (Application.settings.get_boolean ("close-when-opening-externally")) {
                main_window.close ();
            } else {
                Application.instance.last_external_open = new DateTime.now_utc ().to_unix ();
            }
        } catch (Error e) {
            critical (e.message);
        }
    }

    public virtual override new signal void activate () {
        open_button.activate ();
    }
}
