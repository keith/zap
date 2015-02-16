# zap

A simple command line tool to remove a `.app` on OS X and its related
files.

Think [AppZapper](http://www.appzapper.com) from the command line.

## Usage

To delete an application in `/Applications` or `~/Applications`

```sh
zap foo.app
```

To delete a specific application:

```sh
zap /path/foo.app
```

To delete an application securely use `-s` (this must come before the
application):

```sh
zap -s foo.app
```

### Installation

With [Homebrew](http://brew.sh)

```sh
brew tap Keithbsmiley/formulae
brew install zap
```

Without Homebrew just copy `zap` to somewhere in your `$PATH`. If you
would also like the zsh completions copy `_zap` to somewhere in your
`$fpath`.

#### Disclaimer

This CLI deletes stuff. If it deletes the wrong stuff it isn't my fault.
