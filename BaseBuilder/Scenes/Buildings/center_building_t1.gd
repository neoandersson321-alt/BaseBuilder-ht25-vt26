extends Node2D
signal center_building_placed

func _ready() -> void:
	emit_signal("center_building_placed")
