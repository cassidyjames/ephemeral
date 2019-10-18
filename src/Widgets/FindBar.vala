/*
* Copyright © 2019 Cassidy James Blaede (https://cassidyjames.com)
              2018 Christian Dywan <christian@twotoats.de>
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

public class Ephemeral.FindBar : Gtk.Revealer {
    // Parts adapted from Midori:
    // https://github.com/midori-browser/core/blob/435ef6d48c4b4ff07c00ea028edd89a3ea2d5386/core/browser.vala
    public WebView web_view { get; construct set; }
    public Gtk.SearchEntry entry;

    public FindBar (WebView _web_view) {
        Object (
            web_view: _web_view
        );
    }

    construct {
        transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        get_style_context ().add_class ("search-bar");

        var label = new Gtk.Label (_("Find in page:"));

        entry = new Gtk.SearchEntry ();

        var find_grid = new Gtk.Grid ();

        find_grid.add (entry);

        var toolbar = new Gtk.Grid ();
        toolbar.border_width = 3;
        toolbar.column_spacing = 5;
        toolbar.halign = Gtk.Align.CENTER;

        toolbar.add (label);
        toolbar.add (find_grid);

        add (toolbar);

        entry.key_press_event.connect (on_key_press);

        entry.activate.connect ((event) => {
            find_text ();
        });

        entry.search_changed.connect (() => {
            find_text ();
        });

        entry.next_match.connect (() => {
            find_text ();
        });

        entry.previous_match.connect (() => {
            find_text (true);
        });
    }

    private void find_text (bool? backwards = false) {
        uint options = WebKit.FindOptions.WRAP_AROUND;

        // Smart case: case sensitive if starting with an uppercase character
        if (entry.text[0].islower ()) {
            options |= WebKit.FindOptions.CASE_INSENSITIVE;
        }

        if (backwards) {
            options |= WebKit.FindOptions.BACKWARDS;
        }

        web_view.get_find_controller ().search (entry.text, options, int.MAX);
    }

    private bool on_key_press (Gdk.EventKey event) {
        string key = Gdk.keyval_name (event.keyval);
        if (Gdk.ModifierType.SHIFT_MASK in event.state) {
            key = "<Shift>" + key;
        }

        switch (key) {
            case "Down":
                find_text ();
                return true;
            case "Up":
            case "<Shift>Return":
                find_text (true);
                return true;
            case "Escape":
                reveal_child = false;
                web_view.grab_focus ();
                return true;
            default:
                return false;
        }
    }
}
