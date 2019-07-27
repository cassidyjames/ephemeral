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
        reset_suggestions (initial_favorites);
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
                    var current_favorites = Application.settings.get_strv ("favorite-websites");
                    var uri = new Soup.URI (web_view.get_uri ());

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
                            reset_suggestions (current_favorites);
                        } else {
                            debug ("%s is not a favorite, so adding…", favorite);
                            current_favorites += favorite;
                            reset_suggestions (current_favorites);
                        }

                        Application.settings.set_strv ("favorite-websites", current_favorites);
                        set_secondary_icon ();
                    }
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
                formatted_url = "%s://%s".printf ("http", text);
                return true;
            } else {
                formatted_url = search_engine.printf (text);
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

    private void add_suggestion (
      string domain,
      string? name = null,
      string? reason = _("Popular website"),
      string? icon = "web-browser-symbolic"
    ) {
        debug ("Adding %s to suggestions…", domain);

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

    private void reset_suggestions (string[] favorites = {}) {
        debug ("Resetting suggestions…");

        if (list_store is ListStore) {
            list_store.remove_all ();
        }

        list_store = new ListStore (typeof (Dazzle.Suggestion));

        set_model (new ListStore (typeof (Dazzle.Suggestion)));

        foreach (var favorite in favorites) {
            add_suggestion (favorite, null, _("Favorite website"), "starred-symbolic");
        }

        add_suggestion ("247sports.com", "247Sports");
        add_suggestion ("6pm.com", "6pm");
        add_suggestion ("aa.com", "American Airlines");
        add_suggestion ("aarp.org", "AARP");
        add_suggestion ("abc.go.com", "ABC");
        add_suggestion ("abcnews.go.com", "ABC News");
        add_suggestion ("abs-cbnnews.com", "ABS-CBN News");
        add_suggestion ("accuweather.com", "AccuWeather");
        add_suggestion ("aclu.org", "American Civil Liberties Union");
        add_suggestion ("ae.com", "American Eagle Outfitters");
        add_suggestion ("airbnb.com", "Airbnb");
        add_suggestion ("aliexpress.com", "AliExpress");
        add_suggestion ("allrecipes.com", "Allrecipes");
        add_suggestion ("amazon.com", "Amazon");
        add_suggestion ("amazon.co.uk", "Amazon.co.uk");
        add_suggestion ("americanexpress.com", "American Express");
        add_suggestion ("ancestry.com", "Ancestry");
        add_suggestion ("androidcentral.com", "Android Central");
        add_suggestion ("androidpolice.com", "Android Police");
        add_suggestion ("answers.com", "Answers");
        add_suggestion ("aol.com", "AOL");
        add_suggestion ("appcenter.elementary.io", "elementary AppCenter");
        add_suggestion ("archive.org", "Internet Archive");
        add_suggestion ("arstechnica.com", "Ars Technica");
        add_suggestion ("att.com", "AT&amp;T");
        add_suggestion ("audible.com", "Audible");
        add_suggestion ("autotrader.com", "Autotrader");
        add_suggestion ("azlyrics.com", "AZLyrics");
        add_suggestion ("babycenter.com", "BabyCenter");
        add_suggestion ("baidu.com", "Baidu");
        add_suggestion ("bankofamerica.com", "Bank of America");
        add_suggestion ("bankrate.com", "Bankrate");
        add_suggestion ("barclaycardus.com", "Barclays US");
        add_suggestion ("barnesandnoble.com", "Barnes &amp; Noble");
        add_suggestion ("bbc.com", "BBC");
        add_suggestion ("bbc.co.uk", "BBC");
        add_suggestion ("bedbathandbeyond.com", "Bed Bath &amp; Beyond");
        add_suggestion ("bestbuy.com", "Best Buy");
        add_suggestion ("betanews.com", "BetaNews");
        add_suggestion ("bhphotovideo.com", "B&amp;H Photo");
        add_suggestion ("biblegateway.com", "BibleGateway.com");
        add_suggestion ("bing.com", "Bing");
        add_suggestion ("bizjournals.com", "The Business Journals");
        add_suggestion ("blogger.com", "Blogger");
        add_suggestion ("blogspot.com", "Blogspot");
        add_suggestion ("bloomberg.com", "Bloomberg");
        add_suggestion ("bn.com", "Barnes &amp; Noble");
        add_suggestion ("bodybuilding.com", "Bodybuilding.com");
        add_suggestion ("booking.com", "Booking.com");
        add_suggestion ("box.com", "Box");
        add_suggestion ("buffer.com", "Buffer");
        add_suggestion ("businessinsider.com", "Business Insider");
        add_suggestion ("buzzfeed.com", "Buzzfeed");
        add_suggestion ("capitalone360.com", "Capital One Bank");
        add_suggestion ("capitalone.com", "Capital One");
        add_suggestion ("careerbuilder.com", "CareerBuilder");
        add_suggestion ("cars.com", "Cars.com");
        add_suggestion ("cartoonnetwork.com", "Cartoon Network");
        add_suggestion ("cash.app", "Cash App");
        add_suggestion ("cassidyjames.com", "Cassidy James");
        add_suggestion ("cbs.com", "CBS");
        add_suggestion ("cbsnews.com", "CBS News");
        add_suggestion ("cbssports.com", "CBS Sports");
        add_suggestion ("chase.com", "Chase");
        add_suggestion ("chicagotribune.com", "Chicago Tribune");
        add_suggestion ("chron.com", "The Houston Chronicle");
        add_suggestion ("citibankonline.com", "Banking with Citi");
        add_suggestion ("citi.com", "Citi");
        add_suggestion ("cloudflare.com", "Cloudflare");
        add_suggestion ("cnbc.com", "CNBC");
        add_suggestion ("cnet.com", "CNET");
        add_suggestion ("cnn.com", "CNN");
        add_suggestion ("comcast.net", "Comcast");
        add_suggestion ("comenity.net", "Comenity");
        add_suggestion ("consumerreports.org", "Consumer Reports");
        add_suggestion ("costco.com", "Costco");
        add_suggestion ("coupons.com", "Coupons.com");
        add_suggestion ("cox.net", "Cox");
        add_suggestion ("cracked.com", "Cracked.com");
        add_suggestion ("craigslist.org", "Craigslist");
        add_suggestion ("creditkarma.com", "Credit Karma");
        add_suggestion ("custhelp.com", "Oracle Service Cloud");
        add_suggestion ("cvs.com", "CVS");
        add_suggestion ("dailykos.com", "Daily Kos");
        add_suggestion ("dailymotion.com", "Dailymotion");
        add_suggestion ("danielfore.com", "Daniel Foré");
        add_suggestion ("deadspin.com", "Deadspin");
        add_suggestion ("dell.com", "Dell");
        add_suggestion ("delta.com", "Delta Air Lines");
        add_suggestion ("deviantart.com", "DeviantArt");
        add_suggestion ("dickssportinggoods.com", "DICK'S Sporting Goods");
        add_suggestion ("dictionary.com", "Dictionary.com");
        add_suggestion ("digitalocean.com", "DigitalOcean");
        add_suggestion ("digitaltrends.com", "Digital Trends");
        add_suggestion ("diply.com", "Diply");
        add_suggestion ("directv.com", "DIRECTV");
        add_suggestion ("discovercard.com", "Discover");
        add_suggestion ("discover.com", "Discover");
        add_suggestion ("disney.com", "Disney.com");
        add_suggestion ("do.co", "DigitalOcean");
        add_suggestion ("docs.google.com", "Google Docs");
        add_suggestion ("dominos.com", "Domino's");
        add_suggestion ("draftkings.com", "DraftKings");
        add_suggestion ("dribbble.com", "Dribbble");
        add_suggestion ("drive.google.com", "Google Drive");
        add_suggestion ("dropbox.com", "Dropbox");
        add_suggestion ("drugs.com", "Drugs.com");
        add_suggestion ("duckduckgo.com", "DuckDuckGo");
        add_suggestion ("earthlink.net", "EarthLink");
        add_suggestion ("ebates.com", "Ebates");
        add_suggestion ("ebay.com", "eBay");
        add_suggestion ("edmunds.com", "Edmunds");
        add_suggestion ("eff.org", "Electronic Frontier Foundation");
        add_suggestion ("ehow.com", "eHow");
        add_suggestion ("elementary.io", "elementary");
        add_suggestion ("engadget.com", "Engadget");
        add_suggestion ("eonline.com", "E! News");
        add_suggestion ("epicurious.com", "Epicurious");
        add_suggestion ("espn.go.com", "ESPN");
        add_suggestion ("etsy.com", "Etsy");
        add_suggestion ("eventbrite.com", "Eventbrite");
        add_suggestion ("evernote.com", "Evernote");
        add_suggestion ("evite.com", "Evite");
        add_suggestion ("ew.com", "Entertainment Weekly");
        add_suggestion ("expedia.com", "Expedia");
        add_suggestion ("facebook.com", "Facebook");
        add_suggestion ("fandango.com", "Fandango");
        add_suggestion ("fanduel.com", "FanDuel");
        add_suggestion ("fanfiction.net", "FanFiction");
        add_suggestion ("fast.com", "Fast.com");
        add_suggestion ("fedex.com", "FedEx");
        add_suggestion ("feedly.com", "Feedly");
        add_suggestion ("fidelity.com", "Fidelity Investments");
        add_suggestion ("fitbit.com", "Fitbit");
        add_suggestion ("flickr.com", "Flickr");
        add_suggestion ("food52.com", "Food52");
        add_suggestion ("foodnetwork.com", "Food Network");
        add_suggestion ("fool.com", "The Motley Fool");
        add_suggestion ("forbes.com", "Forbes");
        add_suggestion ("forever21.com", "Forever 21");
        add_suggestion ("frys.com", "Fry's Home Electronics");
        add_suggestion ("gamefaqs.com", "GameFAQs");
        add_suggestion ("gamespot.com", "GameSpot");
        add_suggestion ("gamestop.com", "GameStop");
        add_suggestion ("gap.com", "Gap");
        add_suggestion ("gawker.com", "Gawker");
        add_suggestion ("genius.com", "Genius");
        add_suggestion ("gettogether.community", "Get Together");
        add_suggestion ("gfycat.com", "Gfycat");
        add_suggestion ("giphy.com", "Giphy");
        add_suggestion ("github.com", "GitHub");
        add_suggestion ("gizmodo.com", "Gizmodo");
        add_suggestion ("glassdoor.com", "Glassdoor");
        add_suggestion ("gmail.com", "Gmail");
        add_suggestion ("gofundme.com", "GoFundMe");
        add_suggestion ("goodhousekeeping.com", "Good Housekeeping");
        add_suggestion ("goodreads.com", "Goodreads");
        add_suggestion ("google.com", "Google");
        add_suggestion ("greatergood.com", "GreaterGood");
        add_suggestion ("groupon.com", "Groupon");
        add_suggestion ("harvard.edu", "Harvard University");
        add_suggestion ("healthcare.gov", "HealthCare.gov");
        add_suggestion ("hilton.com", "Hilton");
        add_suggestion ("hm.com", "H&amp;M");
        add_suggestion ("homedepot.com", "The Home Depot");
        add_suggestion ("hootsuite.com", "Hootsuite");
        add_suggestion ("hotels.com", "Hotels.com");
        add_suggestion ("hotnewhiphop.com", "HotNewHipHop");
        add_suggestion ("houzz.com", "Houzz");
        add_suggestion ("hp.com", "HP");
        add_suggestion ("hsn.com", "HSN");
        add_suggestion ("huffingtonpost.com", "Huffington Post");
        add_suggestion ("icloud.com", "iCloud");
        add_suggestion ("iflscience.com", "IFLScience");
        add_suggestion ("ign.com", "IGN");
        add_suggestion ("ikea.com", "IKEA");
        add_suggestion ("imdb.com", "Internet Movie Database");
        add_suggestion ("imgur.com", "Imgur");
        add_suggestion ("indeed.com", "Indeed");
        add_suggestion ("independent.co.uk", "The Independent");
        add_suggestion ("indiatimes.com", "Indiatimes");
        add_suggestion ("indiegogo.com", "Indiegogo");
        add_suggestion ("ind.ie", "Indie");
        add_suggestion ("instagram.com", "Instagram");
        add_suggestion ("instructables.com", "Instructables");
        add_suggestion ("intuit.com", "Intuit");
        add_suggestion ("io9.com", "io9");
        add_suggestion ("irs.gov", "Internal Revenue Service");
        add_suggestion ("jalopnik.com", "Jalopnik");
        add_suggestion ("jblive.tv", "Jupiter Broadcasting LIVE!");
        add_suggestion ("jcpenny.com", "JCPenny");
        add_suggestion ("jcrew.com", "J.Crew");
        add_suggestion ("jet.com", "Jet.com");
        add_suggestion ("jezebel.com", "Jezebel");
        add_suggestion ("joinmastodon.org", "The Mastodon Project");
        add_suggestion ("jupiterbroadcasting.com", "Jupiter Broadcasting");
        add_suggestion ("kbb.com", "Kelly Blue Book");
        add_suggestion ("kickstarter.com", "Kickstarter");
        add_suggestion ("kinja.com", "Kinja");
        add_suggestion ("kmart.com", "Kmart");
        add_suggestion ("kohls.com", "Khol's");
        add_suggestion ("kotaku.com", "Kotaku");
        add_suggestion ("ksl.com", "KSL.com");
        add_suggestion ("landsend.com", "Lands' End");
        add_suggestion ("latimes.com", "LA Times");
        add_suggestion ("legacy.com", "Legacy.com");
        add_suggestion ("lego.com", "LEGO");
        add_suggestion ("lifehacker.com", "Lifehacker");
        add_suggestion ("linkedin.com", "LinkedIn");
        add_suggestion ("linuxacademy.com", "Linux Academy");
        add_suggestion ("linuxunplugged.com", "LINUX Unplugged");
        add_suggestion ("littlethings.com", "LittleThings");
        add_suggestion ("liveleak.com", "LiveLeak");
        add_suggestion ("livestrong.com", "Livestrong");
        add_suggestion ("livingsocial.com", "LivingSocial");
        add_suggestion ("llbean.com", "L.L.Bean");
        add_suggestion ("lunduke.com", "Bryan Lunduke");
        add_suggestion ("lowes.com", "Lowes");
        add_suggestion ("macys.com", "Macy's");
        add_suggestion ("mailchimp.com", "Mailchimp");
        add_suggestion ("mapquest.com", "MapQuest");
        add_suggestion ("marketwatch.com", "MarketWatch");
        add_suggestion ("marriott.com", "Marriott");
        add_suggestion ("marthastewart.com", "Martha Stewart");
        add_suggestion ("mashable.com", "Mashable");
        add_suggestion ("match.com", "Match.com");
        add_suggestion ("mayoclinic.org", "Mayo Clinic");
        add_suggestion ("medium.com", "Medium");
        add_suggestion ("meetup.com", "Meetup");
        add_suggestion ("merriam-webster.com", "Dictionary by Merriam-Webster");
        add_suggestion ("mic.com", "Mic");
        add_suggestion ("michaels.com", "Michaels");
        add_suggestion ("mint.com", "Mint");
        add_suggestion ("mit.edu", "Massachusetts Institute of Technology");
        add_suggestion ("mlb.com", "MLB");
        add_suggestion ("monster.com", "Monster Jobs");
        add_suggestion ("mozilla.org", "Mozilla");
        add_suggestion ("msnbc.com", "NBC News");
        add_suggestion ("msn.com", "Microsoft Live");
        add_suggestion ("myfitnesspal.com", "MyFitnessPal");
        add_suggestion ("nationalgeographic.com", "National Geographic");
        add_suggestion ("naver.com", "NAVER");
        add_suggestion ("nba.com", "NBA");
        add_suggestion ("nbc.com", "NBC");
        add_suggestion ("nbcnews.com", "NBC News");
        add_suggestion ("nbcsports.com", "NBC Sports");
        add_suggestion ("nesn.com", "NESN");
        add_suggestion ("newegg.com", "Newegg");
        add_suggestion ("nextdoor.com", "Nextdoor");
        add_suggestion ("nhl.com", "National Hockey League");
        add_suggestion ("nih.gov", "National Institutes of Health");
        add_suggestion ("nike.com", "Nike");
        add_suggestion ("noaa.gov", "National Oceanic and Atmospheric Administration");
        add_suggestion ("nordstrom.com", "Nordstrom");
        add_suggestion ("npr.org", "NPR");
        add_suggestion ("ny.gov", "New York State");
        add_suggestion ("nypost.com", "New York Post");
        add_suggestion ("nytimes.com", "New York Times");
        add_suggestion ("office365.com", "Office 365");
        add_suggestion ("officedepot.com", "Office Depot &amp; OfficeMax");
        add_suggestion ("okcupid.com", "OKCupid");
        add_suggestion ("omgubuntu.co.uk", "OMG! Ubuntu!");
        add_suggestion ("opentable.com", "OpenTable");
        add_suggestion ("oracle.com", "Oracle");
        add_suggestion ("orbitz.com", "Orbitz");
        add_suggestion ("overstock.com", "Overstock");
        add_suggestion ("pandora.com", "Pandora");
        add_suggestion ("patch.com", "Patch");
        add_suggestion ("patheos.com", "Patheos");
        add_suggestion ("paypal.com", "PayPal");
        add_suggestion ("pbs.org", "Public Broadcasting Service");
        add_suggestion ("pcmag.com", "PCMag.com");
        add_suggestion ("people.com", "PEOPLE");
        add_suggestion ("phoronix.com", "Phoronix");
        add_suggestion ("pinterest.com", "Pinterest");
        add_suggestion ("playstation.com", "PlayStation");
        add_suggestion ("pnc.com", "PNC");
        add_suggestion ("pof.com", "POF");
        add_suggestion ("pogo.com", "Pogo.com");
        add_suggestion ("politico.com", "POLITICO");
        add_suggestion ("popsugar.com", "POPSUGAR");
        add_suggestion ("potterybarn.com", "Pottery Barn");
        add_suggestion ("priceline.com", "Priceline");
        add_suggestion ("purdue.edu", "Purdue University");
        add_suggestion ("puri.sm", "Purism");
        add_suggestion ("qq.com", "QQ.com");
        add_suggestion ("qualtrics.com", "Qualtrics");
        add_suggestion ("quizlet.com", "Quizlet");
        add_suggestion ("quora.com", "Quora");
        add_suggestion ("qvc.com", "QVC");
        add_suggestion ("ravelry.com", "Ravelry");
        add_suggestion ("realsimple.com", "Real Simple");
        add_suggestion ("realtor.com", "Realtor.com");
        add_suggestion ("redbox.com", "Redbox");
        add_suggestion ("reddit.com", "Reddit");
        add_suggestion ("redfin.com", "Redfin");
        add_suggestion ("refactoringui.com", "Refactoring UI");
        add_suggestion ("reference.com", "Reference.com");
        add_suggestion ("refinery29.com", "Refinery29");
        add_suggestion ("rei.com", "REI");
        add_suggestion ("retailmenot.com", "RetailMeNot");
        add_suggestion ("reuters.com", "Reuters");
        add_suggestion ("roblox.com", "Roblox");
        add_suggestion ("rollingstone.com", "Rolling Stone");
        add_suggestion ("rotoworld.com", "Rotoworld");
        add_suggestion ("rottentomatoes.com", "Rotten Tomatoes");
        add_suggestion ("salesforce.com", "Salesforce");
        add_suggestion ("salon.com", "Salon.com");
        add_suggestion ("samsclub.com", "Sam's Club");
        add_suggestion ("sbnation.com", "SBNation");
        add_suggestion ("schwab.com", "Charles Schwab");
        add_suggestion ("sears.com", "Sears");
        add_suggestion ("sephora.com", "Sephora");
        add_suggestion ("sfgate.com", "SFGATE");
        add_suggestion ("sharepoint.com", "SharePoint");
        add_suggestion ("sheets.google.com", "Google Sheets");
        add_suggestion ("shopify.com", "Shopify");
        add_suggestion ("shutterfly.com", "Shutterfly");
        add_suggestion ("si.com", "Sports Illustrated");
        add_suggestion ("simple.com", "Simple");
        add_suggestion ("skype.com", "Skype");
        add_suggestion ("slate.com", "Slate");
        add_suggestion ("slides.google.com", "Google Slides");
        add_suggestion ("slideshare.net", "SlideShare");
        add_suggestion ("slimbook.es", "SLIMBOOK");
        add_suggestion ("soundcloud.com", "SoundCloud");
        add_suggestion ("sourceforge.net", "SourceForge");
        add_suggestion ("southwest.com", "Southwest Airlines");
        add_suggestion ("spectrum.com", "Spectrum");
        add_suggestion ("speedtest.net", "Speedtest");
        add_suggestion ("sprint.com", "Sprint");
        add_suggestion ("squarespace.com", "Squarespace");
        add_suggestion ("squareup.com", "Square");
        add_suggestion ("stackoverflow.com", "Stack Overflow");
        add_suggestion ("stanford.edu", "Stanford University");
        add_suggestion ("staples.com", "Staples");
        add_suggestion ("starbucks.com", "Starbucks");
        add_suggestion ("startpage.com", "Startpage.com");
        add_suggestion ("steamcommunity.com", "Steam Community");
        add_suggestion ("steampowered.com", "Steam");
        add_suggestion ("stripe.com", "Stripe");
        add_suggestion ("stubhub.com", "StubHub");
        add_suggestion ("surveymonkey.com", "SurveyMonkey");
        add_suggestion ("swagbucks.com", "Swagbucks");
        add_suggestion ("system76.com", "System76");
        add_suggestion ("taobao.com", "Taobao");
        add_suggestion ("target.com", "Target");
        add_suggestion ("tdbank.com", "TD Bank");
        add_suggestion ("techcrunch.com", "TechCrunch");
        add_suggestion ("telegraph.co.uk", "The Telegraph");
        add_suggestion ("theatlantic.com", "The Atlantic");
        add_suggestion ("thefreedictionary.com", "The Free Dictionary");
        add_suggestion ("theguardian.com", "The Guardian");
        add_suggestion ("thekitchn.com", "Kitchn");
        add_suggestion ("theonion.com", "The Onion");
        add_suggestion ("theoutline.com", "The Outline");
        add_suggestion ("theregister.co.uk", "The Register");
        add_suggestion ("thesaurus.com", "Thesaurus.com");
        add_suggestion ("theverge.com", "The Verge");
        add_suggestion ("thinkgeek.com", "ThinkGeek");
        add_suggestion ("ticketmaster.com", "Ticketmaster");
        add_suggestion ("tickld.com", "tickld.com");
        add_suggestion ("tigerdirect.com", "TigerDirect.com");
        add_suggestion ("timeanddate.com", "timeanddate.com");
        add_suggestion ("time.com", "TIME");
        add_suggestion ("timewarnercable.com", "Spectrum");
        add_suggestion ("t-mobile.com", "T-Mobile");
        add_suggestion ("tmobile.com", "T-Mobile");
        add_suggestion ("tmz.com", "TMZ");
        add_suggestion ("today.com", "TODAY");
        add_suggestion ("tomshardware.com", "Tom's Hardware");
        add_suggestion ("topix.com", "Topix");
        add_suggestion ("tripadvisor.com", "TripAdvisor");
        add_suggestion ("trulia.com", "Trulia");
        add_suggestion ("tumblr.com", "Tumblr");
        add_suggestion ("tvguide.com", "TV Guide");
        add_suggestion ("twitch.tv", "Twitch");
        add_suggestion ("ulta.com", "Ulta Beauty");
        add_suggestion ("united.com", "United Airlines");
        add_suggestion ("unsplash.com", "Unsplash");
        add_suggestion ("ups.com", "UPS");
        add_suggestion ("urbandictionary.com", "Urban Dictionary");
        add_suggestion ("urbanoutfitters.com", "Urban Outfitters");
        add_suggestion ("usaa.com", "USAA");
        add_suggestion ("usatoday.com", "USA Today");
        add_suggestion ("usbank.com", "US Bank");
        add_suggestion ("usmagazine.com", "Us Weekly");
        add_suggestion ("usnews.com", "US News &amp; World Report");
        add_suggestion ("usps.com", "USPS");
        add_suggestion ("valadoc.org", "Valadoc");
        add_suggestion ("vanguard.com", "Vanguard");
        add_suggestion ("verizon.com", "Verizon");
        add_suggestion ("vice.com", "VICE");
        add_suggestion ("vimeo.com", "Vimeo");
        add_suggestion ("vistaprint.com", "Vistaprint");
        add_suggestion ("vox.com", "Vox");
        add_suggestion ("vrbo.com", "VRBO.com");
        add_suggestion ("walgreens.com", "Walgreens");
        add_suggestion ("walmart.com", "Walmart");
        add_suggestion ("washingtonpost.com", "Washington Post");
        add_suggestion ("wayfair.com", "Wayfair");
        add_suggestion ("weather.com", "Weather");
        add_suggestion ("weather.gov", "National Weather Service");
        add_suggestion ("webex.com", "Cisco Webex");
        add_suggestion ("webmd.com", "WebMD");
        add_suggestion ("weebly.com", "Weebly");
        add_suggestion ("wellsfargo.com", "Wells Fargo");
        add_suggestion ("whitepages.com", "Whitepages");
        add_suggestion ("wikia.com", "Wikia");
        add_suggestion ("wikihow.com", "wikiHow");
        add_suggestion ("wikimedia.org", "Wikimedia");
        add_suggestion ("wikipedia.org", "Wikipedia");
        add_suggestion ("wired.com", "WIRED");
        add_suggestion ("wix.com", "Wix");
        add_suggestion ("woot.com", "Woot");
        add_suggestion ("wordpress.com", "Wordpress");
        add_suggestion ("wsj.com", "Wall Street Journal");
        add_suggestion ("wunderground.com", "Weather Underground");
        add_suggestion ("xbox.com", "Xbox");
        add_suggestion ("xfinity.com", "Xfinity");
        add_suggestion ("xkcd.com", "xkcd");
        add_suggestion ("yahoo.com", "Yahoo");
        add_suggestion ("yellowpages.com", "Yellowpages");
        add_suggestion ("yelp.com", "Yelp");
        add_suggestion ("youtube.com", "YouTube");
        add_suggestion ("zappos.com", "Zappos");
        add_suggestion ("zazzle.com", "Zazzle");
        add_suggestion ("zendesk.com", "Zendesk");
        add_suggestion ("zergnet.com", "ZergNet");
        add_suggestion ("zillow.com", "Zillow");
        add_suggestion ("zulily.com", "Zulily");
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
            }
        }
    }
}

