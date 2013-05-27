open Cmdliner
open Lwt
open Lwt_io

module Spotify = Spotify_client.Org_mpris_MediaPlayer2_Player

let with_proxy f =
  lwt bus = OBus_bus.session () in
  let proxy = Spotify_proxy.of_bus bus in
  try_lwt
    f proxy
  with
    | OBus_bus.Name_has_no_owner _
    | OBus_bus.Service_unknown _ ->
      lwt () = printl "Spotify service not found - is it running?" in
      exit 1
    | exn ->
      raise_lwt exn

(* Command implementations *)
let help man_format cmds topic =
  match topic with
  | None -> `Help (`Pager, None)
  | Some topic ->
    let topics = "topics" :: cmds in
    let conv, _ = Cmdliner.Arg.enum (List.rev_map (fun s -> (s, s)) topics) in
    match conv topic with
    | `Error e -> `Error (false, e)
    | `Ok t when t = "topics" -> List.iter print_endline topics; `Ok ()
    | `Ok t when List.mem t cmds -> `Help (man_format, Some t)
    | `Ok t ->
      let page = (topic, 7, "", "", ""), [`S topic; `P "Say something"] in
      `Ok (Manpage.print man_format Format.std_formatter page)

let next () =
  Lwt_main.run (with_proxy Spotify.next)

let play_pause () =
  Lwt_main.run (with_proxy Spotify.play_pause)

let previous () =
  Lwt_main.run (with_proxy Spotify.previous)

(* Command definitions *)
let help_secs = [
  `S "MORE HELP";
  `P "Use `$(mname) $(i,command) --help' for help on a single command.";
  `Noblank;
]

let help_cmd =
  let topic =
    let doc = "The topic to get help on. `topics' lists the topics." in
    Arg.(value & pos 0 (some string) None & info [] ~docv:"TOPIC" ~doc)
  in
  let doc = "display help about spotify-cli" in
  let man = [
    `S "DESCRIPTION";
    `P "Prints help about spotify-cli commands."
  ] @ help_secs in
  Term.(ret (pure help $ Term.man_format $ Term.choice_names $ topic)),
  Term.info "help" ~doc ~man

let next_cmd =
  let doc = "switch to the next track" in
  let man = [
    `S "DESCRIPTION";
    `P "Switch to the next track in the current playlist.";
  ] @ help_secs in
  Term.(pure next $ pure ()),
  Term.info "next" ~doc ~man

let play_pause_cmd =
  let doc = "toggle between playing and paused states" in
  let man = [
    `S "DESCRIPTION";
    `P "Start spotify playing if it is paused, otherwise pause it.";
  ] @ help_secs in
  Term.(pure play_pause $ pure ()),
  Term.info "play_pause" ~doc ~man

let previous_cmd =
  let doc = "switch to the previous track" in
  let man = [
    `S "DESCRIPTION";
    `P "Switch to the previous track in the current playlist.";
  ] @ help_secs in
  Term.(pure previous $ pure ()),
  Term.info "previous" ~doc ~man

let default_cmd =
  let doc = "Spotify CLI" in
  let man = help_secs in
  Term.(ret (pure (fun _ -> `Help (`Pager, None)) $ pure ())),
  Term.info "spotify-cli" ~version:"0.1" ~doc ~man

let cmds = [
  help_cmd;
  next_cmd;
  play_pause_cmd;
  previous_cmd;
]

let () =
  Printexc.record_backtrace true;
  try
    match Term.eval_choice default_cmd cmds with
    | `Error _ -> exit 1
    | _ -> exit 0
  with e ->
    Printf.printf "Error: exception %s\n" (Printexc.to_string e)
