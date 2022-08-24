type error =
  | No_search_results
  | Spotify_not_found
  | Invalid_metadata of string
  | Unexpected_error of string

type 'a command_result = ('a, error) result

type metadata = {
  artists: string list;
  title: string;
  http_url: string;
}

type parse_result =
  | Metadata of metadata
  | Parse_failure of string
