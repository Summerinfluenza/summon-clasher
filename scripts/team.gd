class_name Team

enum Side { PLAYER, ENEMY }

static func enemy_of(side: Side) -> Team.Side:
	if side == Side.PLAYER:
		return Side.ENEMY
	return Side.PLAYER
