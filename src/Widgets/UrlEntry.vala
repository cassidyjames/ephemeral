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

public class UrlEntry : Gtk.Entry {
    private Gtk.ListStore list_store { get; set; }
    private Gtk.TreeIter iter { get; set; }

    public WebKit.WebView web_view { get; construct set; }

    public UrlEntry (WebKit.WebView _web_view) {
        Object (
            hexpand: true,
            web_view: _web_view,
            width_request: 100
        );
    }

    construct {
        tooltip_text = _("Enter a URL or search term");
        placeholder_text = tooltip_text;

        tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>l"}, tooltip_text);

        secondary_icon_name = "go-jump-symbolic";
        secondary_icon_tooltip_text = _("Go");
        secondary_icon_tooltip_markup = Granite.markup_accel_tooltip ({"Return"}, secondary_icon_tooltip_text);

        var completion = new Gtk.EntryCompletion ();
        completion.inline_completion = true;
        set_completion (completion);

     list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
        completion.minimum_key_length = 3;
        completion.model = list_store;
        completion.text_column = 0;

        var cell = new Gtk.CellRendererText ();
        completion.pack_start (cell, false);
        completion.add_attribute (cell, "text", 1);

        add_suggestion ("247sports.com");
        add_suggestion ("6pm.com", "6pm");
        add_suggestion ("aa.com", "American Airlines");
        add_suggestion ("aarp.com", "AARP");
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
        add_suggestion ("att.com", "AT&T");
        add_suggestion ("audible.com", "Audible");
        add_suggestion ("autotrader.com", "Autotrader");
        add_suggestion ("azlyrics.com", "AZLyrics");
        add_suggestion ("babycenter.com", "BabyCenter");
        add_suggestion ("baidu.com", "Baidu");
        add_suggestion ("bankofamerica.com", "Bank of America");
        add_suggestion ("bankrate.com");
        add_suggestion ("barclaycardus.com", "Barclays US");
        add_suggestion ("barnesandnoble.com", "Barnes & Noble");
        add_suggestion ("bbc.com", "BBC");
        add_suggestion ("bbc.co.uk", "BBC");
        add_suggestion ("bedbathandbeyond.com", "Bed Bath & Beyond");
        add_suggestion ("bestbuy.com", "Best Buy");
        add_suggestion ("betanews.com", "BetaNews");
        add_suggestion ("bhphotovideo.com", "B&H Photo");
        add_suggestion ("biblegateway.com", "BibleGateway.com");
        add_suggestion ("bing.com", "Bing");
        add_suggestion ("bizjournals.com");
        add_suggestion ("blogger.com", "Blogger");
        add_suggestion ("blogspot.com", "Blogspot");
        add_suggestion ("bloomberg.com", "Bloomberg");
        add_suggestion ("bn.com", "Barnes & Noble");
        add_suggestion ("bodybuilding.com");
        add_suggestion ("booking.com");
        add_suggestion ("box.com", "Box");
        add_suggestion ("buffer.com", "Buffer");
        add_suggestion ("businessinsider.com", "Business Insider");
        add_suggestion ("buzzfeed.com", "Buzzfeed");
        add_suggestion ("capitalone360.com", "Capital One Bank");
        add_suggestion ("capitalone.com", "Capital One");
        add_suggestion ("careerbuilder.com", "CareerBuilder");
        add_suggestion ("cars.com");
        add_suggestion ("cartoonnetwork.com", "Cartoon Network");
        add_suggestion ("cash.app", "Cash App");
        add_suggestion ("cassidyjames.com", "Cassidy James");
        add_suggestion ("cbs.com", "CBS");
        add_suggestion ("cbsnews.com", "CBS News");
        add_suggestion ("cbssports.com", "CBS Sports");
        add_suggestion ("chase.com", "Chase");
        add_suggestion ("chicagotribune.com", "Chicago Tribune");
        add_suggestion ("chron.com", "The Houston Chronicle");
        add_suggestion ("citibankonline.com");
        add_suggestion ("citi.com", "Citi");
        add_suggestion ("cloudflare.com", "Cloudflare");
        add_suggestion ("cnbc.com", "CNBC");
        add_suggestion ("cnet.com", "CNET");
        add_suggestion ("cnn.com", "CNN");
        add_suggestion ("comcast.net", "Comcast");
        add_suggestion ("comenity.net");
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
        add_suggestion ("draftkings.com");
        add_suggestion ("dribbble.com", "Dribbble");
        add_suggestion ("drive.google.com", "Google Drive");
        add_suggestion ("dropbox.com", "Dropbox");
        add_suggestion ("drugs.com");
        add_suggestion ("duckduckgo.com", "DuckDuckGo");
        add_suggestion ("earthlink.net");
        add_suggestion ("ebates.com", "Ebates");
        add_suggestion ("ebay.com", "eBay");
        add_suggestion ("edmunds.com");
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
        add_suggestion ("genius.com");
        add_suggestion ("gettogether.community", "Get Together");
        add_suggestion ("gfycat.com", "Gfycat");
        add_suggestion ("giphy.com", "Giphy");
        add_suggestion ("github.com", "GitHub");
        add_suggestion ("gizmodo.com", "Gizmodo");
        add_suggestion ("glassdoor.com", "Glassdoor");
        add_suggestion ("gmail.com", "Gmail");
        add_suggestion ("gofundme.com", "GoFundMe");
        add_suggestion ("goodhousekeeping.com");
        add_suggestion ("goodreads.com", "Goodreads");
        add_suggestion ("google.com", "Google");
        add_suggestion ("greatergood.com", "GreaterGood");
        add_suggestion ("groupon.com", "Groupon");
        add_suggestion ("harvard.edu");
        add_suggestion ("healthcare.gov");
        add_suggestion ("hilton.com", "Hilton");
        add_suggestion ("hm.com", "H&M");
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
        add_suggestion ("independent.co.uk");
        add_suggestion ("indiatimes.com");
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
        add_suggestion ("kinja.com");
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
        add_suggestion ("liveleak.com");
        add_suggestion ("livestrong.com");
        add_suggestion ("livingsocial.com");
        add_suggestion ("llbean.com", "L.L.Bean");
        add_suggestion ("lunduke.com", "Bryan Lunduke");
        add_suggestion ("lowes.com", "Lowes");
        add_suggestion ("macys.com", "Macy's");
        add_suggestion ("mailchimp.com", "Mailchimp");
        add_suggestion ("mapquest.com", "MapQuest");
        add_suggestion ("marketwatch.com", "MarketWatch");
        add_suggestion ("marriott.com", "Marriott");
        add_suggestion ("marthastewart.com");
        add_suggestion ("mashable.com", "Mashable");
        add_suggestion ("match.com", "Match.com");
        add_suggestion ("mayoclinic.org", "Mayo Clinic");
        add_suggestion ("medium.com", "Medium");
        add_suggestion ("meetup.com", "Meetup");
        add_suggestion ("merriam-webster.com");
        add_suggestion ("mic.com");
        add_suggestion ("michaels.com");
        add_suggestion ("mint.com", "Mint");
        add_suggestion ("mit.edu");
        add_suggestion ("mlb.com", "MLB");
        add_suggestion ("monster.com", "Monster Jobs");
        add_suggestion ("mozilla.org");
        add_suggestion ("msnbc.com");
        add_suggestion ("msn.com", "Microsoft Live");
        add_suggestion ("myfitnesspal.com", "MyFitnessPal");
        add_suggestion ("nationalgeographic.com");
        add_suggestion ("naver.com");
        add_suggestion ("nba.com", "NBA");
        add_suggestion ("nbc.com", "NBC");
        add_suggestion ("nbcnews.com", "NBC News");
        add_suggestion ("nbcsports.com", "NBC Sports");
        add_suggestion ("nesn.com");
        add_suggestion ("newegg.com", "Newegg");
        add_suggestion ("nextdoor.com", "Nextdoor");
        add_suggestion ("nhl.com");
        add_suggestion ("nih.gov", "National Institutes of Health");
        add_suggestion ("nike.com", "Nike");
        add_suggestion ("noaa.gov");
        add_suggestion ("nordstrom.com", "Nordstrom");
        add_suggestion ("npr.org", "NPR");
        add_suggestion ("ny.gov");
        add_suggestion ("nypost.com", "New York Post");
        add_suggestion ("nytimes.com", "New York Times");
        add_suggestion ("office365.com", "Office 365");
        add_suggestion ("officedepot.com", "Office Depot & OfficeMax");
        add_suggestion ("okcupid.com", "OKCupid");
        add_suggestion ("omgubuntu.co.uk", "OMG! Ubuntu!");
        add_suggestion ("opentable.com", "OpenTable");
        add_suggestion ("oracle.com", "Oracle");
        add_suggestion ("orbitz.com");
        add_suggestion ("overstock.com", "Overstock");
        add_suggestion ("patch.com", "Patch");
        add_suggestion ("patheos.com", "Patheos");
        add_suggestion ("paypal.com", "PayPal");
        add_suggestion ("pbs.org", "Public Broadcasting Service");
        add_suggestion ("pcmag.com", "PCMag.com");
        add_suggestion ("people.com", "PEOPLE");
        add_suggestion ("phoronix.com", "Phoronix");
        add_suggestion ("photobucket.com", "Photobucket");
        add_suggestion ("pinterest.com", "Pinterest");
        add_suggestion ("playstation.com");
        add_suggestion ("pnc.com", "PNC");
        add_suggestion ("pof.com", "POF");
        add_suggestion ("pogo.com", "Pogo.com");
        add_suggestion ("politico.com", "POLITICO");
        add_suggestion ("popsugar.com", "POPSUGAR");
        add_suggestion ("potterybarn.com", "Pottery Barn");
        add_suggestion ("priceline.com", "Priceline");
        add_suggestion ("pudue.edu", "Purdue University");
        add_suggestion ("puri.sm", "Purism");
        add_suggestion ("qq.com", "QQ.com");
        add_suggestion ("qualtrics.com");
        add_suggestion ("quizlet.com", "Quizlet");
        add_suggestion ("quora.com", "Quora");
        add_suggestion ("qvc.com", "QVC");
        add_suggestion ("ravelry.com");
        add_suggestion ("realsimple.com");
        add_suggestion ("realtor.com", "Realtor.com");
        add_suggestion ("redbox.com");
        add_suggestion ("reddit.com", "Reddit");
        add_suggestion ("redfin.com", "Redfin");
        add_suggestion ("refactorintui.com", "Refactoring UI");
        add_suggestion ("reference.com", "Reference.com");
        add_suggestion ("refinery29.com", "Refinery29");
        add_suggestion ("regnok.com");
        add_suggestion ("rei.com", "REI");
        add_suggestion ("retailmenot.com", "RetailMeNot");
        add_suggestion ("reuters.com", "Reuters");
        add_suggestion ("roblox.com", "Roblox");
        add_suggestion ("rollingstone.com", "Rolling Stone");
        add_suggestion ("rotoworld.com");
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
        add_suggestion ("skype.com");
        add_suggestion ("slate.com", "Slate");
        add_suggestion ("slides.google.com", "Google Slides");
        add_suggestion ("slideshare.net");
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
        add_suggestion ("stanford.edu");
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
        add_suggestion ("thefreedictionary.com");
        add_suggestion ("theguardian.com", "The Guardian");
        add_suggestion ("thekitchn.com", "Kitchn");
        add_suggestion ("theonion.com", "The Onion");
        add_suggestion ("theoutline.com", "The Outline");
        add_suggestion ("theregister.co.uk", "The Register");
        add_suggestion ("thesaurus.com", "Thesaurus.com");
        add_suggestion ("theverge.com", "The Verge");
        add_suggestion ("thinkgeek.com", "ThinkGeek");
        add_suggestion ("ticketmaster.com", "Ticketmaster");
        add_suggestion ("tickld.com");
        add_suggestion ("tigerdirect.com", "TigerDirect.com");
        add_suggestion ("timeanddate.com");
        add_suggestion ("time.com", "TIME");
        add_suggestion ("timewarnercable.com", "Spectrum");
        add_suggestion ("t-mobile.com", "T-Mobile");
        add_suggestion ("tmobile.com", "T-Mobile");
        add_suggestion ("tmz.com", "TMZ");
        add_suggestion ("today.com", "TODAY");
        add_suggestion ("tomshardware.com");
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
        add_suggestion ("urbanoutfitters.com");
        add_suggestion ("usaa.com", "USAA");
        add_suggestion ("usatoday.com", "USA Today");
        add_suggestion ("usbank.com", "US Bank");
        add_suggestion ("usmagazine.com", "Us Weekly");
        add_suggestion ("usnews.com", "US News & World Report");
        add_suggestion ("usps.com", "USPS");
        add_suggestion ("valadoc.org", "Valadoc");
        add_suggestion ("vanguard.com");
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

        activate.connect (() => {
            var search_engine = Ephemeral.settings.get_string ("search-engine");

            // TODO: Better URL validation
            if (text == "" || text == null) {
                Gdk.beep ();
                return;
            } else if (!text.contains ("://")) {
                if (text.contains (".") && !text.contains (" ")) {
                    text = "%s://%s".printf ("https", text);
                } else {
                    text = search_engine.printf (text);
                }
            }
            web_view.load_uri (text);
        });

        focus_out_event.connect ((event) => {
            string uri = web_view.get_uri ();
            if (uri == "about:blank") {
                text = "";
            }

            return false;
        });

        icon_release.connect ((icon_pos, event) => {
            if (icon_pos == Gtk.EntryIconPosition.SECONDARY) {
                activate ();
            }
        });

        web_view.load_changed.connect ((source, e) => {
            if (!has_focus) {
                text = source.get_uri ();
            }
        });
    }

    private void add_suggestion (
      string domain,
      string? name = null,
      string? reason = _("Popular website")
    ) {
        Gtk.TreeIter iter;
        list_store.append (out iter);

        string description;
        if (name != null) {
            description = "%s – %s".printf (name, reason);
        } else {
             description = reason;
        }

        list_store.set (iter, 0, domain, 1, description);
    }
}
