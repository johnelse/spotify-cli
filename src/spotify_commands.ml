open Lwt
open Lwt_io

module Spotify = Mpris_spotify.Org_mpris_MediaPlayer2_Player

exception No_results
exception Spotify_not_found

let with_proxy f =
  lwt proxy = Mpris_spotify.make_proxy () in
  try_lwt
    f proxy
  with
    | OBus_bus.Name_has_no_owner _
    | OBus_bus.Service_unknown _ ->
      raise_lwt Spotify_not_found
    | exn ->
      raise_lwt exn

(* Command implementations *)
let next () =
  Lwt_main.run (with_proxy Spotify.next)

let now_playing () =
  Lwt_main.run
    (with_proxy (fun proxy ->
      let metadata_property = Spotify.metadata proxy in
      lwt metadata = OBus_property.get metadata_property in
      try_lwt
        let string_of_dbus = function
          | OBus_value.V.Basic (OBus_value.V.String x) -> x
          | _ -> failwith "unexpected type"
        in
        let artist = match List.assoc "xesam:artist" metadata with
        | OBus_value.V.Array (_, artist) -> List.map string_of_dbus artist
        | _ -> failwith "bad artist type"
        in
        let title = string_of_dbus (List.assoc "xesam:title" metadata) in
        lwt () = Lwt_io.printlf "Artist: %s" (String.concat ", " artist) in
        Lwt_io.printlf "Title: %s" title
      with _ ->
        Lwt_io.printlf "unexpected metadata"))

let play_album album_name =
  let play_album_lwt =
    lwt results = Spotify_search.search_albums album_name in
    match results.Spotify_search_t.albums with
    | album :: _ ->
      with_proxy
        (fun proxy -> Spotify.open_uri proxy album.Spotify_search_t.album_href)
    | [] -> Lwt.fail No_results
  in
  Lwt_main.run play_album_lwt

let play_pause () =
  Lwt_main.run (with_proxy Spotify.play_pause)

let play_track track_name =
  let play_track_lwt =
    lwt results = Spotify_search.search_tracks track_name in
    match results.Spotify_search_t.tracks with
    | track :: _ ->
      with_proxy
        (fun proxy -> Spotify.open_uri proxy track.Spotify_search_t.track_href)
    | [] -> Lwt.fail No_results
  in
  Lwt_main.run play_track_lwt

let previous () =
  Lwt_main.run (with_proxy Spotify.previous)
