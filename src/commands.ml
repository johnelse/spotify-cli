open Lwt
open Types

(* Command implementations *)
let next () = Lwt_main.run (Backend.next ())

let play_pause () = Lwt_main.run (Backend.play_pause ())

let previous () = Lwt_main.run (Backend.previous ())

let play_album album_name =
  Lwt_main.run (
    lwt results = Spotify_search.search_albums album_name in
    match results.Spotify_search_t.albums with
    | album :: _ -> Backend.play_album album.Spotify_search_t.album_href
    | [] -> return No_search_results)

let play_artist artist_name =
  let rec find_href = function
    | [] -> None
    | {Spotify_search_t.artist_href = None} :: rest -> find_href rest
    | {Spotify_search_t.artist_href = Some href} :: _ -> Some href
  in
  Lwt_main.run (
    lwt results = Spotify_search.search_artists artist_name in
    match find_href results.Spotify_search_t.artists with
    | Some artist_href -> Backend.play_artist artist_href
    | None -> return No_search_results)

let play_track track_name =
  Lwt_main.run (
    lwt results = Spotify_search.search_tracks track_name in
    match results.Spotify_search_t.tracks with
    | track :: _ -> Backend.play_track track.Spotify_search_t.track_href
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
