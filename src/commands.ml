open Lwt
open Spotify_web_api
open Types

(* Command implementations *)
let next () = Lwt_main.run (Backend.next ())

let play_pause () = Lwt_main.run (Backend.play_pause ())

let previous () = Lwt_main.run (Backend.previous ())

let play_album album_name =
  Lwt_main.run (
    lwt results = Search.search_albums album_name in
    match results.Paging_t.items with
    | album :: _ -> Backend.play_album album.Album_t.uri
    | [] -> return No_search_results)

let play_artist artist_name =
  Lwt_main.run (
    lwt results = Search.search_artists artist_name in
    match results.Paging_t.items with
    | artist :: _ -> Backend.play_artist artist.Artist_t.uri
    | [] -> return No_search_results)

let play_track track_name =
  Lwt_main.run (
    lwt results = Search.search_tracks track_name in
    match results.Paging_t.items with
    | track :: _ -> Backend.play_track track.Track_t.uri
    | [] -> return No_search_results)

let print_key_value (key, value) =
  Lwt_io.printlf "%s=\"%s\"" key value

let now_playing () =
  Lwt_main.run
    (Backend.now_playing () >>= (function
      | Ok {artists; title; http_url} ->
        let data = [
          "spotify_artist_name", (String.concat ", " artists);
          "spotify_track_name", title;
          "spotify_http_url", http_url;
        ] in
        lwt () = Lwt_list.iter_s print_key_value data in
        return (Ok ())
      | Spotify_not_found -> return Spotify_not_found
      | No_search_results -> return No_search_results
      | Invalid_metadata msg -> return (Invalid_metadata msg)))
