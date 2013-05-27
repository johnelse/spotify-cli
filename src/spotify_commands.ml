open Lwt
open Lwt_io

module Spotify = Spotify_client.Org_mpris_MediaPlayer2_Player

let with_proxy f =
  lwt bus = OBus_bus.session () in
  let proxy = Spotify_proxy.of_bus bus in
  try_lwt
    f proxy
  with
    | OBus_bus.Name_has_no_owner _
    | OBus_bus.Service_unknown _ ->
      lwt () = printl "Spotify service not found - is it running?" in
      exit 1
    | exn ->
      raise_lwt exn

(* Command implementations *)
let next () =
  Lwt_main.run (with_proxy Spotify.next)

let play_pause () =
  Lwt_main.run (with_proxy Spotify.play_pause)

let previous () =
  Lwt_main.run (with_proxy Spotify.previous)
