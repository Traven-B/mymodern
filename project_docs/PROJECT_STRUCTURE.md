# mymodern is somewhat modular

You set up to scrape one or two libraries' websites by writing Crystal code.

The code that calls upon your code doesn't really care about how many modules you've supplied or what you named them.

# hennepin.cr

Supply a file like this for each library website you want to do. You implement these 3 methods.

```
module Hennepin
  def self.lib_data
    # returns data in the form of a NamedTuple

  def self.parse_checkedout_page(page)
    # return a sorted array of CheckedOutRecord
    # uses already existing record and comparison definitions

  def self.parse_on_hold_page(page)
    # return a sorted array of OnHoldRecord
```
And whatever other helpers to use when parsing the web pages.

# The lib_data method.

The {}'s and what's inside them is a named tuple that the method returns. The method name and keys are the same in another library's module, the values are specific to Hennepin.

```
def self.lib_data
  {
    post_data:           HennepinSecrets::POST_DATA,
    post_url:            HENN_BASE_URL + "/user/login?destination=%2F",
    checked_out_url:     HENN_BASE_URL + "/v2/checkedout",
    holds_url:           HENN_BASE_URL + "/v2/holds/ready_for_pickup",
    print_name:          "Hennepin",
    checked_out_fixture: "h_c_v2.html",
    holds_fixture:       "h_h_v2.html",
    trace_name:          "Hennepin",
  }
end
```

## The first four properties of the lib_data method.

```
post_data:           HennepinSecrets::POST_DATA,
post_url:            HENN_BASE_URL + "/user/login?destination=%2F",
checked_out_url:     HENN_BASE_URL + "/v2/checkedout",
holds_url:           HENN_BASE_URL + "/v2/holds/ready_for_pickup",
```

Already existing code uses the lib_data information to post the 'post_data' to the 'post_url', and then get the pages at the 'checked_out_url' and 'holds_url'.

```
login_response =
  @@http_client.post(data_param[:post_url], form: data_param[:post_data])

the_response =
  @@http_client.get(the_url, cookie_headers)
```

# In hennepin_secrets.cr

```
module Hennepin
  HennepinSecrets::POST_DATA = "card_number=12345234534567&user_pin=4321"
end
```

Part of the hennepin module is defined in hennepin_secrets.cr, so the library card number and secret pin are in a separate file, as a first idea for keeping them secret.

The string is the login form information for a form with fields named card_number and user_pin.

The string is sent as is, when supplied as an argument to an already written post request.

```
login_response = @@http_client.post(
    data_param[:post_url], form: data_param[:post_data])
```

## Specifying POST_DATA constant

```
module Hennepin
  HennepinSecrets::POST_DATA = "card_number=12345234534567&user_pin=4321"
end
```
The card_number and user_pin in the above string are values of name attributes of input tags in the website's login form shown below.

```
<form action=
"https://thelibrary.com/user/login?destination="
method="post">
  <input name="card_number" type="text">
  <input name="user_pin"    type="password" value="">
  <input name="commit"      type="submit"   title="Log In">
```

## The Hennepin module

```
module Hennepin  # hennepin_secrets.cr file
  HennepinSecrets::POST_DATA = "card_number=12345234534567&user_pin=4321"
end
```

HennepinSecrets::POST_DATA is mentioned in the more complete definition of the hennepin module in the hennepin.cr file.

```
module Hennepin   # hennepin.cr file
  def self.lib_data
    {
      post_data:     HennepinSecrets::POST_DATA,
      etc, etc...
```

## Specifying post_url: value

```
<form action=
"https://thelibrary.com/user/login?destination="
method="post">
  <input name="card_number" type="text">
  <input name="user_pin"    type="password" value="">
  <input name="commit"      type="submit"   title="Log In">
```

The url we post to seems to be the url of the login page or we should say is the value of the action attribute of the form tag or the formaction attribute of the input tag with type="submit" or a button with a formaction.

## The next four properties of the lib_data method.

Besides the post_data and 3 url's in the lib_data method we have

```
def self.lib_data
  {
    ...
    print_name:          "Hennepin",
    checked_out_fixture: "h_c_v2.html",
    holds_fixture:       "h_h_v2.html",
    trace_name:          "Hennepin",
  }
end
```

## lib_data print_name:

```
print_name: "The Municipal Library of Kalamazoo Michigan"
```

How you want the library's name to appear in the report.

```
The Municipal Library of Kalamazoo Michigan Books Out

The Astronomer
Tuesday December 04, 2018

The Municipal Library of Kalamazoo Michigan Books on Hold

A History of America in Ten Strikes
Wednesday November 14, 2018
```

## lib_data fixtures

```
checked_out_fixture: "h_c_v2.html",
holds_fixture:       "h_h_v2.html",
```

Given the '- -mock' option, the program gets webpages from the disk instead of the internet.

When you write the parse checkedout page and parse on hold page methods, you will probably get the pages in your web browser, save them, and puzzle it out.

This program still has code that refers to the web pages you should (still) have on disk.

## lib_data fixtures

```
checked_out_fixture: "h_c_v2.html",
holds_fixture:       "h_h_v2.html",
```

The name of the checked out books web page is the value for the checked_out_fixture key.

