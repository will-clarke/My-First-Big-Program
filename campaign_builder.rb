# encoding: utf-8
#!/usr/bin/env ruby
      
          #######################################################################################
          #                                                                                     
          #                                                                                     #
          #                           DOCUMENTATION  --- PLEASE READ!                           #
          #                         ###################################                         #
          #                                                                                     #
          #                                                                                     #
          #                                                                                     #
          #     1.      Make sure you have the right Ad Template in the same directory.         #
          #     2.      cd to right directory                                                   #
          #                                                                                     #
          #     3.          ruby campaign_builder.rb aa Coolbrand                               #
          #                                                                                     #
          #                This will search aa for Coolbrand                                    #
          #                                                                                     #
          #          Another option:                                                            #
          #          ruby campaign_builder.rb aa all                                            #
          #            This will create campaigns for ALL brands.                               #
          #                                                                                     #
          #                                                                                     #
          #######################################################################################



      #################################################################################################
      #                                VARIABLES YOU MAY WANT TO CHANGE                               #
      #################################################################################################


@masterlist = [['Dynamic Smart Pixel', 10], ['Converters 180 Days', 20]]
@campaign_budget = '50'
@N1_N2_is_enabled = false
@N1_N2_bid_modifier = 1.2
@broad_match_bid = 0.50
@exact_match_bid = 0.70
@network = "Google Search;Search Partners"
@bid_adjustment = -45
                                                                
      #################################################################################################
      #                                   BORING / NECESSARY PARAMETERS                               #
      #################################################################################################


require 'pry'
require 'mechanize'
require 'csv'
require 'roo'
require 'spreadsheet'
require 'google_drive'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8


AD_TEMPLATE= CSV.parse(open('Ad Text Template.csv'))

TEMPLATE_COLUMNS = {
:variation => 0,
:ad_number => 1,
:headline => 2,
:description_line1 => 3,
:description_line2 => 4,
:display_url => 5
}

@agent = Mechanize.new
@agent.user_agent = 'A Scraper'

@site = ''
@currency_symbol = '' 
@currency = ''
# @country = ''
@country_id = ''
@language = ''
@locations = []
@list_of_brands = []
@csv_array = []
@mega_list_of_adgroups_exact = []
@data = []
@using_product_feed = true
@output_array = []
@already_scraped_brands = []
@failed_brands_array = []






#################################################################################################
#           THIS DEALS WITH ANNOYING ACCENT DIFFERENCES -- EG -- Accents                        #
#################################################################################################


