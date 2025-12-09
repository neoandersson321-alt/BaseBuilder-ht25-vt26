extends StaticBody2D

@onready var game_scene: Node2D = get_node("res://Scenes/MainScenes/game_scene.tscn")
@export var mine_amount: int


func _on_area_entered(area: Node2D) -> void:
	if area == Pickaxe:
		gain_resource()


func gain_resource():
	game_scene.add_resource(name, mine_amount)
