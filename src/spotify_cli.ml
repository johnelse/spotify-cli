open Cmdliner

module Ty = Spotify_cli_types

let help man_format cmds topic =
  match topic with
  | None -> `Help (`Pager, None)
  | Some topic ->
    let topics = "topics" :: cmds in
    let conv, _ = Arg.enum (List.rev_map (fun s -> (s, s)) topics) in
    match conv topic with
    | `Error e -> `Error (false, e)
    | `Ok t when t = "topics" ->
      List.iter print_endline topics;
      `Ok (Ok ())
    | `Ok t when List.mem t cmds -> `Help (man_format, Some t)
    | `Ok _ ->
      let page = (topic, 7, "", "", ""), [`S topic; `P "Say something"] in
      Manpage.print man_format Format.std_formatter page;
      `Ok (Ok ())

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
  Cmd.v
    (Cmd.info "help" ~doc ~man)
    (Term.(ret (const help $ Arg.man_format $ Term.choice_names $ topic)))

let next_cmd =
  let doc = "switch to the next track" in
  let man = [
    `S "DESCRIPTION";
    `P "Switch to the next track in the current playlist.";
  ] @ help_secs in
  Cmd.v
    (Cmd.info "next" ~doc ~man)
    (Term.(const Commands.next $ const ()))

let now_playing_cmd =
  let doc = "print track metadata" in
  let man = [
    `S "DESCRIPTION";
    `P "Print metadata about the currently-playing track";
  ] @ help_secs in
  Cmd.v
    (Cmd.info "now-playing" ~doc ~man)
    (Term.(const Commands.now_playing $ const ()))

let play_album_cmd =
  let album_name =
    let doc = "The album name to use as a search string" in
    Arg.(required & pos 0 (some string) None & info [] ~docv:"NAME" ~doc)
  in
  let doc = "play an album" in
  let man = [
    `S "DESCRIPTION";
    `P "Search for an album using the spotify metadata API, then play the first result"
  ] @ help_secs in
  Cmd.v
    (Cmd.info "play-album" ~doc ~man)
    (Term.(const Commands.play_album $ album_name))

let play_artist_cmd =
  let artist_name =
    let doc = "The artist name to use as a search string" in
    Arg.(required & pos 0 (some string) None & info [] ~docv:"NAME" ~doc)
  in
  let doc = "play an artist" in
  let man = [
    `S "DESCRIPTION";
    `P "Search for an artist using the spotify metadata API, then play the first result"
  ] @ help_secs in
  Cmd.v
    (Cmd.info "play-artist" ~doc ~man)
    (Term.(const Commands.play_artist $ artist_name))

let play_pause_cmd =
  let doc = "toggle between playing and paused states" in
  let man = [
    `S "DESCRIPTION";
    `P "Start spotify playing if it is paused, otherwise pause it.";
  ] @ help_secs in
  Cmd.v
    (Cmd.info "play-pause" ~doc ~man)
    (Term.(const Commands.play_pause $ const ()))

let play_track_cmd =
  let track_name =
    let doc = "The track to use as a search string" in
    Arg.(required & pos 0 (some string) None & info [] ~docv:"NAME" ~doc)
  in
  let doc = "play a track" in
  let man = [
    `S "DESCRIPTION";
    `P "Search for a track using the spotify metadata API, then play the first result"
  ] @ help_secs in
  Cmd.v
    (Cmd.info "play-track" ~doc ~man)
    (Term.(const Commands.play_track $ track_name))

let previous_cmd =
  let doc = "switch to the previous track" in
  let man = [
    `S "DESCRIPTION";
    `P "Switch to the previous track in the current playlist.";
  ] @ help_secs in
  Cmd.v
    (Cmd.info "previous" ~doc ~man)
    (Term.(const Commands.previous $ const ()))

let default_cmd =
  let doc = "Spotify CLI" in
  let man = help_secs in
  Term.(ret (const (fun _ -> `Help (`Pager, None)) $ const ())),
  Cmd.info "spotify-cli" ~version:"0.1" ~doc ~man

let cmds = [
  help_cmd;
  next_cmd;
  now_playing_cmd;
  play_album_cmd;
  play_artist_cmd;
  play_pause_cmd;
  play_track_cmd;
  previous_cmd;
]

let () =
  Printexc.record_backtrace true;
  let group = Cmd.group ~default:(fst default_cmd) (snd default_cmd) cmds in
  exit (Cmd.eval_result group)
