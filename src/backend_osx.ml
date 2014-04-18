open Lwt
open Types

let (|>) x f = f x

(* Call osascript, and pass it a script over stdin. *)
let osascript_command = ("osascript", [|"osascript"; "-"|])

let script args =
  Printf.sprintf
    "tell app \"Spotify\" to %s"
    (String.concat " " args)

let run script =
  Lwt_process.pwrite_line ~stdout:`Dev_null osascript_command script

let run_get_stdout script =
  Lwt_process.pmap_line osascript_command script

let is_running () =
  run_get_stdout "get running of application \"Spotify\""
  >>= (function | "true" -> return true | _ -> return false)

let ok x = return (Ok x)

let with_check_return_ok f =
  is_running ()
  >>= (function | true -> f () >>= ok | false -> return Spotify_not_found)

let next () =
  with_check_return_ok
    (fun () -> ["next"; "track"] |> script |> run)

let play_pause () =
  with_check_return_ok
    (fun () -> ["playpause"] |> script |> run)

let previous () =
  with_check_return_ok
    (fun () -> ["previous"; "track"] |> script |> run)

let quote str =
  Printf.sprintf "\"%s\"" str

let play_album album_name =
  lwt results = Spotify_search.search_albums album_name in
  match results.Spotify_search_t.albums with
  | album :: _ ->
    with_check_return_ok
      (fun () ->
        ["play"; "track"; quote album.Spotify_search_t.album_href]
        |> script |> run)
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
    with_check_return_ok
      (fun () -> ["play"; "track"; quote href] |> script |> run)
  | None -> return No_search_results

let play_track track_name =
  lwt results = Spotify_search.search_tracks track_name in
  match results.Spotify_search_t.tracks with
  | track :: _ ->
    with_check_return_ok
      (fun () ->
        ["play"; "track"; quote track.Spotify_search_t.track_href]
        |> script |> run)
  | [] -> return No_search_results

let now_playing () =
  with_check_return_ok
    (fun () ->
      lwt artist =
        ["get"; "artist"; "of"; "current"; "track"]
        |> script |> run_get_stdout in
      lwt title =
        ["get"; "name"; "of"; "current"; "track"]
        |> script |> run_get_stdout in
      return {artists = [artist]; title})
