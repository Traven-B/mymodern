require "./method_name_macro"
require "http/client"
require "lexbor"
require "./record_types"
require "./print"
require "./my_mock_client"
require "./module_names"

module MyModern
  include T

  alias Webpage = String
  alias PagesChannel = Channel({checked_out: Webpage, on_hold: Webpage})
  alias ClientUnion = (HTTP::Client.class | MyMockClient.class)

  def self.setup(@@http_client : ClientUnion = HTTP::Client)
    self
  end

  def self.run
    result_pages = concurrent_network_part
    parse_and_print(result_pages)
  end

  def self.concurrent_network_part
    the_channels = MODULE_NAMES.map do |a_module|
      the_channel = PagesChannel.new
      the_params = a_module.lib_data
      spawn fetch_pair(the_channel, the_params)
      {the_channel, a_module}
    end

    result_pages = the_channels.map do |channel_module_pair|
      pages_channel, a_module = channel_module_pair
      fetched_pair_of_pages = pages_channel.receive # => {checked_out: String, on_hold: String}
      {fetched_pair_of_pages, a_module}             # .map's to an array in MODULE_NAMES order, which is order we print results
    end
    # return array of {{checked_out: String, on_hold: String}, Springfield:Module | Shelbyville:Module}
    result_pages
  end

  def self.fetch_pair(pair_of_webpage_results_channel, data_param)
    library_name = data_param[:trace_name]; dt "doing post for #{library_name}"

    # post login information, get cookies back in response header
    login_response = @@http_client.not_nil!.post(data_param[:post_url], form: data_param[:post_data])

    dt "done with post for #{library_name}" # if we used mock client, it did a Fiber.yield

    # set cookie_headers
    cookie_headers = HTTP::Headers.new
    cookies = login_response.cookies
    cookies.add_request_headers(cookie_headers)

    # create a channel for each page
    checked_out_webpage_channel = Channel(Webpage).new
    on_hold_webpage_channel = Channel(Webpage).new

    # Spawn
    spawn get_page(checked_out_webpage_channel, cookie_headers, data_param[:checked_out_url], "#{library_name} checked out")
    spawn get_page(on_hold_webpage_channel, cookie_headers, data_param[:holds_url], "#{library_name} on hold")

    # Receive
    checked_out_page = checked_out_webpage_channel.receive
    on_hold_page = on_hold_webpage_channel.receive

    dt "after both receives for #{library_name}"

    # Send
    pair_of_webpage_results_channel.send(
      {checked_out: checked_out_page, on_hold: on_hold_page})

    dt "after sending pair for #{library_name} *"
  end

  def self.get_page(webpage_result_channel, cookie_headers, the_url, extra)
    dt "before get #{extra}" # extra is trace string saying "library_name web_page_type"

    # Fetch a single page concurrently
    the_response = @@http_client.not_nil!.get(the_url, cookie_headers)

    dt "after get #{extra}" # if we used mock client, it did a Fiber.yield

    # Send the result on the corresponding channel
    webpage_result_channel.send the_response.body

    dt "after send #{extra} *"
  end

  def self.parse_and_print(result_pages)
    result_pages.each do |pages_module_pair|
      # block parameter is {{checked_out: String, on_hold: String}, Springfield:Module | Shelbyville:Module}
      pages, a_module = pages_module_pair
      checkedout = a_module.parse_checkedout_page(pages[:checked_out])
      holds = a_module.parse_on_hold_page(pages[:on_hold])
      if !T.trace? # if we're not emitting trace messages print the results
        print_name = a_module.lib_data[:print_name]
        Print.print_checked_out_books(checkedout, print_name)
        Print.print_books_on_hold(holds, print_name)
      end
    end
  end
end
