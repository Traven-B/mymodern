# mymodern installation and development

### Running with the --mock Option

The `--mock` option fakes going to the internet and reads web pages from disk.

You can place your own library's web pages in the directory where the supplied
sample web pages are, and use the program to develop and test your own scraping
routines.

### Development Considerations

Crystal provides fast execution, but the compilation process can be relatively
slow, especially on older hardware. When developing your scraping routines,
write a separate small program to develop and test the parsing of your web
pages. It's easiest to do that anyway. --mock will then help with integrating
your code into the main application.

## Compatibility with Library Websites

Some library websites might use dynamic loading techniques, which could prevent
mymodern from returning a complete web page with a single get request.

My honest intuition, for what it's worth, is that it will work. I'm batting 2
out of 2, but I would guess at least one of the websites is as complicated as
you're likely to see, and is provided to many libraries by the same company.

If this is an issue, try the following:
- Check if URLs for an earlier, simpler version of the website are still accessible.
- Look for a "print version" of the pages.

Don't assume this will be a problem just because the website does fancy stuff
and the view source in the browser is huge and hi-tech. It might not be an
issue at all.

If you suspect there is a problem, focus on having mymodern fetch a web page
first instead of parsing it. Search the returned page for expected content. Try
grepping for a book title that you can see when viewing the page in your
browser.

If it looks good, then later, when analyzing the structure of the page,
simplify the HTML by removing unnecessary elements and pretty-printing
what's left. Focus on HTML tags and class attributes to understand the
structure.

## Installation

