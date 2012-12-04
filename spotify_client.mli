
module Org_mpris_MediaPlayer2 : sig
  val raise : OBus_proxy.t -> unit Lwt.t
  val quit : OBus_proxy.t -> unit Lwt.t
  val can_quit : OBus_proxy.t -> (bool, [ `readable ]) OBus_property.t
  val can_raise : OBus_proxy.t -> (bool, [ `readable ]) OBus_property.t
  val has_track_list : OBus_proxy.t -> (bool, [ `readable ]) OBus_property.t
  val identity : OBus_proxy.t -> (string, [ `readable ]) OBus_property.t
  val desktop_entry : OBus_proxy.t -> (string, [ `readable ]) OBus_property.t
  val supported_uri_schemes : OBus_proxy.t -> (string list, [ `readable ]) OBus_property.t
  val supported_mime_types : OBus_proxy.t -> (string list, [ `readable ]) OBus_property.t
end

module Org_mpris_MediaPlayer2_Player : sig
  val next : OBus_proxy.t -> unit Lwt.t
  val previous : OBus_proxy.t -> unit Lwt.t
  val pause : OBus_proxy.t -> unit Lwt.t
  val play_pause : OBus_proxy.t -> unit Lwt.t
  val stop : OBus_proxy.t -> unit Lwt.t
  val play : OBus_proxy.t -> unit Lwt.t
  val seek : OBus_proxy.t -> offset : int64 -> unit Lwt.t
  val set_position : OBus_proxy.t -> trackId : OBus_proxy.t -> position : int64 -> unit Lwt.t
  val open_uri : OBus_proxy.t -> string -> unit Lwt.t
  val seeked : OBus_proxy.t -> int64 OBus_signal.t
  val playback_status : OBus_proxy.t -> (string, [ `readable ]) OBus_property.t
  val loop_status : OBus_proxy.t -> (string, [ `readable | `writable ]) OBus_property.t
  val rate : OBus_proxy.t -> (float, [ `readable | `writable ]) OBus_property.t
  val shuffle : OBus_proxy.t -> (bool, [ `readable | `writable ]) OBus_property.t
  val metadata : OBus_proxy.t -> ((string * OBus_value.V.single) list, [ `readable ]) OBus_property.t
  val volume : OBus_proxy.t -> (float, [ `readable | `writable ]) OBus_property.t
  val position : OBus_proxy.t -> (int64, [ `readable ]) OBus_property.t
  val minimum_rate : OBus_proxy.t -> (float, [ `readable ]) OBus_property.t
  val maximum_rate : OBus_proxy.t -> (float, [ `readable ]) OBus_property.t
  val can_go_next : OBus_proxy.t -> (bool, [ `readable ]) OBus_property.t
  val can_go_previous : OBus_proxy.t -> (bool, [ `readable ]) OBus_property.t
  val can_play : OBus_proxy.t -> (bool, [ `readable ]) OBus_property.t
  val can_pause : OBus_proxy.t -> (bool, [ `readable ]) OBus_property.t
  val can_seek : OBus_proxy.t -> (bool, [ `readable ]) OBus_property.t
  val can_control : OBus_proxy.t -> (bool, [ `readable ]) OBus_property.t
end
