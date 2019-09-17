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
*              Hannes Schulze <haschu0103@gmail.com>
*/

public class Ephemeral.UrlEntry : Dazzle.SuggestionEntry {
    private ListStore list_store { get; set; }
    private string last_text { get; set; }

    public WebView web_view { get; construct set; }

    public UrlEntry (WebView _web_view) {
        Object (
            hexpand: true,
            web_view: _web_view,
            width_request: 100
        );
    }

    construct {
        var tooltip_text = _("Enter a URL or search term");
        placeholder_text = tooltip_text;
        last_text = "";

        tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>l"}, tooltip_text);

        primary_icon_name = "system-search-symbolic";
        primary_icon_tooltip_text = tooltip_text;
        primary_icon_tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>l"}, primary_icon_tooltip_text);

        var initial_favorites = Application.settings.get_strv ("favorite-websites");
        reload_suggestions (initial_favorites);
        set_secondary_icon ();

        changed.connect (() => {
            // Update placeholder
            if (text == "") {
                placeholder_text = tooltip_text;
            } else {
                placeholder_text = null;
            }
        });

        // We need to block this event handler sometimes, so we store its
        // id in a variable
        var changed_event = changed.connect (() => {
            filter_suggestions (text.strip (), !(text.length >= 2));

            last_text = text;
        });

        activate_suggestion.connect (() => {
            // Format the currently selected id as a url and load it
            if (text == "" || text == null) {
                Gdk.beep ();
                return;
            }

            string url;
            format_url (get_suggestion ().id, out url);

            web_view.load_uri (url);
            web_view.grab_focus ();
        });

        suggestion_activated.connect (() => {
            // Set the text to the current suggestion's one
            text = get_suggestion ().id;
        });

        move_suggestion.connect ((amount) => {
            // Workaround because suggestion_selected isn't available
            var current_index = 0;
            for (var i = 0; i < get_model ().get_n_items (); i++) {
                var item = get_model ().get_item (i) as Dazzle.Suggestion;
                if (item.id == get_suggestion ().id)  {
                    current_index = i;
                    break;
                }
            }

            var new_item = get_model ().get_item (current_index + amount);
            if (new_item == null) {
                new_item = get_suggestion ();
            }

            // Update text to the selected domain name
            SignalHandler.block (this, changed_event);
            text = (new_item as Dazzle.Suggestion).id;
            SignalHandler.unblock (this, changed_event);
            set_position (-1);
        });

        focus_in_event.connect ((event) => {
            set_secondary_icon ();

            return false;
        });

        focus_out_event.connect ((event) => {
            string uri = web_view.get_uri ();

            if (uri == null || uri == "about:blank") {
                text = "";
            } else if (text == "") {
                text = uri;
            }

            set_secondary_icon ();

            return false;
        });

        icon_release.connect ((icon_pos, event) => {
            if (icon_pos == Gtk.EntryIconPosition.PRIMARY) {
                grab_focus ();
            } else if (icon_pos == Gtk.EntryIconPosition.SECONDARY) {
                if (has_focus) {
                    activate ();
                } else {
                    toggle_suggestion (new Soup.URI (web_view.get_uri ()));
                }
            }
        });

        web_view.load_changed.connect ((source, e) => {
            SignalHandler.block (this, changed_event);
            if (!has_focus) {
                text = source.get_uri ();
                set_secondary_icon ();
            }
            SignalHandler.unblock (this, changed_event);
        });
    }

    private bool format_url (string input, out string formatted_url) {
        var search_engine = Application.settings.get_string ("search-engine");

        // TODO: Better URL validation
        if (!input.contains ("://")) {
            if (input.contains (".") && !input.contains (" ")) {
                // TODO: Try HTTPS, and fall back to HTTP?
                formatted_url = "%s://%s".printf ("http", input);
                return true;
            } else {
                formatted_url = search_engine.printf (input);
                return false;
            }
        } else {
            formatted_url = input;
            return true;
        }
    }

