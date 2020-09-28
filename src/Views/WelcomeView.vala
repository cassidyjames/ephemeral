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

public class Ephemeral.WelcomeView : Gtk.Grid {
    public WelcomeView () {
        Object ();
    }

    construct {
        var title = new Gtk.Label ("Ephemeral");
        title.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        var subtitle = new Gtk.Label (_("The always-incognito web browser"));

        string tracking_disclaimer = _("Remember, Ephemeral and any browser’s incognito or private mode can only do so much: they mitigate some tracking and don’t store data on your device, but they won’t stop your ISP, government, or determined websites from tracking you.");
        string vpn_suggestion = _("For the best protection, always use a VPN.");

        var copy = new Gtk.Label ("%s\n\n<b>%s</b>".printf (tracking_disclaimer, vpn_suggestion));
        copy.margin = 24;
        copy.max_width_chars = 70;
        copy.use_markup = true;
        copy.wrap = true;
        copy.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        subtitle.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        var alignment_grid = new Gtk.Grid ();
        alignment_grid.halign = Gtk.Align.CENTER;
        alignment_grid.hexpand = true;
        alignment_grid.margin_bottom = 200; // Roughly visually centered
        alignment_grid.orientation = Gtk.Orientation.VERTICAL;
        alignment_grid.valign = Gtk.Align.CENTER;
        alignment_grid.vexpand = true;

        alignment_grid.add (title);
        alignment_grid.add (subtitle);
        alignment_grid.add (copy);

        get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);
        add (alignment_grid);
    }
}
