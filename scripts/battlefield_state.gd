extends Node

var player_base: Building
var enemy_base: Building

func get_enemy_base(for_team: Team.Side) -> Building:
	return enemy_base if for_team == Team.Side.PLAYER else player_base
