extends Control

signal game_ready

onready var Ships = ["2Ship", "3ShipA", "3ShipB", "4Ship", "5Ship"]

onready var Victory = preload("res://scenes/Game/Player.tscn")

var light_theme = load("res://light_theme.tres")
var dark_theme = load("res://dark_theme.tres")

class ShipData:
	var Position: Vector2
	var Length: int
	var Orientation: bool # (True = vertical) (False = horizontal)
	var Variant: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Moves the focus to this menu
	if find_next_valid_focus(): find_next_valid_focus().grab_focus()
	
	get_node("PlaceShipDialog").get_ok().rect_min_size.x = 50
	
	var _errno = 0;
	_errno += OptionsController.connect("change_theme", self, "_on_change_theme")
	_on_change_theme(OptionsController.get_theme())

func _on_Confirm_Placement_pressed():
	# Make the button noise
	AudioBus.emit_signal("button_clicked")
	var valid = true
	for ship in Ships:
		# validate_placement returns the x-axis distance from the board
		# if this is more than zero, the ship is invalid
		if get_node(ship).validate_placement():
			valid = false
	print ("Placement: ", valid)
	if valid == false:
		get_node("PlaceShipDialog").popup()
	else:
		#Saves the location of ships and length of ship into an array
		var shipLocation = []
		for ship in Ships:
			var shipdata = ShipData.new()
			shipdata.Position = get_node(ship).position
			shipdata.Length = get_node(ship).get("ship_length")
			shipdata.Orientation = get_node(ship).get("vertical")
			match ship:
				"3ShipB":
					shipdata.Variant = 1
				_:
					shipdata.Variant = 0
			shipLocation.append(shipdata)
		
		#print out the array for testing
		for x in shipLocation:
			print("Ship Length: ", x.Length, ", Ship Orientation: ", x.Orientation, ", Ship Position: ", x.Position)
		
		# Return the shipLocation array to those listening on game_ready
		emit_signal("game_ready", shipLocation)
		queue_free()
	return valid # Replace with function body.

func _on_Clear_pressed():
	AudioBus.emit_signal("button_clicked")
	for ship in Ships:
		get_node(ship).clear()
	pass # Replace with function body.
	
func _on_change_theme(theme):
	if theme == "light":
		self.set_theme(light_theme)
	elif theme == "dark":
		self.set_theme(dark_theme)
