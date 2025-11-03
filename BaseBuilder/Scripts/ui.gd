extends CanvasLayer

func set_tower_preview(tower_type, mouse_position):
	var drag_building = load("res://Scenes/Buildings/" + tower_type + ".tscn").instantiate()
	drag_building.set_name("Drag_building")
	drag_building.modulate = Color("ad54ff3c")
	drag_building.z_index = 100
	
	"res://Scenes/Buildings/GunT1.tscn"
	
	var control = Control.new()
	control.add_child(drag_building, true)
	control.position = mouse_position
	control.set_name("Building_preview")
	add_child(control, true)
