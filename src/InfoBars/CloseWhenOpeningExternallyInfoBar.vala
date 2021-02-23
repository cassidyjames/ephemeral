/*
* Copyright © 2019–2021 Cassidy James Blaede (https://cassidyjames.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
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

public class Ephemeral.CloseWhenOpeningExternallyInfoBar : Gtk.InfoBar {
    public CloseWhenOpeningExternallyInfoBar () {
        Object (
            message_type: Gtk.MessageType.INFO,
            show_close_button: true
        );
    }

    construct {
        string title = _("Close When Opening Externally?");
        string details = _("You frequently close Ephemeral after opening a page externally. You can set Ephemeral to automatically close instead.");

        var default_label = new Gtk.Label ("<b>%s</b> %s".printf (title, details));
        default_label.use_markup = true;
        default_label.wrap = true;

        var never_button = new Gtk.Button.with_label (_("Never Ask Again"));
        never_button.halign = Gtk.Align.END;
        never_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        get_content_area ().add (default_label);
        add_action_widget (never_button, Gtk.ResponseType.REJECT);
        add_button (_("Turn On"), Gtk.ResponseType.ACCEPT);

        try_set_revealed ();

        response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.ACCEPT:
                    Application.settings.set_boolean ("close-when-opening-externally", true);
                    try_set_revealed ();
                    break;
                case Gtk.ResponseType.REJECT:
                    Application.settings.set_boolean ("suggest-close-when-opening-externally", false);
                case Gtk.ResponseType.CLOSE:
                    revealed = false;
                    break;
                default:
                    assert_not_reached ();
            }
        });
    }

    public void try_set_revealed (bool? reveal = true) {
        revealed =
            reveal &&
            !Application.settings.get_boolean ("close-when-opening-externally") &&
            Application.settings.get_boolean ("suggest-close-when-opening-externally") &&
            Application.settings.get_int ("manual-closes-after-opening-externally") > 3;
    }
}
