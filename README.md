# mymodern

Program that scrapes web pages at one or more public libraries' web sites. It
parses the web pages using CSS selector rules and lists checked out books and
books on hold ready for pickup.

The program is a command line program written in [Crystal][]. It is
'structured' to use Crystal's concurrency support to have more than one fiber
waiting for http requests to complete.

The program is somewhat modular, you can define a module for your town's
library website, and if you want, modules for another library or two where
you're a regular patron. You supply not only data used to login and fetch pages
but code to scrape the fetched webpages.

## Installation

In the project directory run `shards install`, then `make`.

The library kostya/myhtml includes native c, and there's a compile step for it.

## Usage

```terminal
~/at_the_prompt/crystal/mymodern$ bin/mymodern --help
Usage: mymodern [OPTIONS]
Scrape pages at public libraries' web sites.
    -m, --mock                       this option mocks everything
    -t, --trace                      trace where it's all happening
    -h, --help                       show this message
```

Example program output:

```terminal
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

## Development

The program calls upon identically named methods provided by one or another
library's module.

```
module Hennepin
  def self.lib_data
    # returns data in the form of a NamedTuple

  def self.parse_checkedout_page(page)
    # return a sorted array of CheckedOutRecord
    # uses already existing record and comparison definitions

  def self.parse_on_hold_page(page)
    # return a sorted array of OnHoldRecord
```

Code for another library where you're a regular patron would do the same, and
parts of the program that invoke these methods iterate over an array of the
module names, and don't hard code the number or names of the modules.

You can adapt the modules that define these few methods, name them Springfield
and Shelbyville, and require them from a single file which also lists them in
an array of module names.

```
require "./hennepin"
require "./stpaul"

MODULE_NAMES = [Hennepin, StPaul]
```

So this can be used to scrape web pages at 1, 2, or 3 libraries, and all things
being equal, runs in constant time no matter how many you're doing. *

\* Because concurrency.

1 web site, 1.5 times faster. All things being equal, 2 websites, could be 3
times faster, 3 web sites, 4.5 times faster. Conceivably.

## Contributing

1. Fork it (<https://github.com/your-github-user/mymodest/fork>{:t})
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [your-github-user](https://github.com/your-github-user){:t} Michael Kamb -
  creator, maintainer

{:t: target="_blank"}
[Crystal]: https://crystal-lang.org/
{:t}
