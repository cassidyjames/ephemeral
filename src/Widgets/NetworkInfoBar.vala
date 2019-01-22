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

public class NetworkInfoBar : Gtk.InfoBar {
    public NetworkInfoBar () {
        Object (
            message_type: Gtk.MessageType.WARNING,
            show_close_button: true
        );
    }

    construct {
        var settings = new Settings (Ephemeral.instance.application_id);

        var default_label = new Gtk.Label ("<b>Network Not Available.</b> Connect to the Internet to browse the Web.");
        default_label.use_markup = true;
        default_label.wrap = true;

        var never_button = new Gtk.Button.with_label ("Never Warn Again");
        never_button.halign = Gtk.Align.END;
        never_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        get_content_area ().add (default_label);
        add_action_widget (never_button, Gtk.ResponseType.REJECT);
        add_button ("Network Settings…", Gtk.ResponseType.ACCEPT);

        try_set_revealed ();

        response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.ACCEPT:
                    try {
                        AppInfo.launch_default_for_uri ("settings://network", null);
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }
                    break;
                case Gtk.ResponseType.REJECT:
                    settings.set_boolean ("warn-network", false);
                case Gtk.ResponseType.CLOSE:
                    revealed = false;
                    break;
                default:
                    assert_not_reached ();
            }
        });

        var network_monitor = NetworkMonitor.get_default ();
        network_monitor.network_changed.connect (() => {
            try_set_revealed ();
        });
    }

    private void try_set_revealed (bool? reveal = true) {
        var settings = new Settings ("com.github.cassidyjames.ephemeral");
        var network_available = NetworkMonitor.get_default ().get_network_available ();

        revealed =
            reveal &&
            settings.get_boolean ("warn-network") &&
            !network_available;
    }
}

