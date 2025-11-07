extends Node2D

@onready var turret = $Turret
@onready var upgrade_button: Button = $UpgradeButton
@onready var game_scene: Node2D = get_parent().get_parent().get_parent()


signal upgrade_button_pressed

func _ready() -> void:
	if name != "DragBuilding":
		upgrade_button.pressed.connect(_on_upgrade_button_pressed.bind(self))
	else:
		upgrade_button.queue_free()



func _on_upgrade_button_pressed(tower):
	print(str(tower) + "Has Been Upgraded")

func _physics_process(delta: float) -> void:
	_turn()


func _turn():
	var enemy_position = get_global_mouse_position()
	turret.look_at(enemy_position)
