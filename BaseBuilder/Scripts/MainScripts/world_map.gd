extends Node

@onready var wall_layer = $WallLayer

const TERRAIN_SET := 0
const TERRAIN := 0

var walls := {}  # Vector2i -> data


func place_wall(cell: Vector2i) -> void:
	if walls.has(cell):
		return

	walls[cell] = { "hp": 100 }

	wall_layer.set_cells_terrain_connect(
		[cell],
		TERRAIN_SET,
		TERRAIN
	)


func damage_wall(cell: Vector2i, amount: int) -> void:
	if not walls.has(cell):
		return

	walls[cell].hp -= amount

	if walls[cell].hp <= 0:
		remove_wall(cell)
