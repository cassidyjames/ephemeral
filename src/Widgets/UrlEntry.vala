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

public class UrlEntry : Gtk.Entry {
    public WebKit.WebView web_view { get; construct set; }

    public UrlEntry (WebKit.WebView _web_view) {
        Object (
            hexpand: true,
            tooltip_text: "Enter a URL",
            web_view: _web_view,
            width_request: 100
        );
    }

    construct {
        Regex protocol_regex;
        try {
            protocol_regex = new Regex (".*://.*");
        } catch (RegexError e) {
            critical (e.message);
        }

        tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>l"}, tooltip_text);

        activate.connect (() => {
            // TODO: Search?
            var url = this.text;
            if (!protocol_regex.match (url)) {
                url = "%s://%s".printf ("https", url);
            }
            web_view.load_uri (url);
        });
    }
}

