class_name CharacterStats
extends Resource

@export_group("Defensive")
@export var max_hp : int
@export var hp : int
@export var max_shield : int
@export var shield : int
@export var armor : int

@export_group("Offensive")
@export var attack_damage: int
@export var attack_speed: float
@export var attack_range: int

@export_group("Utility")
@export var price : int
@export var movement_speed : float
@export var max_energy : int
@export var energy : int

enum UnitType { MELEE, ANTI_CAVALRY, CAVALRY, ARCHER, BOSS }
@export var unit_type : String
