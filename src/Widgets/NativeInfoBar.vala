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

public class NativeInfoBar : Gtk.InfoBar {
    public NativeInfoBar () {
        Object (
            message_type: Gtk.MessageType.INFO,
            show_close_button: true
        );
    }

    construct {
        var settings = new Settings (Ephemeral.instance.application_id);

        var default_label = new Gtk.Label ("<b>Ephemeral is a paid app designed for elementary OS.</b> Some features may not work properly when running on another OS or desktop environment.\n<small>Ephemeral is also typically funded by elementary AppCenter purchases. Consider donating if you find value in using Ephemeral on other platforms.</small>");
        default_label.use_markup = true;
        default_label.wrap = true;

        get_content_area ().add (default_label);
        add_button ("Donate…", Gtk.ResponseType.ACCEPT);

        int64 now = new DateTime.now_utc ().to_unix ();

        revealed =
            ! Ephemeral.instance.get_native () &&
            (settings.get_int64 ("last-native-response") < now - Ephemeral.NOTICE_SECS) &&
            Ephemeral.instance.warn_native_for_session;

        response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.ACCEPT:
                    try {
                        Gtk.show_uri (get_screen (), "https://cassidyjames.com/pay", Gtk.get_current_event_time ());
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }
                case Gtk.ResponseType.REJECT:
                    now = new DateTime.now_utc ().to_unix ();
                    settings.set_int64 ("last-native-response", now);
                case Gtk.ResponseType.CLOSE:
                    Ephemeral.instance.warn_native_for_session = false;
                    revealed = false;
                    break;
                default:
                    assert_not_reached ();
            }
        });
    }
}

