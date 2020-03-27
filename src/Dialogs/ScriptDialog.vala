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
* Authored by: David Hewitt <davidmhewitt@gmail.com>
*/

public class Ephemeral.ScriptDialog : Granite.MessageDialog {
    public WebKit.ScriptDialog dialog_info { get; construct; }

    public ScriptDialog (WebKit.ScriptDialog dialog) {
        Object (
            dialog_info: dialog,
            primary_text: _("Message From Page"),
            secondary_text: dialog.get_message (),
            title: _("Message From Page")
        );
    }

    construct {

        switch (dialog_info.get_dialog_type ()) {
            case WebKit.ScriptDialogType.ALERT:
                image_icon = new ThemedIcon ("dialog-information");

                var cancel_button = add_button (_("Close"), Gtk.ResponseType.CANCEL) as Gtk.Button;
                cancel_button.clicked.connect (() => { destroy (); });

                break;
            case WebKit.ScriptDialogType.CONFIRM:
            case WebKit.ScriptDialogType.BEFORE_UNLOAD_CONFIRM:
                image_icon = new ThemedIcon ("dialog-question");

                var cancel_button = add_button (_("Close"), Gtk.ResponseType.CANCEL) as Gtk.Button;

                var ok_button = add_button (_("Confirm"), Gtk.ResponseType.OK) as Gtk.Button;
                ok_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

                cancel_button.clicked.connect (() => { destroy (); });
                ok_button.clicked.connect (() => {
                    dialog_info.confirm_set_confirmed (true);
                    destroy ();
                });

                break;
            case WebKit.ScriptDialogType.PROMPT:
                image_icon = new ThemedIcon ("dialog-question");

                var prompt_entry = new Gtk.Entry ();
                prompt_entry.show ();
                prompt_entry.activates_default = true;
                prompt_entry.text = dialog_info.prompt_get_default_text ();

                custom_bin.add (prompt_entry);

                var cancel_button = add_button (_("Close"), Gtk.ResponseType.CANCEL) as Gtk.Button;

                var ok_button = add_button (_("Confirm"), Gtk.ResponseType.OK) as Gtk.Button;
                ok_button.grab_default ();
                ok_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

                cancel_button.clicked.connect (() => { destroy (); });
                ok_button.clicked.connect (() => {
                    dialog_info.prompt_set_text (prompt_entry.text);
                    destroy ();
                });

                break;
            default:
                break;
        }
    }
}
