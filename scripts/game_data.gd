extends Node

# Level progress tracking
var current_level: int = 1
var max_unlocked_level: int = 1
var level_scores: Dictionary = {}  # {level_num: score}
var level_times: Dictionary = {}   # {level_num: time_in_seconds}

# Player stats
var total_score: int = 0

func _ready():
	load_progress()

func complete_level(level_num: int, score: int, time: float):
	# Update scores and times if better
	if not level_scores.has(level_num) or score > level_scores[level_num]:
		level_scores[level_num] = score
	
	if not level_times.has(level_num) or time < level_times[level_num]:
		level_times[level_num] = time
	
	# Unlock next level
	if level_num >= max_unlocked_level:
		max_unlocked_level = level_num + 1
	
	save_progress()

func is_level_unlocked(level_num: int) -> bool:
	return level_num <= max_unlocked_level

func get_level_score(level_num: int) -> int:
	return level_scores.get(level_num, 0)

func get_level_time(level_num: int) -> float:
	return level_times.get(level_num, 0.0)

func reset_progress():
	current_level = 1
	max_unlocked_level = 1
	level_scores.clear()
	level_times.clear()
	total_score = 0
	save_progress()

func save_progress():
	var config = ConfigFile.new()
	config.set_value("progress", "max_unlocked_level", max_unlocked_level)
	config.set_value("progress", "level_scores", level_scores)
	config.set_value("progress", "level_times", level_times)
	config.set_value("progress", "total_score", total_score)
	config.save("user://game_progress.cfg")

func load_progress():
	var config = ConfigFile.new()
	var err = config.load("user://game_progress.cfg")
	if err == OK:
		max_unlocked_level = config.get_value("progress", "max_unlocked_level", 1)
		level_scores = config.get_value("progress", "level_scores", {})
		level_times = config.get_value("progress", "level_times", {})
		total_score = config.get_value("progress", "total_score", 0)
