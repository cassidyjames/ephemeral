/*
* Copyright © 2019–2020 Cassidy James Blaede (https://cassidyjames.com)
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

public class Ephemeral.WebContext : WebKit.WebContext {
    public WebContext () {
        Object (
            // This causes a known visual regression with navigation gestures.
            // See: https://bugs.webkit.org/show_bug.cgi?id=205651
            process_swap_on_cross_site_navigation_enabled: true,
            website_data_manager: new WebKit.WebsiteDataManager.ephemeral ()
        );

        set_process_model (WebKit.ProcessModel.MULTIPLE_SECONDARY_PROCESSES);
        set_sandbox_enabled (true);

        get_cookie_manager ().set_accept_policy (
            WebKit.CookieAcceptPolicy.NO_THIRD_PARTY
        );
    }
}
