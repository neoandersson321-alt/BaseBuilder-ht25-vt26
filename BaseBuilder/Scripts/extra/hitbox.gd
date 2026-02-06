extends Area2D

var parent: Node2D # ägar scenen

func _ready() -> void:
	parent = get_parent()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		print(area.damage)
