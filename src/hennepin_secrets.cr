# ##############################################
#
# Never commit this file with real credentials
# to version control in a public repository.
#
# Don't commit this file with real credentials to your
# local version control if you intend to share the code.
#
# Even if you later stop hard coding the secrets or remove the secret files
# from the latest version of the code using "git rm <file>" or similar
# commands they will likely persist in the version control history, which would
# allow someone to extract them. Just start a new repository if you later decide
# to post the code would be a plan.
#
# ##############################################

module Hennepin
  # ## DELETE_ME
  # ## extra extraneous introductory block of code.
  # ## Remove the follwing begin  ..  end block.
  begin
    ENV["SECRET_HENNEPIN"]
  rescue e : KeyError
    STDERR.puts "Hello from hennepin_secrets.cr stderr."
    STDERR.puts "When using this code and these fake credentials, " \
                "run with --mock option to see full report with book titles."
    STDERR.puts "Use --mock option when you are scraping your own sample web pages on your file system."
    STDERR.puts "Don't use --mock when you specify URLs and secrets in modules for the website(s) you'll be scraping."
    STDERR.puts "Use --mock option when testing your finished code."
  end
  # ## end DELETE_ME

  # always use --mock option until you develop youre own URL data and your own real secrets.

  # Code to use for fake or real hard coded secrets. Unless you are supplingg the
  # login string from an ENV variable. Do this if you don't want them hard coded.
  #
  # The take from the environment scheme is recommend in some contexts. It's good
  # if you are going to share your code

  POST_DATA = begin
    ENV["SECRET_HENNEPIN"]
  rescue e : KeyError
    # The string below is what is assigned to the constant when not using an environment
    # variable to supply the login secret. Replace with your correctly formed real secret when
    # you go to post to the login URL of the website you'll be scraping. This really
    # should end up in a file of a different name containing the secrets for a module
    # of a different name.
    "name=fake_barcode&user_pin=fake_pin"
  end

  # this is the result we want to achieve.
  # POST_DATA = "name=11111111111111&user_pin=2222"
end
