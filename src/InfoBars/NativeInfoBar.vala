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

public class Ephemeral.NativeInfoBar : Gtk.InfoBar {
    public NativeInfoBar () {
        Object (
            message_type: Gtk.MessageType.INFO,
            show_close_button: true
        );
    }

    construct {
        string designed_for_elementary = _("Ephemeral is a paid app designed for elementary OS.");
        string disclaimer = _("Some features may not work properly when running on another OS or desktop environment.");
        string fund = _("Ephemeral is also typically funded by elementary AppCenter purchases. Consider donating if you find value in using Ephemeral on other platforms.");

        var default_label = new Gtk.Label ("<b>%s</b> %s\n<small>%s</small>".printf (
            designed_for_elementary, disclaimer, fund
        ));
        default_label.use_markup = true;
        default_label.wrap = true;

        var dismiss_button = new Gtk.Button.with_label (_("Dismiss"));
        dismiss_button.halign = Gtk.Align.END;
        dismiss_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        // TRANSLATORS: Includes an ellipsis (…) in English to signify the action will be performed in a new window
        var donate_button = new Gtk.Button.with_label (_("Donate…"));
        donate_button.tooltip_text = Application.DONATE_URL;

        get_content_area ().add (default_label);
        add_action_widget (dismiss_button, Gtk.ResponseType.REJECT);
        add_action_widget (donate_button, Gtk.ResponseType.ACCEPT);

        int64 now = new DateTime.now_utc ().to_unix ();

        revealed =
            ! Application.native () &&
            (Application.settings.get_int64 ("last-native-response") < now - Application.NOTICE_SECS) &&
            Application.instance.warn_native_for_session;

        response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.ACCEPT:
                    try {
                        Gtk.show_uri (get_screen (), Application.DONATE_URL, Gtk.get_current_event_time ());
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }
                case Gtk.ResponseType.REJECT:
                    now = new DateTime.now_utc ().to_unix ();
                    Application.settings.set_int64 ("last-native-response", now);
                case Gtk.ResponseType.CLOSE:
                    Application.instance.warn_native_for_session = false;
                    revealed = false;
                    break;
                default:
                    assert_not_reached ();
            }
        });
    }
}

