open Lwt
open Spotify_web_api
open Rresult
open Types

(* Command implementations *)
let next () = Lwt_main.run (Backend.next ())

let play_pause () = Lwt_main.run (Backend.play_pause ())

let previous () = Lwt_main.run (Backend.previous ())

let play_album album_name =
  Lwt_main.run (
    lwt results = Search.search_albums album_name in
    match results.Paging_t.items with
    | album :: _ ->
      Backend.play_album album.Album_t.uri >>| coerce
      (*((Backend.play_album album.Album_t.uri) :> (unit, [ `Spotify_not_found | `No_search_results ]) result Lwt.t)*)
    | [] -> return (Error `No_search_results))

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

let now_playing () =
  Lwt_main.run
    (Backend.now_playing () >>= (function
      | Ok {artists; title} ->
        lwt () = Lwt_io.printlf "Artist: %s" (String.concat ", " artists) in
        lwt () = Lwt_io.printlf "Title: %s" title in
        return (Ok ())
      | Spotify_not_found -> return Spotify_not_found
      | No_search_results -> return No_search_results
      | Invalid_metadata msg -> return (Invalid_metadata msg)))
