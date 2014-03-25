spotify-cli [![Build status](https://travis-ci.org/johnelse/spotify-cli.png?branch=master)](https://travis-ci.org/johnelse/spotify-cli)
-----------

Minimal OCaml CLI program for controlling spotify on Linux via dbus.

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

`play-track` and `play-album` search for the supplied name using the spotify
metadata API, and play the first result (if any).

`search-string` doesn't have to match the album or track title exactly - in
fact you will probably get better results if you specify the artist name along
with the album or track name e.g.

```
    spotify-cli play-album "sepultura arise"
```
