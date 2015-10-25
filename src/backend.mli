open Rresult
open Types

val next : unit -> (unit, [ `Spotify_not_found ]) result Lwt.t
val play_pause : unit -> (unit, [ `Spotify_not_found ]) result Lwt.t
val previous : unit -> (unit, [ `Spotify_not_found ]) result Lwt.t

val play_album :
  string -> (unit, [ `Spotify_not_found ] ) result Lwt.t
val play_artist :
  string -> (unit, [ `Spotify_not_found ] ) result Lwt.t
val play_track :
  string -> (unit, [ `Spotify_not_found ] ) result Lwt.t

val now_playing :
  unit -> (metadata, [ `Invalid_metadata | `Spotify_not_found ]) result Lwt.t
