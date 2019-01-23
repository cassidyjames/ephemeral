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

public class PaidInfoBar : Gtk.InfoBar {
    public PaidInfoBar () {
        Object (
            message_type: Gtk.MessageType.INFO,
            show_close_button: true
        );
    }

    construct {
        // TRANSLATORS: This is an emphasized part at the beginning of a complete sentence, no terminating punctuation
        string title = _("Ephemeral is a paid app");
        // TRANSLATORS: This continues the previous string, with terminating punctuation
        string details = _("funded by AppCenter purchases.");
        string consider_purchasing = _("Consider purchasing or funding if you find value in using Ephemeral.");

        var default_label = new Gtk.Label ("<b>%s</b> %s\n<small>%s</small>".printf (
            title, details, consider_purchasing
        ));
        default_label.use_markup = true;
        default_label.wrap = true;

        var dismiss_button = new Gtk.Button.with_label (_("Dismiss"));
        dismiss_button.halign = Gtk.Align.END;
        dismiss_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

        get_content_area ().add (default_label);
        add_action_widget (dismiss_button, Gtk.ResponseType.REJECT);
        // TRANSLATORS: Includes an ellipsis (…) in English to signify the action will be performed in a new window
        add_button (_("Purchase or Fund…"), Gtk.ResponseType.ACCEPT);

        int64 now = new DateTime.now_utc ().to_unix ();

        revealed =
            Ephemeral.instance.native () &&
            ! paid () &&
            (Ephemeral.settings.get_int64 ("last-paid-response") < now - Ephemeral.NOTICE_SECS) &&
            Ephemeral.instance.warn_paid_for_session;

        response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.ACCEPT:
                    try {
                        Gtk.show_uri (get_screen (), "appstream://" + Ephemeral.instance.application_id, Gtk.get_current_event_time ());
                    } catch (GLib.Error e) {
                        critical (e.message);
                    }
                case Gtk.ResponseType.REJECT:
                    now = new DateTime.now_utc ().to_unix ();
                    Ephemeral.settings.set_int64 ("last-paid-response", now);
                case Gtk.ResponseType.CLOSE:
                    Ephemeral.instance.warn_paid_for_session = false;
                    revealed = false;
                    break;
                default:
                    assert_not_reached ();
            }
        });
    }

    private bool paid () {
        var appcenter_settings_schema = SettingsSchemaSource.get_default ().lookup ("io.elementary.appcenter.settings", false);
        if (appcenter_settings_schema != null) {
            if (appcenter_settings_schema.has_key ("paid-apps")) {
                var appcenter_settings = new GLib.Settings ("io.elementary.appcenter.settings");
                return strv_contains (appcenter_settings.get_strv ("paid-apps"), Ephemeral.instance.application_id);
            }
        }

        return false;
    }
}

