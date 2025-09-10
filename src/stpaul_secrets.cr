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

module StPaul
  POST_DATA = begin
    ENV["SECRET_STPAUL"]
  rescue e : KeyError
    # string below is what is assinged to the constant
    "code=fake_code&pin=fake_pin"
  end
end
