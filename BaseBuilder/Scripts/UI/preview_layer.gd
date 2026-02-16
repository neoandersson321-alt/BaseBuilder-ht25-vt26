extends CanvasLayer

var preview_passive: bool # för att kunna användas globalt i detta script

func set_tower_preview(tower_type, mouse_position, passive: bool):
	preview_passive = passive # sätta preview_passive
	var drag_building = load("res://Scenes/Buildings/" + tower_type + ".tscn").instantiate() # vi sätter ut våran preview-byggnad
	drag_building.set_name("DragBuilding") # sätter deras namn, detta används så de inte ska kunna attackers mm
	drag_building.modulate = Color("91ff63ca") # sätter färgen till grönt
	drag_building.get_child(0).disabled = true # tar bort dess collision
	
	var control = Control.new() # skapar en controlnod som ska få "bära" tornet
	
	if ! preview_passive: # om det är ett skjutande torn
		var range_texture = Sprite2D.new() # sätt ut dess range-textur
		range_texture.position = Vector2.ZERO # sätt positionen till lokala noll
		var scaling = 2.0 * GameData.tower_data[tower_type]["range"]/ 600.0 # viktigt med .0 för att få en float
		# gånger 2.0 då tornen redan skalas up 2 gånger i deras scener
		range_texture.scale = Vector2(scaling, scaling) # sätter range-texturens storlek
		var texture = load("res://Resources/UI/range_overlay.png") #laddar in dess texture
		range_texture.texture = texture # ganska självförklarande
		range_texture.modulate = Color("91ff63ca") # sätter färgen till grön
		control.add_child(range_texture, true) # lägger till range-texturen till control-föräldern

	control.add_child(drag_building, true) # lägger till preview-tornet
	control.global_position = mouse_position # sätter dess position till musens position
	control.set_name("BuildingPreview") # detter controllens namn till det som står
	add_child(control, true) # (.., true) -> namnet blir unkt så det går att referera till på andra ställen
	move_child($BuildingPreview, 0) # här använder vi det namnet för att flytta på noden


func update_tower_preview(new_position, color):
	$BuildingPreview.position = new_position # vi flyttar preview:n
	if $BuildingPreview/DragBuilding.modulate != Color(color): # color i detta fallet kollas i game-scene (grön om det är en korrekt placering, röd annars)
		$BuildingPreview/DragBuilding.modulate = Color(color)
		if $BuildingPreview.has_node("Sprite2D"): # detta är det namnet vi gav till range-texturen
			$BuildingPreview/Sprite2D.modulate = Color(color)
