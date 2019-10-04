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

public class Ephemeral.ErrorView : Gtk.Grid {
    public ErrorView () {
        Object ();
    }

    construct {
        var title = new Gtk.Label (_("Whoops"));
        title.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        var subtitle = new Gtk.Label (_("Could not display the page."));

        var subtitle_context = subtitle.get_style_context ();
        subtitle_context.add_class (Granite.STYLE_CLASS_H2_LABEL);

        var alignment_grid = new Gtk.Grid ();
        alignment_grid.halign = Gtk.Align.CENTER;
        alignment_grid.hexpand = true;
        alignment_grid.margin_bottom = 200; // Roughly visually centered
        alignment_grid.orientation = Gtk.Orientation.VERTICAL;
        alignment_grid.valign = Gtk.Align.CENTER;
        alignment_grid.vexpand = true;

        alignment_grid.add (title);
        alignment_grid.add (subtitle);

        get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);
        add (alignment_grid);
    }
}
