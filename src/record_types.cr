module Recs
  def self.date_title_composite_key(a_date, a_title)
    # format string using %m and %d has zero padding
    # Time.local(2000, 2, 1).to_s "%Y %m %d" # => "2000 02 01"
    "#{a_date.to_s "%Y %m %d"} #{alter_title_key(a_title)}"
  end

  def self.create_checked_composite_key(a)
    date_title_composite_key(a.due_date, a.title)
  end

  def self.create_holds_composite_key(a)
    date_title_composite_key(a.exp_date, a.title)
  end

  def self.alter_title_key(a_string)
    a_string.downcase.sub(/^(the|a|an)\s+/i, "")
  end

  def self.date_then_title_compare(a_date, b_date, a_title, b_title)
    if a_date != b_date
      a_date <=> b_date
    else
      alter_title_key(a_title) <=> alter_title_key(b_title)
    end
  end

  def self.checked_compare(a, b)
    date_then_title_compare(a.due_date, b.due_date, a.title, b.title)
  end

  def self.holds_compare(a, b)
    date_then_title_compare(a.exp_date, b.exp_date, a.title, b.title)
  end
end

record CheckedOutRecord, title : String, due_date : Time, renewed_count : Int32, number_waiting : Int32

record OnHoldRecord, title : String, exp_date : Time
