class_name Health
extends Node

signal hurt(current_hp: int)
signal died()

var current_hp: int
var max_hp: int
var armor: int

func setup(stats: CharacterStats) -> void:
	max_hp = stats.max_hp
	armor = stats.armor
	current_hp = max_hp

func take_damage(amount: int) -> void:
	var mitigated := maxi(amount - armor, 1)
	current_hp = maxi(current_hp - mitigated, 0)
	hurt.emit(current_hp)
	if current_hp <= 0:
		died.emit()
