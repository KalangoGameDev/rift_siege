extends Resource
class_name Upgrade

var upgrade_type: UpgradeType
var upgrade_rarity: Rarity
var upgrade_description: String

enum Rarity {
	Common,
	Uncommon,
	Rare,
	Epic,
	Legendary,
}

enum UpgradeType {
	#Player
	Luck,
	UpgradeCards,
	Life,
	Exp,
	# Tank
	MoveSpeed,
	Ammo,
	ReloadSpeed
}

func execute_upgrade() -> void:
	match  upgrade_type:
		UpgradeType.Luck:
			match upgrade_rarity:
				Rarity.Common:
					Player.gain_luck(5)
					print(Player.luck)
				Rarity.Uncommon:
					Player.gain_luck(10)
					print(Player.luck)
				Rarity.Rare:
					Player.gain_luck(15)
					print(Player.luck)
				Rarity.Epic:
					Player.gain_luck(20)
					print(Player.luck)
				Rarity.Legendary:
					Player.gain_luck(25)
					print(Player.luck)
		
		UpgradeType.UpgradeCards:
			match upgrade_rarity:
				Rarity.Common:
					Player.gain_upgrade_cards(1)
					print(Player.upgrade_cards)
				Rarity.Uncommon:
					Player.gain_upgrade_cards(2)
					print(Player.upgrade_cards)
				Rarity.Rare:
					Player.gain_upgrade_cards(3)
					print(Player.upgrade_cards)
				Rarity.Epic:
					Player.gain_upgrade_cards(4)
					print(Player.upgrade_cards)
				Rarity.Legendary:
					Player.gain_upgrade_cards(5)
					print(Player.upgrade_cards)
		
		UpgradeType.Life:
			match upgrade_rarity:
				Rarity.Common:
					Player.gain_life(1)
					print(Player.lifes)
				Rarity.Uncommon:
					Player.gain_life(2)
					print(Player.lifes)
				Rarity.Rare:
					Player.gain_life(3)
					print(Player.lifes)
				Rarity.Epic:
					Player.gain_life(4)
					print(Player.lifes)
				Rarity.Legendary:
					Player.gain_life(5)
					print(Player.lifes)
		
		UpgradeType.Exp:
			match upgrade_rarity:
				Rarity.Common:
					Player.gain_exp_modifier(0.05)
					print(Player.exp_modifier)
				Rarity.Uncommon:
					Player.gain_exp_modifier(0.1)
					print(Player.exp_modifier)
				Rarity.Rare:
					Player.gain_exp_modifier(0.15)
					print(Player.exp_modifier)
				Rarity.Epic:
					Player.gain_exp_modifier(0.2)
					print(Player.exp_modifier)
				Rarity.Legendary:
					Player.gain_exp_modifier(0.25)
					print(Player.exp_modifier)
		
		UpgradeType.MoveSpeed:
			match upgrade_rarity:
				Rarity.Common:
					Player.gain_movement_speed(0.1)
					print(Player.movement_speed)
				Rarity.Uncommon:
					Player.gain_movement_speed(0.15)
					print(Player.movement_speed)
				Rarity.Rare:
					Player.gain_movement_speed(0.2)
					print(Player.movement_speed)
				Rarity.Epic:
					Player.gain_movement_speed(0.25)
					print(Player.movement_speed)
				Rarity.Legendary:
					Player.gain_movement_speed(0.5)
					print(Player.movement_speed)
		
		UpgradeType.Ammo:
			match upgrade_rarity:
				Rarity.Common:
					pass
				Rarity.Uncommon:
					pass
				Rarity.Rare:
					pass
				Rarity.Epic:
					pass
				Rarity.Legendary:
					pass
		
		UpgradeType.ReloadSpeed:
			match upgrade_rarity:
				Rarity.Common:
					pass
				Rarity.Uncommon:
					pass
				Rarity.Rare:
					pass
				Rarity.Epic:
					pass
				Rarity.Legendary:
					pass

func get_data(data: String) -> String:
	match data:
		"name":
			match upgrade_type:
				UpgradeType.Luck:
					return "LUCK"
				
				UpgradeType.UpgradeCards:
					return "EXTRA CARDS"
				
				UpgradeType.Life:
					return "EXTRA LIFE"
				
				UpgradeType.Exp:
					return "EXTRA EXP"
				
				UpgradeType.MoveSpeed:
					return "MOVE SPEED"
		
		"rarity":
			match upgrade_rarity:
				Rarity.Common:
					return "COMMON"
				Rarity.Uncommon:
					return "UNCOMMON"
				Rarity.Rare:
					return "RARE"
				Rarity.Epic:
					return "EPIC"
				Rarity.Legendary:
					return "LEGENDARY"
		
		"description":
			match upgrade_type:
				UpgradeType.Luck:
					match upgrade_rarity:
						Rarity.Common:
							return "+5\nLuck"
						Rarity.Uncommon:
							return "+10\nLuck"
						Rarity.Rare:
							return "+15\nLuck"
						Rarity.Epic:
							return "+20\nLuck"
						Rarity.Legendary:
							return "+40\nLuck"
				
				UpgradeType.UpgradeCards:
					match upgrade_rarity:
						Rarity.Common:
							return "+1\nCard options"
						Rarity.Uncommon:
							return "+2\nCard options"
						Rarity.Rare:
							return "+3\nCard options"
						Rarity.Epic:
							return "+4\nCard options"
						Rarity.Legendary:
							return "+5\nCard options"
						
				UpgradeType.Life:
					match upgrade_rarity:
						Rarity.Common:
							return "+1\nLife"
						Rarity.Uncommon:
							return "+2\nLife"
						Rarity.Rare:
							return "+3\nLife"
						Rarity.Epic:
							return "+4\nLife"
						Rarity.Legendary:
							return "+5\nLife"
				
				UpgradeType.Exp:
					match upgrade_rarity:
						Rarity.Common:
							return "5%\nBonus Exp"
						Rarity.Uncommon:
							return "10%\nBonus Exp"
						Rarity.Rare:
							return "15%\nBonus Exp"
						Rarity.Epic:
							return "20%\nBonus Exp"
						Rarity.Legendary:
							return "25%\nBonus Exp"
				
				UpgradeType.MoveSpeed:
					match upgrade_rarity:
						Rarity.Common:
							return "10%\nMove Speed"
						Rarity.Uncommon:
							return "15%\nMove Speed"
						Rarity.Rare:
							return "20%\nMove Speed"
						Rarity.Epic:
							return "25%\nMove Speed"
						Rarity.Legendary:
							return "50%\nMove Speed"
	
	return ""
