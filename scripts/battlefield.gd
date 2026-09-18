extends Node2D

@onready var player_base: Building = $PlayerBase
@onready var enemy_base: Building = $EnemyBase

func _ready() -> void:
	BattlefieldState.player_base = player_base
	BattlefieldState.enemy_base = enemy_base