class RegexpExtension
 
  ACCENTED = {
    'A' => "[Aa\u00aa\u00c0-\u00c5\u00e0-\u00e5\u0100-\u0105\u01cd\u01ce\u0200-\u0203\u0226\u0227\u1d2c\u1d43\u1e00\u1e01\u1e9a\u1ea0-\u1ea3\u2090\u2100\u2101\u213b\u249c\u24b6\u24d0\u3371-\u3374\u3380-\u3384\u3388\u3389\u33a9-\u33af\u33c2\u33ca\u33df\u33ff\uff21\uff41]",
    'B' => "[Bb\u1d2e\u1d47\u1e02-\u1e07\u212c\u249d\u24b7\u24d1\u3374\u3385-\u3387\u33c3\u33c8\u33d4\u33dd\uff22\uff42]",
    'C' => "[Cc\u00c7\u00e7\u0106-\u010d\u1d9c\u2100\u2102\u2103\u2105\u2106\u212d\u216d\u217d\u249e\u24b8\u24d2\u3376\u3388\u3389\u339d\u33a0\u33a4\u33c4-\u33c7\uff23\uff43]",
    'D' => "[Dd\u010e\u010f\u01c4-\u01c6\u01f1-\u01f3\u1d30\u1d48\u1e0a-\u1e13\u2145\u2146\u216e\u217e\u249f\u24b9\u24d3\u32cf\u3372\u3377-\u3379\u3397\u33ad-\u33af\u33c5\u33c8\uff24\uff44]",
    'E' => "[Ee\u00c8-\u00cb\u00e8-\u00eb\u0112-\u011b\u0204-\u0207\u0228\u0229\u1d31\u1d49\u1e18-\u1e1b\u1eb8-\u1ebd\u2091\u2121\u212f\u2130\u2147\u24a0\u24ba\u24d4\u3250\u32cd\u32ce\uff25\uff45]",
    'F' => "[Ff\u1da0\u1e1e\u1e1f\u2109\u2131\u213b\u24a1\u24bb\u24d5\u338a-\u338c\u3399\ufb00-\ufb04\uff26\uff46]",
    'G' => "[Gg\u011c-\u0123\u01e6\u01e7\u01f4\u01f5\u1d33\u1d4d\u1e20\u1e21\u210a\u24a2\u24bc\u24d6\u32cc\u32cd\u3387\u338d-\u338f\u3393\u33ac\u33c6\u33c9\u33d2\u33ff\uff27\uff47]",
    'H' => "[Hh\u0124\u0125\u021e\u021f\u02b0\u1d34\u1e22-\u1e2b\u1e96\u210b-\u210e\u24a3\u24bd\u24d7\u32cc\u3371\u3390-\u3394\u33ca\u33cb\u33d7\uff28\uff48]",
    'I' => "[Ii\u00cc-\u00cf\u00ec-\u00ef\u0128-\u0130\u0132\u0133\u01cf\u01d0\u0208-\u020b\u1d35\u1d62\u1e2c\u1e2d\u1ec8-\u1ecb\u2071\u2110\u2111\u2139\u2148\u2160-\u2163\u2165-\u2168\u216a\u216b\u2170-\u2173\u2175-\u2178\u217a\u217b\u24a4\u24be\u24d8\u337a\u33cc\u33d5\ufb01\ufb03\uff29\uff49]",
    'J' => "[Jj\u0132-\u0135\u01c7-\u01cc\u01f0\u02b2\u1d36\u2149\u24a5\u24bf\u24d9\u2c7c\uff2a\uff4a]",
    'K' => "[Kk\u0136\u0137\u01e8\u01e9\u1d37\u1d4f\u1e30-\u1e35\u212a\u24a6\u24c0\u24da\u3384\u3385\u3389\u338f\u3391\u3398\u339e\u33a2\u33a6\u33aa\u33b8\u33be\u33c0\u33c6\u33cd-\u33cf\uff2b\uff4b]",
    'L' => "[Ll\u0139-\u0140\u01c7-\u01c9\u02e1\u1d38\u1e36\u1e37\u1e3a-\u1e3d\u2112\u2113\u2121\u216c\u217c\u24a7\u24c1\u24db\u32cf\u3388\u3389\u33d0-\u33d3\u33d5\u33d6\u33ff\ufb02\ufb04\uff2c\uff4c]",
    'M' => "[Mm\u1d39\u1d50\u1e3e-\u1e43\u2120\u2122\u2133\u216f\u217f\u24a8\u24c2\u24dc\u3377-\u3379\u3383\u3386\u338e\u3392\u3396\u3399-\u33a8\u33ab\u33b3\u33b7\u33b9\u33bd\u33bf\u33c1\u33c2\u33ce\u33d0\u33d4-\u33d6\u33d8\u33d9\u33de\u33df\uff2d\uff4d]",
    'N' => "[Nn\u00d1\u00f1\u0143-\u0149\u01ca-\u01cc\u01f8\u01f9\u1d3a\u1e44-\u1e4b\u207f\u2115\u2116\u24a9\u24c3\u24dd\u3381\u338b\u339a\u33b1\u33b5\u33bb\u33cc\u33d1\uff2e\uff4e]",
    'O' => "[Oo\u00ba\u00d2-\u00d6\u00f2-\u00f6\u014c-\u0151\u01a0\u01a1\u01d1\u01d2\u01ea\u01eb\u020c-\u020f\u022e\u022f\u1d3c\u1d52\u1ecc-\u1ecf\u2092\u2105\u2116\u2134\u24aa\u24c4\u24de\u3375\u33c7\u33d2\u33d6\uff2f\uff4f]",
    'P' => "[Pp\u1d3e\u1d56\u1e54-\u1e57\u2119\u24ab\u24c5\u24df\u3250\u3371\u3376\u3380\u338a\u33a9-\u33ac\u33b0\u33b4\u33ba\u33cb\u33d7-\u33da\uff30\uff50]",
    'Q' => "[Qq\u211a\u24ac\u24c6\u24e0\u33c3\uff31\uff51]",
    'R' => "[Rr\u0154-\u0159\u0210-\u0213\u02b3\u1d3f\u1d63\u1e58-\u1e5b\u1e5e\u1e5f\u20a8\u211b-\u211d\u24ad\u24c7\u24e1\u32cd\u3374\u33ad-\u33af\u33da\u33db\uff32\uff52]",
    'S' => "[Ss\u015a-\u0161\u017f\u0218\u0219\u02e2\u1e60-\u1e63\u20a8\u2101\u2120\u24ae\u24c8\u24e2\u33a7\u33a8\u33ae-\u33b3\u33db\u33dc\ufb06\uff33\uff53]",
    'T' => "[Tt\u0162-\u0165\u021a\u021b\u1d40\u1d57\u1e6a-\u1e71\u1e97\u2121\u2122\u24af\u24c9\u24e3\u3250\u32cf\u3394\u33cf\ufb05\ufb06\uff34\uff54]",
    'U' => "[Uu\u00d9-\u00dc\u00f9-\u00fc\u0168-\u0173\u01af\u01b0\u01d3\u01d4\u0214-\u0217\u1d41\u1d58\u1d64\u1e72-\u1e77\u1ee4-\u1ee7\u2106\u24b0\u24ca\u24e4\u3373\u337a\uff35\uff55]",
    'V' => "[Vv\u1d5b\u1d65\u1e7c-\u1e7f\u2163-\u2167\u2173-\u2177\u24b1\u24cb\u24e5\u2c7d\u32ce\u3375\u33b4-\u33b9\u33dc\u33de\uff36\uff56]",
    'W' => "[Ww\u0174\u0175\u02b7\u1d42\u1e80-\u1e89\u1e98\u24b2\u24cc\u24e6\u33ba-\u33bf\u33dd\uff37\uff57]",
    'X' => "[Xx\u02e3\u1e8a-\u1e8d\u2093\u213b\u2168-\u216b\u2178-\u217b\u24b3\u24cd\u24e7\u33d3\uff38\uff58]",
    'Y' => "[Yy\u00dd\u00fd\u00ff\u0176-\u0178\u0232\u0233\u02b8\u1e8e\u1e8f\u1e99\u1ef2-\u1ef9\u24b4\u24ce\u24e8\u33c9\uff39\uff59]",
    'Z' => "[Zz\u0179-\u017e\u01f1-\u01f3\u1dbb\u1e90-\u1e95\u2124\u2128\u24b5\u24cf\u24e9\u3390-\u3394\uff3a\uff5a]"
  } unless const_defined? :ACCENTED
   def self.accent_insensitive_pattern(search)
    search.each_char.collect { |char| ACCENTED[char.upcase] || char } .join
  end
 end


#################################################################################################
#                   ASSIGN THE RIGHT VARIABLES TO THE ARGUMENT PARAMETERS                       #
#################################################################################################


