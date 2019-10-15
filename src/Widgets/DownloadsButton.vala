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

public class Ephemeral.DownloadsButton : Gtk.Revealer {
    public DownloadsButton () {
        Object ();
    }

    construct {
        tooltip_text = _("Downloads");
        tooltip_markup = Granite.markup_accel_tooltip (
            {"<Ctrl>j"},
            tooltip_text
        );

        reveal_child = true;

        var button = new Gtk.MenuButton ();
        button.image = new Gtk.Image.from_icon_name ("folder-download", Application.instance.icon_size);

        var popover = new Gtk.Popover (button);
        button.popover = popover;

        var popover_grid = new Gtk.Grid ();
        popover_grid.margin_top = popover_grid.margin_bottom = 3;
        popover_grid.orientation = Gtk.Orientation.VERTICAL;

        // FIXME: Foreach download item…
        string[] items = {"downloaded-image.jpg", "elementary-os-5.1-hera_20191014.iso"};

        foreach (string item in items) {
            var item_icon = new Gtk.Image.from_icon_name ("application-x-partial-download", Gtk.IconSize.DND);

            var item_folder_button = new Gtk.Button.from_icon_name ("folder-open", Gtk.IconSize.MENU);
            item_folder_button.halign = Gtk.Align.END;
            item_folder_button.hexpand = true;
            item_folder_button.margin_start = 6;
            item_folder_button.tooltip_text = _("Open in folder");
            item_folder_button.valign = Gtk.Align.CENTER;
            item_folder_button.get_style_context ().add_class ("circular");

            var item_grid = new Gtk.Grid ();
            item_grid.add (item_icon);
            item_grid.add (new Gtk.Label (item));
            item_grid.add (item_folder_button);

            var item_button = new Gtk.Button ();
            item_button.tooltip_text = _("Open");
            item_button.add (item_grid);

            var item_button_context = item_button.get_style_context ();
            item_button_context.add_class (Gtk.STYLE_CLASS_MENUITEM);
            item_button_context.add_class (Gtk.STYLE_CLASS_FLAT);

            popover_grid.add (item_button);
        }
        // FIXME: END foreach

        popover_grid.show_all ();
        popover.add (popover_grid);

        add (button);
    }
}
