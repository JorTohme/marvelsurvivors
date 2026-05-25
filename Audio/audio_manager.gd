extends Node

const SFX_PATH := "res://Audio/SFX/"
const MUSIC_PATH := "res://Audio/Music/"

var _sfx_cache: Dictionary = {}
var _music_player: AudioStreamPlayer
var _current_music: String = ""

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

func play_sfx(name: String) -> void:
	var stream := _load_audio(SFX_PATH + name)
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "SFX"
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

func play_music(name: String, loop: bool = true) -> void:
	if _current_music == name and _music_player.playing:
		return
	var stream := _load_audio(MUSIC_PATH + name)
	if stream == null:
		return
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = loop
	_current_music = name
	_music_player.stream = stream
	_music_player.volume_db = -18.0
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()
	_current_music = ""

func _load_audio(path: String) -> AudioStream:
	if _sfx_cache.has(path):
		return _sfx_cache[path]
	for ext: String in ["ogg", "mp3", "wav"]:
		var full := path + "." + ext
		if ResourceLoader.exists(full):
			var stream: AudioStream = load(full)
			_sfx_cache[path] = stream
			return stream
	push_warning("AudioManager: no se encontró audio en '%s'" % path)
	return null