    private void filter_suggestions (string search, bool is_empty) {
        var filtered_list_store = new ListStore (typeof (Dazzle.Suggestion));
        var current_suggestion = new Dazzle.Suggestion ();
        string formatted_url;
        var is_url = format_url (search, out formatted_url);
        current_suggestion.id = search;
        current_suggestion.title = (is_url ? _("Go to \"%s\"") : _("Search for \"%s\"")).printf (Markup.escape_text (search));
        current_suggestion.icon_name = "system-search-symbolic";
        filtered_list_store.append (current_suggestion);

        if (!is_empty) {
            Dazzle.Suggestion[] secondary_suggestions = { };

            for (int i = 0; i < list_store.get_n_items (); i++) {
                var suggestion = list_store.get_item (i) as Dazzle.Suggestion;

                if (Regex.match_simple ("^%s".printf (search), suggestion.id) ||
                    Regex.match_simple ("^%s".printf (search), suggestion.title)) {
                    filtered_list_store.append (suggestion);
                }

                if (Regex.match_simple (".%s".printf (search), suggestion.id) ||
                    Regex.match_simple (".%s".printf (search), suggestion.title)) {
                    secondary_suggestions += suggestion;
                }
            }

            foreach (var suggestion in secondary_suggestions) {
                filtered_list_store.append (suggestion);
            }
        }

        set_model (filtered_list_store);
    }

    public SuggestionResult toggle_suggestion (Soup.URI uri) {
        var current_favorites = Application.settings.get_strv ("favorite-websites");
        var suggestion_result = SuggestionResult.ERROR;

        if (uri != null) {
            string favorite = uri.get_host ();

            if (favorite in current_favorites) {
                debug ("%s is already a favorite, so removing…", favorite);
                string[] pruned_favorites = {};
                foreach (string existing_favorite in current_favorites) {
                    if (existing_favorite != favorite) {
                        pruned_favorites += existing_favorite;
                    }
                }

                current_favorites = pruned_favorites;
                reload_suggestions (current_favorites);
                suggestion_result = SuggestionResult.REMOVED;
            } else {
                debug ("%s is not a favorite, so adding…", favorite);
                current_favorites += favorite;
                reload_suggestions (current_favorites);
                suggestion_result = SuggestionResult.ADDED;
            }

            Application.settings.set_strv ("favorite-websites", current_favorites);
            set_secondary_icon ();
        }

        return suggestion_result;
    }

    private void load_suggestion (
        string domain,
        string? name = null,
        string? reason = _("Popular website"),
        string? icon = "web-browser-symbolic"
    ) {
        debug ("Loading %s into suggestions…", domain);

        var suggestion = new Dazzle.Suggestion ();
        suggestion.id = domain;
        suggestion.title = domain;
        suggestion.icon_name = icon;

        string description;
        if (name != null) {
            description = "%s – %s".printf (name, reason);
        } else {
             description = reason;
        }
        suggestion.subtitle = description;

        list_store.append (suggestion);
    }

