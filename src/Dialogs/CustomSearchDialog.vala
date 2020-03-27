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

public class Ephemeral.CustomSearchDialog : Granite.MessageDialog {
    public CustomSearchDialog () {
        Object (
            image_icon: new ThemedIcon ("system-search"),
            primary_text: _("Set a Custom Search Engine"),
            secondary_text: _("Searches from the URL entry will be sent to this custom URL. <b>%s</b> will be replaced with the search query."),
            title: _("Custom Search Engine")
        );
    }

    construct {
        secondary_label.use_markup = true;

        var cancel = add_button (_("Never Mind"), Gtk.ResponseType.CANCEL) as Gtk.Button;
        cancel.clicked.connect (() => { destroy (); });

        var accept = add_button (_("Set Search Engine"), Gtk.ResponseType.OK) as Gtk.Button;
        accept.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var search_entry = new Gtk.Entry ();
        search_entry.activates_default = true;
        search_entry.text = Application.settings.get_string ("search-engine");
        search_entry.bind_property ("text", accept, "sensitive", BindingFlags.SYNC_CREATE,
            (binding, srcval, ref targetval) => {
                string text = (string) srcval;
                targetval.set_boolean (
                    text.contains ("%s") &&
                    text.contains (".") && (
                        text.has_prefix ("http://") ||
                        text.has_prefix ("https://")
                    )
                );
                return true;
            }
        );

        custom_bin.add (search_entry);
        custom_bin.show_all ();

        set_default_response (Gtk.ResponseType.OK);

        accept.clicked.connect (() => {
            Application.settings.set_string ("search-engine", search_entry.text);
        });
    }
}
