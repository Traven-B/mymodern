# mymodern Project Structure

mymodern is somewhat modular. You set up to scrape one or two libraries' websites by writing Crystal code. The code that calls upon your code doesn't really care about how many modules you've supplied or what you named them.

## Library Module Structure

Supply a file like this for each library website you want to scrape. You implement these 3 methods:

```crystal
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

### The lib_data method

The {}'s and what's inside them is a named tuple that the method returns. The method name and keys are the same in another library's module, the values are specific to Hennepin.

```crystal
def self.lib_data
  {
    post_data: POST_DATA,
    post_url: HENN_BASE_URL + "/user/login?destination=%2F",
    checked_out_url: HENN_BASE_URL + "/v2/checkedout",
    holds_url: HENN_BASE_URL + "/v2/holds/ready_for_pickup",
    print_name: "Hennepin",
    checked_out_fixture: "h_c_v2.html",
    holds_fixture: "h_h_v2.html",
    trace_name: "Hennepin",
  }
end
```

#### Key properties of the lib_data method

```crystal
post_data: POST_DATA,
post_url: HENN_BASE_URL + "/user/login?destination=%2F",
checked_out_url: HENN_BASE_URL + "/v2/checkedout",
holds_url: HENN_BASE_URL + "/v2/holds/ready_for_pickup",
```

Already existing code uses the lib_data information to post the 'post_data' to the 'post_url', and then get the pages at the 'checked_out_url' and 'holds_url'.

```crystal
login_response = @@http_client.post(data_param[:post_url], form: data_param[:post_data])
spawn get_page(checked_out_webpage_channel, cookie_headers, data_param[:checked_out_url], "#{library_name} checked out")
spawn get_page(on_hold_webpage_channel, cookie_headers, data_param[:holds_url], "#{library_name} on hold")
```

## Secrets Management

### In hennepin_secrets.cr

```crystal
module Hennepin
  POST_DATA = "card_number=12345234534567&user_pin=4321"
end
```

Part of the hennepin module is defined in hennepin_secrets.cr, so the library card number and secret pin are in a separate file, as a first idea for keeping them secret. The string is the login form information for a form with fields named card_number and user_pin. The string is sent as is, when supplied as an argument to an already written post request.

```crystal
login_response = @@http_client.post(
  data_param[:post_url],
  form: data_param[:post_data]
)
```

### Specifying POST_DATA constant

The `POST_DATA` constant is defined with the library card number and PIN:

```crystal
module Hennepin
  POST_DATA = "card_number=12345234534567&user_pin=4321"
end
```

The card_number and user_pin in the above string correspond to the `name` attributes of input tags in the library's login form:

```html
<form action="https://thelibrary.com/user/login?destination=" method="post">
  <input name="card_number" type="text">
  <input name="user_pin"    type="password" value="">
  <input name="commit"      type="submit"   title="Log In">
</form>
```

## Module Structure

### The Hennepin module spans 2 files

1. In `hennepin_secrets.cr`:
   ```crystal
   module Hennepin
     POST_DATA = "card_number=12345234534567&user_pin=4321"
   end
   ```

2. In `hennepin.cr`:
   ```crystal
   module Hennepin
     def self.lib_data
       {
         post_data: POST_DATA,
         # ... other properties
       }
     end
   end
   ```

The constant POST_DATA is defined in hennepin_secrets.cr and is used in the the
otherwise complete definition of the hennepin module in the hennepin.cr file.

### Specifying post_url value

The `post_url` value in `lib_data` should match the `action` attribute of the login form:

```html
<form action="https://thelibrary.com/user/login?destination=" method="post">
  <!-- form inputs -->
</form>
```

Or we should say is the value of the action attribute of the form tag or the formaction attribute of the input tag with type="submit" or a button with a formaction.

## Additional lib_data Properties

### Print Name

```crystal
print_name: "The Municipal Library of Kalamazoo Michigan"
```

This property determines how the library's name appears in the report:

```
The Municipal Library of Kalamazoo Michigan Books Out

The Astronomer
Tuesday December 04, 2018

The Municipal Library of Kalamazoo Michigan Books on Hold

