extends Node2D

#BGM
@onready var music_main_menu: AudioStreamPlayer = $Music/main_menu
@onready var music_phase_1: AudioStreamPlayer = $Music/phase1
@onready var music_bird_boss: AudioStreamPlayer = $Music/bird_boss
@onready var music_robot_boss: AudioStreamPlayer = $Music/robot_boss
@onready var music_final_boss: AudioStreamPlayer = $Music/final_boss

var current_bgm_stream: AudioStreamPlayer

#SFX
@onready var bird_cry: AudioStreamPlayer = $SFX/bird_cry
@onready var failure: AudioStreamPlayer = $SFX/failure
@onready var final_boss_bells: AudioStreamPlayer = $SFX/final_boss_bells
@onready var robot_appear: AudioStreamPlayer = $SFX/robot_appear
@onready var super_victory: AudioStreamPlayer = $SFX/super_victory
@onready var use_potion: AudioStreamPlayer = $SFX/use_potion
@onready var victory: AudioStreamPlayer = $SFX/victory
@onready var attack_woosh: AudioStreamPlayer = $SFX/attack_woosh


func change_music(new_music: AudioStreamPlayer):
	if current_bgm_stream!=new_music:
		if current_bgm_stream:
			fade_audio(current_bgm_stream, 5, false)
		current_bgm_stream = new_music
		fade_audio(current_bgm_stream, 5, true)

func play_music_main_menu():
	change_music(music_main_menu)

func play_music_phase1():
	change_music(music_phase_1)

func play_music_boss(bossIndex: int):
	print("boss: ", bossIndex)
	if bossIndex==1:
		change_music(music_bird_boss)
	elif bossIndex==2:
		change_music(music_robot_boss)
	elif bossIndex==3:
		change_music(music_final_boss)

func fade_out_victory():
	fade_audio(current_bgm_stream, 5, false)
	victory.volume_db = -30.0
	victory.play()

func fade_out_defeat():
	fade_audio(current_bgm_stream, 5, false)
	failure.volume_db = -35.0
	failure.play()

func fade_out_super_victory():
	fade_audio(current_bgm_stream, 5, false)
	super_victory.volume_db = -30.0
	super_victory.play()

func fade_audio(stream: AudioStreamPlayer, time: float, fade_in: bool):
	var start_db = -80.0 if fade_in else stream.volume_db
	var end_db = -40.0 if fade_in else -80.0

	if fade_in:
		stream.volume_db = start_db
		stream.play()

	var tween := create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(stream, "volume_db", end_db, time)
	await tween.finished

	if not fade_in:
		stream.stop()
