extends Node2D

@onready var main_scene: Node
@onready var tank: CharacterBody2D = %tank

var tick: int = 0
var threat_time: int = 1000
var threat_level: int = 1

func _ready() -> void:
	Gamecontrol.tick.connect(_tick)

func _tick() -> void:
	tick += 1
	
	if tick >= threat_time:
		threat_level += 1
		
		threat_time = max(threat_time * 0.95, 0.5)
		
		tick = 0