def start___deal_with_argument_parameters

  unless Dir.glob('Ad Text Template.csv').any?
    abort 'Please include the "Ad Text Template.csv" file in the same directory.'
  end

  if ARGV.count < 3
    abort "===================================
    Please Use this format:



     ruby -----FileName ----   -Site-    -Country-        -Product(s)-

     Eg.
     ruby campaign_builder.rb    aa        UK-US-SE       CoolBrand    AnotherBrand   YetAnother


     To get the Brand CoolBrand from AA in the UK, US and Sweden. 



      Use the code '--without-product-feed' to also import from the product feed. Eg:
          ruby campaign_builder.rb    aa     UK-US-SE      CoolBrand  --without-product-feed

      Use either '--N1' or '--R1' to add two Core adgroups ('Core || N1' & 'Core || R1')
          ruby campaign_builder.rb    aa        UK-DK        CoolBrand   --R1

     ==================================="
  end

  ag = ARGV[1].downcase
  ag = ag.split('-')
ag.each do |ar|
  @list_of_brands = []  
  a = ar.downcase
    ARGV.each_with_index do|argument, i|

      if i == 0
      case argument.downcase
        when 'aa'
          @site = 'aa.co.uk'
          @masterlist = [['Dynamic Smart Pixel', 10], ['aa Converters', 20]]

        when 'bb'
          @site = 'bb.com'

        when 'cc'
          @site = 'cc.net'
          @masterlist = [['Dynamic Smart Pixel', 10], ['cc Buyers', 20]]

        else
          abort "\n\nPlease label the site first. Eg. 'ruby campaign_builder.rb aa ...........'\n\n"
       end
      elsif i == 1
        case ar #a.downcase
          when 'au'
            @currency = '?switchcurrency=AUD'
            @currency_symbol = '$'
            @country_id = 'AU'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['Australia']

          when 'dk'
            @currency = '?switchcurrency=DKK'  
            @currency_symbol = 'kr'
            @country_id = 'DK'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['Denmark']

          when 'eu', 'eur'
            @currency = '?switchcurrency=EUR'  
            @currency_symbol = '€'
            @country_id = 'EU'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['Albania', 'Andorra', 'Austria', 'Azerbaijan', 'Belarus', 'Belgium', 'Bosnia and Herzegovina', 'Bulgaria', 'Croatia', 'Cyprus', 'Czech Republic', 'Estonia', 'France', 'Georgia', 'Germany', 'Greece', 'Hungary', 'Iceland', 'Italy', 'Kazakhstan', 'Latvia', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Macedonia', 'Malta', 'Moldova', 'Monaco', 'Montenegro', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Russia', 'San Marino', 'Serbia', 'Slovakia', 'Slovenia', 'Spain', 'Switzerland', 'Turkey', 'Ukraine', 'Vatican City' ]

          when 'no', 'norway'
            @currency = '?switchcurrency=NOK'
            @currency_symbol = 'kr'
            @country_id = 'NO'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['Norway']

          when 'se'
            @currency = '?switchcurrency=SEK'
            @currency_symbol = 'kr'
            @country_id = 'SE'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['Sweden']

          when 'uk'
            @currency = '?switchcurrency=GBP'
            @currency_symbol = '£'
            @country_id = 'UK'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['United Kingdom']

          when 'us'
            @currency = '?switchcurrency=USD'
            @currency_symbol = '$'
            @country_id = 'US'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['USA']

          when 'ie'
            @currency = '?switchcurrency=EUR'  
            @currency_symbol = '€'
            @country_id = 'IE'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['Republic of Ireland']

          when 'fi'
            @currency = '?switchcurrency=EUR'  
            @currency_symbol = '€'
            @country_id = 'FI'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['Finland']


          when 'ca', 'canada', 'canadian'
            @currency = '?switchcurrency=CAD'  
            @currency_symbol = '$'
            @country_id = 'CA'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['Canada']


          when 'nz'
            @currency = '?switchcurrency=NZD'  
            @currency_symbol = '$'
            @country_id = 'NZ'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['New Zealand']


          when 'hk'
            @currency = '?switchcurrency=HKD'  
            @currency_symbol = '$'
            @country_id = 'HK'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['Hong Kong']

          when 'sg'
            @currency = '?switchcurrency=GBP'  
            @currency_symbol = '£'
            @country_id = 'SG'
            @language = 'ar;bg;cs;da;el;en;et;fa;fi;hi;hr;hu;id;is;it;iw;ja;ko;lt;lv;ms;nl;no;pl;ro;ru;sk;sl;sr;sv;th;tl;tr;uk;ur;vi;zh_CN;zh_TW'
            @locations = ['Singapore']
  


          else
            abort "\n\nPlease label the Country second. Eg. 'ruby campaign_builder.rb aa UK CoolBrand'
            The available symbols are:
                      AU
                      DK
                      EUR
                      NO
                      SE
                      UK
                      US


                      You can also chain them together. Eg:

                AU-NO-UK-US


            "
          end

      elsif argument.downcase == "--without-product-feed" 
        @using_product_feed = false

      elsif (argument.downcase == '--n1' || argument.downcase == '--r1')
        @N1_N2_is_enabled = true

      elsif argument.downcase == 'all'
          brand_page = @agent.get "http://www.#{@site}/brands.list"
          # counter_ = 0
          brand_page.search('.brand-tabs-item a').each do |brand|
            # counter_+=1
            # break if counter_ == 20
            @list_of_brands << [brand.attributes['title'].value, brand.attributes['href'].value.to_s +  @currency]
            end
      else
            @list_of_brands << [argument, "http://www.#{@site.downcase}/brands/#{argument}.list" + @currency]
        end
      end

  p ''
  p ''
  p "   #{ar.upcase}          "  
  p ''
      main_method ### MEGA BIG METHOD-CALL HERE. OMG.

    end
end
#################################################################################################
#                              SCRAPE THE SITE. OMG. TOTES AWESOME                              #
#################################################################################################

def start___scrape_site

@csv_array = []   ############# Reset the array
@brands_categories = []
@brands_categories_with_prices = []
failed_brands = 0
# counter = 1
# another_counter = 0
brands_categories = []
@list_of_brands.each do |title, url|
  # p "#{title} -- #{url}"
   
  if @already_scraped_brands.include? url + " " + @country_id
    p 'NEXT'
    next
  end
  brands_categories << [title, url, 'Core___________________________________', url]
  p "Brand -- #{title}"
  # counter += 1
  begin
    # p "Scraping #{url}"
  page = @agent.get(url)
  @already_scraped_brands << url + " " + @country_id

  # p @already_scraped_brands
