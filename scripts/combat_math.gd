# combat_math.gd
class_name CombatMath
extends RefCounted

const COUNTER_BONUS := 3

const COUNTERS := {
	CharacterStats.UnitType.MELEE: CharacterStats.UnitType.ANTI_CAVALRY,
	CharacterStats.UnitType.ANTI_CAVALRY: CharacterStats.UnitType.CAVALRY,
	CharacterStats.UnitType.CAVALRY: CharacterStats.UnitType.ARCHER,
}

static func calculate_damage(attacker_stats: CharacterStats, defender_stats: CharacterStats) -> int:
	var damage := attacker_stats.attack_damage
	if COUNTERS.get(attacker_stats.unit_type) == defender_stats.unit_type:
		damage += COUNTER_BONUS
	return damage
