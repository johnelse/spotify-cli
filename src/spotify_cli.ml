open Cmdliner

let help man_format cmds topic =
  match topic with
  | None -> `Help (`Pager, None)
  | Some topic ->
    let topics = "topics" :: cmds in
    let conv, _ = Arg.enum (List.rev_map (fun s -> (s, s)) topics) in
    match conv topic with
    | `Error e -> `Error (false, e)
    | `Ok t when t = "topics" -> List.iter print_endline topics; `Ok ()
    | `Ok t when List.mem t cmds -> `Help (man_format, Some t)
    | `Ok t ->
      let page = (topic, 7, "", "", ""), [`S topic; `P "Say something"] in
      `Ok (Manpage.print man_format Format.std_formatter page)

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
  Term.(pure Spotify_commands.next $ pure ()),
  Term.info "next" ~doc ~man

let play_pause_cmd =
  let doc = "toggle between playing and paused states" in
  let man = [
    `S "DESCRIPTION";
    `P "Start spotify playing if it is paused, otherwise pause it.";
  ] @ help_secs in
  Term.(pure Spotify_commands.play_pause $ pure ()),
  Term.info "play-pause" ~doc ~man

let previous_cmd =
  let doc = "switch to the previous track" in
  let man = [
    `S "DESCRIPTION";
    `P "Switch to the previous track in the current playlist.";
  ] @ help_secs in
  Term.(pure Spotify_commands.previous $ pure ()),
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
