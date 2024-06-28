# See hennepin_secrets.cr for my and the chat ai bots thoughts about managing not
# so secret credentials.  How not to share them when sharing code anyway.
# What you might actually consider doing if you were using actually important secrets I leave to you.

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

module StPaul
  # comment out one of the assignments to POST_DATA, use the other, if you
  # comment out the assignment of a string literal it doesn't make sense to
  # have real data there, replace with fake data.

  # do this with your field names and values
  # POST_DATA = "code=11111111111111&pin=222222"
  # or do this
  POST_DATA = begin
    ENV["SECRET_STPAUL"]
  rescue e : KeyError
    STDERR.puts e
    STDERR.puts "Error: Environment variable 'SECRET_STPAUL' is not set."
    exit 1
  end
end
