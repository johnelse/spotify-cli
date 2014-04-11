open Lwt
open Lwt_io
open Types

(* Command implementations *)
let next () = Lwt_main.run (Backend.next ())

let play_pause () = Lwt_main.run (Backend.play_pause ())

let previous () = Lwt_main.run (Backend.previous ())

let play_album album_name =
  Lwt_main.run (Backend.play_album album_name)

let play_artist artist_name =
  Lwt_main.run (Backend.play_artist artist_name)

let play_track track_name =
  Lwt_main.run (Backend.play_track track_name)

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
