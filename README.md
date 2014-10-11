# PPC Campaign Builder

This script gather information through scraping sites. It then uses this information to generate fully-fledged PPC campaigns.

The script is written in Ruby.

## Supported Fields

The fields that are generated are:

- Campaign
- Ad Group
- Keyword
- Criterion Type
- Headline
- Description Line 1
- Description Line 2
- Display URL
- Destination URL
- Campaign Budget
- Networks
- Max CPC
- Audience
- Negative Audience
- Sitelink Text
- Language
- Location 

### Adtext

The adtext is generated from a template which can either be online (Google Docs) or stored locally. 

### Product Feed

There is also an option to add information from a Product Feed. This can create product-specific adgroups, which are have very specific adtext & keywords.

### Countries

Countries have been integrated and there are several predefined countries which automatically set the right location, the right currency and the right language.

### Adwords

This is fully compatible with Adwords.

### Usage
    
Please Use this format:

   `ruby -----FileName ----   -Site-    -Country-        -Product(s)-`

   Eg.

    ruby campaign_builder.rb    aa        UK-US-SE       CoolBrand    AnotherBrand   YetAnother

To get the Brand CoolBrand from AA in the UK, US and Sweden. 

  Use the code '--without-product-feed' to also import from the product feed. Eg:

          ruby campaign_builder.rb    aa     UK-US-SE      CoolBrand  --without-product-feed

  Use either '--N1' or '--R1' to add two Core adgroups ('Core || N1' & 'Core || R1')

          ruby campaign_builder.rb    aa        UK-DK        CoolBrand   --R1

### Output

An excel file (.xls) is generated and is 100% ready to be uploaded to Adwords.

### To Do

There is documentation throughout the script and a TODO list showing features added & to be added.