rescue
  unless @failed_brands_array.include? url

  p ''
  p '========================================'
  p ''
  p "          #{url.scan(/brands\/(.*)\.list/)[0][0] }"
  p ''
  p "Soz. Doesn't look like #{url} exists. :( "
  p ''
  p '========================================'
  p ''
   @failed_brands_array << url
  end

  failed_brands += 1
  next   
end

a = ''
 
# removed '.nav-link a,' from \\
    a = page.parser.css('specifc css selectors')

  a.each do |link|

      real_url = link.attributes['href'].value.gsub(@currency, '')
      if real_url[0] == '?'
        real_url = url + real_url
      end

      real_url.gsub!('?', '&')
      real_url.sub!('&', '?')

      if real_url.include? "?"
        real_url+= '&affil=tag'
      else
        real_url+= '?affil=tag'
      end

      brands_categories << [title, url, link.attributes['title'].value, real_url ]
      # another_counter += 1
    end
  end

  abort(["It's not your fault.", "Try again.", "Stop being stupid.", "Now try getting it right.", "OMG! OH NOES!", "Nope."].sample) if failed_brands == @list_of_brands.count

# ======================================================================

a = brands_categories
  @brands_categories_with_prices = []
a.length.times do |row_count|

    ###############################
    #     Append Currency URL     #
    ###############################

    product_or_category_url = a[row_count][3] 

    product_or_category_url += @currency unless product_or_category_url.include? @currency[1..-1]
    product_or_category_url = product_or_category_url.gsub('?', '&').sub('&', '?')

    a[row_count][3] = product_or_category_url

  begin

    page = @agent.get a[row_count][3]

    prices = page.search('.unit .price').text
    prices = prices.scan /[\d\.|,]+/

    products = page.search('.product-button')

    product = if products && products.any? && products.length == 1
       page.search('.product-button')[0].parent.children.children[2].attributes['href'].value
     else
      nil
    end

    if product
      row = a[row_count]
      row[3] = product
        @brands_categories_with_prices << row + [prices.map!{|i| i.sub(/,/, '.').to_f}.min]
    else
        @brands_categories_with_prices << a[row_count] + [prices.map!{|i| i.sub(/,/, '.').to_f}.min]
    end
    # sleep rand
    rescue => e
    # p e
    # p a[row_count]
  end

  end

end


#################################################################################################
#                        IMPORT PRODUCT FEED  FROM GOOGLE SPREADSHEET                           #
#################################################################################################



def get_product_feed_from_google_doc  #Not used any more. Luckily. It took ages. :|
  begin
  session = GoogleDrive.login("username", "password")
  ws = session.spreadsheet_by_title("aa Product Feed").worksheets[0]
  @data = ws.rows
  rescue
  p "\n\nFor some reason, the Spreadsheet isn't available. Soz ;(\n\n"
  end
end


def get_product_feed_from_csv

if @site == 'aa.com' && @country_id == 'UK'
  product_feed_file = 'aa-feed.txt'

elsif @site == 'aa.com' && @country_id == 'AU'
  product_feed_file = 'aa-au-feed.txt'

elsif @site == 'aa.com' && @country_id == 'US'
  product_feed_file = 'aa-us-feed.txt'

elsif @site == 'bb.co.uk' && @country_id == 'UK'
  product_feed_file = 'bb-feed.txt'

elsif @site == 'cc.co.uk' && @country_id == 'UK'
  product_feed_file = 'cc-feed.txt'
end
if product_feed_file


  a=File.read(product_feed_file);
  a = a.split("\n").map{|i| i.gsub("\"", '').split("\t")};

  @data = a.map do |i|
    [i[6], i[0].gsub(/\?.+$/, ''), i[17],      i[8], i[4].to_f, i[2], ''  ]
    # id  url availability  brand price title rrp price_euro  colour  dated client
  end

end



  # encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '___________________________________'))
end
#################################################################################################
#                 POTENTIALLY MENTAL STEP (ADDING PRODUCTS FROM THE FEED)                       #
#################################################################################################


def add_products_from_product_feed
  @list_of_brands.each do |brand|
    brand_name = brand[0].downcase

    @data.each do |product_feed_rows|
      # p product_feed_rows[3] if product_feed_rows[3]
      # next if product_feed_rows[3] && product_feed_rows[3].include?('___________________________________')
      # next if product_feed_rows[2] && product_feed_rows[2].include?('___________________________________')
      product_feed_brand = if (product_feed_rows[3].class == String) && product_feed_rows[3].length > 2
        product_feed_rows[3].downcase
      else
        'zzzzzzzz'
      end
      # p product_feed_rows[3]
      if brand_name && (brand_name.match product_feed_brand)
        # p "brand name: #{brand_name} -- product_feed_brand = #{product_feed_brand}"
        # p product_feed_rows[5]
        @brands_categories_with_prices << [brand[0], '_PRODUCT_', product_feed_rows[5], product_feed_rows[1].sub('?affil=tag',''), product_feed_rows[4].to_f ]
      end
    end
  end


end



#################################################################################################
#               ITERATE OVER BRANDS FOUND BY PREVIOUS METHOD (START)                            #
#################################################################################################


