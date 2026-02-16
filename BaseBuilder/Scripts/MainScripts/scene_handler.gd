extends Node


@onready var new_game_button = $MainMenu/Margin/VBox/NewGame
@onready var settings_button = $MainMenu/Margin/VBox/Settings
@onready var about_button = $MainMenu/Margin/VBox/About
@onready var quit_button = $MainMenu/Margin/VBox/Quit

@onready var main_menue = $MainMenu

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	about_button.pressed.connect(_on_about_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed():
	main_menue.queue_free()
	var game_scene = load("res://Scenes/MainScenes/game_scene.tscn").instantiate()
	game_scene.main_menue.connect(_back_to_main_menue)
	game_scene.retry.connect(_retry)
	add_child(game_scene)

func _back_to_main_menue():
	get_tree().paused = false
	get_child(0).queue_free()
	var main_menue = load("res://Scenes/UI/main_menu.tscn").instantiate()
	add_child(main_menue)
	reconnect_buttons()

func _retry():
	get_tree().paused = false
	get_child(0).queue_free()
	var game_scene = load("res://Scenes/MainScenes/game_scene.tscn").instantiate()
	game_scene.main_menue.connect(_back_to_main_menue)
	game_scene.retry.connect(_retry)
	add_child(game_scene)

func reconnect_buttons():
	new_game_button = $MainMenu/Margin/VBox/NewGame
	settings_button = $MainMenu/Margin/VBox/Settings
	about_button = $MainMenu/Margin/VBox/About
	quit_button = $MainMenu/Margin/VBox/Quit
	main_menue = $MainMenu
	
	
	new_game_button.pressed.connect(_on_new_game_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	about_button.pressed.connect(_on_about_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
func _on_settings_pressed():
	pass


func _on_about_pressed():
	pass

func _on_quit_pressed():
	get_tree().quit()
