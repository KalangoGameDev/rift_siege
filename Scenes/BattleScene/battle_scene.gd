extends Node2D

@onready var main_scene: Node
@onready var tank: CharacterBody2D = %tank
@onready var remote_players: Node2D = %remote_players

var tick: int = 0
var threat_time: float = 1000.0
var threat_level: int = 1

func _ready() -> void:
	Gamecontrol.tick.connect(_tick)

func _tick() -> void:
	tick += 1

	if NetworkManager.is_online() and not NetworkManager.is_host():
		return

	if tick >= threat_time:
		threat_level += 1

		threat_time = max(threat_time * 0.95, 1.0)
		tick = 0

		if NetworkManager.is_online():
			sync_threat_state.rpc(tick, threat_level, threat_time)

@rpc("any_peer", "call_local", "reliable")
func sync_threat_state(new_tick: int, new_threat_level: int, new_threat_time: float) -> void:
	tick = new_tick
	threat_level = new_threat_level
	threat_time = new_threat_time
