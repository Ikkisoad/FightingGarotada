extends Area2D
@onready var collision_area_collision = $collisionAreaCollision
@onready var character_body_2d = $".."

func getCollider():
	return collision_area_collision

func setPlayerGlobalPosition(x, y):
	character_body_2d.global_position += Vector2(x,y)

func isGrounded():
	return character_body_2d.grounded