    private void reload_suggestions (string[] favorites = {}) {
        debug ("Reloading suggestions…");

        if (list_store is ListStore) {
            list_store.remove_all ();
        }

        list_store = new ListStore (typeof (Dazzle.Suggestion));

        set_model (new ListStore (typeof (Dazzle.Suggestion)));

        foreach (var favorite in favorites) {
            load_suggestion (favorite, null, _("Favorite website"), "starred-symbolic");
        }

        load_suggestion ("247sports.com", "247Sports");
        load_suggestion ("6pm.com", "6pm");
        load_suggestion ("aa.com", "American Airlines");
        load_suggestion ("aarp.org", "AARP");
        load_suggestion ("abc.go.com", "ABC");
        load_suggestion ("abcnews.go.com", "ABC News");
        load_suggestion ("abs-cbnnews.com", "ABS-CBN News");
        load_suggestion ("accuweather.com", "AccuWeather");
        load_suggestion ("aclu.org", "American Civil Liberties Union");
        load_suggestion ("ae.com", "American Eagle Outfitters");
        load_suggestion ("airbnb.com", "Airbnb");
        load_suggestion ("aliexpress.com", "AliExpress");
        load_suggestion ("allrecipes.com", "Allrecipes");
        load_suggestion ("amazon.com", "Amazon");
        load_suggestion ("amazon.co.uk", "Amazon.co.uk");
        load_suggestion ("americanexpress.com", "American Express");
        load_suggestion ("ancestry.com", "Ancestry");
        load_suggestion ("androidcentral.com", "Android Central");
        load_suggestion ("androidpolice.com", "Android Police");
        load_suggestion ("answers.com", "Answers");
        load_suggestion ("aol.com", "AOL");
        load_suggestion ("appcenter.elementary.io", "elementary AppCenter");
        load_suggestion ("archive.org", "Internet Archive");
        load_suggestion ("arstechnica.com", "Ars Technica");
        load_suggestion ("att.com", "AT&amp;T");
        load_suggestion ("audible.com", "Audible");
        load_suggestion ("autotrader.com", "Autotrader");
        load_suggestion ("azlyrics.com", "AZLyrics");
        load_suggestion ("babycenter.com", "BabyCenter");
        load_suggestion ("baidu.com", "Baidu");
        load_suggestion ("bankofamerica.com", "Bank of America");
        load_suggestion ("bankrate.com", "Bankrate");
        load_suggestion ("barclaycardus.com", "Barclays US");
        load_suggestion ("barnesandnoble.com", "Barnes &amp; Noble");
        load_suggestion ("bbc.com", "BBC");
        load_suggestion ("bbc.co.uk", "BBC");
        load_suggestion ("bedbathandbeyond.com", "Bed Bath &amp; Beyond");
        load_suggestion ("bestbuy.com", "Best Buy");
        load_suggestion ("betanews.com", "BetaNews");
        load_suggestion ("bhphotovideo.com", "B&amp;H Photo");
        load_suggestion ("biblegateway.com", "BibleGateway.com");
        load_suggestion ("bing.com", "Bing");
        load_suggestion ("bizjournals.com", "The Business Journals");
        load_suggestion ("blogger.com", "Blogger");
        load_suggestion ("blogspot.com", "Blogspot");
        load_suggestion ("bloomberg.com", "Bloomberg");
        load_suggestion ("bn.com", "Barnes &amp; Noble");
        load_suggestion ("bodybuilding.com", "Bodybuilding.com");
        load_suggestion ("booking.com", "Booking.com");
        load_suggestion ("box.com", "Box");
        load_suggestion ("buffer.com", "Buffer");
        load_suggestion ("businessinsider.com", "Business Insider");
        load_suggestion ("buzzfeed.com", "Buzzfeed");
        load_suggestion ("capitalone360.com", "Capital One Bank");
        load_suggestion ("capitalone.com", "Capital One");
        load_suggestion ("careerbuilder.com", "CareerBuilder");
        load_suggestion ("cars.com", "Cars.com");
        load_suggestion ("cartoonnetwork.com", "Cartoon Network");
        load_suggestion ("cash.app", "Cash App");
        load_suggestion ("cassidyjames.com", "Cassidy James");
        load_suggestion ("cbs.com", "CBS");
        load_suggestion ("cbsnews.com", "CBS News");
        load_suggestion ("cbssports.com", "CBS Sports");
        load_suggestion ("chase.com", "Chase");
        load_suggestion ("chicagotribune.com", "Chicago Tribune");
        load_suggestion ("chron.com", "The Houston Chronicle");
        load_suggestion ("citibankonline.com", "Banking with Citi");
        load_suggestion ("citi.com", "Citi");
        load_suggestion ("cloudflare.com", "Cloudflare");
        load_suggestion ("cnbc.com", "CNBC");
        load_suggestion ("cnet.com", "CNET");
        load_suggestion ("cnn.com", "CNN");
        load_suggestion ("comcast.net", "Comcast");
        load_suggestion ("comenity.net", "Comenity");
        load_suggestion ("consumerreports.org", "Consumer Reports");
        load_suggestion ("costco.com", "Costco");
        load_suggestion ("coupons.com", "Coupons.com");
        load_suggestion ("cox.net", "Cox");
        load_suggestion ("cracked.com", "Cracked.com");
        load_suggestion ("craigslist.org", "Craigslist");
        load_suggestion ("creditkarma.com", "Credit Karma");
        load_suggestion ("custhelp.com", "Oracle Service Cloud");
        load_suggestion ("cvs.com", "CVS");
        load_suggestion ("dailykos.com", "Daily Kos");
        load_suggestion ("dailymotion.com", "Dailymotion");
        load_suggestion ("danielfore.com", "Daniel Foré");
        load_suggestion ("deadspin.com", "Deadspin");
        load_suggestion ("dell.com", "Dell");
        load_suggestion ("delta.com", "Delta Air Lines");
        load_suggestion ("deviantart.com", "DeviantArt");
        load_suggestion ("dickssportinggoods.com", "DICK'S Sporting Goods");
        load_suggestion ("dictionary.com", "Dictionary.com");
        load_suggestion ("digitalocean.com", "DigitalOcean");
        load_suggestion ("digitaltrends.com", "Digital Trends");
        load_suggestion ("diply.com", "Diply");
        load_suggestion ("directv.com", "DIRECTV");
        load_suggestion ("discovercard.com", "Discover");
        load_suggestion ("discover.com", "Discover");
        load_suggestion ("disney.com", "Disney.com");
        load_suggestion ("do.co", "DigitalOcean");
        load_suggestion ("docs.google.com", "Google Docs");
        load_suggestion ("dominos.com", "Domino's");
        load_suggestion ("draftkings.com", "DraftKings");
        load_suggestion ("dribbble.com", "Dribbble");
        load_suggestion ("drive.google.com", "Google Drive");
        load_suggestion ("dropbox.com", "Dropbox");
        load_suggestion ("drugs.com", "Drugs.com");
        load_suggestion ("duckduckgo.com", "DuckDuckGo");
        load_suggestion ("earthlink.net", "EarthLink");
        load_suggestion ("ebates.com", "Ebates");
        load_suggestion ("ebay.com", "eBay");
        load_suggestion ("edmunds.com", "Edmunds");
        load_suggestion ("eff.org", "Electronic Frontier Foundation");
        load_suggestion ("ehow.com", "eHow");
        load_suggestion ("elementary.io", "elementary");
        load_suggestion ("engadget.com", "Engadget");
        load_suggestion ("eonline.com", "E! News");
        load_suggestion ("epicurious.com", "Epicurious");
        load_suggestion ("espn.go.com", "ESPN");
        load_suggestion ("etsy.com", "Etsy");
        load_suggestion ("eventbrite.com", "Eventbrite");
        load_suggestion ("evernote.com", "Evernote");
        load_suggestion ("evite.com", "Evite");
        load_suggestion ("ew.com", "Entertainment Weekly");
        load_suggestion ("expedia.com", "Expedia");
        load_suggestion ("facebook.com", "Facebook");
        load_suggestion ("fandango.com", "Fandango");
        load_suggestion ("fanduel.com", "FanDuel");
        load_suggestion ("fanfiction.net", "FanFiction");
        load_suggestion ("fast.com", "Fast.com");
        load_suggestion ("fedex.com", "FedEx");
        load_suggestion ("feedly.com", "Feedly");
        load_suggestion ("fidelity.com", "Fidelity Investments");
        load_suggestion ("fitbit.com", "Fitbit");
        load_suggestion ("flickr.com", "Flickr");
        load_suggestion ("food52.com", "Food52");
        load_suggestion ("foodnetwork.com", "Food Network");
        load_suggestion ("fool.com", "The Motley Fool");
        load_suggestion ("forbes.com", "Forbes");
        load_suggestion ("forever21.com", "Forever 21");
        load_suggestion ("frys.com", "Fry's Home Electronics");
        load_suggestion ("gamefaqs.com", "GameFAQs");
        load_suggestion ("gamespot.com", "GameSpot");
        load_suggestion ("gamestop.com", "GameStop");
        load_suggestion ("gap.com", "Gap");
        load_suggestion ("gawker.com", "Gawker");
        load_suggestion ("genius.com", "Genius");
        load_suggestion ("gettogether.community", "Get Together");
        load_suggestion ("gfycat.com", "Gfycat");
        load_suggestion ("giphy.com", "Giphy");
        load_suggestion ("github.com", "GitHub");
        load_suggestion ("gizmodo.com", "Gizmodo");
        load_suggestion ("glassdoor.com", "Glassdoor");
        load_suggestion ("gmail.com", "Gmail");
        load_suggestion ("gofundme.com", "GoFundMe");
        load_suggestion ("goodhousekeeping.com", "Good Housekeeping");
        load_suggestion ("goodreads.com", "Goodreads");
        load_suggestion ("google.com", "Google");
        load_suggestion ("greatergood.com", "GreaterGood");
        load_suggestion ("groupon.com", "Groupon");
        load_suggestion ("harvard.edu", "Harvard University");
        load_suggestion ("healthcare.gov", "HealthCare.gov");
        load_suggestion ("hilton.com", "Hilton");
        load_suggestion ("hm.com", "H&amp;M");
        load_suggestion ("homedepot.com", "The Home Depot");
        load_suggestion ("hootsuite.com", "Hootsuite");
        load_suggestion ("hotels.com", "Hotels.com");
        load_suggestion ("hotnewhiphop.com", "HotNewHipHop");
        load_suggestion ("houzz.com", "Houzz");
        load_suggestion ("hp.com", "HP");
        load_suggestion ("hsn.com", "HSN");
        load_suggestion ("huffingtonpost.com", "Huffington Post");
        load_suggestion ("icloud.com", "iCloud");
        load_suggestion ("iflscience.com", "IFLScience");
        load_suggestion ("ign.com", "IGN");
        load_suggestion ("ikea.com", "IKEA");
        load_suggestion ("imdb.com", "Internet Movie Database");
        load_suggestion ("imgur.com", "Imgur");
        load_suggestion ("indeed.com", "Indeed");
        load_suggestion ("independent.co.uk", "The Independent");
        load_suggestion ("indiatimes.com", "Indiatimes");
        load_suggestion ("indiegogo.com", "Indiegogo");
        load_suggestion ("ind.ie", "Indie");
        load_suggestion ("instagram.com", "Instagram");
        load_suggestion ("instructables.com", "Instructables");
        load_suggestion ("intuit.com", "Intuit");
        load_suggestion ("io9.com", "io9");
        load_suggestion ("irs.gov", "Internal Revenue Service");
        load_suggestion ("jalopnik.com", "Jalopnik");
        load_suggestion ("jblive.tv", "Jupiter Broadcasting LIVE!");
        load_suggestion ("jcpenny.com", "JCPenny");
        load_suggestion ("jcrew.com", "J.Crew");
        load_suggestion ("jet.com", "Jet.com");
        load_suggestion ("jezebel.com", "Jezebel");
        load_suggestion ("joinmastodon.org", "The Mastodon Project");
        load_suggestion ("jupiterbroadcasting.com", "Jupiter Broadcasting");
        load_suggestion ("kbb.com", "Kelly Blue Book");
        load_suggestion ("kickstarter.com", "Kickstarter");
        load_suggestion ("kinja.com", "Kinja");
        load_suggestion ("kmart.com", "Kmart");
        load_suggestion ("kohls.com", "Khol's");
        load_suggestion ("kotaku.com", "Kotaku");
        load_suggestion ("ksl.com", "KSL.com");
        load_suggestion ("landsend.com", "Lands' End");
        load_suggestion ("latimes.com", "LA Times");
        load_suggestion ("legacy.com", "Legacy.com");
        load_suggestion ("lego.com", "LEGO");
        load_suggestion ("lifehacker.com", "Lifehacker");
        load_suggestion ("linkedin.com", "LinkedIn");
        load_suggestion ("linuxacademy.com", "Linux Academy");
        load_suggestion ("linuxunplugged.com", "LINUX Unplugged");
        load_suggestion ("littlethings.com", "LittleThings");
        load_suggestion ("liveleak.com", "LiveLeak");
        load_suggestion ("livestrong.com", "Livestrong");
        load_suggestion ("livingsocial.com", "LivingSocial");
        load_suggestion ("llbean.com", "L.L.Bean");
        load_suggestion ("lunduke.com", "Bryan Lunduke");
        load_suggestion ("lowes.com", "Lowes");
        load_suggestion ("macys.com", "Macy's");
        load_suggestion ("mailchimp.com", "Mailchimp");
        load_suggestion ("mapquest.com", "MapQuest");
        load_suggestion ("marketwatch.com", "MarketWatch");
        load_suggestion ("marriott.com", "Marriott");
        load_suggestion ("marthastewart.com", "Martha Stewart");
        load_suggestion ("mashable.com", "Mashable");
        load_suggestion ("match.com", "Match.com");
        load_suggestion ("mayoclinic.org", "Mayo Clinic");
        load_suggestion ("medium.com", "Medium");
        load_suggestion ("meetup.com", "Meetup");
        load_suggestion ("merriam-webster.com", "Dictionary by Merriam-Webster");
        load_suggestion ("mic.com", "Mic");
        load_suggestion ("michaels.com", "Michaels");
        load_suggestion ("mint.com", "Mint");
        load_suggestion ("mit.edu", "Massachusetts Institute of Technology");
        load_suggestion ("mlb.com", "MLB");
        load_suggestion ("monster.com", "Monster Jobs");
        load_suggestion ("mozilla.org", "Mozilla");
        load_suggestion ("msnbc.com", "NBC News");
        load_suggestion ("msn.com", "Microsoft Live");
        load_suggestion ("myfitnesspal.com", "MyFitnessPal");
        load_suggestion ("nationalgeographic.com", "National Geographic");
        load_suggestion ("naver.com", "NAVER");
        load_suggestion ("nba.com", "NBA");
        load_suggestion ("nbc.com", "NBC");
        load_suggestion ("nbcnews.com", "NBC News");
        load_suggestion ("nbcsports.com", "NBC Sports");
        load_suggestion ("nesn.com", "NESN");
        load_suggestion ("newegg.com", "Newegg");
        load_suggestion ("nextdoor.com", "Nextdoor");
        load_suggestion ("nhl.com", "National Hockey League");
        load_suggestion ("nih.gov", "National Institutes of Health");
        load_suggestion ("nike.com", "Nike");
        load_suggestion ("noaa.gov", "National Oceanic and Atmospheric Administration");
        load_suggestion ("nordstrom.com", "Nordstrom");
        load_suggestion ("npr.org", "NPR");
        load_suggestion ("ny.gov", "New York State");
        load_suggestion ("nypost.com", "New York Post");
        load_suggestion ("nytimes.com", "New York Times");
        load_suggestion ("office365.com", "Office 365");
        load_suggestion ("officedepot.com", "Office Depot &amp; OfficeMax");
        load_suggestion ("okcupid.com", "OKCupid");
        load_suggestion ("omgubuntu.co.uk", "OMG! Ubuntu!");
        load_suggestion ("opentable.com", "OpenTable");
        load_suggestion ("oracle.com", "Oracle");
        load_suggestion ("orbitz.com", "Orbitz");
        load_suggestion ("overstock.com", "Overstock");
        load_suggestion ("pandora.com", "Pandora");
        load_suggestion ("patch.com", "Patch");
        load_suggestion ("patheos.com", "Patheos");
        load_suggestion ("paypal.com", "PayPal");
        load_suggestion ("pbs.org", "Public Broadcasting Service");
        load_suggestion ("pcmag.com", "PCMag.com");
        load_suggestion ("people.com", "PEOPLE");
        load_suggestion ("phoronix.com", "Phoronix");
        load_suggestion ("pinterest.com", "Pinterest");
        load_suggestion ("playstation.com", "PlayStation");
        load_suggestion ("pnc.com", "PNC");
        load_suggestion ("pof.com", "POF");
        load_suggestion ("pogo.com", "Pogo.com");
        load_suggestion ("politico.com", "POLITICO");
        load_suggestion ("popsugar.com", "POPSUGAR");
        load_suggestion ("potterybarn.com", "Pottery Barn");
        load_suggestion ("priceline.com", "Priceline");
        load_suggestion ("purdue.edu", "Purdue University");
        load_suggestion ("puri.sm", "Purism");
        load_suggestion ("qq.com", "QQ.com");
        load_suggestion ("qualtrics.com", "Qualtrics");
        load_suggestion ("quizlet.com", "Quizlet");
        load_suggestion ("quora.com", "Quora");
        load_suggestion ("qvc.com", "QVC");
        load_suggestion ("ravelry.com", "Ravelry");
        load_suggestion ("realsimple.com", "Real Simple");
        load_suggestion ("realtor.com", "Realtor.com");
        load_suggestion ("redbox.com", "Redbox");
        load_suggestion ("reddit.com", "Reddit");
        load_suggestion ("redfin.com", "Redfin");
        load_suggestion ("refactoringui.com", "Refactoring UI");
        load_suggestion ("reference.com", "Reference.com");
        load_suggestion ("refinery29.com", "Refinery29");
        load_suggestion ("rei.com", "REI");
        load_suggestion ("retailmenot.com", "RetailMeNot");
        load_suggestion ("reuters.com", "Reuters");
        load_suggestion ("roblox.com", "Roblox");
        load_suggestion ("rollingstone.com", "Rolling Stone");
        load_suggestion ("rotoworld.com", "Rotoworld");
        load_suggestion ("rottentomatoes.com", "Rotten Tomatoes");
        load_suggestion ("salesforce.com", "Salesforce");
        load_suggestion ("salon.com", "Salon.com");
        load_suggestion ("samsclub.com", "Sam's Club");
        load_suggestion ("sbnation.com", "SBNation");
        load_suggestion ("schwab.com", "Charles Schwab");
        load_suggestion ("sears.com", "Sears");
        load_suggestion ("sephora.com", "Sephora");
        load_suggestion ("sfgate.com", "SFGATE");
        load_suggestion ("sharepoint.com", "SharePoint");
        load_suggestion ("sheets.google.com", "Google Sheets");
        load_suggestion ("shopify.com", "Shopify");
        load_suggestion ("shutterfly.com", "Shutterfly");
        load_suggestion ("si.com", "Sports Illustrated");
        load_suggestion ("simple.com", "Simple");
        load_suggestion ("skype.com", "Skype");
        load_suggestion ("slate.com", "Slate");
        load_suggestion ("slides.google.com", "Google Slides");
        load_suggestion ("slideshare.net", "SlideShare");
        load_suggestion ("slimbook.es", "SLIMBOOK");
        load_suggestion ("soundcloud.com", "SoundCloud");
        load_suggestion ("sourceforge.net", "SourceForge");
        load_suggestion ("southwest.com", "Southwest Airlines");
        load_suggestion ("spectrum.com", "Spectrum");
        load_suggestion ("speedtest.net", "Speedtest");
        load_suggestion ("sprint.com", "Sprint");
        load_suggestion ("squarespace.com", "Squarespace");
        load_suggestion ("squareup.com", "Square");
        load_suggestion ("stackoverflow.com", "Stack Overflow");
        load_suggestion ("stanford.edu", "Stanford University");
        load_suggestion ("staples.com", "Staples");
        load_suggestion ("starbucks.com", "Starbucks");
        load_suggestion ("startpage.com", "Startpage.com");
        load_suggestion ("steamcommunity.com", "Steam Community");
        load_suggestion ("steampowered.com", "Steam");
        load_suggestion ("stripe.com", "Stripe");
        load_suggestion ("stubhub.com", "StubHub");
        load_suggestion ("surveymonkey.com", "SurveyMonkey");
        load_suggestion ("swagbucks.com", "Swagbucks");
        load_suggestion ("system76.com", "System76");
        load_suggestion ("taobao.com", "Taobao");
        load_suggestion ("target.com", "Target");
        load_suggestion ("tdbank.com", "TD Bank");
        load_suggestion ("techcrunch.com", "TechCrunch");
        load_suggestion ("telegraph.co.uk", "The Telegraph");
        load_suggestion ("theatlantic.com", "The Atlantic");
        load_suggestion ("thefreedictionary.com", "The Free Dictionary");
        load_suggestion ("theguardian.com", "The Guardian");
        load_suggestion ("thekitchn.com", "Kitchn");
        load_suggestion ("theonion.com", "The Onion");
        load_suggestion ("theoutline.com", "The Outline");
        load_suggestion ("theregister.co.uk", "The Register");
        load_suggestion ("thesaurus.com", "Thesaurus.com");
        load_suggestion ("theverge.com", "The Verge");
        load_suggestion ("thinkgeek.com", "ThinkGeek");
        load_suggestion ("ticketmaster.com", "Ticketmaster");
        load_suggestion ("tickld.com", "tickld.com");
        load_suggestion ("tigerdirect.com", "TigerDirect.com");
        load_suggestion ("timeanddate.com", "timeanddate.com");
        load_suggestion ("time.com", "TIME");
        load_suggestion ("timewarnercable.com", "Spectrum");
        load_suggestion ("t-mobile.com", "T-Mobile");
        load_suggestion ("tmobile.com", "T-Mobile");
        load_suggestion ("tmz.com", "TMZ");
        load_suggestion ("today.com", "TODAY");
        load_suggestion ("tomshardware.com", "Tom's Hardware");
        load_suggestion ("topix.com", "Topix");
        load_suggestion ("tripadvisor.com", "TripAdvisor");
        load_suggestion ("trulia.com", "Trulia");
        load_suggestion ("tumblr.com", "Tumblr");
        load_suggestion ("tvguide.com", "TV Guide");
        load_suggestion ("twitch.tv", "Twitch");
        load_suggestion ("ulta.com", "Ulta Beauty");
        load_suggestion ("united.com", "United Airlines");
        load_suggestion ("unsplash.com", "Unsplash");
        load_suggestion ("ups.com", "UPS");
        load_suggestion ("urbandictionary.com", "Urban Dictionary");
        load_suggestion ("urbanoutfitters.com", "Urban Outfitters");
        load_suggestion ("usaa.com", "USAA");
        load_suggestion ("usatoday.com", "USA Today");
        load_suggestion ("usbank.com", "US Bank");
        load_suggestion ("usmagazine.com", "Us Weekly");
        load_suggestion ("usnews.com", "US News &amp; World Report");
        load_suggestion ("usps.com", "USPS");
        load_suggestion ("valadoc.org", "Valadoc");
        load_suggestion ("vanguard.com", "Vanguard");
        load_suggestion ("verizon.com", "Verizon");
        load_suggestion ("vice.com", "VICE");
        load_suggestion ("vimeo.com", "Vimeo");
        load_suggestion ("vistaprint.com", "Vistaprint");
        load_suggestion ("vox.com", "Vox");
        load_suggestion ("vrbo.com", "VRBO.com");
        load_suggestion ("walgreens.com", "Walgreens");
        load_suggestion ("walmart.com", "Walmart");
        load_suggestion ("washingtonpost.com", "Washington Post");
        load_suggestion ("wayfair.com", "Wayfair");
        load_suggestion ("weather.com", "Weather");
        load_suggestion ("weather.gov", "National Weather Service");
        load_suggestion ("webex.com", "Cisco Webex");
        load_suggestion ("webmd.com", "WebMD");
        load_suggestion ("weebly.com", "Weebly");
        load_suggestion ("wellsfargo.com", "Wells Fargo");
        load_suggestion ("whitepages.com", "Whitepages");
        load_suggestion ("wikia.com", "Wikia");
        load_suggestion ("wikihow.com", "wikiHow");
        load_suggestion ("wikimedia.org", "Wikimedia");
        load_suggestion ("wikipedia.org", "Wikipedia");
        load_suggestion ("wired.com", "WIRED");
        load_suggestion ("wix.com", "Wix");
        load_suggestion ("woot.com", "Woot");
        load_suggestion ("wordpress.com", "Wordpress");
        load_suggestion ("wsj.com", "Wall Street Journal");
        load_suggestion ("wunderground.com", "Weather Underground");
        load_suggestion ("xbox.com", "Xbox");
        load_suggestion ("xfinity.com", "Xfinity");
        load_suggestion ("xkcd.com", "xkcd");
        load_suggestion ("yahoo.com", "Yahoo");
        load_suggestion ("yellowpages.com", "Yellowpages");
        load_suggestion ("yelp.com", "Yelp");
        load_suggestion ("youtube.com", "YouTube");
        load_suggestion ("zappos.com", "Zappos");
        load_suggestion ("zazzle.com", "Zazzle");
        load_suggestion ("zendesk.com", "Zendesk");
        load_suggestion ("zergnet.com", "ZergNet");
        load_suggestion ("zillow.com", "Zillow");
        load_suggestion ("zulily.com", "Zulily");
    }

