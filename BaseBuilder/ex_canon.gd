extends StaticBody2D
var preview: bool = false

func _ready() -> void:
	if name == "Drag_building":
		preview = true

func _process(delta: float) -> void:
	if preview:
		return
