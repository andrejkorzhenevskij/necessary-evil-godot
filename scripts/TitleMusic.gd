extends Node

const TITLE_THEME_PATHS := [
	"res://audio/title_theme.mp3",
	"res://audio/title_theme.ogg",
]
const DEFAULT_VOLUME_DB := -14.0

var player: AudioStreamPlayer
var current_stream_path := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player = AudioStreamPlayer.new()
	player.name = "TitleThemePlayer"
	player.volume_db = DEFAULT_VOLUME_DB
	player.bus = _resolve_audio_bus()
	add_child(player)


func ensure_title_theme() -> void:
	if player == null:
		return

	var stream_data := _load_title_theme()
	if stream_data.is_empty():
		return

	var stream_path := str(stream_data.get("path", ""))
	var stream := stream_data.get("stream") as AudioStream

	if stream == null:
		return

	if player.playing and current_stream_path == stream_path:
		return

	if current_stream_path != stream_path:
		player.stream = stream
		current_stream_path = stream_path

	if not player.playing:
		player.play()


func ensure_playing() -> void:
	ensure_title_theme()


func stop_playback() -> void:
	if player != null and player.playing:
		player.stop()


func _load_title_theme() -> Dictionary:
	for path: String in TITLE_THEME_PATHS:
		if not ResourceLoader.exists(path):
			continue

		var stream := load(path)
		if stream is AudioStream:
			var audio_stream := (stream as AudioStream).duplicate()
			if audio_stream is AudioStreamOggVorbis:
				(audio_stream as AudioStreamOggVorbis).loop = true
			elif audio_stream is AudioStreamMP3:
				(audio_stream as AudioStreamMP3).loop = true
			return {
				"path": path,
				"stream": audio_stream,
			}

	return {}


func _resolve_audio_bus() -> String:
	return "Music" if AudioServer.get_bus_index("Music") != -1 else "Master"
