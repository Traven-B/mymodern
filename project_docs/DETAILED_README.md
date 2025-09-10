# mymodern Installation and Development Guide

## Installation

1.  **Install Crystal:**

    *   Follow the [official Crystal installation guide](https://crystal-lang.org/install/).

2.  **Clone the repository:**

    ```
    git clone --depth 1 https://github.com/Traven-B/mymodern.git
    ```

3.  **Install CMake (required for kostya/lexbor):**

    Test if cmake is already installed with `cmake --version`

    ```
    sudo apt install cmake  # For Debian/Ubuntu
    ```

    *   For other systems, visit the [CMake official website](https://cmake.org/download/).

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

You can place your own library\'s web pages in the directory with the sample web
pages and use the program to develop and test your own scraping routines.

When developing your scraping routines, write a separate small program to
develop and test the parsing of your web pages. It will compile faster, and
it\'s generally easier to isolate parsing logic this way. Use `--mock` to
integrate your code into the main application.

When analyzing page structure, simplify the HTML by removing unnecessary
elements and pretty-printing what\'s left. Focus on HTML tags and class
attributes to understand the structure. The program will work on the full HTML,
but simplifying it can make development easier.

### Troubleshooting Modern Websites

Before using `--mock` and web page fixtures saved with your browser, consider fetching web pages directly and examining them. This ensures that the program can retrieve complete and usable content for parsing.

Some library websites may use dynamic loading techniques that prevent `mymodern` from returning a complete web page with a single GET request. To address this:

*   **Start with the login form HTML:** Focus on reading the login form\'s HTML to construct your `POST_DATA` string before investing time in parsing routines for pages that might not load completely.
*   **Verify fetched pages:** Check if the fetched page contains the expected content. For example, grep for a book title or other recognizable data.
*   **Explore simpler options:** Look for \"print versions\" of pages or older, less complex versions of the website. Sometimes, URLs from a previous iteration of the site may still work and provide easier access to the needed data.

*Don\'t assume dynamic loading will be an issue just because the website looks modern or has complex HTML when viewed in your browser\'s \"View Source.\" In many cases, this won\'t be a problem at all. My honest guess is that most library websites will work just fine.*

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
