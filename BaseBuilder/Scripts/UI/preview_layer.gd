extends CanvasLayer


func set_tower_preview(tower_type, mouse_position):
	var drag_building = load("res://Scenes/Buildings/" + tower_type + ".tscn").instantiate()
	drag_building.set_name("DragBuilding")
	drag_building.modulate = Color("91ff63ca")
	drag_building.get_child(0).disabled = true
	
	var range_texture = Sprite2D.new()
	range_texture.position = Vector2.ZERO
	var scaling = GameData.tower_data[tower_type]["range"]/ 600.0 # viktigt med .0 för att få en float
	range_texture.scale = Vector2(scaling, scaling)
	var texture = load("res://Resources/UI/range_overlay.png")
	range_texture.texture = texture
	range_texture.modulate = Color("91ff63ca")
	
	var control = Control.new()
	control.add_child(drag_building, true)
	control.add_child(range_texture, true)
	control.position = mouse_position
	control.set_name("BuildingPreview")
	add_child(control, true)
	move_child($BuildingPreview, 0)


func update_tower_preview(new_position, color):
	$BuildingPreview.position = new_position
	if $BuildingPreview/DragBuilding.modulate != Color(color):
		$BuildingPreview/DragBuilding.modulate = Color(color)
		$BuildingPreview/Sprite2D.modulate = Color(color)
