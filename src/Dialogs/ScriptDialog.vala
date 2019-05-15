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
* Authored by: David Hewitt <davidmhewitt@gmail.com>
*/

public class ScriptDialog : Granite.MessageDialog {
    public WebKit.ScriptDialog dialog_info { get; construct; }

    public ScriptDialog (WebKit.ScriptDialog dialog) {
        Object (
            image_icon: new ThemedIcon ("dialog-information"),
            title: _("Message From Page"),
            primary_text: _("Message From Page"),
            secondary_text: dialog.get_message (),
            dialog_info: dialog
        );
    }

    construct {
        switch (dialog_info.get_dialog_type ()) {
            case WebKit.ScriptDialogType.ALERT:
                var cancel = add_button (_("Close"), Gtk.ResponseType.CANCEL) as Gtk.Button;
                cancel.clicked.connect (() => { destroy (); });
                break;
            case WebKit.ScriptDialogType.CONFIRM:
            case WebKit.ScriptDialogType.BEFORE_UNLOAD_CONFIRM:
                var ok = add_button (_("OK"), Gtk.ResponseType.OK) as Gtk.Button;
                ok.clicked.connect (() => {
                    dialog_info.confirm_set_confirmed (true);
                    destroy ();
                });

                var cancel = add_button (_("Close"), Gtk.ResponseType.CANCEL) as Gtk.Button;
                cancel.clicked.connect (() => { destroy (); });
                break;
            case WebKit.ScriptDialogType.PROMPT:
                var prompt_entry = new Gtk.Entry ();
                prompt_entry.show ();
                prompt_entry.text = dialog_info.prompt_get_default_text ();

                custom_bin.add (prompt_entry);

                var ok = add_button (_("OK"), Gtk.ResponseType.OK) as Gtk.Button;
                ok.clicked.connect (() => {
                    dialog_info.prompt_set_text (prompt_entry.text);
                    destroy ();
                });

                var cancel = add_button (_("Close"), Gtk.ResponseType.CANCEL) as Gtk.Button;
                cancel.clicked.connect (() => { destroy (); });
                break;
            default:
                break;
        }
    }
}