&nbsp;&nbsp; 0. Install Crystal (if you haven't already):

LLVM compiler technology has let a thousand languages bloom, and Crystal is a
particularly beautiful one. Follow the [official Crystal installation
guide][crystal guide].

A Crystal Shard is like a Ruby Gem. You can compile a Crystal program with the
`crystal` command, but we are going to say `shards`. shards looks in
`shard.yml` for dependency information. So at the install dependency step we
will say `shards install`. The `shard.yml` file also says what is the main
target file of the build, the main entry point, so we'll say `shards build` for
the compile step.

&nbsp;&nbsp; 1. Clone the repository:

```sh
git clone --depth 1 https://github.com/Traven-B/mymodern.git
```

2. Install CMake

cmake is a required dependency for the upcoming kostya/lexbor installation.

A Debian / Ubuntu  specific installation command of the most likely missing build tool,
`cmake`, is mentioned at the top of the [kostya/lexbor][] README.

```sh
sudo apt install cmake
```

Test if cmake is already installed, or verify an installation by running `cmake --version`

- Visit the [CMake official website](https://cmake.org/download/) for
  installation guidelines specific to your operating system.

Additional Notes:\
If you're new to compiling C code the upcoming install step might fail and
you'll have to set up a development environment consisting of the usual build
tools. You might encounter some hurdles. Don't be discouraged; this is normal.

&nbsp;&nbsp; 3. Navigate to the project directory and install dependencies:

```sh
cd mymodern
shards install
```

This project uses the [kostya/lexbor][] library, a fast HTML5 parser with CSS
selectors. It's a straightforward dependency specified in the `shard.yml` file.
The `shards install` command will handle everything for you, and install the
dependency locally within your project directory.

Note: The `kostya/lexbor` library includes native C code, which requires a
compile step during installation. This step uses CMake and other build tools.
The `shards install` command will take care of the compilation process.

&nbsp;&nbsp; 4. Build the project:

```sh
shards build
```

&nbsp;&nbsp; 5. Enjoy

Let's see that --mock output for real. Then try the --trace and --mock options together
to see the interleaved execution of methods using concurrency, even though we are
not actually blocking on waiting for http responses.

```sh
export SECRET_STPAUL=any ; export SECRET_HENNEPIN=any ; bin/mymodern --mock
export SECRET_STPAUL=any ; export SECRET_HENNEPIN=any ; bin/mymodern --mock --trace
```

I show running it now with the environment variables so I can
say look, it works out of the box.

It is an artifact of my eventual implementation of a scheme allowing me to
share the code I am using as is, without sharing my secrets (the login pins).

Actually you want to make a tiny change to a couple of secrets files, and
recompile, comment and uncomment where it says or just make sure you're using
the methods listed below.

Well, it's not even a method. The first snippet is a partial definition of the
Hennepin module. The POST_DATA constant is used in the complete Hennepin module
in hennepin.cr. Don't worry for the moment, but we have sister files that both
say `module Hennepin` in them. Eventually, you will create a module with a name
of your choice, but the definition of that module will be in two files. We
avoid hard-coding secrets in the file that contains all the other code.

What we are doing now is hard-coding a secret in a separate hennepin_secrets.cr
file. Since you don't have a login string yet, we will supply an arbitrary
string. We will run in mock mode only, but with the convenience of not having
to supply environment variables. Simple.

Eventually you'll need to construct a string with the = and & chars, so we'll
use an arbitrary string that is more than you need at the moment.

If all you notice is a wall of comments in these files, don't just drop these
snippets in, find the actual code down at the bottom and comment it out, or
comment and uncomment what the comments in the actual code part suggests.

Make changes equivalent to this in two files.

```crystal
# in hennepin_secrets.cr

module Hennepin
  POST_DATA = "code=11111111111111&pin=222222"
end
```

```crystal
# in stpaul_secrets.cr`

module StPaul
  POST_DATA = "code=11111111111111&pin=222222"
end
```

And in the project directory where the shard.yml file is, recompile.

```sh
shards build
```

## The Narrow Path

The program can run in three modes:

1. With fake credentials hard coded in the secrets file (for mocking and testing) &nbsp;
    * &nbsp; --mock &nbsp;&nbsp; \| &nbsp;&nbsp; --mock --trace &nbsp;&nbsp; only
2. With real credentials hard-coded in the secrets file
3. With real credentials from environment variables

### Day One (Out of the box) Using Fake Credentials

So we have done this part.

This is the concise way to run the program after initial setup. (Not using
environment variables) You can always use mock mode for testing and offline
development. Here you can only use mock mode.

See the **Documentation section**\
near the end of this text to get another overview of which parts of the program you have to
supply / modify.

#### Getting Started with Mock Mode

- Save a couple of webpages with your browser to get sample data from your library's website.
- Examine the login form of the website to identify the names of the text input fields.
- Look at the (fake) secrets in the `POST_DATA` variable in the secrets file.
  The format is typically `fieldname1=value1&fieldname2=value2`.

#### Troubleshooting Modern Websites

If you're concerned about websites using modern technologies (Web 2.0, XMLHttpRequest, etc.):
- The initial request might not return a complete web page.
- Focus first on reading the login form HTML to construct your `POST_DATA` string.
- Check if the page you get has expected content, grep for a book title say.
- If no pages can be found being served up in a traditional manner,
  - look for a "print version" of the page.
  - Check if URLs for an earlier, simpler version of the website are still accessible.

#### Continuing Development

As your path continues to using real credentials, you can still use `--mock` to work offline:

- For developing the program as a whole
- When integrating parsing routines developed with a small program that reads mock webpages
- When updating for webpage changes:
  - Save the new page using your web browser
  - Put the new fixture (mock webpage) in the appropriate directory
  - Fix the parse methods for that website using the program in mock mode

When you’re ready to use real credentials to fetch actual data, you’ll need to
determine how to present your login string.

### Day Two (Real credentials, hard-coded):

Put your login string in the secrets file, I guess you could modify the one I gave you,
but let's say you're a patron of the Springfield Public Library

```crystal
# in springfield_secrets.cr

module Springfield
  POST_DATA = "barcode=38473269927348&password=374652"
end
```

This file works in conjunction with springfield.cr, which contains:

* The URL where this string is posted
* The two URLs for fetching the pages we want
* Other small data strings
* The two parse methods for the webpages we fetch

Like this file, springfield.cr also begins with `module Springfield`. This
structure, where a module is defined across two files, is mentioned below, but
I'm reiterating it here to familiarize you with the layout. 

**Important:** Do not commit your secret files (one or two, depending on how
many websites you're scraping) to public repositories.

Do not commit these files to your local source control if you intend to share
the code someday. It's crucial to handle these files correctly from the start.
While I can provide guidance on protecting less sensitive information, I'm not
qualified to advise on managing truly important secrets. Always err on the side
of caution when dealing with sensitive data.

#### File Permissions for Secret Files

For any files containing secrets (even if they seem unimportant), you're
supposed to restrict file permissions. This is a simple yet effective first
step in protecting your sensitive information.

&nbsp;&nbsp; 1. For files containing secrets (like `springfield_secrets.cr` and
`shelbyville_secrets.cr`), set permissions to allow read and write access only for
the owner (you):

```sh
chmod 600 springfield_secrets.cr shelbyville_secrets.cr
```

This command sets the file permissions to read and write for the owner, and no
permissions for group or others.

&nbsp;&nbsp; 2. Verify the permissions:

```sh
ls -l springfield_secrets.cr shelbyville_secrets.cr
```

You should see something like: `-rw-------` at the beginning of each line.

Remember: While this helps prevent unauthorized access on your local system,
it's not a substitute for keeping secrets out of version control or secure
secret management in a production environment.

### Day Three (Environment variables):

See the original hennepin_secrets.cr file for how to assigned to POST_DATA with
a login string we get from an environment variable.

Let's say you're also a patron of the library in the neighboring town of Shelbyville.
You would say this somewhere so these variables are in your program's environment.

```sh
export SECRET_SPRINGFIELD=your_real_springfield_credentials
export SECRET_SHELBYVILLE=your_real_shelbyville_credentials
```

**you're not using your real credentials as hard coded strings now, so xxxx
them out** of your secret file. (springfield_secrets.cr) No reason for them to
be there.

Do this if you think it supplies additional security. The only problem it
solves for me is being able to share my secrets file(s) with the world as is,
because I'm not sharing my pins.

## Development

The program uses modules to define scraping logic for different library
websites. Each module should implement the following methods:

```crystal
module Springfield
  def self.lib_data
    # returns data in the form of a NamedTuple
  end

  def self.parse_checkedout_page(page)
    # return a sorted array of CheckedOutRecord
    # uses already existing record and comparison definitions
  end

  def self.parse_on_hold_page(page)
    # return a sorted array of OnHoldRecord
  end
end
```

To add support for another library, create a new module with the same methods
and include it in the list of module names. The example file below reflects the
fact that part of the definition of the Springfield module is in
springfield_secrets.cr, and we chose to require it here, instead of
springfield.cr including it. So we are listing the complete contents of
module_names.cr. The file name has to be that exact name, and the constant,
MODULE_NAMES that references the list of modules you have developed, has to be
spelled exactly that way also.

```crystal
# in module_names.cr

require "./springfield"
require "./springfield_secrets"
require "./shelbyville"
require "./shelbyville_secrets"

MODULE_NAMES = [Springfield, Shelbyville]
```

This allows the program to scrape web pages from multiple libraries
concurrently, as it knows to iterate over MODULE_NAMES.

## Documentation

[Project Structure Documentation](PROJECT_STRUCTURE.md) outlines
the specific parts of the supplied code you'll need to adapt or modify to work
with your library's website.

The above link provides a good walk through, but please note the code examples
in some cases may not match the actual code exactly.

### Viewing a pdf slideshow

Skip to slide 24 to see the above link's walk through as a pdf slide show.

Note: This is a link to the pdf file on github pages, so it should do the right
thing when viewed with your browser. Your welcome. If your browser downloads it
instead of rendering it, avoid accumulating multiple numbered copies in your
Downloads directory. In that case once you have it, view it offline.

[View in browser][modern.pdf] (**Start reading from page (slide) 24 for the relevant information**)

### Additional Information

The actual work involves writing code using parsers for web scraping. Code to
do this using Nokogiri for Ruby, Gokogiri and Goquery for Go, and MyHTML for
Crystal (for which the Kostal/Lexbor library was a drop-in replacement) was all
very similar to what we have provided here. Some libraries might use XPath
instead of CSS selectors, but you probably know how to specify parts of a web
page with CSS selectors.

[crystal guide]: https://crystal-lang.org/install/
[kostya/lexbor]: https://github.com/kostya/lexbor
[modern.pdf]: https://traven-b.github.io/mymodern/as_pdf_my_modern.pdf
