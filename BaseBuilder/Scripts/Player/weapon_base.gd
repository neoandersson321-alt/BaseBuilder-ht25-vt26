extends Area2D

var attack_window: bool = false
var base_modulate: Color
var attack_time = 0.5
@export var weapon_damage: int

@onready var sprite = $Sprite

signal attack_started

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	base_modulate = sprite.modulate

func attack():
	attack_window = true
	emit_signal("attack_started")
	sprite.modulate = Color.RED
	
	await get_tree().create_timer(attack_time).timeout
	
	sprite.modulate = base_modulate
	attack_window = false

func _on_body_entered(body: CharacterBody2D):
	if body.is_in_group("enemies") and attack_window:
		body._take_damage(weapon_damage)
