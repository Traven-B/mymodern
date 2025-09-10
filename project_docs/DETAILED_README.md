# mymodern Installation and Development Guide

## Installation

1.  **Install Crystal:**

    * Follow the [official Crystal installation guide](https://crystal-lang.org/install/).

2.  **Clone the repository:**

    ```
    git clone --depth 1 https://github.com/Traven-B/mymodern.git
    ```

3.  **Install CMake (required for kostya/lexbor):**

    Test if cmake is already installed with `cmake --version`

    ```
    sudo apt install cmake  # For Debian/Ubuntu
    ```

    * For other systems, visit the [CMake official website](https://cmake.org/download/).

4.  **Navigate to the project directory and install dependencies:**

    ```
    cd mymodern
    shards install
    ```

    *Note: The `kostya/lexbor` library includes native C code, which requires a compile step during installation. This step uses CMake and other build tools. The `shards install` command will handle the compilation process.*

    *It\'s a straightforward dependency specified in the `shard.yml` file. The `shards install` command will handle everything for you, and lexbor will be installed locally within your project directory.*

5.  **Build the project:**

    ```
    shards build
    ```

## Running the Program

### Mock Mode

__Use the `--mock` option__ to simulate web requests and read pages from disk:

```
bin/mymodern --mock
bin/mymodern --mock --trace
```

*__It is necessary to use `--mock` when first running the program__. Without it,
you will be posting fake placeholder credentials to actual library websites,
and the logins will fail.*

You can place your own library\'s web pages in the directory with the sample
web pages and use the program to develop and test your own scraping routines
without making actual network requests.

When developing your scraping routines, write a separate small program to
develop and test the parsing of your web pages. It will compile faster, and
it\'s generally easier to isolate parsing logic this way. Use `--mock` to
integrate your code into the main application.

When analyzing page structure, simplify the HTML by removing unnecessary
elements and pretty-printing what\'s left. Focus on HTML tags and class
attributes to understand the structure. The program will work on the full HTML,
but simplifying it can make development easier.

### Troubleshooting Modern Websites

#### Capturing Page Source for Parsing

The primary approach to start development is to save the raw HTML you want to parse from your browser's "View Page Source".

Do not use your browser's "File > Save Page As" menu when viewing the normal rendered web page, as it may save additional resources and dynamic content, leading to confusion.

Instead, in the browser, right-click in the rendered page and choose "View Page Source" (or press Ctrl+U). This shows the exact raw HTML returned by the server on the initial page load.

Select all the text in the page source view, copy it, and paste into your text editor. (Again, do NOT use 'Save Page As" for the  source view either.)

Before working on your fixtures, (the pages saved from your browser\'s view source,) search the HTML text for the expected content. If the rendered view had a book title, grep for it.

If the expected data is present in the HTML obtained from the browser's **view source HTML**, then an initial HTTP GET request by the program should be sufficient to retrieve it.

If the expected data is **not** present in the view source HTML, but appears in the fully rendered web page, this indicates the site uses dynamic Web 2.0 techniques where JavaScript loads content after the initial page load. In such cases, the program's single HTTP GET approach will not be enough.

To handle such dynamic sites, consider looking for simpler or print-friendly versions of pages, or earlier but still working versions of pages (earlier but still working URLs) that provide the needed data statically.

Don’t assume dynamic loading is a problem just because a site looks modern or complex when inspected in your browser's rendered view - if the data appears in the View Page Source, the program should work. Some “Web 2.0” techniques still provide all needed data as HTML on the initial GET.

### Using Real Credentials

1.  **Modify the secrets files** (e.g., `springfield_secrets.cr`):

    ```
    module Springfield
      POST_DATA = "barcode=38473269927348&password=374652"
    end
    ```

2.  **Or use environment variables:**

    ```
    export SECRET_SPRINGFIELD=your_real_springfield_credentials
    export SECRET_SHELBYVILLE=your_real_shelbyville_credentials
    ```

## Development

### Adding Support for a New Library

1.  **Create a new module implementing these methods:**

    ```
    module Springfield
      def self.lib_data
        # returns data as a NamedTuple
      end

      def self.parse_checkedout_page(page)
        # return a sorted array of CheckedOutRecord
      end

      def self.parse_on_hold_page(page)
        # return a sorted array of OnHoldRecord
      end
    end
    ```

2.  **Include the new module in `module_names.cr`:**

    ```
    require "./springfield"
    require "./springfield_secrets"

    MODULE_NAMES = [Springfield]
    ```

## Documentation

For more detailed information, refer to:

*   [Project Structure Documentation](PROJECT_STRUCTURE.md)
*   [PDF Slideshow](https://traven-b.github.io/mymodern/as_pdf_my_modern.pdf) (Start from slide 24 for relevant information)
