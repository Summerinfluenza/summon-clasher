class_name HealthBar
extends Node2D

@onready var bar: ProgressBar = $ProgressBar

func _ready() -> void:
	visible = false

func setup(health: Health) -> void:
	bar.max_value = health.max_hp
	bar.value = health.current_hp
	health.hurt.connect(_on_hurt)

func _on_hurt(current_hp: int) -> void:
	bar.value = current_hp
	visible = current_hp < bar.max_value
