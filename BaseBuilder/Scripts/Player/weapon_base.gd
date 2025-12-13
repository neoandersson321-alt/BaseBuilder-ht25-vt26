extends Area2D

var damage_window: bool = false
@export var weapon_damage: int
func attack():
	damage_window = true
	await get_tree().create_timer(0.5).timeout
	damage_window = false

func _on_body_entered(body: CharacterBody2D):
	if body.is_in_group("enemies") and damage_window:
		body._take_damage(weapon_damage)
