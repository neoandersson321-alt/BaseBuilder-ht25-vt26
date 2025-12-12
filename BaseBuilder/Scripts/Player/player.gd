extends CharacterBody2D

const MAX_SPEED = 500.0
const ACC = 7.0

var input: Vector2

var direction_history = []
const HISTORY_LENGHT = 10
const ATTACK_ANGLE_THRESHOLD = PI/2

var weapon_scenes = {
	"1": preload("res://Scenes/Player/pickaxe.tscn")
}

@onready var weapon_slot = $Weapon

func _get_move_input():
	input.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	input.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	return input.normalized()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("LeftClick"):
		attack_init()
	
	for key in weapon_scenes.keys():
		if event.is_action_pressed(key):
			equip_weapon(weapon_scenes[key])

func _physics_process(delta: float) -> void:
	var player_input = _get_move_input()
	velocity = lerp(velocity, player_input * MAX_SPEED, ACC*delta)
	
	var mouse_dir = (get_global_mouse_position() - global_position).normalized()
	
	store_direction(mouse_dir)
	check_for_attack(mouse_dir)
	
	look_at(get_global_mouse_position())
	move_and_slide()


func equip_weapon(weapon_scene):
	if weapon_slot.get_child_count() > 0:
		weapon_slot.get_child(0).queue_free()
	var weapon = weapon_scene.instantiate()
	weapon_slot.add_child(weapon)
	weapon.position = $WeaponPos.position
	weapon.rotation = PI/2


func attack_init():
	if weapon_slot.get_child_count() > 0:
		weapon_slot.get_child(0).attack()
