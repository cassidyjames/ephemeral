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

public class UrlEntry : Gtk.Entry {
    private const string SEARCH = "https://duckduckgo.com/?q=%s";
    public WebKit.WebView web_view { get; construct set; }

    public UrlEntry (WebKit.WebView _web_view) {
        Object (
            hexpand: true,
            web_view: _web_view,
            width_request: 100
        );
    }

    construct {
        tooltip_text = _("Enter a URL or search term");
        placeholder_text = tooltip_text;

        tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>l"}, tooltip_text);

        secondary_icon_name = "go-jump-symbolic";
        secondary_icon_tooltip_text = _("Go");
        secondary_icon_tooltip_markup = Granite.markup_accel_tooltip ({"Return"}, secondary_icon_tooltip_text);

        activate.connect (() => {
            // TODO: Better URL validation
            if (text == "" || text == null) {
                Gdk.beep ();
                return;
            } else if (!text.contains ("://")) {
                if (text.contains (".") && !text.contains (" ")) {
                    text = "%s://%s".printf ("https", text);
                } else {
                    text = SEARCH.printf (text);
                }
            }
            web_view.load_uri (text);
        });

        focus_out_event.connect ((event) => {
            string uri = web_view.get_uri ();
            if (uri == "about:blank") {
                text = "";
            }

            return false;
        });

        icon_release.connect ((icon_pos, event) => {
            if (icon_pos == Gtk.EntryIconPosition.SECONDARY) {
                activate ();
            }
        });

        web_view.load_changed.connect ((source, e) => {
            if (!has_focus) {
                text = source.get_uri ();
            }
        });
    }
}

