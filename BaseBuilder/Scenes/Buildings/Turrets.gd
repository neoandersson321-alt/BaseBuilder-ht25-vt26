extends Node2D

@onready var Turret = $Turret

func _physics_process(delta: float) -> void:
	_turn()


func _turn():
	var enemy_position = get_global_mouse_position()
	Turret.look_at(enemy_position)
