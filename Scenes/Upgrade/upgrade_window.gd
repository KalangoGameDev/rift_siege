extends CanvasLayer

@onready var upgrade_card_container: GridContainer = %upgrade_card_container

const UPGRADE_CARD = preload("uid://dcyntlgmbmk1g")

func _ready() -> void:
	setup_upgrade_window()

func setup_upgrade_window() -> void:
	for t in Player.upgrade_cards:
		instantiate_upgrade_card()

func instantiate_upgrade_card() -> void:
	var upgrade_card: Node = UPGRADE_CARD.instantiate()
	upgrade_card.upgrade_card_pressed_signal.connect(_on_card_pressed)
	upgrade_card_container.add_child(upgrade_card)

func _on_card_pressed() -> void:
	queue_free()
