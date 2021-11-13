extends Node

class ShipData:
	var Coor: Vector2
	var Length: int
	var Orientation: bool #vertical is true, (Trueship = vertical) (Falseship = horizontal)

# Preloaded assets, to be used later
onready var Setup = preload("res://scenes/Game/Setup.tscn")
onready var Fire  = preload("res://scenes/Game/Fire.tscn")

# Path to Player class, for instantiating new Players in code
var Player = "res://script/game/Gameplay/Player.gd"


# Array of instances of the Player class; stores the Players
var players # = player1, player2, ...
# turn counter
var turn = 0
# Variable transporting hit state between players
var hit = false
# Variable tracking whether a game is multiplayer (so that the correct Player type can be spawned)
# TODO: Multiplayer
var is_multiplayer = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var setup = Setup.instance()
	setup.connect("game_ready", self, "game_setup")
	add_child(setup)

func game_setup(_ships):
	print_debug("Congrats! Setup complete.")
	add_child(Fire.instance())

# Member functions:
#   game_start: starts the game
func game_start():
	pass

#   victory_screen: display the victory screen
func victory_screen():
	pass

#   display_turn(): display which turn it is on the screen
func display_turn():
	pass

func _on_Forfeit_pressed():
	AudioBus.emit_signal("button_clicked")
	end()

func end():
	queue_free()
