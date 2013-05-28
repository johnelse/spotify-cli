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

let play_album album_name =
  let play_album_lwt =
    lwt results = Spotify_search.search_albums album_name in
    let album = List.nth results.Spotify_search_t.albums 0 in
    with_proxy
      (fun proxy -> Spotify.open_uri proxy album.Spotify_search_t.album_href)
  in
  Lwt_main.run play_album_lwt

let play_pause () =
  Lwt_main.run (with_proxy Spotify.play_pause)

let play_track track_name =
  let play_track_lwt =
    lwt results = Spotify_search.search_tracks track_name in
    let track = List.nth results.Spotify_search_t.tracks 0 in
    with_proxy
      (fun proxy -> Spotify.open_uri proxy track.Spotify_search_t.track_href)
  in
  Lwt_main.run play_track_lwt

let previous () =
  Lwt_main.run (with_proxy Spotify.previous)