    private void set_secondary_icon () {
        if (this.has_focus || text == "") {
            secondary_icon_name = "go-jump-symbolic";
            secondary_icon_tooltip_text = _("Go");
            secondary_icon_tooltip_markup = Granite.markup_accel_tooltip ({"Return"}, secondary_icon_tooltip_text);
        } else {
            var current_favorites = Application.settings.get_strv ("favorite-websites");
            var uri = new Soup.URI (web_view.get_uri ());

            if (uri != null) {
                string domain = uri.get_host ();

                if (domain in current_favorites) {
                    debug ("%s is a favorite, showing filled star.", domain);
                    secondary_icon_name = "starred";
                    secondary_icon_tooltip_text = _("Remove Website from Suggestions");
                } else {
                    debug ("%s is not a favorite, showing empty star.", domain);
                    secondary_icon_name = "non-starred-symbolic";
                    secondary_icon_tooltip_text = _("Add Website to Suggestions");
                }

                secondary_icon_tooltip_markup = Granite.markup_accel_tooltip (
                    {"<Ctrl>d"},
                    secondary_icon_tooltip_text
                );
            }
        }
    }

    protected override void populate_popup (Gtk.Menu popup) {
        string? clipboard_text = Gtk.Clipboard.get_for_display (get_display (), Gdk.SELECTION_CLIPBOARD).wait_for_text ();
        critical ("populate_popupt: %s", clipboard_text);

        var item = new Gtk.MenuItem.with_mnemonic ("Paste and _Go");
        item.sensitive = clipboard_text != null;
        item.show ();

        // FIXME: Kind of a hack, assumes Copy and Paste are the first two items
        popup.insert (item, 3);

        item.activate.connect (() => {
            critical ("item.activate.connect: %s", clipboard_text);
            string url = "";
            format_url (clipboard_text, out url);
            critical (url);

            web_view.load_uri (url);
            web_view.grab_focus ();
        });
    }

    public enum SuggestionResult {
        REMOVED,
        ADDED,
        ERROR;
    }
}

