extends CharacterBody2D

const MAX_SPEED = 500.0
const ACC = 7.0

var input: Vector2
var can_attack: bool  =true
var health: float = 50
var direction_history = []
const HISTORY_LENGHT = 7
const MIN_ATTACK_ANGLE = PI/2
const MAX_ATTACK_ANGLE = PI
var weapon_scenes = {
	"1": preload("res://Scenes/Player/pickaxe.tscn"),
	"2": preload("res://Scenes/Player/dagger.tscn")
}

@onready var weapon_slot = $Weapon
@onready var attack_timer = $AttackTimer

func _get_move_input():
	input.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	input.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	return input.normalized()

func _unhandled_input(event: InputEvent) -> void:
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
		can_attack = false
		attack_timer.start()

func store_direction(dir):
		direction_history.append(dir)
		if direction_history.size() > HISTORY_LENGHT:
			direction_history.pop_front()

func check_for_attack(dir):
	if ! can_attack:
		return
	if direction_history.size() < HISTORY_LENGHT:
		return
	var old_dir = direction_history[0]
	var angle = old_dir.angle_to(dir)
	if angle <= -MIN_ATTACK_ANGLE and -MAX_ATTACK_ANGLE <= angle:
		attack_init()

func _on_attack_timer_timeout() -> void:
	can_attack = true

func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func die():
	print("döööööööööd")
