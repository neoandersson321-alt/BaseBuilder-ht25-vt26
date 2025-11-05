extends Node


@onready var new_game_button = $MainMenu/Margin/VBox/NewGame
@onready var settings_button = $MainMenu/Margin/VBox/Settings
@onready var about_button = $MainMenu/Margin/VBox/About
@onready var quit_button = $MainMenu/Margin/VBox/Quit

@onready var main_menu = $MainMenu

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	about_button.pressed.connect(_on_about_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed():
	main_menu.queue_free()
	var game_scene = load("res://Scenes/MainScenes/game_scene.tscn").instantiate()
	add_child(game_scene)


func _on_settings_pressed():
	pass


func _on_about_pressed():
	pass

func _on_quit_pressed():
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
