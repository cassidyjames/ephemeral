/*
 * Copyright © 2019 Adrian Cochrane (https://adrian.geek.nz)
 *             2019 Cassidy James Blaede (https://cassidyjames.com)
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
namespace Ephemeral {
    public class DownloadsButton : Gtk.Revealer {
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

            downloads_list.row_activated.connect ((row) => {
                var download = (DownloadRow) row;
                if (download == null) return;
                download.open ();
            });

            popover.add (downloads_list);
            add (button);
        }

        public void add_download (WebKit.Download download) {
            var row = new DownloadRow (download);
            row.build_ui ();

            row.show_all ();
            downloads_list.add (row);
            reveal_child = true;
        }
    }

    public class DownloadRow : Gtk.ListBoxRow {
        public WebKit.Download download;

        public DownloadRow (WebKit.Download download) {
            this.download = download;
        }

        public void build_ui () {
            var image = new Gtk.Image.from_icon_name (
                    "document-save-as", Gtk.IconSize.DND
            );

            var label = new Gtk.Label ("");
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
                if (download.estimated_progress == 1.0) {
                    DBus.Files.show_files ({download.destination});
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
                this.destroy ();
            });

            var secondary_stack = new Gtk.Stack ();
            secondary_stack.halign = Gtk.Align.END;
            secondary_stack.margin_start = secondary_stack.margin_end = 6;
            secondary_stack.add (folder_button);
            secondary_stack.add (cancel_button);
            secondary_stack.show_all ();
            secondary_stack.visible_child = cancel_button;

            download.finished.connect (() => {
                download.received_data (uint64.MAX); // To ensure initial data is displayed.
                if (cancelled) return;

                this.selectable = this.activatable = true;
                secondary_stack.visible_child = folder_button;
            });

            var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.HORIZONTAL;
            grid.column_spacing = 3;
            grid.add (image);
            grid.add (overlay);
            grid.add (secondary_stack);

            add (grid);
            tooltip_text = download.destination;
            selectable = activatable = false;

            ulong download_started = 0;
            download_started = download.received_data.connect(() => {
                var mimetype = download.response.mime_type;
                if (mimetype == "application/octet-stream") {
                    mimetype = ContentType.guess (download.response.uri, null, null);
                }

                image.gicon = ContentType.get_icon (mimetype);
                image.tooltip_text = ContentType.get_description (mimetype);

                label.label = Filename.display_basename (download.destination);

                download.disconnect (download_started);
            });
        }

        public void open () {
            var mimetype = download.response.mime_type;
            if (mimetype == "application/octet-stream") {
                mimetype = ContentType.guess (download.response.uri, null, null);
            }

            var app = AppInfo.get_default_for_type (mimetype, false);
            if (app == null) return; // TODO It'd be nice to integrate AppCenter here.

            var uris = new List<string>();
            uris.append (download.destination);
            try {
                app.launch_uris (uris, null);
            } catch (Error err) {
                warning ("%s", err.message);
            }
        }
    }

    [DBus (name = "org.freedesktop.FileManager1")]
    interface DBus.Files : Object {
        const string FILES_DBUS_ID = "org.freedesktop.FileManager1";
        const string FILES_DBUS_PATH = "/org/freedesktop/FileManager1";

        public abstract void show_items (string[] uris, string startup_id) throws IOError, DBusError;
        public abstract void show_folders (string[] uris, string startup_id) throws IOError, DBusError;

        public static void show_files (string[] uris) {
            try {

                DBus.Files files = Bus.get_proxy_sync (BusType.SESSION, FILES_DBUS_ID, FILES_DBUS_PATH);
                files.show_items (uris, "ephemeral");

            } catch (DBusError err) {

                // Fallback to just opening the Downloads folder
                var path = Environment.get_user_special_dir (UserDirectory.DOWNLOAD);
                AppInfo.launch_default_for_uri (File.new_for_path (path).get_uri (), null);

            } catch (Error err) {
                warning ("Failed to open file manager: %s", err.message);
            }
        }
    }
}
