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

        script_dialog.connect (on_script_dialog);
    }

    private bool on_script_dialog (WebKit.ScriptDialog dialog) {
        var message_dialog = new Ephemeral.ScriptDialog (dialog);
        message_dialog.show ();
        return true;
    }
}

