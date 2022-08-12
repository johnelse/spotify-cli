open Lwt
open Spotify_web_api
open Spotify_cli_types

module type INPUT = sig
  val next: unit -> (unit command_result) Lwt.t
  val play_pause: unit -> (unit command_result) Lwt.t
  val previous: unit -> (unit command_result) Lwt.t

  val play_album: string -> (unit command_result) Lwt.t
  val play_artist: string -> (unit command_result) Lwt.t
  val play_track: string -> (unit command_result) Lwt.t

  val now_playing: unit -> (metadata command_result) Lwt.t
end

module type S = sig
  val next: unit -> (unit command_result)
  val play_pause: unit -> (unit command_result)
  val previous: unit -> (unit command_result)

  val play_album: string -> (unit command_result)
  val play_artist: string -> (unit command_result)
  val play_track: string -> (unit command_result)

  val now_playing: unit -> (unit command_result)
end

(* Command implementations *)
module Make (Input : INPUT) : S = struct
  let next () = Lwt_main.run (Input.next ())

  let play_pause () = Lwt_main.run (Input.play_pause ())

  let previous () = Lwt_main.run (Input.previous ())

  let play_album album_name =
    Lwt_main.run (
      Search.search_albums album_name
      >>= fun results ->
        match results.Paging_t.items with
        | album :: _ -> Input.play_album album.Album_t.uri
        | [] -> return No_search_results)

  let play_artist artist_name =
    Lwt_main.run (
      Search.search_artists artist_name
      >>= fun results ->
        match results.Paging_t.items with
        | artist :: _ -> Input.play_artist artist.Artist_t.uri
        | [] -> return No_search_results)

  let play_track track_name =
    Lwt_main.run (
      Search.search_tracks track_name
      >>= fun results ->
        match results.Paging_t.items with
        | track :: _ -> Input.play_track track.Track_t.uri
        | [] -> return No_search_results)

  let print_key_value (key, value) =
    Lwt_io.printlf "%s=\"%s\"" key value

  let now_playing () =
    Lwt_main.run
      (Input.now_playing () >>= (function
        | Ok {artists; title; http_url} ->
          let data = [
            "spotify_artist_name", (String.concat ", " artists);
            "spotify_track_name", title;
            "spotify_http_url", http_url;
          ] in
          Lwt_list.iter_s print_key_value data
          >>= fun () -> return (Ok ())
        | Spotify_not_found -> return Spotify_not_found
        | No_search_results -> return No_search_results
        | Invalid_metadata msg -> return (Invalid_metadata msg)
        | Unexpected_error msg -> return (Unexpected_error msg)))
end

let make () : (module S)=
  let unsupported_plateform () = failwith "Unsupported platform!" in 
    if Sys.win32 then
      unsupported_plateform ()
    else
      let uname = Lwt_main.run (Lwt_process.pread_line ("uname", [|"-s"|])) in
      match uname with
      | "Linux" -> (module Make (Backend_linux))
      | "Darwin" -> (module Make (Backend_osx))
      | _ -> unsupported_plateform ()
