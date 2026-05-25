extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_enter)

func _on_body_enter(body: Node) -> void:
	if body is Demon:
		body.die()
		Player.lose_life(1)
