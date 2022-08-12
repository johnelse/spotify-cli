module type S = sig
    val next : unit -> unit Spotify_cli_types.command_result
    val play_pause : unit -> unit Spotify_cli_types.command_result
    val previous : unit -> unit Spotify_cli_types.command_result
    val play_album : string -> unit Spotify_cli_types.command_result
    val play_artist : string -> unit Spotify_cli_types.command_result
    val play_track : string -> unit Spotify_cli_types.command_result
    val now_playing : unit -> unit Spotify_cli_types.command_result
  end

val make : unit -> (module S)
