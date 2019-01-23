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

public class ExternalDialog : Granite.MessageDialog {
    public string protocol { get; construct set; }

    public ExternalDialog (string? _protocol = null) {
        Object (
            image_icon: new ThemedIcon ("dialog-warning"),
            primary_text: "Open Externally?",
            protocol: _protocol,
            title: "Open Externally?"
        );
    }

    construct {
        string explanation = "This page is trying to open an app";
        string implication = "Your data may not be kept private by the opened app";

        if (protocol != null) {
            explanation = "%s for “%s” links".printf (explanation, protocol);
        }

        secondary_text = "%s. %s.".printf (explanation, implication);

        var cancel = add_button ("Don’t Open", Gtk.ResponseType.CANCEL) as Gtk.Button;
        cancel.clicked.connect (() => { destroy (); });

        var accept = add_button ("Open Anyway", Gtk.ResponseType.OK) as Gtk.Button;
        accept.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
    }
}

