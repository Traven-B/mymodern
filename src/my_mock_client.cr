# mock two methods in HTTP::Client -- post(), get()

class MyMockClient
  @@filename_for = {} of String => String

  def self.setup
    MODULE_NAMES.each do |m|
      the_params = m.lib_data
      @@filename_for[the_params[:checked_out_url]] = the_params[:checked_out_fixture]
      @@filename_for[the_params[:holds_url]] = the_params[:holds_fixture]
    end
    self
  end

  def self.post(url, form)
    # always send same post response
    Fiber.yield
    HTTP::Client::Response.new(200, "post page")
  end

  def self.get(url, headers)
    # given the get url parameter as key, look up the filename of the web page
    file_name_of_page = @@filename_for[url]
    absolute_path = File.join(__DIR__, "../spec/fixtures/#{file_name_of_page}")
    page_string = File.read(absolute_path)
    Fiber.yield
    HTTP::Client::Response.new(200, page_string)
  end
end
