module Hennepin
  def self.lib_data
    {
      post_data:           POST_DATA, # constant defined in hennepin_secrets.cr, but must be named here also
      post_url:            HENN_BASE_URL + "/user/login?destination=%2F",
      checked_out_url:     HENN_BASE_URL + "/v2/checkedout",
      holds_url:           HENN_BASE_URL + "/v2/holds/ready_for_pickup",
      print_name:          "Hennepin",
      checked_out_fixture: "h_c_v2.html",
      holds_fixture:       "h_h_v2.html",
      trace_name:          "Hennepin",
    }
  end

  def self.parse_checkedout_page(page)
    doc = Lexbor::Parser.new(page)
    books_out = doc.css("div.cp-checked-out-item").to_a.map do |book_part|
      the_title = find_checkedout_title(book_part)
      the_date = find_checkedout_date(book_part)
      the_renewed_count = find_renewed_count(book_part)
      the_number_waiting = find_number_waiting(book_part)
      CheckedOutRecord.new(the_title, the_date, the_renewed_count, the_number_waiting)
    end
    # ##### no never mind ##### => books_out.sort_by { |a| Recs.create_checked_composite_key(a) }
    books_out.sort { |a, b| Recs.checked_compare(a, b) }
  end

  def self.parse_on_hold_page(page)
    doc = Lexbor::Parser.new(page)
    books_on_hold = doc.css("div.cp-bib-list-item.cp-hold-item.ready_for_pickup").to_a.map do |book_part|
      the_title = find_on_hold_title(book_part)
      the_date = find_on_hold_date(book_part)
      OnHoldRecord.new(the_title, the_date)
    end
    # ##### no never mind ##### => books_on_hold.sort_by { |a| Recs.create_holds_composite_key(a) }
    books_on_hold.sort { |a, b| Recs.holds_compare(a, b) }
  end

  HENN_BASE_URL = "https://hclib.bibliocommons.com"

  def self.find_checkedout_title(book_part)
    # <a><span class="title-content">Introducing Elixir</span>
    #   <span class="sr-only ">Introducing Elixir, Book</span></a>
    book_part.css("a span.title-content").first.inner_text
  end

  def self.find_checkedout_date(book_part)
    # <div class="cp-checked-out-due-on">
    #   <span>Due by <span class="cp-short-formatted-date">Nov 19, 2018</span></span></div>
    date_text =
      book_part.css("div.cp-checked-out-due-on span.cp-short-formatted-date").first.inner_text
    Time.parse(date_text, "%b %d, %Y", Time::Location.local)
  end

  def self.find_renewed_count(book_part)
    # old <div class="cp-renew-count">
    # old   <span>Renewed</span> <span>1 time</span></div>
    # now
    # <div class="cp-renew-count">Renewed 2 times</div>
    renewed_count_div = book_part.css("div.cp-renew-count").first? # Myhtml::Iterator.first? yields Myhtml::Node or Nil
    if renewed_count_div
      n_times_text = renewed_count_div.inner_text
    else
      n_times_text = "0 times"
    end
    n_times_text.match(/(\d+) times*/).not_nil![1].to_i
  end

  def self.find_number_waiting(book_part)
    # old <div class="cp-held-copies-count">
    # old  <span>1 person waiting</span></div>
    # now
    # <div class="cp-held-copies-count">27 people waiting</div>
    number_waiting_div = book_part.css("div.cp-held-copies-count").first? # Myhtml::Node or Nil
    if number_waiting_div
      n_people_waiting_text = number_waiting_div.inner_text
    else
      n_people_waiting_text = "0 people waiting"
    end
    n_people_waiting_text.match(/(\d+) (person|people) waiting/).not_nil![1].to_i
  end

  def self.find_on_hold_title(book_part)
    # <a><span class="title-content">A History of America in Ten Strikes</span>
    #   <span class="sr-only">A History of America in Ten Strikes, Book</span></a>
    book_part.css("a span.title-content").first.inner_text
  end

  def self.find_on_hold_date(book_part)
    # <div class="holds-status ready_for_pickup">
    #   <div class="cp-holds-secondary-info">
    #     <span>Pick up by <span class="cp-short-formatted-date">Nov 14, 2018</span></span></div></div>
    date_text = book_part.css("div.holds-status.ready_for_pickup span.cp-short-formatted-date").first.inner_text
    Time.parse(date_text, "%b %d, %Y", Time::Location.local)
  end
end
