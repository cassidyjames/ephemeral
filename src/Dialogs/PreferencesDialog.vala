/*
* Copyright © 2019–2020 Cassidy James Blaede (https://cassidyjames.com)
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

public class Ephemeral.PreferencesDialog : Granite.MessageDialog {
    public PreferencesDialog () {
        Object (
            image_icon: new ThemedIcon ("document-open-recent"),
            primary_text: _("Reset Preferences?"),
            secondary_text: _("All added website suggestions will be removed. Any dismissed or remembered alerts, warnings, etc. will be displayed again the next time Ephemeral is opened."),
            title: _("Reset Preferences?")
        );
    }

    construct {
        var cancel = add_button (_("Never Mind"), Gtk.ResponseType.CANCEL) as Gtk.Button;
        cancel.clicked.connect (() => { destroy (); });

        var accept = add_button (_("Reset Preferences"), Gtk.ResponseType.OK) as Gtk.Button;
        accept.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
    }
}
