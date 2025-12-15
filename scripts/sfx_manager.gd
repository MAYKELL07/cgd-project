extends Node

# SFX references - organized and cleaned audio files
var sfx_jump: AudioStream = preload("res://Audio/SFX/jump.mp3")
var sfx_land: AudioStream = preload("res://Audio/SFX/land.wav")
var sfx_attack: AudioStream = preload("res://Audio/SFX/attack.wav")
var sfx_damage: AudioStream = preload("res://Audio/SFX/damage.wav")
var sfx_heal: AudioStream = preload("res://Audio/SFX/heal.wav")
var sfx_enemy_death: AudioStream = preload("res://Audio/SFX/enemy_death.mp3")
var sfx_collect: AudioStream = preload("res://Audio/SFX/collect.wav")
var sfx_complete: AudioStream = preload("res://Audio/SFX/level_complete.wav")
var sfx_game_over: AudioStream = preload("res://Audio/SFX/game_over.mp3")
var sfx_button_click: AudioStream = preload("res://Audio/SFX/button_click.mp3")
var sfx_button_hover: AudioStream = preload("res://Audio/SFX/jump.mp3")  # Using jump sound for hover
var sfx_menu_open: AudioStream = preload("res://Audio/SFX/menu_open.wav")
var sfx_powerup: AudioStream = preload("res://Audio/SFX/collect.wav")

# Helper functions to play sounds through AudioManager
func play_jump():
	AudioManager.play_sfx(sfx_jump)

func play_land():
	AudioManager.play_sfx(sfx_land)

func play_attack():
	AudioManager.play_sfx(sfx_attack)

func play_damage():
	AudioManager.play_sfx(sfx_damage)

func play_heal():
	AudioManager.play_sfx(sfx_heal)

func play_enemy_death():
	AudioManager.play_sfx(sfx_enemy_death)

func play_collect():
	AudioManager.play_sfx(sfx_collect)

func play_complete():
	AudioManager.play_sfx(sfx_complete)

func play_game_over():
	AudioManager.play_sfx(sfx_game_over)

func play_button_click():
	AudioManager.play_sfx(sfx_button_click)

func play_button_hover():
	AudioManager.play_sfx(sfx_button_hover)

func play_menu_open():
	AudioManager.play_sfx(sfx_menu_open)

func play_powerup():
	AudioManager.play_sfx(sfx_powerup)
