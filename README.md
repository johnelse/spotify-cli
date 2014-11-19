spotify-cli [![Build status](https://travis-ci.org/johnelse/spotify-cli.png?branch=master)](https://travis-ci.org/johnelse/spotify-cli)
-----------

Minimal OCaml CLI program for controlling the spotify desktop client.
Supported platforms:

* Linux (via DBus)
* Mac OSX (via osascript)

Installation
------------

The easiest way to install is with [opam](http://opam.ocaml.org/), an OCaml
package manager. spotify-cli is not yet in the main opam repository, so you'll
have to add an extra remote first:

```
    opam remote add johnelse git://github.com/johnelse/opam-repo-johnelse
    opam install spotify-cli
```

Build dependencies
------------------

* [cmdliner](https://github.com/dbuenzli/cmdliner)
* [obus](https://github.com/diml/obus)
* [ocaml-mpris](https://github.com/johnelse/ocaml-mpris)
* [ocaml-spotify-web](https://github.com/johnelse/ocaml-spotify-web)

Supported commands
------------------

```
    spotify-cli now-playing
    spotify-cli play-pause
    spotify-cli previous
    spotify-cli next
    spotify-cli play-album <search-string>
    spotify-cli play-artist <search-string>
    spotify-cli play-track <search-string>
```

`play-album`, `play-artist` and `play-track` search for the supplied name using
the spotify metadata API, and play the first result (if any).

`search-string` doesn't have to match the album or track title exactly - in
fact you will probably get better results if you specify the artist name along
with the album or track name e.g.

```
    spotify-cli play-album "sepultura arise"
```
