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
    private const string SEARCH = "https://duckduckgo.com/?q=%s";
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

        var list_store = new Gtk.ListStore (2, typeof (string), typeof (string));
        completion.set_model (list_store);
        completion.set_text_column (0);

        var cell = new Gtk.CellRendererText ();
        completion.pack_start (cell, false);
        completion.add_attribute (cell, "text", 1);

        Gtk.TreeIter iter;

        list_store.append (out iter); list_store.set (iter, 0, "aa.com", 1, "American Airlines – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "abcnews.go.com", 1, "ABC News – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "accuweather.com", 1, "AccuWeather – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "airbnb.com", 1, "Airbnb – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "aliexpress.com", 1, "AliExpress – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "allrecipes.com", 1, "Allrecipes – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "amazon.com", 1, "Amazon – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "americanexpress.com", 1, "American Express – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "ancestry.com", 1, "Ancestry – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "answers.com", 1, "Answers – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "aol.com", 1, "AOL – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "att.com", 1, "AT&T – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "audible.com", 1, "Audible – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "baidu.com", 1, "Baidu – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "bankofamerica.com", 1, "Bank of America – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "barnesandnoble.com", 1, "Barnes & Noble – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "bbc.com", 1, "BBC – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "bbc.co.uk", 1, "BBC – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "bedbathandbeyond.com", 1, "Bed Bath & Beyond – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "bestbuy.com", 1, "Best Buy – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "bhphotovideo.com", 1, "B&H Photo – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "bing.com", 1, "Bing – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "blogger.com", 1, "Blogger – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "blogspot.com", 1, "Blogspot – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "bloomberg.com", 1, "Bloomberg – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "bn.com", 1, "Barnes & Noble – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "businessinsider.com", 1, "Business Insider – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "buzzfeed.com", 1, "Buzzfeed – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "capitalone.com", 1, "Capital One – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "cassidyjames.com", 1, "Cassidy James – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "cbs.com", 1, "CBS – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "cbsnews.com", 1, "CBS News – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "cbssports.com", 1, "CBS Sports – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "chase.com", 1, "Chase – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "citi.com", 1, "Citi – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "cnbc.com", 1, "CNBC – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "cnet.com", 1, "CNET – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "cnn.com", 1, "CNN – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "comcast.net", 1, "Comcast – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "costco.com", 1, "Costco – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "coupons.com", 1, "Coupons.com – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "craigslist.org", 1, "Craigslist – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "creditkarma.com", 1, "Credit Karma – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "deadspin.com", 1, "Deadspin – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "dell.com", 1, "Dell – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "delta.com", 1, "Delta Air Lines – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "deviantart.com", 1, "DeviantArt – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "dictionary.com", 1, "Dictionary.com – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "diply.com", 1, "Diply – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "discover.com", 1, "Discover – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "discovercard.com", 1, "Discover – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "dropbox.com", 1, "Dropbox – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "duckduckgo.com", 1, "DuckDuckGo – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "ebates.com", 1, "Ebates – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "ebay.com", 1, "eBay – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "elementary.io", 1, "elementary – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "engadget.com", 1, "Engadget – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "eonline.com", 1, "E! News – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "espn.go.com", 1, "ESPN – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "etsy.com", 1, "Etsy – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "evite.com", 1, "Evite – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "ew.com", 1, "Entertainment Weekly – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "expedia.com", 1, "Expedia – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "facebook.com", 1, "Facebook – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "fandango.com", 1, "Fandango – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "fanduel.com", 1, "FanDuel – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "fedex.com", 1, "FedEx – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "feedly.com", 1, "Feedly – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "fidelity.com", 1, "Fidelity Investments – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "flickr.com", 1, "Flickr – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "food52.com", 1, "Food52 – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "foodnetwork.com", 1, "Food Network – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "forbes.com", 1, "Forbes – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "forever21.com", 1, "Forever 21 – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "gamestop.com", 1, "GameStop – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "gamefaqs.com", 1, "GameFAQs – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "gap.com", 1, "Gap – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "gawker.com", 1, "Gawker – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "gettogether.community", 1, "Get Together – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "gfycat.com", 1, "Gfycat – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "github.com", 1, "GitHub – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "gizmodo.com", 1, "Gizmodo – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "glassdoor.com", 1, "Glassdoor – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "gofundme.com", 1, "GoFundMe – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "goodreads.com", 1, "Goodreads – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "google.com", 1, "Google – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "groupon.com", 1, "Groupon – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "homedepot.com", 1, "The Home Depot – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "houzz.com", 1, "Houzz – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "hp.com", 1, "HP – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "huffingtonpost.com", 1, "Huffington Post – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "icloud.com", 1, "iCloud – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "iflscience.com", 1, "IFLScience – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "ign.com", 1, "IGN – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "ikea.com", 1, "IKEA – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "imdb.com", 1, "Internet Movie Database – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "imgur.com", 1, "Imgur – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "indeed.com", 1, "Indeed – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "indiegogo.com", 1, "Indiegogo – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "instagram.com", 1, "Instagram – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "intuit.com", 1, "Intuit – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "jcpenny.com", 1, "JCPenny – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "kickstarter.com", 1, "Kickstarter – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "kmart.com", 1, "Kmart – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "kohls.com", 1, "Khol's – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "latimes.com", 1, "LA Times – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "legacy.com", 1, "Legacy.com – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "lifehacker.com", 1, "Lifehacker – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "linkedin.com", 1, "LinkedIn – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "littlethings.com", 1, "LittleThings – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "lowes.com", 1, "Lowes – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "macys.com", 1, "Macy's – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "mapquest.com", 1, "MapQuest – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "mashable.com", 1, "Mashable – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "mayoclinic.org", 1, "Mayo Clinic – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "medium.com", 1, "Medium – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "meetup.com", 1, "Meetup – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "msn.com", 1, "Microsoft Live – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "myfitnesspal.com", 1, "MyFitnessPal – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "nba.com", 1, "NBA – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "nbcnews.com", 1, "NBC News – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "nbcsports.com", 1, "NBC Sports – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "newegg.com", 1, "Newegg – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "nextdoor.com", 1, "Nextdoor – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "nih.gov", 1, "National Institutes of Health – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "nike.com", 1, "Nike – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "nordstrom.com", 1, "Nordstrom – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "npr.org", 1, "NPR – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "nypost.com", 1, "New York Post – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "nytimes.com", 1, "New York Times – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "okcupid.com", 1, "OKCupid – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "office365.com", 1, "Office 365 – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "overstock.com", 1, "Overstock – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "patch.com", 1, "Patch – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "paypal.com", 1, "PayPal – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "pcmag.com", 1, "PCMag.com – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "people.com", 1, "PEOPLE – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "pinterest.com", 1, "Pinterest – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "pnc.com", 1, "PNC – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "pof.com", 1, "POF – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "popsugar.com", 1, "POPSUGAR – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "priceline.com", 1, "Priceline – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "puri.sm", 1, "Purism – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "qq.com", 1, "QQ.com – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "quizlet.com", 1, "Quizlet – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "quora.com", 1, "Quora – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "qvc.com", 1, "QVC – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "realtor.com", 1, "Realtor.com – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "reddit.com", 1, "Reddit – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "redfin.com", 1, "Redfin – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "reference.com", 1, "Reference.com – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "rei.com", 1, "REI – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "retailmenot.com", 1, "RetailMeNot – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "reuters.com", 1, "Reuters – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "rottentomatoes.com", 1, "Rotten Tomatoes – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "salesforce.com", 1, "Salesforce – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "samsclub.com", 1, "Sam's Club – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "sbnation.com", 1, "SBNation – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "sears.com", 1, "Sears – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "sephora.com", 1, "Sephora – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "sfgate.com", 1, "SFGATE – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "shopify.com", 1, "Shopify – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "shutterfly.com", 1, "Shutterfly – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "simple.com", 1, "Simple – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "slate.com", 1, "Slate – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "soundcloud.com", 1, "SoundCloud – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "southwest.com", 1, "Southwest Airlines – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "squareup.com", 1, "Square – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "stackoverflow.com", 1, "Stack Overflow – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "staples.com", 1, "Staples – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "steamcommunity.com", 1, "Steam Community – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "steampowered.com", 1, "Steam – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "stripe.com", 1, "Stripe – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "surveymonkey.com", 1, "SurveyMonkey – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "swagbucks.com", 1, "Swagbucks – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "system76.com", 1, "System76 – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "target.com", 1, "Target – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "telegraph.co.uk", 1, "The Telegraph – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "theguardian.com", 1, "The Guardian – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "theatlantic.com", 1, "The Atlantic – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "thekitchn.com", 1, "Kitchn – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "theoutline.com", 1, "The Outline – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "thesaurus.com", 1, "Thesaurus.com – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "theverge.com", 1, "The Verge – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "ticketmaster.com", 1, "Ticketmaster – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "t-mobile.com", 1, "T-Mobile – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "time.com", 1, "TIME – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "tmobile.com", 1, "T-Mobile – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "tmz.com", 1, "TMZ – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "today.com", 1, "TODAY – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "tripadvisor.com", 1, "TripAdvisor – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "trulia.com", 1, "Trulia – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "tumblr.com", 1, "Tumblr – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "twitch.tv", 1, "Twitch – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "united.com", 1, "United Airlines – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "unsplash.com", 1, "Unsplash – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "usaa.com", 1, "USAA – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "usatoday.com", 1, "US Today – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "usbank.com", 1, "US Bank – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "usps.com", 1, "USPS – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "valadoc.org", 1, "Valadoc – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "verizon.com", 1, "Verizon – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "vice.com", 1, "VICE – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "vimeo.com", 1, "Vimeo – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "walgreens.com", 1, "Walgreens – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "walmart.com", 1, "Walmart – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "washingtonpost.com", 1, "Washington Post – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "wayfair.com", 1, "Wayfair – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "weather.com", 1, "Weather – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "weather.gov", 1, "National Weather Service – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "webmd.com", 1, "WebMD – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "weebly.com", 1, "Weebly – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "wellsfargo.com", 1, "Wells Fargo – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "whitepages.com", 1, "Whitepages – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "wikia.com", 1, "Wikia – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "wikihow.com", 1, "wikiHow – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "wikipedia.org", 1, "Wikipedia – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "woot.com", 1, "Woot – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "wordpress.com", 1, "Wordpress – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "wsj.com", 1, "Wall Street Journal – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "wunderground.com", 1, "Weather Underground – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "xfinity.com", 1, "Xfinity – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "yahoo.com", 1, "Yahoo – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "yellowpages.com", 1, "Yellowpages – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "yelp.com", 1, "Yelp – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "youtube.com", 1, "YouTube – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "zappos.com", 1, "Zappos – Popular website");
        list_store.append (out iter); list_store.set (iter, 0, "zillow.com", 1, "Zillow – Popular website");

        activate.connect (() => {
            // TODO: Better URL validation
            if (text == "" || text == null) {
                Gdk.beep ();
                return;
            } else if (!text.contains ("://")) {
                if (text.contains (".") && !text.contains (" ")) {
                    text = "%s://%s".printf ("https", text);
                } else {
                    text = SEARCH.printf (text);
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
}

