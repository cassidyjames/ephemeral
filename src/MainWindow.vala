/*
* Copyright © 2019–2021 Cassidy James Blaede (https://cassidyjames.com)
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

public class Ephemeral.MainWindow : Gtk.Window {
    public string uri { get; construct set; }
    public SimpleActionGroup actions { get; construct; }

    public static Gtk.Settings gtk_settings;

    private Gtk.Button zoom_default_button;
    private Gtk.Stack stack;
    private WebView web_view;
    private FindBar find_bar;
    private Gtk.Stack refresh_stop_stack;
    private Gtk.Button back_button;
    private Gtk.Button forward_button;
    private Gtk.Button refresh_button;
    private Gtk.Button stop_button;
    private UrlEntry url_entry;
    private BrowserButton browser_button;
    private Gtk.Button erase_button;

    private uint overlay_timeout_id = 0;

    public MainWindow (Gtk.Application application, string? _uri = null) {
        Object (
            application: application,
            border_width: 0,
            icon_name: Application.instance.application_id,
            resizable: true,
            title: "Ephemeral",
            uri: _uri,
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    static construct {
        gtk_settings = Gtk.Settings.get_default ();
    }

    construct {
        default_height = 800;
        default_width = 1280;

        var header = new Gtk.HeaderBar ();
        header.show_close_button = true;
        header.has_subtitle = false;

        web_view = new WebView ();

        var suggestion_toast = new Granite.Widgets.Toast ("");
        suggestion_toast.set_default_action (_("Undo"));

        var web_overlay = new Gtk.Overlay ();
        web_overlay.add (web_view);
        web_overlay.add_overlay (suggestion_toast);

        var web_overlay_bar = new Granite.Widgets.OverlayBar (web_overlay);
        web_overlay_bar.visible = false;

        unowned Gtk.StyleContext web_overlay_bar_context = web_overlay_bar.get_style_context ();
        web_overlay_bar_context.add_class ("hidden");

        back_button = new Gtk.Button.from_icon_name ("go-previous-symbolic", Application.instance.icon_size);
        back_button.sensitive = false;
        back_button.tooltip_text = _("Back");
        back_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Alt>Left"}, back_button.tooltip_text);
        back_button.get_style_context ().add_class ("back");

        forward_button = new Gtk.Button.from_icon_name ("go-next-symbolic", Application.instance.icon_size);
        forward_button.sensitive = false;
        forward_button.tooltip_text = _("Forward");
        forward_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Alt>Right"}, forward_button.tooltip_text);
        forward_button.get_style_context ().add_class ("forward");

        refresh_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic", Application.instance.icon_size);
        refresh_button.tooltip_text = _("Reload page");
        refresh_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>r"}, refresh_button.tooltip_text);
        refresh_button.get_style_context ().add_class ("refresh");

        stop_button = new Gtk.Button.from_icon_name ("process-stop-symbolic", Application.instance.icon_size);
        stop_button.tooltip_text = _("Stop loading");
        stop_button.get_style_context ().add_class ("stop");

        refresh_stop_stack = new Gtk.Stack ();
        refresh_stop_stack.add (refresh_button);
        refresh_stop_stack.add (stop_button);
        refresh_stop_stack.visible_child = refresh_button;

        url_entry = new UrlEntry (web_view);

        erase_button = new Gtk.Button.from_icon_name ("edit-delete", Application.instance.icon_size);
        erase_button.sensitive = false;
        erase_button.tooltip_text = _("Close window and erase history");
        erase_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>W"}, erase_button.tooltip_text);

        browser_button = new BrowserButton (this, web_view) {
            sensitive = false
        };

        var settings_button = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("open-menu", Application.instance.icon_size),
            tooltip_text = _("Menu")
        };

        var settings_popover = new Gtk.Popover (settings_button);
        settings_button.popover = settings_popover;

        var style_switch = new Granite.ModeSwitch.from_icon_name (
            "display-brightness-symbolic",
            "weather-clear-night-symbolic"
        ) {
            primary_icon_tooltip_text = _("Light content"),
            secondary_icon_tooltip_text = _("Dark content"),
            halign = Gtk.Align.CENTER,
            margin = 12
        };

        style_switch.bind_property (
            "active",
            gtk_settings,
            "gtk_application_prefer_dark_theme",
            BindingFlags.BIDIRECTIONAL
        );

        var style_switch_revealer = new Gtk.Revealer ();
        style_switch_revealer.add (style_switch);

        /* WebKit uses -dark to set a dark style, and some OSes expose -dark
        stylesheets to users as a hacky dark mode (like Ubuntu and Pop!_OS). As
        such, if we have a -dark stylesheet, hide the style switcher. */
        gtk_settings.bind_property (
            "gtk-theme-name",
            style_switch_revealer,
            "reveal-child",
            BindingFlags.SYNC_CREATE,
            (binding, srcval, ref targetval) => {
                string gtk_theme_name = (string) srcval;
                targetval.set_boolean (!gtk_theme_name.has_suffix ("-dark"));
                return true;
            }
        );

        var zoom_out_button = new Gtk.Button.from_icon_name ("zoom-out-symbolic", Gtk.IconSize.MENU);
        zoom_out_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"<Ctrl>minus"},
            _("Zoom out")
        );
        zoom_out_button.clicked.connect (zoom_out);

        zoom_default_button = new Gtk.Button.with_label ("100%");
        zoom_default_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"<Ctrl>0"},
            _("Default zoom level")
        );
        zoom_default_button.clicked.connect (zoom_default);

        var zoom_in_button = new Gtk.Button.from_icon_name ("zoom-in-symbolic", Gtk.IconSize.MENU);
        zoom_in_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"<Ctrl>plus"},
            _("Zoom in")
        );
        zoom_in_button.clicked.connect (zoom_in);

        var zoom_grid = new Gtk.Grid ();
        zoom_grid.column_homogeneous = true;
        zoom_grid.hexpand = true;
        zoom_grid.margin = 12;
        zoom_grid.margin_bottom = 6;
        zoom_grid.margin_top = 6;
        zoom_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);

        zoom_grid.add (zoom_out_button);
        zoom_grid.add (zoom_default_button);
        zoom_grid.add (zoom_in_button);

        var js_warning = new Gtk.Label (_("<b>Note:</b> Disabling JavaScript will likely break many sites"));
        js_warning.margin_start = 6;
        js_warning.max_width_chars = 0;
        js_warning.use_markup = true;
        js_warning.wrap = true;
        js_warning.xalign = 0;
        js_warning.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var js_revealer = new Gtk.Revealer ();
        js_revealer.add (js_warning);
        js_revealer.reveal_child = !Application.settings.get_boolean ("enable-javascript");

        var js_switch = new Gtk.Switch ();
        js_switch.halign = Gtk.Align.END;
        js_switch.valign = Gtk.Align.CENTER;

        var js_label = new Gtk.Label (_("JavaScript"));
        js_label.halign = Gtk.Align.START;
        js_label.hexpand = true;
        js_label.margin_start = 6;

        var js_grid = new Gtk.Grid ();
        js_grid.attach (js_label, 0, 0);
        js_grid.attach (js_switch, 1, 0);
        js_grid.attach (js_revealer, 0, 1, 2);

        var js_button = new Gtk.Button ();
        set_menu_style_classes (js_button);
        js_button.add (js_grid);

        var new_window_label = new Gtk.Label (_("Open New Window"));
        new_window_label.halign = Gtk.Align.START;
        new_window_label.hexpand = true;
        new_window_label.margin_start = 6;

        var new_window_accel_label = new Gtk.Label (Granite.markup_accel_tooltip ({"<Ctrl>n"}));
        new_window_accel_label.halign = Gtk.Align.END;
        new_window_accel_label.margin_end = 6;
        new_window_accel_label.use_markup = true;

        var new_window_grid = new Gtk.Grid ();
        new_window_grid.add (new_window_label);
        new_window_grid.add (new_window_accel_label);

        var new_window_button = new Gtk.Button ();
        set_menu_style_classes (new_window_button);
        new_window_button.add (new_window_grid);

        var quit_label = new Gtk.Label (_("Quit Ephemeral"));
        quit_label.halign = Gtk.Align.START;
        quit_label.hexpand = true;
        quit_label.margin_start = 6;

        var quit_description = new Gtk.Label (_("Close all windows and erase all history"));
        quit_description.margin_start = quit_description.margin_end = 6;
        quit_description.max_width_chars = 0;
        quit_description.wrap = true;
        quit_description.xalign = 0;
        quit_description.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var quit_accel_label = new Gtk.Label (Granite.markup_accel_tooltip ({"<Ctrl>q"}));
        quit_accel_label.halign = Gtk.Align.END;
        quit_accel_label.margin_end = 6;
        quit_accel_label.use_markup = true;

        var quit_grid = new Gtk.Grid ();
        quit_grid.attach (quit_label, 0, 0);
        quit_grid.attach (quit_accel_label, 1, 0);
        quit_grid.attach (quit_description, 0, 1, 2);

        var quit_button = new Gtk.Button ();
        set_menu_style_classes (quit_button);
        quit_button.add (quit_grid);

        var ddg_button = new Gtk.RadioButton.with_label (null, _("DuckDuckGo Search"));
        set_menu_style_classes (ddg_button);

        var startpage_button = new Gtk.RadioButton.with_label_from_widget (ddg_button, _("Startpage.com Search"));
        set_menu_style_classes (startpage_button);

        var custom_search_button = new Gtk.RadioButton.with_label_from_widget (
            startpage_button,
            _("Custom Search Engine…")
        );
        set_menu_style_classes (custom_search_button);

        var preferences_label = new Gtk.Label (_("Reset Preferences…"));
        preferences_label.halign = Gtk.Align.START;
        preferences_label.hexpand = true;
        preferences_label.margin_start = preferences_label.margin_end = 6;

        var preferences_button = new Gtk.Button ();
        set_menu_style_classes (preferences_button);
        preferences_button.add (preferences_label);

        var settings_popover_grid = new Gtk.Grid ();
        settings_popover_grid.margin_bottom = 3;
        settings_popover_grid.margin_top = 6;
        settings_popover_grid.orientation = Gtk.Orientation.VERTICAL;
        settings_popover_grid.width_request = 200;

        settings_popover_grid.add (style_switch_revealer);
        settings_popover_grid.add (zoom_grid);
        settings_popover_grid.add (js_button);
        settings_popover_grid.add (new MenuSeparator ());
        settings_popover_grid.add (new_window_button);
        settings_popover_grid.add (quit_button);
        settings_popover_grid.add (new MenuSeparator ());
        settings_popover_grid.add (ddg_button);
        settings_popover_grid.add (startpage_button);
        settings_popover_grid.add (custom_search_button);
        settings_popover_grid.add (new MenuSeparator ());
        settings_popover_grid.add (preferences_button);
        settings_popover_grid.show_all ();

        settings_popover.add (settings_popover_grid);

        var back_forward_grid = new Gtk.Grid ();
        unowned Gtk.StyleContext back_forward_context = back_forward_grid.get_style_context ();
        back_forward_context.add_class (Gtk.STYLE_CLASS_LINKED);
        back_forward_context.add_class ("navigation");

        back_forward_grid.add (back_button);
        back_forward_grid.add (forward_button);

        header.pack_start (back_forward_grid);
        header.pack_start (refresh_stop_stack);
        header.pack_start (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        header.pack_end (settings_button);
        header.pack_end (browser_button);
        header.pack_end (erase_button);
        header.pack_end (new Gtk.Separator (Gtk.Orientation.VERTICAL));

        header.custom_title = url_entry;

        var close_when_opening_externally_info_bar = new CloseWhenOpeningExternallyInfoBar ();
        var default_info_bar = new DefaultInfoBar ();
        var native_info_bar = new NativeInfoBar ();
        var network_info_bar = new NetworkInfoBar ();
        var paid_info_bar = new PaidInfoBar ();

        var welcome_view = new WelcomeView ();
        var error_view = new ErrorView ();

        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        stack.add_named (welcome_view, "welcome-view");
        stack.add_named (web_overlay, "web-view");
        stack.add_named (error_view, "error-view");
        stack.visible_child_name = "welcome-view";

        find_bar = new FindBar (web_view);

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.add (paid_info_bar);
        grid.add (native_info_bar);
        grid.add (default_info_bar);
        grid.add (network_info_bar);
        grid.add (close_when_opening_externally_info_bar);
        grid.add (stack);
        grid.add (find_bar);

        set_titlebar (header);
        add (grid);

        show_all ();

        if (uri != null && uri != "") {
            web_view.load_uri (uri);
            stack.visible_child_name = "web-view";
        } else {
            url_entry.grab_focus ();
            stack.visible_child_name = "welcome-view";
        }

        set_search_engine_active (
            startpage_button,
            ddg_button,
            custom_search_button
        );

        back_button.clicked.connect (web_view.go_back);
        forward_button.clicked.connect (web_view.go_forward);
        refresh_button.clicked.connect (web_view.reload);
        stop_button.clicked.connect (web_view.stop_loading);
        erase_button.clicked.connect (close);

        settings_button.clicked.connect (() => {
            set_search_engine_active (
                startpage_button,
                ddg_button,
                custom_search_button
            );
        });

        new_window_button.clicked.connect (() => {
            settings_popover.popdown ();
            Application.new_window ();
        });

        quit_button.clicked.connect (() => {
            application.quit ();
        });

        js_button.clicked.connect (() => {
            js_switch.activate ();
        });

        startpage_button.clicked.connect (() => {
            if (startpage_button.active) {
                Application.settings.set_string ("search-engine", Application.STARTPAGE);
            }
        });

        ddg_button.clicked.connect (() => {
            if (ddg_button.active) {
                Application.settings.set_string ("search-engine", Application.DDG);
            }
        });

        custom_search_button.clicked.connect (() => {
            if (custom_search_button.active) {
                var custom_search_dialog = new CustomSearchDialog ();
                custom_search_dialog.transient_for = (Gtk.Window) get_toplevel ();

                custom_search_dialog.response.connect ((response_id) => {
                    switch (response_id) {
                        case Gtk.ResponseType.OK:
                            debug ("Search engine set in dialog.");
                        case Gtk.ResponseType.CANCEL:
                        case Gtk.ResponseType.CLOSE:
                        case Gtk.ResponseType.DELETE_EVENT:
                            custom_search_dialog.close ();
                            break;
                        default:
                            assert_not_reached ();
                    }
                });

                custom_search_dialog.run ();
                custom_search_dialog.destroy ();
                settings_popover.popdown ();
            }
        });

        preferences_button.clicked.connect (() => {
            settings_popover.popdown ();
            var preferences_dialog = new PreferencesDialog ();
            preferences_dialog.transient_for = (Gtk.Window) get_toplevel ();

            preferences_dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.OK:
                        string[] keys = Application.settings.list_keys ();
                        foreach (string key in keys) {
                            Application.settings.reset (key);
                        }

                        set_search_engine_active (
                            startpage_button,
                            ddg_button,
                            custom_search_button
                        );
                    case Gtk.ResponseType.CANCEL:
                    case Gtk.ResponseType.CLOSE:
                    case Gtk.ResponseType.DELETE_EVENT:
                        preferences_dialog.close ();
                        break;
                    default:
                        assert_not_reached ();
                }
            });

            preferences_dialog.run ();
            preferences_dialog.destroy ();
        });

        web_view.load_changed.connect (update_progress);
        web_view.notify["uri"].connect (update_progress);
        web_view.notify["estimated-load-progress"].connect (update_progress);
        web_view.notify["is-loading"].connect (update_progress);

        web_view.decide_policy.connect ((decision, type) => {
            switch (type) {
                case WebKit.PolicyDecisionType.NAVIGATION_ACTION:
                    stack.visible_child_name = "web-view";
                    var action = ((WebKit.NavigationPolicyDecision)decision).navigation_action;
                    var navigation_type = action.get_navigation_type ();
                    string uri = action.get_request ().get_uri ();
                    var soup_uri = new Soup.URI (uri);

                    debug (
                        "Navigation type: %s\nURL: %s\n",
                        navigation_type.to_string (),
                        uri
                    );

                    // Check if site is in external sites list; if so, open in
                    // the preferred browser and close the Ephemeral window.
                    if (
                        !Application.instance.manually_navigated &&
                        soup_uri.get_host () in Application.settings.get_strv ("external-websites") &&
                        (navigation_type == WebKit.NavigationType.LINK_CLICKED || navigation_type == WebKit.NavigationType.OTHER) &&
                        // TODO: don't open externally if we're already on the same domain
                        soup_uri.get_host () != new Soup.URI (web_view.get_uri ()).get_host ()
                    ) {
                        var uris = new List<string> ();
                        uris.append (uri);

                        foreach (AppInfo app_info in AppInfo.get_all ()) {
                            if (app_info.get_id () == Application.settings.get_string ("last-used-browser")) {
                                try {
                                    app_info.launch_uris (uris, null);
                                    Application.instance.last_external_open = new DateTime.now_utc ().to_unix ();

                                    decision.ignore ();

                                    // TODO: respect close-when-opening-externally setting here
                                    // close ();

                                    return true;
                                } catch (Error e) {
                                    critical (e.message);
                                }
                            }
                        }
                    }

                    if (action.is_user_gesture ()) {
                        // Middle- or ctrl-click
                        bool has_ctrl = (action.get_modifiers () & Gdk.ModifierType.CONTROL_MASK) != 0;
                        if (
                            action.get_mouse_button () == 2 ||
                            (has_ctrl && action.get_mouse_button () == 1)
                        ) {
                            Application.new_window (uri);

                            decision.ignore ();
                            return true;
                        }
                    }

                    decision.use ();
                    break;

                case WebKit.PolicyDecisionType.NEW_WINDOW_ACTION:
                    var action = ((WebKit.NavigationPolicyDecision)decision).navigation_action;
                    string uri = action.get_request ().get_uri ();

                    if (action.is_user_gesture ()) {
                        // Middle- or ctrl-click
                        bool has_ctrl = (action.get_modifiers () & Gdk.ModifierType.CONTROL_MASK) != 0;
                        if (
                            action.get_mouse_button () == 2 ||
                            (has_ctrl && action.get_mouse_button () == 1)
                        ) {
                            Application.new_window (uri);
                            decision.ignore ();
                            return true;
                        }
                    }

                    if (is_location (uri)) {
                        web_view.load_uri (uri);
                    }
            }

            return false;
        });

        web_view.load_failed.connect ((load_event, uri, load_error) => {
            if (load_error is WebKit.PluginError.WILL_HANDLE_LOAD) {
                // A plugin will take over
                return false;
            } else if (load_error is WebKit.NetworkError.CANCELLED) {
                // Mostly initiated by JS redirects
                return false;
            } else if (load_error is WebKit.PolicyError.FRAME_LOAD_INTERRUPTED_BY_POLICY_CHANGE) {
                // A frame load is cancelled because of a download
                return false;
            } else if (load_error is WebKit.PolicyError.CANNOT_SHOW_URI) {
                open_externally (uri);
            } else {
                stack.visible_child_name = "error-view";
            }

            return true;
        });

        web_view.mouse_target_changed.connect ((target, modifiers) => {
            if (target.context_is_link ()) {
                web_overlay_bar.label = target.link_uri;
                web_overlay_bar.visible = true;
                web_overlay_bar_context.remove_class ("hidden");

                if (overlay_timeout_id != 0) {
                    Source.remove (overlay_timeout_id);
                    overlay_timeout_id = 0;
                }
            } else {
                // Let the overlay bar stay for a moment to prevent flashing
                // when mousing over many links
                overlay_timeout_id = Timeout.add (200, () => {
                    web_overlay_bar_context.add_class ("hidden");

                    // Actually hide the widget once the 200ms CSS animation is done
                    overlay_timeout_id = Timeout.add (200, () => {
                        web_overlay_bar.visible = false;

                        if (overlay_timeout_id != 0) {
                            Source.remove (overlay_timeout_id);
                            overlay_timeout_id = 0;
                        }
                        return false;
                    });
                    return false;
                });
            }
        });

        suggestion_toast.default_action.connect (() => {
            url_entry.toggle_suggestion (new Soup.URI (web_view.get_uri ()));
        });

        Application.settings.bind ("zoom", web_view, "zoom-level", SettingsBindFlags.DEFAULT);

        Application.settings.bind_with_mapping ("zoom", zoom_default_button, "label", SettingsBindFlags.DEFAULT,
            (value, variant) => {
                value.set_string ("%.0f%%".printf (variant.get_double () * 100));
                return true;
            }, () => { return true; }, null, null
        );

        Application.settings.bind ("enable-javascript", js_switch, "active", SettingsBindFlags.DEFAULT);
        js_switch.bind_property ("active", js_revealer, "reveal-child", BindingFlags.INVERT_BOOLEAN);

        stack.bind_property ("visible-child-name", zoom_grid, "sensitive",
            BindingFlags.SYNC_CREATE,
            (binding, srcval, ref targetval) => {
                string visible_child_name = (string) srcval;
                targetval.set_boolean (visible_child_name == "web-view");
                return true;
            }
        );

        var accel_group = new Gtk.AccelGroup ();

        accel_group.connect (
            Gdk.Key.Left,
            Gdk.ModifierType.MOD1_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                web_view.go_back ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.Right,
            Gdk.ModifierType.MOD1_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                web_view.go_forward ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.R,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                debug ("Reloading…");
                web_view.reload ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.R,
            Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                debug ("Hard reloading (bypassing cache)…");
                web_view.reload_bypass_cache ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.L,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                url_entry.grab_focus ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.W,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                close ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.N,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                Application.new_window ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.O,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                browser_button.activate ();
            }
        );

        accel_group.connect (
            Gdk.Key.plus,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                zoom_in ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.equal,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                zoom_in ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.minus,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                zoom_out ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.@0,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                zoom_default ();
                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.D,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                var uri = new Soup.URI (web_view.get_uri ());

                switch (url_entry.toggle_suggestion (uri)) {
                    case UrlEntry.SuggestionResult.REMOVED:
                        suggestion_toast.title = _("Suggestion removed");
                        suggestion_toast.send_notification ();
                        break;
                    case UrlEntry.SuggestionResult.ADDED:
                        suggestion_toast.title = _("Suggestion added");
                        suggestion_toast.send_notification ();
                        break;
                    case UrlEntry.SuggestionResult.ERROR:
                        critical ("Error toggling suggestion");
                        break;
                    default:
                        assert_not_reached ();
                }

                return true;
            }
        );

        accel_group.connect (
            Gdk.Key.F,
            Gdk.ModifierType.CONTROL_MASK,
            Gtk.AccelFlags.VISIBLE | Gtk.AccelFlags.LOCKED,
            () => {
                switch (stack.visible_child_name) {
                    case "web-view":
                        if (find_bar.reveal_child && find_bar.entry.has_focus) {
                            find_bar.reveal_child = false;
                            web_view.grab_focus ();
                        } else {
                            find_bar.reveal_child = true;
                            find_bar.entry.grab_focus ();
                        }

                        break;
                    default:
                        Gdk.beep ();
                }

                return true;
            }
        );

        add_accel_group (accel_group);

        var granite_settings = Granite.Settings.get_default ();
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
    }

    protected override bool delete_event (Gdk.EventAny event) {
        if (Application.settings.get_boolean ("close-when-opening-externally")) {
            // Don't keep this around unless it's being used
            Application.settings.reset ("manual-closes-after-opening-externally");
        } else if (new DateTime.now_utc ().to_unix () < (Application.instance.last_external_open + 10)) {
            Application.settings.set_int (
                "manual-closes-after-opening-externally",
                Application.settings.get_int ("manual-closes-after-opening-externally") + 1
            );
        }

        return false;
    }

    private void update_progress () {
        title = web_view.title;
        back_button.sensitive = web_view.can_go_back ();
        forward_button.sensitive = web_view.can_go_forward ();

        browser_button.sensitive = true;
        erase_button.sensitive = true;

        if (web_view.is_loading) {
            refresh_stop_stack.visible_child = stop_button;
            // FIXME: somehow this is broken
            web_view.bind_property ("estimated-load-progress", url_entry, "progress-fraction");
        } else {
            refresh_stop_stack.visible_child = refresh_button;
            url_entry.progress_fraction = 0;
            browser_button.external_check.active = new Soup.URI (web_view.get_uri ()).get_host () in Application.settings.get_strv ("external-websites");

            if (!url_entry.has_focus) {
                url_entry.text = WebKit.uri_for_display (web_view.get_uri ());
            }

            // Reset back to default
            Application.instance.manually_navigated = false;
        }
    }

    private void open_externally (string uri) {
        string? protocol = Uri.parse_scheme (uri);

        var external_dialog = new ExternalDialog (protocol);
        external_dialog.transient_for = (Gtk.Window) get_toplevel ();

        external_dialog.response.connect ((response_id) => {
            switch (response_id) {
                case Gtk.ResponseType.OK:
                    try {
                        Gtk.show_uri (get_screen (), uri, Gtk.get_current_event_time ());
                    } catch (Error e) {
                        critical (e.message);
                    }
                    external_dialog.close ();
                    break;
                case Gtk.ResponseType.CANCEL:
                case Gtk.ResponseType.CLOSE:
                case Gtk.ResponseType.DELETE_EVENT:
                    external_dialog.close ();
                    break;
                default:
                    assert_not_reached ();
            }
        });

        external_dialog.run ();
        external_dialog.destroy ();
    }

    private bool is_location (string uri) {
        return
            uri.has_prefix ("about:") ||
            uri.has_prefix ("http://") ||
            uri.has_prefix ("https://") ||
            (uri.has_prefix ("data:") && (";" in uri)) ||
            uri.has_prefix ("javascript:");
    }

    private void zoom_in () {
        if (web_view.zoom_level < 5.0 && stack.visible_child_name == "web-view") {
            web_view.zoom_level = web_view.zoom_level + 0.1;
        } else {
            Gdk.beep ();
        }

        return;
    }

    private void zoom_out () {
        if (web_view.zoom_level > 0.2 && stack.visible_child_name == "web-view") {
            web_view.zoom_level = web_view.zoom_level - 0.1;
        } else {
            Gdk.beep ();
        }

        return;
    }

    private void zoom_default () {
        if (stack.visible_child_name == "web-view") {
            web_view.zoom_level = 1.0;
        } else {
            Gdk.beep ();
        }

        return;
    }

    private void set_search_engine_active (
        Gtk.RadioButton startpage_button,
        Gtk.RadioButton ddg_button,
        Gtk.RadioButton custom_search_button
    ) {
        var search_engine = Application.settings.get_string ("search-engine");
        if (search_engine == Application.STARTPAGE) {
            startpage_button.active = true;
        } else if (search_engine == Application.DDG) {
            ddg_button.active = true;
        } else {
            custom_search_button.active = true;
        }
    }

    private void set_menu_style_classes (Gtk.Widget widget) {
        unowned Gtk.StyleContext context = widget.get_style_context ();
        context.add_class (Gtk.STYLE_CLASS_FLAT);
        context.add_class (Gtk.STYLE_CLASS_MENUITEM);
    }

    private class MenuSeparator : Gtk.Separator {
        public MenuSeparator () {
            Object (
                margin_bottom: 3,
                margin_top: 3,
                orientation: Gtk.Orientation.HORIZONTAL
            );
        }
    }
}
