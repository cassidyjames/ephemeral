/*
 * Copyright © 2019 Adrian Cochrane (https://adrian.geek.nz)
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
 * Authored by: Adrian Cochrane <alcinnz@lavabit.com>
 */
public class Ephemeral.DownloadsButton : Gtk.Revealer {
    Gtk.ListBox downloads_list;

    public DownloadsButton() {
        Object ();
    }

    construct {
        tooltip_text = _("Downloads");
        tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>j"}, tooltip_text);

        reveal_child = false;

        var button = new Gtk.MenuButton ();
        button.image = new Gtk.Image.from_icon_name (
                "folder-download", Application.instance.icon_size
        );

        var popover = new Gtk.Popover (null);
        button.popover = popover;

        downloads_list = new Gtk.ListBox ();
        downloads_list.activate_on_single_click = true;
        downloads_list.selection_mode = Gtk.SelectionMode.SINGLE;
        downloads_list.show ();

        popover.add (downloads_list);
        add (button);
    }

    public void add_download(WebKit.Download download) {
        var mimetype = download.response.mime_type;
        if (mimetype == "application/octet-stream") {
            mimetype = ContentType.guess (download.response.uri, null, null);
        }

        var row = new Gtk.ListBoxRow ();

        var image = new Gtk.Image.from_gicon (
                ContentType.get_icon (mimetype), Gtk.IconSize.DND
        );
        image.tooltip_text = ContentType.get_description (mimetype);

        var label = new Gtk.Label (Filename.display_basename (download.destination));
        label.hexpand = true;
        label.xalign = 0;

        var progressbar = new Gtk.ProgressBar ();
        progressbar.get_style_context ().add_class ("osd");
        progressbar.fraction = 0;
        download.received_data.connect (() => {
            progressbar.fraction = download.estimated_progress;
        });

        var overlay = new Gtk.Overlay ();
        overlay.add (label);
        overlay.add_overlay (progressbar);

        var folder_button = new Gtk.Button.from_icon_name (
                "folder-open", Gtk.IconSize.MENU
        );
        folder_button.tooltip_text = _("Open in folder");
        folder_button.clicked.connect (() => {
            try {
                Gtk.show_uri (
                        get_screen (),
                        download.destination,
                        Gtk.get_current_event_time ()
                );
            } catch (Error err) {
                warning ("%s", err.message);
            }
        });

        var cancel_button = new Gtk.Button.from_icon_name (
                "process-stop", Gtk.IconSize.MENU
        );
        cancel_button.tooltip_text = _("Cancel download");
        var cancelled = false;
        cancel_button.clicked.connect (() => {
            download.cancel ();
            cancelled = true;
            row.destroy ();
        });

        var secondary_stack = new Gtk.Stack ();
        secondary_stack.halign = Gtk.Align.END;
        secondary_stack.margin_start = secondary_stack.margin_end = 6;
        secondary_stack.add (folder_button);
        secondary_stack.add (cancel_button);
        secondary_stack.visible_child = cancel_button;
        download.finished.connect (() => {
            secondary_stack.visible_child = folder_button;
        });

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.HORIZONTAL;
        grid.add (image);
        grid.add (overlay);
        grid.add (secondary_stack);

        row.add (grid);
        row.tooltip_text = download.destination;
        row.activate.connect (() => {
            var app = AppInfo.get_default_for_type (mimetype, false);
            if (app == null) return; // TODO It'd be nice to integrate AppCenter here.

            var uris = new List<string>();
            uris.append (download.destination);
            try {
                app.launch_uris (uris, null);
            } catch (Error err) {
                warning ("%s", err.message);
            }
        });

        grid.show_all ();
        downloads_list.add (row);
        reveal_child = true;
    }
}
