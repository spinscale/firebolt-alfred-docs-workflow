# Alfred Firebolt Documentation Workflow

[Alfred](https://www.alfredapp.com/) is a fantastic launcher allowing you to
implement custom actions based on keyboard. This workflow implements a
search in the [Firebolt](https://docs.firebolt.io/) documentation, using the
same data used by the in-browser search, but matching using a fuzzy search
(similar to what sublime does, the letters have to occur in similar order).

## Installation

1. Install [crystal](https://crystal-lang.org/install/on_mac_os/)
2. Install Alfred with the Powerpack extension (which is a paid feature)
3. Clone this repo
4. Install the workflow by running `make` and `open firebolt.alfredworkflow`
   which will install the workflow - this can be repeated anytime

## Usage

Open your alfred launcher, type `firebolt <term>`, for example `firebolt
JDBC` and enjoy the results. Hitting enter on one of the results will open
them in your browser.

Here is a sample with a couple of terms:

![](img/firebolt-sample.gif)
