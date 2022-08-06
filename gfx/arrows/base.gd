tool
extends Polygon2D

export var cue = "beat"
export var note = -1
export var direction = 0
export var directions = PoolRealArray([
	270.0,
	0.0,
	180.0,
	90.0
])
export var colors = [
	Color("#0000FF"),
	Color("#F03229"),
	Color("#EDC71A"),
	Color("#0EED62")
]

var prev_direction = -1

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if direction == prev_direction:
		return
	rotation_degrees = directions[direction]
	color = colors[direction]
	$Node2D.trigger_cue = cue
	$Node2D.trigger_note = note
	pass