def iterate_over_brands

  @brands_categories_with_prices.each do |row|
    # p row
    adgroup = Adgroup.new
    adgroup.campaign = "#@country_id || EN || SEA || NB || Products || #{row[0].gsub('-', ' ')} || EM"
    adgroup.brand = row[0].gsub('-', ' ')
    adgroup.destination_url = row[3]
    adgroup.price = row[4]
    adgroup.adgroup_name = row[3].match(/(?:uk|com)(.*)\./)[1].gsub('-', ' ').gsub('/', ' || ').split.each{|i| i[0] = i[0].upcase}.join(' ')
    adgroup.adgroup_name+= row[2].include?('Core') ? ' || Core' : ''

    unless adgroup.destination_url.match @currency[1..-1]
      adgroup.destination_url = adgroup.destination_url + @currency
    end

       #THIS ADGROUP_NAME UNDERNEATH WAS ADGROUP PRODUCTS. IT'S OVERWRITING ADGROUP_NAME. OMG

    adgroup.adgroup_name = if row[2].match adgroup.campaign
      row[2].gsub($&, '').gsub('  ', ' ').gsub(/^ /, '')
    elsif row[2].match adgroup.campaign.gsub(' ','')
      row[2].gsub($&, '').gsub('  ', ' ').gsub(/^ /, '')
    else
      row[2]
    end

    if row[1] == '_PRODUCT_'
      adgroup.adgroup_name = 'Product || ' +adgroup.adgroup_name
    end


   clever_regex = /#{RegexpExtension.accent_insensitive_pattern Regexp.escape(adgroup.brand)}/i
      if adgroup.adgroup_name.scan(clever_regex).length > 0
        # p 'omg. triggered the adgroup neame things'
        adgroup.adgroup_name = adgroup.adgroup_name.gsub(clever_regex, '').gsub(/\s+/, ' ').sub(/^\s/, '')

      end

      if adgroup.adgroup_name[0].class == String
        adgroup.adgroup_name[0] = adgroup.adgroup_name[0].upcase
      end

    adgroup.product = adgroup.adgroup_name

    ###############################
    #        CREATE ADS HERE      #
    ###############################

    adgroup.ads = create_ads(adgroup)

  adgroup.ads.each do |ads|
    ads.each do |k, v|
      if (v && (v.match /[£|\$|kr|€](\d+(\.\d+)?)/)) 
        ads[k] = v.sub($1, "{param1:#{$1}}")
        end
    end
  end

    ###############################
    #     CREATE KEYWORDS HERE    #
    ###############################
    adgroup.keywords = create_keywords(adgroup)

    @mega_list_of_adgroups_exact << adgroup
  end
end


#################################################################################################
#                                             KEYWORD CLASS                                     #
#################################################################################################

class Keyword
  attr_accessor :keyword, :match_type
  def initialize(keyword, match_type)
    @keyword = keyword
    @match_type = match_type
  end
end

#################################################################################################
#                                          ADGROUP CLASS                                        #
#################################################################################################

class Adgroup
  attr_accessor :destination_url, :adgroup_name, :campaign, :keywords, :ads, :brand, :price, :settings, :product

  def to_row(csv)
  # ["Campaign", "Ad Group", "Keyword", "Criterion Type", "Headline", "Description Line 1", "Description Line 2", "Display URL", "Destination URL"]
    self.ads.each do |ad|
      csv << [self.campaign, self.adgroup_name, "", "", ad[:headline], ad[:description_line1], ad[:description_line2], ad[:display_url], self.destination_url]
    end
      self.keywords.each do |keyword|
      csv << [self.campaign, self.adgroup_name, keyword.keyword, keyword.match_type, "", "", "", '', self.destination_url]
      end
  end
end


#################################################################################################
#                                          CREATE KEYWORDS                                      #
#################################################################################################


