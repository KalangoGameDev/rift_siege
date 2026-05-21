# Upgrade Card
extends Control

@onready var selection_border: ColorRect = %selection_border

#@onready var card_bg: ColorRect = %card_bg
@onready var upgrade_name: Label = %upgrade_name
@onready var upgrade_icon: ColorRect = %upgrade_icon
@onready var upgrade_rarity: Label = %upgrade_rarity
@onready var upgrade_description: Label = %upgrade_description
@onready var upgrade_button: TextureButton = %upgrade_button
signal upgrade_card_pressed_signal

var upgrade_resource: Upgrade
@export var upgrade_scene: Resource

enum Rarity {
	Common,
	Uncommon,
	Rare,
	Epic,
	Legendary,
}

var rarity_weights : Dictionary = {
	Rarity.Common: 70.0,
	Rarity.Uncommon: 20.0,
	Rarity.Rare: 6.0,
	Rarity.Epic: 3.0,
	Rarity.Legendary: 1.0
}

enum UpgradeType {
	Luck,
	UpgradeCards,
	Life,
	Exp,
	MoveSpeed,
}

#enum UpgradePack1 {
# Weapon
# Damage
# Crit Chance
# Crit Damage
# Bullet Velocity
# Range
# Armor Penetration
#}

#enum UpgradePack2 {
# Tank
# Move Speed
# Lifes
# Cards
# Luck
# Fire Rate
# Ammo
#}

#enum UpgradePack3 {
# Tech
# Multishot
# Ricochet
# Splitshot
# Stunshot
# Scale
#
#}


func _ready() -> void:
	upgrade_button.pressed.connect(_add_upgrade)
	setup_card()

func setup_card() -> void:
	_set_upgrade_resource()
	
	upgrade_name.text = upgrade_resource.get_data("name")
	upgrade_rarity.text = upgrade_resource.get_data("rarity")
	upgrade_description.text = upgrade_resource.get_data("description")
	
	#match upgrade_resource.upgrade_rarity:
		#Rarity.Common:
			#card_bg.color = Color.DIM_GRAY
		#Rarity.Uncommon:
			#card_bg.color = Color.BURLYWOOD
		#Rarity.Rare:
			#card_bg.color = Color.DARK_BLUE
		#Rarity.Epic:
			#card_bg.color = Color.BLUE_VIOLET
		#Rarity.Legendary:
			#card_bg.color = Color.GOLD


func _set_upgrade_resource() -> void:
	var luck := Player.luck
	
	var rolled_rarity: int = _roll_rarity(luck)
	var rolled_type: int = _roll_upgrade_type()
	
	var new_upgrade: Upgrade = upgrade_scene.duplicate(true)
	
	@warning_ignore("int_as_enum_without_cast")
	new_upgrade.upgrade_type = rolled_type
	
	@warning_ignore("int_as_enum_without_cast")
	new_upgrade.upgrade_rarity = rolled_rarity
	
	upgrade_resource = new_upgrade

func _roll_rarity(luck: float) -> int:
	var adjusted := {}
	
	for rarity in rarity_weights.keys():
		var base: Rarity = rarity_weights[rarity]
		var multiplier: float = _luck_multiplier(luck, rarity)
		
		var weight :float= base * multiplier
		weight = _cap_weight(rarity, weight)
		
		adjusted[rarity] = weight
	
	return _weighted_roll(adjusted)


func _luck_multiplier(luck: float, tier: int) -> float:
	var tier_factor := pow(tier + 1, 2)
	var luck_factor := 1.0 - exp(-luck / 50.0)
	
	return 1.0 + (luck_factor * tier_factor)


func _cap_weight(rarity: int, weight: float) -> float:
	match rarity:
		Rarity.Legendary:
			return min(weight, 5.0)
		Rarity.Epic:
			return min(weight, 12.0)
		_:
			return weight


func _weighted_roll(weights: Dictionary) -> int:
	var total := 0.0
	for w in weights.values():
		total += w
	
	var roll := randf() * total
	var cumulative := 0.0
	
	for rarity in weights.keys():
		cumulative += weights[rarity]
		if roll <= cumulative:
			return rarity
	
	return Rarity.Common

func _roll_upgrade_type() -> int:
	var values := UpgradeType.values().duplicate()
	
	if Player.upgrade_cards >= 10:
		values.erase(UpgradeType.UpgradeCards)
	
	return values[randi() % values.size()]

func _add_upgrade() -> void:
	upgrade_resource.execute_upgrade()
	emit_signal("upgrade_card_pressed_signal")
