extends Control
@onready var lbl_player = $lblPlayer
@onready var button = $btnRemap
@onready var text = $lblText
@onready var txtButton = $lblButton
@onready var tmr_set = $tmrSet

@export var player: String = "1"

@export var array = ["2","4","8","6","LP","MP","HP","LK","MK","HK"]
#var p2Array = ["p2_2","p2_4","p2_8","p2_6","p2LP","p2MP","p2HP","p2LK","p2MK","p2HK"]

var inputArray = ["down","left","up","right","LP","MP","HP","LK","MK","HK"]

var remapping = false
var currentAction = ""
var actionIndex = 0
var actionSize = 0

func _ready():
	lbl_player.text = "Player " + player
	button.connect("pressed", _on_btn_remap_pressed)
	text.visible = false
	txtButton.visible = false

func _on_btn_remap_pressed():
	text.visible = true
	txtButton.visible = true
	actionIndex = 0
	actionSize = array.size()
	currentAction = array[actionIndex]
	txtButton.text = str(inputArray[actionIndex])
	remapping = true
	button.release_focus()

func remapButtons():
	actionIndex += 1
	if actionIndex > actionSize - 1:
		remapping = false
		text.visible = false
		txtButton.visible = false
		return
	currentAction = array[actionIndex]
	txtButton.text = str(inputArray[actionIndex])

func _input(event):
	if remapping && tmr_set.is_stopped():
		if event is InputEventKey || event is InputEventJoypadButton:
			if event.pressed:
				remmapEvent(event)
		elif event is InputEventJoypadMotion:
			if event.axis_value != 0:
				remmapEvent(event)

func remmapEvent(event):
	InputMap.action_erase_events(currentAction)
	InputMap.action_add_event(currentAction, event)
	print(currentAction, " - set")
	tmr_set.start(0.25)
	remapButtons()

func _on_tmr_set_timeout():
	tmr_set.stop()