/*
* Copyright ⓒ 2019 Cassidy James Blaede (https://cassidyjames.com)
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

public class Ephemeral : Gtk.Application {
    private bool opening_link = false;

    public Ephemeral () {
        Object (
            application_id: "com.github.cassidyjames.ephemeral",
            flags: ApplicationFlags.HANDLES_OPEN
        );
    }

    protected override void activate () {
        if (!opening_link) {
            var app_window = new MainWindow (this);
            app_window.show_all ();
        }

        var quit_action = new SimpleAction ("quit", null);
        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Ctrl>Q"});

        quit_action.activate.connect (() => {
            quit ();
        });

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/com/github/cassidyjames/ephemeral/Application.css");
        Gtk.StyleContext.add_provider_for_screen (
            Gdk.Screen.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }

    public override void open(File[] files, string hint) {
        opening_link = true;
        activate ();
        opening_link = false;

        foreach (var file in files) {
            var app_window = new MainWindow (this, file.get_uri());
            app_window.show_all ();
        }
    }

    public static int main (string[] args) {
        var app = new Ephemeral ();
        return app.run (args);
    }
}

