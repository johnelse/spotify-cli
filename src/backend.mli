open Spotify_cli_types

val next: unit -> (unit command_result) Lwt.t
val play_pause: unit -> (unit command_result) Lwt.t
val previous: unit -> (unit command_result) Lwt.t

val play_album: string -> (unit command_result) Lwt.t
val play_artist: string -> (unit command_result) Lwt.t
val play_track: string -> (unit command_result) Lwt.t

val now_playing: unit -> (metadata command_result) Lwt.t
