module StPaul
  def self.lib_data
    {
      post_data:           POST_DATA, # constant defined in stpaul_secrets.cr, but must be named here also
      post_url:            STPAUL_BASE_URL + "/patroninfo~S16",
      checked_out_url:     STPAUL_BASE_URL + "/patroninfo~S16/1600472/items",
      holds_url:           STPAUL_BASE_URL + "/patroninfo~S16/1600472/holds",
      print_name:          "St. Paul",
      checked_out_fixture: "s_c.html",
      holds_fixture:       "s_h.html",
      trace_name:          "StPaul",
    }
  end

  def self.parse_checkedout_page(page)
    doc = Lexbor::Parser.new(page)
    books_out = doc.css("table tr.patFuncEntry").to_a.map do |book_part|
      the_title = find_checkedout_title(book_part)
      the_date = find_checkedout_date(book_part)
      the_renewed_count = find_renewed_count(book_part)
      the_number_waiting = 0
      CheckedOutRecord.new(the_title, the_date, the_renewed_count, the_number_waiting)
    end
    books_out.sort { |a, b| Recs.checked_compare(a, b) }
  end

  def self.parse_on_hold_page(page)
    # For on hold books, status might be <td class="patFuncStatus"> 16 of 19 holds </td>
    # We want to select only those like <td class="patFuncStatus"> Ready. Must pick up by 10-25-16 </td>
    # The if statement generates a record when status.match(/^Ready/) is true, otherwise producing nil.
    # compact_map removes nils, then maps remaining non-nil elements by evaluating the block.
    # This allows operating only on book_parts that matched /^Ready/ and not any spurious nils.
    doc = Lexbor::Parser.new(page)
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

  STPAUL_BASE_URL = "https://alpha.stpaul.lib.mn.us"

  def self.finds_either_title(book_part)
    # <th class="patFuncBibTitle" scope="row"><a href="/record=b1266537~S16">
    # <span class="patFuncTitleMain">Feed zone portables : a cookbook et cetera / Biju Thomas & Allen Lim.</span></a><br />
    # </th>
    title_span = book_part.css("th.patFuncBibTitle span.patFuncTitleMain").first
    # remove the author after a /  remove possible sub title after a :
    # remove the author after an old style title [by] author sequence
    title = title_span.inner_text.split(" /")[0].split(" :")[0].split(" [by]")[0]
    title = title[0, 42]
    title.sub(/\.$/, "")
  end

  def self.find_checkedout_title(book_part)
    finds_either_title(book_part)
  end

  def self.find_checkedout_date(book_part)
    # <td class="patFuncStatus"> DUE 10-18-16 </td>
    td_status = book_part.css("td.patFuncStatus").first
    status = td_status.inner_text.strip
    date_match = status.match(
      /^.* ([0-9]{2})-([0-9]{2})-([0-9]{2}).*$/
    ).not_nil!
  rescue e : NilAssertionError
    Time.local(1, 1, 1)
  else
    Time.local("20#{date_match[3]}".to_i, date_match[1].to_i, date_match[2].to_i)
  end

  def self.find_renewed_count(book_part)
    # <td class="patFuncStatus">
    #   DUE 11-01-16 <span class="patFuncRenewCount">Renewed 3 times</span></td>
    # case where there is a nested span, not seen in find_checkedout_date example snippet
    renewed_span = book_part.css("td.patFuncStatus span.patFuncRenewCount").first?
    renewed_count_text = "Renewed 0 times"
    if renewed_span
      renewed_count_text = renewed_span.inner_text.strip
    end
    renewed_count_match = renewed_count_text.match(
      /^Renewed ([0-9]{1}) times*$/ # *s for time or times possibly appearing
    ).not_nil!
    renewed_count_match[1].to_i
  end

  def self.find_on_hold_title(book_part)
    finds_either_title(book_part)
  end

  def self.find_on_hold_date(status)
    # status is e.g., "Ready. Must pick up by 10-25-16"
    date_match = status.match(
      /^.* ([0-9]{2})-([0-9]{2})-([0-9]{2}).*$/
    ).not_nil!
  rescue e : NilAssertionError
    Time.local(1, 1, 1)
  else
    Time.local("20#{date_match[3]}".to_i, date_match[1].to_i, date_match[2].to_i)
  end
end
