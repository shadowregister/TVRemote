enum RemoteKey {
  // Power
  power,
  powerOff,
  powerOn,

  // Navigation
  up,
  down,
  left,
  right,
  enter,
  back,
  home,
  menu,

  // Volume
  volumeUp,
  volumeDown,
  mute,

  // Channel
  channelUp,
  channelDown,

  // Playback
  play,
  pause,
  playPause,
  stop,
  rewind,
  fastForward,
  previous,
  next,

  // Numbers
  num0,
  num1,
  num2,
  num3,
  num4,
  num5,
  num6,
  num7,
  num8,
  num9,

  // Input/Source
  source,
  input,

  // Info
  info,
  guide,

  // Colors (for some remotes)
  red,
  green,
  yellow,
  blue,

  // Apps
  netflix,
  youtube,
  amazonPrime,
  disney,
  hulu,

  // Special
  settings,
  search,
  voice,
  keyboard,
}

abstract class RemoteCommand {
  final RemoteKey key;
  final String? customValue;

  const RemoteCommand({required this.key, this.customValue});

  Map<String, dynamic> toJson();
}
