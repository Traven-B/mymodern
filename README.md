
# mymodern

mymodern is a command line program written in [Crystal][] that scrapes web
pages from public library websites. It uses CSS selector rules to parse the
pages and lists checked-out books and books on hold ready for pickup.

The program uses Crystal's concurrency support to handle multiple HTTP requests
simultaneously. It is modular, allowing you to define modules for different
library websites and customize the scraping logic for each.

## Installation

To set up mymodern on your local machine, follow these steps:

1. Clone the repository to your local machine.
2. Navigate to the project directory.
3. Run the following commands:

```
shards install
shards build
```

The library [kostya/lexbor](https://github.com/kostya/lexbor) includes native C
code, so there's an additional compile step for it. Don't worry, though - this
is handled automatically during the build process.

Once installed, the library will be available locally within your project directory.

For more information about the project and how to customize it for your needs,
please refer to our:

- [Detailed README](project_docs/DETAILED_README.md) for **detailed
  installation instructions**, and subsequent setup and usage notes.

- [Project Structure Documentation](project_docs/PROJECT_STRUCTURE.md) which
  outlines the specific parts you'll need to adapt or modify to work with your
  library's website.

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

1. Fork the repository (<https://github.com/Traven-B/mymodern/fork>)
2. Create a new feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Traven-B](https://github.com/Traven-B) Michael Kamb - creator, maintainer

[Crystal]: https://crystal-lang.org
[kostya/lexbor]: https://github.com/kostya/lexbor
