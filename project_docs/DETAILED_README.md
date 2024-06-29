# mymodern

mymodern is a command line program written in [Crystal][] that scrapes web
pages from public library websites. It uses CSS selector rules to parse the
pages and lists checked-out books and books on hold ready for pickup.

The program uses Crystal's concurrency support to handle multiple HTTP requests
simultaneously. It is modular, allowing you to define modules for different
library websites and customize the scraping logic for each.

## Usage

```sh
bin/mymodern --help

Usage: mymodern [OPTIONS]
Scrape pages at public libraries' web sites.
    -m, --mock                       this option mocks everything
    -t, --trace                      trace where it's all happening
    -h, --help                       show this message
```

Example program output:

```sh
Hennepin Books Out

The Astronomer
Tuesday December 04, 2018

Subterranean Twin Cities
Wednesday December 05, 2018
Renewed: 1 time
2 people waiting

Hennepin Books on Hold

A History of America in Ten Strikes
Wednesday November 14, 2018

St. Paul Books Out

St. Paul Books on Hold

The mysterious flame of Queen Loana
Saturday November 17, 2018
```

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

&nbsp;&nbsp; 2. [Mutatis Mutandis][] or preparing for the [kostya/lexbor][] library.

The readme of the dependency we are installing says the crystal wrapper and
underlying library has been tested or benchmarked on more than one OS.

It says before the install step make sure you have `cmake` and gives a specific
Debian or Ubuntu command to install it on your system. So I doubt this will
work on windows (crystal on windows is in a preview state), I know it works on
Linux. Otherwise? Try, and try again. Then quit, no use being a fool about it.

The underlying [Lexbor][] code is written in C and currently supports the
x86_64 architecture. Its readme mentions installation on macOS with Homebrew
and MacPorts. Also mentions vcpkg if that means anything to you.

Though many build tools are a prerequisite to the upcoming step, kostya/lexbor
singled cmake out, so see if you have it. It might be a cross platform build
tool that you haven't needed yet.

On Debian I did `which cmake`, and got the path to the binary printed.
Then `cmake --version`, to print version information. If you're not on
Linux, this can still work but I'm busy writing the README at the moment.

While the shards install command aims to handle the installation process
seamlessly, there's a possibility that additional build tools and dependencies
may be required. If the installation fails, put the usual build tools on your
system. Find a random hello c repository or 'GNU hello' and get it to compile.

```sh
sudo apt install cmake
```

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
recompile, comment and uncomment where it says or just make sure you're using the
methods listed below.

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

If I was in some kind of mood and left a wall of comments in these files, don't
just drop these snippets in, find the actual code down at the bottom and
comment it out, or comment and uncomment what the comments in the actual code
part suggests.

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
- Look at the (fake) secrets in the `POST_DATA` variable in the secrets file. The format is typically `fieldname1=value1&fieldname2=value2`.

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

### Viewing the PDF

Skip to slide 24:

Note: This is a link to the file on github pages, so it should do the right
thing when viewed with your browser. Your welcome. If your browser downloads it
instead of rendering it, avoid accumulating multiple numbered copies in your
Downloads directory. In that case once you have it, view it offline.

[View in browser][modern.pdf] (**Start reading from page (slide) 24 for the relevant information**)

### Code Consistency

While the PDF provides a good walkthrough, please note the code examples in
some cases may not match the actual code exactly. As a specific example, the
names of attributes in `lib_data` are correct, but the way `POST_DATA` is
namespaced may differ in the code. So copy and paste from the code files.

### Additional Information

The actual work involves writing code using parsers for web scraping. This has
been done with Nokogiri for Ruby, Gokogiri and Goquery for Go, and MyHTML for
Crystal. The Kostal/Lexbor library was a drop-in replacement. You can study or
use this code for web scraping, as the scraper libraries are quite similar.
Some might use XPath instead of CSS selectors, but you probably know how to
specify parts of a web page with CSS selectors.

## Contributing

1. Fork the repository (<https://github.com/Traven-B/mymodern/fork>)
2. Create a new feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Traven-B](https://github.com/Traven-B) Michael Kamb - creator, maintainer

[Crystal]: https://crystal-lang.org
[crystal guide]: https://crystal-lang.org/install/
[kostya/lexbor]: https://github.com/kostya/lexbor
[Lexbor]: https://github.com/lexbor/lexbor
[Mutatis Mutandis]: https://en.wiktionary.org/wiki/mutatis_mutandis#Adverb "with the necessary changes having been made"
[modern.pdf]: https://traven-b.github.io/mymodern/as_pdf_my_modern.pdf
