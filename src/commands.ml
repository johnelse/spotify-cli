open Lwt
open Spotify_web_api
open Spotify_cli_types

let convert_result = function
  | Ok _ as ok -> ok
  | Error No_search_results -> Error "No search results"
  | Error Spotify_not_found -> Error "Spotify not found"
  | Error (Invalid_metadata msg) -> Error ("Invalid metadata " ^ msg)
  | Error (Unexpected_error msg) -> Error ("Unexpected error " ^ msg)

(* Command implementations *)
let next () = Lwt_main.run (Backend.next () >|= convert_result)

let play_pause () = Lwt_main.run (Backend.play_pause () >|= convert_result)

let previous () = Lwt_main.run (Backend.previous () >|= convert_result)

let play_album album_name =
  Lwt_main.run (
    Search.search_albums album_name
    >>= (fun results ->
      match results.Paging_t.items with
      | album :: _ -> Backend.play_album album.Album_t.uri
      | [] -> return (Error No_search_results))
    >|= convert_result)

let play_artist artist_name =
  Lwt_main.run (
    Search.search_artists artist_name
    >>= (fun results ->
      match results.Paging_t.items with
      | artist :: _ -> Backend.play_artist artist.Artist_t.uri
      | [] -> return (Error No_search_results))
    >|= convert_result)

let play_track track_name =
  Lwt_main.run (
    Search.search_tracks track_name
    >>= (fun results ->
      match results.Paging_t.items with
      | track :: _ -> Backend.play_track track.Track_t.uri
      | [] -> return (Error No_search_results))
    >|= convert_result)

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
        Lwt_list.iter_s print_key_value data
        >>= fun () -> return (Ok ())
      | Error error -> return (Error error))
    >|= convert_result)
