class_name Building
extends StaticBody2D

# __________________________Building Configs Properties__________________________
@export var team : Team.Side
@export var stats : CharacterStats

@onready var health: Health = $Health
@onready var health_bar: HealthBar = $HealthBar

signal building_hurt(current_hp: int)
signal die()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if stats == null:
		push_warning("%s has no Stats assigned — using defaults." % name)
		stats = CharacterStats.new()
	stats = stats.duplicate()
	health.setup(stats)
	health_bar.setup(health)
	health.hurt.connect(func(hp): building_hurt.emit(hp))
	health.died.connect(_die)

# __________________________Bulding interactions__________________________
func _hurt(amount: int) -> void:
	health.take_damage(amount)

func _die() -> void:
	die.emit()
	queue_free()
