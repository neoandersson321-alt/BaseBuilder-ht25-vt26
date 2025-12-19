extends Area2D

var damage_window: bool = false
var base_modulate: Color
@export var weapon_damage: int

@onready var sprite = $Sprite

signal mineable_hit(mineable: Mineable)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	base_modulate = sprite.modulate

func attack():
	damage_window = true
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.5).timeout
	sprite.modulate = base_modulate
	damage_window = false

func _on_body_entered(body: CharacterBody2D):
	if body.is_in_group("enemies") and damage_window:
		body._take_damage(weapon_damage)

func _on_area_entered(area: Area2D):
	
	if area is Mineable and damage_window:
		mineable_hit.emit(area)
		print(area)
