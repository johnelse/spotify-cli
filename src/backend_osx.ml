open Lwt
open Types

(* OCaml 4.00.1 compatibility. *)
let (|>) x f = f x

(* Call osascript such that it will expect to receive a script over stdin. *)
let osascript_command = ("osascript", [|"osascript"; "-"|])

(* Convert a list of strings into an applescript string targeting Spotify. *)
let script args =
  Printf.sprintf
    "tell app \"Spotify\" to %s"
    (String.concat " " args)

let quote str =
  Printf.sprintf "\"%s\"" str

(* Send a script string to osascript, ignoring stdout. *)
let run script =
  Lwt_process.pwrite_line ~stdout:`Dev_null osascript_command script

(* Send a script string to osascript, returning stdout. *)
let run_get_stdout script =
  Lwt_process.pmap_line osascript_command script

(* Determine whether Spotify is running. *)
let is_running () =
  run_get_stdout "get running of application \"Spotify\""
  >>= (function | "true" -> return true | _ -> return false)

let ok x = return (Ok x)

(* Check that Spotify is running; if it is, call f and return the result
 * wrapped in Ok. *)
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

let play_album album_href =
  with_check_return_ok
    (fun () -> ["play"; "track"; quote album_href] |> script |> run)

let play_artist artist_href =
  with_check_return_ok
    (fun () -> ["play"; "track"; quote artist_href] |> script |> run)

let play_track track_href =
  with_check_return_ok
    (fun () -> ["play"; "track"; quote track_href] |> script |> run)

let convert_url spotify_url =
  Scanf.sscanf spotify_url "spotify:track:%s"
    (fun id -> Printf.sprintf "https://open.spotify.com/track/%s" id)

let now_playing () =
  with_check_return_ok
    (fun () ->
      lwt artist =
        ["get"; "artist"; "of"; "current"; "track"]
        |> script |> run_get_stdout in
      lwt title =
        ["get"; "name"; "of"; "current"; "track"]
        |> script |> run_get_stdout in
      lwt http_url =
        ["get"; "spotify"; "url"; "of"; "current"; "track"]
        |> script |> run_get_stdout >|= convert_url in
return {artists = [artist]; title; http_url})
