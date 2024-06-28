module Print
  def self.pluralize(count, singular, plural)
    "#{count} " + (count == 1 ? singular : plural)
  end

  def self.print_checked_out_books(books_out, library_system_name)
    puts "#{library_system_name} Books Out\n\n"
    books_out.each do |record|
      puts record.title
      puts record.due_date.to_s "%A %B %d, %Y"
      times_renewed = record.renewed_count
      puts "Renewed: #{pluralize(times_renewed, "time", "times")}" if times_renewed > 0
      number_waiting = record.number_waiting
      puts "#{pluralize(number_waiting, "person", "people")} waiting" if number_waiting > 0
      puts
    end
  end

  def self.print_books_on_hold(books_on_hold, library_system_name)
    puts "#{library_system_name} Books on Hold\n\n"
    books_on_hold.each do |record|
      puts record.title
      puts record.exp_date.to_s "%A %B %d, %Y"
      puts
    end
  end
end
