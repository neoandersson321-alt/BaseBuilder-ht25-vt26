extends Area2D

var attack_window: bool = false
var already_attacked: bool = false
var base_modulate: Color

@export var attack_time = 0.5
@export var damage: int
@export var cooldown_time: float

@onready var sprite = $Sprite
@onready var attack_timer = $AttackTimer
@onready var attack_cooldown = $AttackCooldown

signal attack_started

func _ready() -> void:
	attack_cooldown.timeout.connect(_on_attack_cooldown_timeout)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	body_entered.connect(_on_body_entered)
	
	attack_timer.wait_time = attack_time
	attack_cooldown.wait_time = cooldown_time
	
	base_modulate = sprite.modulate

func attack():
	if already_attacked:
		return
	already_attacked = true
	attack_window = true
	attack_started.emit()
	sprite.modulate = Color.RED
	
	attack_cooldown.start()
	attack_timer.start()



func _on_body_entered(body: CharacterBody2D):
	if body.is_in_group("enemies") and attack_window and ! already_attacked:
		body.take_damage(damage)
		already_attacked = true
		attack_cooldown.start()


func _on_attack_timer_timeout() -> void:
	sprite.modulate = base_modulate
	attack_window = false

func _on_attack_cooldown_timeout() -> void:
	already_attacked = false
