extends CanvasLayer

var preview_passive: bool

func set_tower_preview(tower_type, mouse_position, passive: bool):
	preview_passive = passive
	var drag_building = load("res://Scenes/Buildings/" + tower_type + ".tscn").instantiate()
	drag_building.set_name("DragBuilding")
	drag_building.modulate = Color("91ff63ca")
	drag_building.get_child(0).disabled = true
	
	var control = Control.new()
	
	if ! preview_passive:
		var range_texture = Sprite2D.new()
		range_texture.position = Vector2.ZERO
		var scaling = 2.0 * GameData.tower_data[tower_type]["range"]/ 600.0 # viktigt med .0 för att få en float
		range_texture.scale = Vector2(scaling, scaling)
		var texture = load("res://Resources/UI/range_overlay.png")
		range_texture.texture = texture
		range_texture.modulate = Color("91ff63ca")
		control.add_child(range_texture, true)

	control.add_child(drag_building, true)
	control.position = mouse_position
	control.set_name("BuildingPreview")
	add_child(control, true)
	move_child($BuildingPreview, 0)


func update_tower_preview(new_position, color):
	$BuildingPreview.position = new_position
	if $BuildingPreview/DragBuilding.modulate != Color(color):
		$BuildingPreview/DragBuilding.modulate = Color(color)
		if $BuildingPreview.has_node("Sprite2D"):
			$BuildingPreview/Sprite2D.modulate = Color(color)
