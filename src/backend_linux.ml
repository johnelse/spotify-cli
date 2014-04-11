open Lwt
open Types

module Spotify = Mpris_spotify.Org_mpris_MediaPlayer2_Player

let with_proxy f =
  lwt proxy = Mpris_spotify.make_proxy () in
  try_lwt
    f proxy
  with
  | OBus_bus.Name_has_no_owner _
  | OBus_bus.Service_unknown _ ->
    return Spotify_not_found

let ok x = return (Ok x)

let with_proxy_return_ok f =
  with_proxy (fun proxy -> f proxy >>= ok)

let next () = with_proxy_return_ok Spotify.next

let play_pause () = with_proxy_return_ok Spotify.play_pause

let previous () = with_proxy_return_ok Spotify.previous

let play_album album_name =
  lwt results = Spotify_search.search_albums album_name in
  match results.Spotify_search_t.albums with
  | album :: _ ->
    with_proxy
      (fun proxy ->
        Spotify.open_uri proxy album.Spotify_search_t.album_href >>= ok)
  | [] -> return No_search_results

let play_artist artist_name =
  let rec find_href = function
    | [] -> None
    | {Spotify_search_t.artist_href = None} :: rest -> find_href rest
    | {Spotify_search_t.artist_href = Some href} :: _ -> Some href
  in
  lwt results = Spotify_search.search_artists artist_name in
  match find_href results.Spotify_search_t.artists with
  | Some href ->
    with_proxy (fun proxy -> Spotify.open_uri proxy href >>= ok)
  | None -> return No_search_results

let play_track track_name =
  lwt results = Spotify_search.search_tracks track_name in
  match results.Spotify_search_t.tracks with
  | track :: _ ->
    with_proxy
      (fun proxy ->
        Spotify.open_uri proxy track.Spotify_search_t.track_href >>= ok)
  | [] -> return No_search_results

let parse_metadata metadata =
  let artist_key = "xesam:artist" in
  let title_key = "xesam:title" in
  try
    let string_of_dbus = function
      | OBus_value.V.Basic (OBus_value.V.String x) -> x
      | _ -> failwith "unexpected type"
    in
    let artists = match List.assoc artist_key metadata with
    | OBus_value.V.Array (_, artists) -> List.map string_of_dbus artists
    | _ -> failwith "bad artist type"
    in
    let title = string_of_dbus (List.assoc title_key metadata) in
    Metadata {artists; title}
  with
    | Not_found -> Parse_failure "missing key"
    | Failure msg -> Parse_failure msg

let now_playing () =
  with_proxy (fun proxy ->
    let metadata_property = Spotify.metadata proxy in
    OBus_property.get metadata_property
    >|= parse_metadata
    >>= (function
      | Metadata metadata -> return (Ok metadata)
      | Parse_failure msg -> return (Invalid_metadata msg)))
