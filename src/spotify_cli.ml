open Lwt
open Lwt_io

module Spotify = Spotify_interfaces.Org_mpris_MediaPlayer2_Player

let run_command command proxy =
  OBus_method.call command proxy ()

let commands =
  [
    "pp", ("Play/pause", Spotify.m_PlayPause);
    "p", ("Previous", Spotify.m_Previous);
    "n", ("Next", Spotify.m_Next);
  ]

(* Print usage text. *)
let usage () =
  let usage_text = [
    "Usage:";
    Printf.sprintf "%s <command>" Sys.argv.(0);
    "";
    "Available commands:";
  ]
  @
  (List.map
    (fun (command, (doc, _)) -> Printf.sprintf "%s: %s" command doc)
    commands)
  in
  List.iter print_endline usage_text

lwt _ =
  let command = begin
    try
      let command_id = Sys.argv.(1) in
      snd (List.assoc command_id commands)
    with _ ->
      usage ();
      exit 1
  end in

  lwt bus = OBus_bus.session () in
  let proxy = Spotify_proxy.of_bus bus in

  try_lwt
    run_command command proxy
  with
    | OBus_bus.Name_has_no_owner _
    | OBus_bus.Service_unknown _ ->
      lwt () = printl "Spotify service not found - is it running?" in
      exit 1
    | exn ->
      raise_lwt exn