def create_keywords(adgroup)
    brand = adgroup.brand.downcase
    product = adgroup.product.downcase
    # p '-'*15
    # p "brand: #{brand}"
    # p "product: #{product}"
    if product.match brand
      product = product.gsub(brand, '').gsub(/\s+/, ' ')
    end

    return_array = [Keyword.new("#{brand} #{product}".gsub('product || ', '').gsub(/\s+/, ' ').gsub(/\(|\)/, ''), "exact"), Keyword.new("#{product} #{brand}".gsub('product || ', '').gsub(/\s+/, ' ').gsub(/(\(|\))/, ''), "exact")]

    to_be_added = []
    return_array.each do |kw|
      clever_regex = /#{RegexpExtension.accent_insensitive_pattern Regexp.escape(brand)}/i
      if kw.keyword.scan(clever_regex).length > 1

          brand_regex = kw.keyword.scan(clever_regex)
          price_regex = kw.keyword.match /(\d+(ml|kg|g))/
          # p price_regex

          brand_regex.each do |r|
            # p r
            # p kw.keyword
            # p kw.keyword.gsub(r, '')
            # p ''
            # p ''
            # p ''
            to_be_added << Keyword.new(kw.keyword.gsub(r, '').gsub(/\s+/, ' '), "exact")
            to_be_added << Keyword.new(kw.keyword.gsub(r, '').gsub(/\s+/, ' ').gsub(brand,'') + r, "exact")
            to_be_added << Keyword.new(r + kw.keyword.gsub(r, '').gsub(/\s+/, ' ').gsub(brand,''), "exact")
            if price_regex
              to_be_added << Keyword.new(kw.keyword.gsub(r, '').gsub(price_regex[0], '').gsub(/\s+/, ' '), "exact")
              to_be_added << Keyword.new(kw.keyword.gsub(r, '').gsub(price_regex[0], '').gsub(/\s+/, ' ').gsub(brand,'') + r, "exact")
              to_be_added << Keyword.new(r + kw.keyword.gsub(r, '').gsub(price_regex[0], '').gsub(/\s+/, ' ').gsub(brand,''), "exact")
            end
          end
      end
      price_regex = kw.keyword.match /(\d+(ml|kg|g))/
      if price_regex
        to_be_added << Keyword.new(kw.keyword.gsub(price_regex[0], '').gsub(/\s+/, ' '), "exact")
        to_be_added << Keyword.new(kw.keyword.gsub(price_regex[0], '').gsub(' x ', '').gsub(/\d+/, '').gsub(/\s+/, ' '), "exact")
      end

    end
    to_be_added.each do |kw|
      if kw.keyword.include? ','
        kw.keyword = kw.keyword.gsub(',','').gsub(/\s+/, ' ')
      end
      if kw.keyword.split.count > 10
        kw.keyword = kw.keyword.split[0..9].join(' ')
      end
    end

    return_array += to_be_added


    if return_array.each do |kw| 
      if kw.keyword.match /'|-|&/ 
        break 'y'
      end
    end == 'y'
    a = Marshal.load(Marshal.dump(return_array))
    b = Marshal.load(Marshal.dump(return_array))

    a = a.map {|i| i.keyword = i.keyword.gsub(/'/, " ").gsub(/-/, " ").gsub(/&/, " ").gsub(/\s+/, ' '); i}
    b = b.map {|i| i.keyword = i.keyword.gsub(/'/, "").gsub(/-/, "").gsub(/&/, "").gsub(/\s+/, ' '); i}

    return_array = return_array + a + b
    # p return_array
  end
  return_array.each do |kw|
    kw.keyword = kw.keyword.gsub(/[!,%]/, '').gsub('@', 'a').gsub(/\s+/, ' ').sub(/\s+$/, '')
  end
    return_array.uniq
end


#################################################################################################
#                                             CREATE ADS                                        #
#################################################################################################


def create_ads(adgroup)
    brand = adgroup.brand
    product = adgroup.product.gsub('Product || ', '')
    url = adgroup.destination_url
    price = ''
    product_without_brand = product.gsub(Regexp.new(brand, true),'').gsub('Product || ', '').gsub(/[\d\,]+(ml|kg|g|cl)/, '').gsub(/\s+/, ' ').gsub(/[\(|\)]/, '').gsub(/^\s+/, '').gsub(/\s+$/, '')

    if adgroup.price.class == Float
       price = sprintf('%.2f', adgroup.price).to_s
    else
      price = '___________________________________'
    end
    if price[-3..-1] == '.00'
      price[-3..-1] = ''
    end
    ad_template = AD_TEMPLATE.map do |rows|
      rows.map do |cell|
        if cell

          clever_price = (@currency_symbol+price).gsub(/kr(\d+)\.(\d+)/, ("kr" + '\1' + ',' + '\2'))
          cell = cell.gsub('PRODUCT_WITHOUT_BRAND', product_without_brand).gsub('BRAND', brand).gsub('PRODUCT', product).gsub('PRICE', clever_price).gsub('URL', url).gsub('SITE', @site).gsub(/\s+/, ' ')
        end
        cell
      end
    end
    a=ad_template
    ads = []

  get_row_count = lambda {|variation, ad_number| (((variation-1)*3)+(ad_number-1)%3)+1}
  (1..3).each do |ad_number|
    headline, description_line1, descriptionline_2, display_url = nil
  ad_contents = {
  :headline => nil,
  :description_line1 => nil,
  :description_line2 => nil,
  :display_url => nil
  }
  ad_contents.each do |key, value|
    column_number = TEMPLATE_COLUMNS[key]
    variation = 1
    while ad_contents[key] == nil
          specific_row = ad_template[get_row_count.call(variation, ad_number)]
          if column_number == nil
          end
          if key == :headline
            if specific_row[column_number].length > 25
            else 
              ad_contents[key] = specific_row[column_number]
            end
          else
            if specific_row[column_number].length > 35
            else 
              ad_contents[key] = specific_row[column_number]
            end
          end
          variation = variation+1
          break if variation > 6
        end
  end
  ads << ad_contents
  end
  ads.each do |ad|
    if ad[:display_url] && ad[:display_url].class == String
      ad[:display_url] = ad[:display_url].gsub(' ', '-').gsub('@', 'a')
    end
  end
  ads
end


#################################################################################################
#                                    DUPLICATE BROAD TO EXACT                                   #
#################################################################################################


def duplicate_em_to_bmm

mega_list_of_adgroups_broad = Marshal.load(Marshal.dump(@mega_list_of_adgroups_exact))

mega_list_of_adgroups_broad.each do |broad_adgroup|
  broad_adgroup.campaign = broad_adgroup.campaign.sub(/EM$/, 'BMM')
  negative_keywords = []
  broad_adgroup.keywords.each do |kw|
    neg_kw = kw.dup
    neg_kw.match_type = 'negative exact'
    negative_keywords << neg_kw
    kw.match_type = 'broad'
    kw.keyword = "+#{kw.keyword.gsub(' ', ' +')}"
  end
  broad_adgroup.keywords += negative_keywords
end

mega_list_of_adgroups = @mega_list_of_adgroups_exact | mega_list_of_adgroups_broad#
mega_list_of_adgroups.each do |adgroup|

  adgroup.campaign.sub!(/___________________________________/,'')
  adgroup.adgroup_name.sub!(/___________________________________/,'')
  if @N1_N2_is_enabled
    adgroup.adgroup_name = adgroup.adgroup_name + " || N1"
  end

  unless adgroup.destination_url.include? "affil=tag"
    if adgroup.destination_url.include? "?" 
      adgroup.destination_url+="&affil=tag" 
    else
      adgroup.destination_url+="?affil=tag"
    end
  end

  adgroup.keywords.each do |i| 
    i.keyword.sub!(/\+core___________________________________/,'') 
    i.keyword.sub!(/core___________________________________/,'')
    i.keyword.sub!(/\s*/, '')
    i.keyword.sub!(/\+ \+/, '+')
    i.keyword.sub!(/\s+$/, '')
 end
end

mega_list_of_adgroups.each do |adgroup|
    adgroup.to_row(@csv_array)
end

@csv_array.uniq!
end


#################################################################################################
#                                     CREATE AD-LEVEL SETTINGS                                  #
#################################################################################################


def create_ad_level_settings
  adgroups = @csv_array.map {|i| [i[0], i[1], i[8]]}.uniq.reject{|i| i[2] == '' }
  adgroups.each do |adgroup|
  campaign = adgroup[0]
  adgroup_name = adgroup[1]
  destination_url = adgroup[2]


  ### CREATE ADGROUPS
  ### Starting with N1 
    new_adgroup = adgroup.dup
#SETTINGS FOR BIDS
    adgroup_array = Array.new(15){''}
    adgroup_array[0] = campaign
    adgroup_array[1] = adgroup_name
    adgroup_array[11] = campaign.include?('BMM') ?  @broad_match_bid : @exact_match_bid 
    # adgroup_array[12] = @masterlist

    @csv_array << adgroup_array

#SETTINGS FOR MASTERLIST
    @masterlist.each do |audience_list|
      adgroup_array = Array.new(17){''}
      adgroup_array[0] = campaign
      adgroup_array[1] = adgroup_name
      adgroup_array[12] = audience_list[0]
      adgroup_array[17] = audience_list[1]

      @csv_array << adgroup_array
    end

  end
end


#################################################################################################
#                                          CREATE SETTINGS                                      #
#################################################################################################

def create_campaign_and_location_settings
  campaigns = @csv_array.map {|i| i[0]}.uniq
  campaigns.each do |campaign|
    campaign_settings = Array.new(17) {''}
    campaign_settings[0] = campaign
    campaign_settings[9] = @campaign_budget
    campaign_settings[10] = @network
    campaign_settings[15] = @language
    campaign_settings[17] = @bid_adjustment
   @csv_array << campaign_settings

  @locations.each do |location|
    locations_array = Array.new(17) {''}
    locations_array[0] = campaign
    locations_array[16] = location
    @csv_array << locations_array
    end
  end
end


#################################################################################################
#                                         DUPLICATE N1 / R1                                     #
#################################################################################################
def duplicate_n1_r1
  # start as N1 then get transformed into R1
  r1 = []
  @csv_array.each do |i|
    campaign = i.dup
    campaign[1] = campaign[1].sub(/N1/, 'R1')
    campaign[13] = ''
    if campaign[11].class == (Float || Fixnum)
      campaign[11] = campaign[11] * @N1_N2_bid_modifier ############## THIS IS THE MODIFIER TO SHOW R1 Vs N1 CPC
    end
    # i[12] = ''  #recently changed....
    if i[1].include? 'Core'
    # if campaign.compact.select{|n1| n1.to_s.length > 0 }.count > 2 #counting the number of items in array to discard any with just campaign & adgroup.
      r1 << campaign
    else
      i[1].sub!(' || N1', '')
    end
    # end
  end
  @csv_array += r1

  @csv_array.delete_if{|i| i.compact.select{|n1| n1.to_s.length > 1 }.count <= 2}

end

#################################################################################################
#                                            SITELINKS                                          #
#################################################################################################


def deal_with_sitelinks
  ### CREATE SITELINKS
  adgroups = @csv_array.map {|i| [i[0], i[1], i[8], i[5], i[6]]}.uniq.reject{|i| i[2] == '' }
  sitelinks = []
  adgroups.each do |adgroup|
    campaign = adgroup[0]
    adgroup_name = adgroup[1]
    destination_url = adgroup[2]
    description_line1 = adgroup[3]
    description_line2 = adgroup[4]


    sitelinks_array = Array.new(15){''}
    sitelinks_array[0] = campaign
    sitelinks_array[14] = adgroup_name.match(/([^\|]*)$/)[1]#[1..-1] #adgroup_name.sub('N1 || ','') # this is our sitelink text
    sitelinks_array[8] = destination_url
    sitelinks_array[5] = description_line1
    sitelinks_array[6] = description_line2

    unless (sitelinks_array[14] == 'Core' || sitelinks_array[14].length > 25)
      sitelinks << sitelinks_array
    end
  end

  sitelinks.reject!{|i| i[6]==(''||nil)}

  sitelinks.reject!{|i| i[14] && i[14].class==String && (i[14].include?('Core') || i[14].include?('All') || i[14].include?('R1') || i[14].include?('N1'))}
  sitelinks.uniq!{|i| [i[0] , i[14]]}

  sitelinks = sitelinks.map do |link|

    link.map do |i|
      if i.class == String
        i.gsub('{param1:','').gsub('}', '')
      else
        ''
      end
    end
  end

campaigns = {}
  sitelinks.each do |sitelink|
     campaigns[sitelink[0]] ||= []
     campaigns[sitelink[0]] << sitelink
  end

  campaigns.keys.each do |key|
    campaigns[key].sample(20).each do |slink|
      @csv_array << slink
    end
  end


  # sitelinks.each do |i|
  #   @csv_array << i
  # end

end


# 0 = Campaign
# 1 = Ad Group
# 2 = Keyword
# 3 = Criterion Type
# 4 = Headline
# 5 = Description Line 1
# 6 = Description Line 2
# 7 = Display URL
# 8 = Destination URL
# 9 = Campaign Budget
# 10 = Networks
# 11 = Max CPC
# 12 = Audience
# 13 = Negative Audience
# 14 = Sitelink Text
# 15 = Language
# 16 = Location 


def remove_duplicates
  @csv_array.uniq!
end


def save_to_output_array
  @csv_array.each do |i|
    @output_array << i
  end
end


def sort_everything
  @output_array.sort_by!{|a| [  (a[9]||''), (a[16]||''), (a[11].to_s||''), (a[12].to_s||'')  ]}.reverse!   ## This is a sort. Needed
end
#################################################################################################
#                            PARAMETER OUTPUT (FOR GDOC)                                        #
#################################################################################################

def output_parameters
  # This outputs a 'parameter' csv which only contains the campaigns / adgroups of PRODUCTS (with a product dest-url)
  params_array = []
  @csv_array.each do |i|
    headline_has_price = i[4] && i[4].class == String && i[4].include?(@currency_symbol)
    desc_line_1_has_price = i[5] && i[5].class == String && i[5].include?(@currency_symbol)
    desc_line_2_has_price = i[6] && i[6].class == String && i[6].include?(@currency_symbol)
    product_has_dest_url = i[8] && i[8].class == String && i[8].scan(/\d{8}/).any?

    if (headline_has_price || desc_line_1_has_price || desc_line_2_has_price ) && product_has_dest_url
      params_array << [i[0], i[1], i[8]] 
    end
  end

  ############### CAMPAIGNS ON TOP ####################
  # @csv_array.sort_by!{|a| [  (a[9]||''), (a[16]||''), (a[11].to_s||''), (a[12].to_s||'')  ]}.reverse!   ## This is a sort. Needed

  ######### OUTPUT A LIST OF CAMPIAGNS ADGROUPS & DESTINATION URLS
  params_array.uniq!
  if params_array
    params_array.select!{|i| i[1] && i[1].class == String && i[1].length > 0}
  end
  params_array
  # CSV.open('GOOGLE_DOC_PARAMS_OUTPUT.csv', 'wb') do |meh|

  #   params_array.each do |param|
  #     meh << param
  #   end
  # end
end



#################################################################################################
#                                   WRITING TO .XLS FILE                                       #
#################################################################################################

def write_to_excel
  if @output_array.count == 0
    abort ["It's not your fault.", "Try again.", "Stop being stupid.", "Now try getting it right.", "OMG! OH NOES!", "Nope."].sample
  end

  parameters = output_parameters
  begin

  book = Spreadsheet::Workbook.new
  main_output_sheet = book.create_worksheet name: 'Adwords'
  params_sheet = book.create_worksheet name: 'Parameters for GDoc'

  @output_array.each_with_index do  |row, index|
    if index==0
      main_output_sheet.row(0).replace ["Campaign", "Ad Group", "Keyword", "Criterion Type", "Headline", "Description Line 1", "Description Line 2", "Display URL", "Destination URL", "Campaign Budget", "Networks", 'Max CPC', 'Audience', 'Negative Audience', 'Sitelink Text', 'Language', 'Location', 'Bid Adjustment']
    end
    main_output_sheet.row(index + 1).replace row
  end

  parameters.each_with_index do |param, index|
    unless index == 0
      params_sheet.row(index + 1).replace param
    end
  end


  book.write "ADWORDS_EDITOR_OUTPUT.xls"

  rescue => e
    # p e
  book.write "OUTPUT2.xls"
  abort "\n\n\nFAILED:  Please close the excel file. \n\nTa\n\nWe've managed to heroicly rescue the data. It's in 'OUTPUT2.xls'\n\n You're welcome. \n\n"

  end


  p "                             "
  p "                             "
  p "                             "
  p "     All Finished!           "
  p "                             "       
  p "                             "       
  p "                             "       
  p "            _                "                     
  p "           /(|               "                     
  p "          (  :               "                     
  p '         __\ \   _____     '                             
  p "       (____)  `|            "                         
  p "      (____)|   |            "                         
  p "       (____).__|            "                         
  p "        (___)__.|_____       "                             
  p "                             "       
  p "                             "       
  p "                             "       

end


#################################################################################################
#                                       XLS COLUMN KEY                                          #
#################################################################################################



# 0 = Campaign
# 1 = Ad Group
# 2 = Keyword
# 3 = Criterion Type
# 4 = Headline
# 5 = Description Line 1
# 6 = Description Line 2
# 7 = Display URL
# 8 = Destination URL
# 9 = Campaign Budget
# 10 = Networks
# 11 = Max CPC
# 12 = Audience
# 13 = Negative Audience
# 14 = Sitelink Text
# 15 = Language
# 16 = Location
# 17 = Bid Adjustment


def main_method
  start___scrape_site
  #??????????????????????????????????????
  # p @list_of_brands
  if @using_product_feed && @list_of_brands.any?
    # get_product_feed_from_google_doc                       #comment this line out if it goes mental.
    get_product_feed_from_csv
    add_products_from_product_feed         #comment this line out if it goes mental.
  end
  #??????????????????????????????????????
  
  iterate_over_brands
  duplicate_em_to_bmm
  create_ad_level_settings
  duplicate_n1_r1
  create_campaign_and_location_settings
  deal_with_sitelinks
  output_parameters
  remove_duplicates
  save_to_output_array

  @mega_list_of_adgroups_exact = []
  @data = []
end



#################################################################################################
#                                  ACTUALLY RUN THE METHODS                                     #
#################################################################################################
# @list_of_brands

def main

  start___deal_with_argument_parameters


  sort_everything
  @output_array.uniq!

  p ''
  p ''  
  p 'Writing to Excel'

  write_to_excel

end






main


__END__


    TO DO:
      # N1 / N2
      # Adgroup Max CPC
      # Sitelinks
      # Location settings
      # Language settings
      # New Adgroup Naming Convention based on the URL
      # Audiences at the campaign level are negative audiences   <== doesn't work. We split at the adgroup level.
      # KW level destination URL
      # Put Parameter doc to different tab of the spreadsheet 
      # Get ordering right (campaign settings, campaign location, adgroup settings, rest.)
      #fix destination urls -- append currency url 
      #N1 and R1 only for Core camapaigns
      #target & bid for Returning Adgroups
      #Get Display URLs gsubbing ' ' with '-'
      #Only choose the top 20 sitelinks 
      #Stop there being a hyphen between brand names (eg. St-Tropez)
      #get sizes effectively gsubbed out of kws 
      #remove commas from kws. also @ signs
      #Core || N1 rather than the other way around
      #Audinece list for bb / cc (dynamic smart pixel doesnt' work...)
      #KW max size = 10 words
      #REMOVE N1 & R1 From Sitelinks.
      #kw % signs. Remove them

      duplicate keywords 
      duplicate ads
      sitelinks = dont't have N1 / R1


      add audience lists to every adgroup

      remove any brand name from adgroup name


      'Dynamic Smart Pixel' && 'Converters 180 Days'

