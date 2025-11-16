extends Node

# Audio players
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Volume settings (0.0 to 1.0)
var music_volume: float = 0.7
var sfx_volume: float = 0.8

# Audio streams - will be loaded as needed
var current_music: AudioStream = null

func _ready():
	# Create audio players
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	
	# Load saved settings
	load_settings()
	apply_volumes()

func play_music(music_stream: AudioStream, fade_duration: float = 1.0):
	if current_music == music_stream and music_player.playing:
		return
	
	# Fade out current music
	if music_player.playing and fade_duration > 0:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, fade_duration)
		tween.tween_callback(func():
			music_player.stop()
			_start_new_music(music_stream, fade_duration)
		)
	else:
		_start_new_music(music_stream, fade_duration)

func _start_new_music(music_stream: AudioStream, fade_duration: float):
	current_music = music_stream
	music_player.stream = music_stream
	music_player.volume_db = -80 if fade_duration > 0 else linear_to_db(music_volume)
	music_player.play()
	
	if fade_duration > 0:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), fade_duration)

func stop_music(fade_duration: float = 1.0):
	if not music_player.playing:
		return
	
	if fade_duration > 0:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, fade_duration)
		tween.tween_callback(func():
			music_player.stop()
			current_music = null
		)
	else:
		music_player.stop()
		current_music = null

func play_sfx(sfx_stream: AudioStream):
	if not sfx_stream:
		return
	
	# Create a one-shot player for this sound
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = sfx_stream
	player.volume_db = linear_to_db(sfx_volume)
	add_child(player)
	player.play()
	
	# Remove when finished
	player.finished.connect(func():
		player.queue_free()
	)

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	apply_volumes()
	save_settings()

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	apply_volumes()
	save_settings()

func apply_volumes():
	if music_player and music_player.playing:
		music_player.volume_db = linear_to_db(music_volume)
	
	# SFX volume will be applied to individual players when created

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save("user://audio_settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	if err == OK:
		music_volume = config.get_value("audio", "music_volume", 0.7)
		sfx_volume = config.get_value("audio", "sfx_volume", 0.8)

func linear_to_db(linear: float) -> float:
	if linear <= 0:
		return -80
	return 20 * log(linear) / log(10)