And the name of the on hold web page on disk, h_h_v2.html in this example, is the value for the holds_fixture key.

When you supply the '- -mock' option when you run the program, the program uses a mock http client that associates urls that get web pages with files on the disk.

This is done for you in my_mock_client.cr. The only part that is somewhat hard coded is the directory path to the webpages. Put your pages where the already existing ones are.

# lib_data trace_name:

```
trace_name:          "Hennepin",
```

Given the '- -trace' option, the program prints trace messages that demonstrate concurrency when fetching web pages. This value represents the name of the library in the trace messages.

```
0.021  :  fetch_pair : doing post for Hennepin
0.242  :  fetch_pair : doing post for StPaul
2.067  :  fetch_pair : done with post for StPaul
```

# The parse methods

Each of the one or two or three modules for the one or two or three libraries we are scraping not only need a

```
def self.lib_data
```

method, but also this pair of methods

```
def self.parse_checkedout_page(page)

def self.parse_on_hold_page(page)
```


# The parse methods

Once you've found the parts of the pages that represent the sequence of books in the webpages, just look at the example code.

The two libraries I'm doing have top level parse_checkedout_page(page) methods differing only in their css selector rules, one page has books inside of divs, the other uses table rows.

```
books_out = doc.css("div.cp-checked-out-item").to_a.map do |book_part|
# versus
books_out = doc.css("table tr.patFuncEntry").to_a.map do |book_part|
```

# a variation on the high level routine

The St. Paul parse_on_hold_page method has a conditional to test for books whose hold status is Ready. (see next slide for comments)

```
def self.parse_on_hold_page(page)
  doc = Myhtml::Parser.new(page)
  books_on_hold =
  doc.css("table tr.patFuncEntry").to_a.compact_map do |book_part|
    td_status = book_part.css("td.patFuncStatus").first
    status = td_status.inner_text.strip
    if status.match(/^Ready/)
      the_title = find_on_hold_title(book_part)
      the_date = find_on_hold_date(status)
      OnHoldRecord.new(the_title, the_date)
    end
  end
  books_on_hold.sort { |a, b| Recs.holds_compare(a, b) }
end
```

# a variation continued

```
For on hold books, status might be
          <td class="patFuncStatus"> 16 of 19 holds </td>
We want to select only those like
          <td class="patFuncStatus"> Ready. Must pick up by 10-25-16 </td>
if generates a record when status.match(/^Ready/) is true,
otherwise the if statement produces nil.
compact_map removes nils,
then maps the non-nil elements by evaluating the block
This allows operating only on book_parts that matched /^Ready/

def self.parse_on_hold_page(page)
  doc = Myhtml::Parser.new(page)
  books_on_hold =
  doc.css("table tr.patFuncEntry").to_a.compact_map do |book_part|
    td_status = book_part.css("td.patFuncStatus").first
    status = td_status.inner_text.strip
    if status.match(/^Ready/)
      the_title = find_on_hold_title(book_part)
      the_date = find_on_hold_date(status)
      OnHoldRecord.new(the_title, the_date)
    end
  end
  books_on_hold.sort { |a, b| Recs.holds_compare(a, b) }
end
```

# Development

The program calls upon identically named methods provided by one or another library's module.

```
module Hennepin
  def self.lib_data
    # return a NamedTuple

  def self.parse_checkedout_page(page)
    # return a sorted array of CheckedOutRecord
    # the record and comparison definitions are done elsewhere

  def self.parse_on_hold_page(page)
    # return a sorted array of OnHoldRecord
```

# Development

```
require "./hennepin"
require "./hennepin_secrets"
require "./stpaul"
require "./stpaul_secrets"

MODULE_NAMES = [Hennepin, StPaul]
```

Code for another library where you're a regular patron would provide the same, and parts of the program that invoke these methods iterate over an array of the module names, and don't hard code the number or names of the modules.

# Development

```
require "./hennepin"
require "./hennepin_secrets"
require "./stpaul"
require "./stpaul_secrets"

MODULE_NAMES = [Hennepin, StPaul]
```

You can adapt the modules that define these few methods, name them Springfield and Shelbyville, and require them from a single file which also lists them in an array of module names.

# Development

```
require "./hennepin"
require "./hennepin_secrets"
require "./stpaul"
require "./stpaul_secrets"

MODULE_NAMES = [Hennepin, StPaul]
```

The file with content similar to the above must be named 'module_names.cr'

# Development

The already written code has the aforementioned file name in its list of required files.

```
require "http/client"
require "myhtml"
require "./record_types"
require "./print"
require "./my_mock_client"

require "./module_names"
```

# Development

In module_names.cr the constant naming the array appears in the already written code.

```
MODULE_NAMES = [Hennepin, StPaul]
```

```
  def self.concurrent_network_part
    the_channels = MODULE_NAMES.map do |a_module|
      the_channel = PagesChannel.new
      the_params = a_module.lib_data
      spawn fetch_pair(the_channel, the_params)
      {the_channel, a_module}
    end
    # etc
  end
```

# Development

So this program can be used to scrape web pages at 1, 2, or 3 libraries, and all things being equal, runs in constant time no matter how many you're doing.*\\n

\* Because concurrency.

# here's a picture of a bunny with a pancake on it's head

![](dorayaki_259_320-f6d17158.jpg)
