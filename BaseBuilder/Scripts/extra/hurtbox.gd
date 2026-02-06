extends Area2D

var parent: Node2D
var damage: float

func _ready() -> void:
	parent = get_parent()
	damage = parent.damage
