## ##############################################
##
## Never commit this file with real credentials
## to version control in a public repository.
##
## Don't commit this file with real credentials to your
## local version control if you intend to share the code.
##
## ##############################################

# This separate secrets file originally held my login information to prevent it
# from being unintentionally published with the shared source code. It can now be
# distributed as-is, as my credentials are currently accessed through environment
# variables.

# Using environment variables for credentials is convenient for me, although it
# may not offer significant security benefits over other methods.

# Library card credentials don't seem like top-secret information, so if you use
# my code to scrape library web sites it seems ok to have your library card and
# pin as clear text, even in the source code of the program.

# If you use this model to store the pin to access another not really sensitive
# website, like the one for tomorrows weather forecast, that seems ok too, but
# I'm not telling you to use this code to scrape your banking information.

# This file demonstrates two approaches for setting the `POST_DATA` constant:

# 1. Direct String Assignment:
# This approach embeds credentials directly in the code as a string literal.

#    module MyTown  # Replace with your actual module name, e.g., MyLocalLibrary
#      POST_DATA = "name=your-barcode-here&user_pin=your-secret-pin-here"
#    end

# 2. Environment Variable:
# This approach attempts to retrieve credentials from an environment variable.
# If the variable is not set, an exception is thrown.

#    module MyTown
#      POST_DATA = begin
#        ENV["SECRET_MYTOWN"]
#      rescue e : KeyError
#        STDERR.puts e
#        STDERR.puts "Error: Environment variable 'SECRET_MYTOWN' is not set."
#        exit 1
#      end
#    end

# I have an incomplete understanding of this, and am using an environment
# variable for my convenience and additional security in my use case.

#   AI bot says:
#
#   Reminder: Removing sensitive files from the latest commit (HEAD) does not
#   purge them from the entire version control history. Use tools like
#   'git filter-branch' or 'BFG Repo-Cleaner' to completely remove sensitive
#   data from the repository's commit history before sharing the code.


## ##############################################
##
## Never commit this file with real credentials
## to version control in a public repository.
##
## Don't commit this file with real credentials to your
## local version control if you intend to share the code.
##
## ##############################################

module Hennepin
  # comment out one of the assignments to POST_DATA, use the other, if you
  # comment out the assignment of a string literal it doesn't make sense to
  # have real data there, replace with fake data.

  # do this with your field names and values
  # POST_DATA = "name=11111111111111&user_pin=2222"
  # or do this
  POST_DATA = begin
    ENV["SECRET_HENNEPIN"]
  rescue e : KeyError
    STDERR.puts e
    STDERR.puts "Error: Environment variable 'SECRET_HENNEPIN' is not set."
    exit 1
  end
end
