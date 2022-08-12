open Cmdliner

module Ty = Spotify_cli_types
module Commands = (val Commands.make ()) 

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
      `Ok (Ty.Ok ())
    | `Ok t when List.mem t cmds -> `Help (man_format, Some t)
    | `Ok _ ->
      let page = (topic, 7, "", "", ""), [`S topic; `P "Say something"] in
      Manpage.print man_format Format.std_formatter page;
      `Ok (Ty.Ok ())

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
  Term.(pure Commands.next $ pure ()),
  Term.info "next" ~doc ~man

let now_playing_cmd =
  let doc = "print track metadata" in
  let man = [
    `S "DESCRIPTION";
    `P "Print metadata about the currently-playing track";
  ] @ help_secs in
  Term.(pure Commands.now_playing $ pure ()),
  Term.info "now-playing" ~doc ~man

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
  Term.(pure Commands.play_album $ album_name),
  Term.info "play-album" ~doc ~man

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
  Term.(pure Commands.play_artist $ artist_name),
  Term.info "play-artist" ~doc ~man

let play_pause_cmd =
  let doc = "toggle between playing and paused states" in
  let man = [
    `S "DESCRIPTION";
    `P "Start spotify playing if it is paused, otherwise pause it.";
  ] @ help_secs in
  Term.(pure Commands.play_pause $ pure ()),
  Term.info "play-pause" ~doc ~man

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
  Term.(pure Commands.play_track $ track_name),
  Term.info "play-track" ~doc ~man

let previous_cmd =
  let doc = "switch to the previous track" in
  let man = [
    `S "DESCRIPTION";
    `P "Switch to the previous track in the current playlist.";
  ] @ help_secs in
  Term.(pure Commands.previous $ pure ()),
  Term.info "previous" ~doc ~man

let default_cmd =
  let doc = "Spotify CLI" in
  let man = help_secs in
  Term.(ret (pure (fun _ -> `Help (`Pager, None)) $ pure ())),
  Term.info "spotify-cli" ~version:"0.1" ~doc ~man

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
  match Term.eval_choice default_cmd cmds with
  | `Error _ -> exit 1
  | `Version | `Help -> ()
  | `Ok (Ty.Ok ()) -> ()
  | `Ok Ty.No_search_results ->
    Printf.printf "Search found no results\n";
    exit 1
  | `Ok Ty.Spotify_not_found ->
    Printf.printf "Spotify service not found - is it running?\n";
    exit 1
  | `Ok Ty.Invalid_metadata msg ->
    Printf.printf "Could not understand the received metadata: %s\n" msg;
    exit 1
  | `Ok Ty.Unexpected_error msg ->
    Printf.printf "An unexpected error occurred: %s\n" msg;
    exit 1
