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

public class Ephemeral.WebView : WebKit.WebView {
    public WebView () {
        Object (
            expand: true,
            height_request: 200
        );
    }

    construct {
        var webkit_settings = new WebKit.Settings();
        webkit_settings.allow_file_access_from_file_urls = true;
        webkit_settings.default_font_family = Gtk.Settings.get_default().gtk_font_name;
        webkit_settings.enable_java = false;
        webkit_settings.enable_mediasource = true;
        webkit_settings.enable_plugins = false;
        webkit_settings.enable_smooth_scrolling = true;

        var webkit_web_context = new WebKit.WebContext.ephemeral ();
        webkit_web_context.set_process_model (WebKit.ProcessModel.MULTIPLE_SECONDARY_PROCESSES);
        webkit_web_context.get_cookie_manager ().set_accept_policy (WebKit.CookieAcceptPolicy.NO_THIRD_PARTY);

        settings = webkit_settings;
        web_context = webkit_web_context;

        context_menu.connect (on_context_menu);
        script_dialog.connect (on_script_dialog);

        button_release_event.connect ((event) => {
            if (event.button == 8) {
                go_back ();
                return true;
            } else if (event.button == 9) {
                go_forward ();
                return true;
            }

            return false;
        });

        // bind webkit_settings.enable_javascript to setting
        Application.settings.bind ("enable-javascript", webkit_settings, "enable-javascript", SettingsBindFlags.DEFAULT);
    }

    private bool on_context_menu (
        WebKit.ContextMenu context_menu,
        Gdk.Event event,
        WebKit.HitTestResult hit_test_result
    ) {
        if (hit_test_result.context_is_link ()) {
            debug ("Intercepting and rebuilding context menu since it’s a link");
            context_menu.remove_all ();

            var new_window_action = new SimpleAction ("new-window", null);
            var new_window_item = new WebKit.ContextMenuItem.from_gaction (
                new_window_action,
                _("Open Link in New _Window"),
                null
            );

            context_menu.append (new_window_item);
            context_menu.append (new WebKit.ContextMenuItem.from_stock_action (WebKit.ContextMenuAction.COPY_LINK_TO_CLIPBOARD));

            new_window_action.activate.connect (() => {
                Application.instance.new_window (hit_test_result.link_uri);
            });

        } else {
            debug ("Leaving context menu as-is");
        }

        return false;
    }

    private bool on_script_dialog (WebKit.ScriptDialog dialog) {
        var message_dialog = new ScriptDialog (dialog);
        message_dialog.show ();

        return true;
    }
}