A History of America in Ten Strikes
Wednesday November 14, 2018
```

### Fixtures for Testing

```crystal
checked_out_fixture: "h_c_v2.html",
holds_fixture:       "h_h_v2.html",
```

These properties specify the names of HTML files used for testing with the `--mock` option. The program uses these local files instead of fetching from the internet.

Here, h_c_v2.html and h_h_v2.html name the checked out books web page, and the on hold web page on disk.

Put your pages where the already existing ones are. (or look in
my_mock_client.cr to see the path name, and admire how cleverly we associate
the URL's with the fixtures)

### Trace Name

```crystal
trace_name: "Hennepin",
```

This property is used in trace messages when the `--trace` option is provided, demonstrating concurrency in web page fetching:

```
0.021  :  fetch_pair : doing post for Hennepin
0.242  :  fetch_pair : doing post for StPaul
2.067  :  fetch_pair : done with post for StPaul
```

Choose a short name to represent the name of the library in the messages.

## Parsing Methods

Each library module requires three key methods:

1. `self.lib_data`
2. `self.parse_checkedout_page(page)`
3. `self.parse_on_hold_page(page)`

Let's examine the parse methods.

### parse_checkedout_page Method

This method parses the checked-out books page:

```crystal
def self.parse_checkedout_page(page)
  doc = Myhtml::Parser.new(page)
  books_out = doc.css("div.cp-checked-out-item").to_a.map do |book_part|
    # Parse book information
  end
  # Sort and return books_out
end
```

It might be the top level parse method for one kind of page differs from another library's  only in its CSS selector rule.
Below we see `table` in a parse_checkedout_page method, above we see `div`.

```crystal
books_out = doc.css("table tr.patFuncEntry").to_a.map do |book_part|
  # Parse book information
end
```

### parse_on_hold_page Method

The following top level method to parse an on hold page is not used with a URL to ask for a page with
only books on hold that are ready for pickup, nor does it have class attributes that mark
books as ready for pickup.

So we have a conditional to test actual text in the page for books whose hold status is Ready.
When the `if status.match(/^Ready/)` succeeds, then creation of a hold record is the last statement evaluated by the if,
and is also the last thing evaluated by the block, and so the record is mapped into the array being
constructed and eventually assigned to books_on_hold.

When the if test fails because a book is not `Ready`, it actually produces a nil.
So we are mapping a sequence of OnHoldRecords and nils into an array.

doc.css(...) makes a sequence, but it doesn't respond to map, so we first make
it an array with `.to_a`. But note we say compact_map, not map. We could
.compact the array to remove the nils, but we can say .compact_map instead of
.map as another way to filter out the spurious nils.


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
  books_on_hold = doc.css("table tr.patFuncEntry").to_a.compact_map do |book_part|
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



## Integrating Your Changes

To make your specific library modules known to the existing code:

1. Create a file named `module_names.cr` with the following content:

   ```crystal
   require "./your_library"
   require "./your_library_secrets"
   require "./maybe_another_library"
   require "./maybe_another_library_secrets"

   MODULE_NAMES = [YourLibrary, AnotherLibrary]
   ```

   The trick is module_names.cr and MODULE_NAMES are spelled exactly as shown.

2. The main program already includes this file:

   ```crystal
   require "http/client"
   require "myhtml"
   require "./record_types"
   require "./print"
   require "./my_mock_client"

   require "./module_names"
   ```

3. The program uses the `MODULE_NAMES` constant to work with the libraries you've defined:

   ```crystal
   def self.concurrent_network_part
     the_channels = MODULE_NAMES.map do |a_module|
       the_channel = PagesChannel.new
       the_params = a_module.lib_data
       spawn fetch_pair(the_channel, the_params)
       {the_channel, a_module}
     end
     # Additional processing
   end
   ```

## Development Process

1. Implement the required methods for each library module:
   - `self.lib_data`
   - `self.parse_checkedout_page(page)`
   - `self.parse_on_hold_page(page)`

2. Add your library modules to `module_names.cr`.

3. The existing code handles HTTP requests, concurrent processing, and overall program flow.

4. Your code focuses on parsing the library web pages.

5. You also provide login data to post, a URL to post to, and two URL's that return the pages we want.
   And, 2 examples of the wanted pages, which are fixtures used by the program in mock mode.

## Conclusion

- The program is designed to work with multiple libraries concurrently.
- It runs in constant time regardless of the number of libraries, thanks to Crystal's concurrency features.
- Minimal changes to the codebase are required when adding new libraries.
- The main challenge is parsing the web pages for each specific library.
