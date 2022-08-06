extends Node2D
class_name PolygonBounce

export var trigger_cue: String = "beat"
export var trigger_note: int = -1
export var bounce_distance: float = 10.0
export var bounce_duration: float = 0.3

onready var displayed: Polygon2D = Polygon2D.new()
onready var ground_truth: Polygon2D = get_parent()

func _ready():
	add_child(displayed)
	MusicMan.connect("cue", self, "cue")
	displayed.polygon = ground_truth.polygon

var bounce_timer = 5.0
func _process(delta):
	bounce_timer -= delta
	transform.origin = Vector2.ZERO
	if ground_truth.color.a > 0:
		displayed.color = Color(ground_truth.color.r, ground_truth.color.g, ground_truth.color.b, ground_truth.color.a)
		ground_truth.color.a = 0
		for i in ground_truth.get_property_list():
			var v = i["name"]
			if v == "polygon" or v == "visible" or v == "color" or not (v in displayed and v in ground_truth):
				continue
			if displayed[v] != ground_truth[v]:
				displayed[v] = ground_truth[v]
	if bounce_timer <= 0:
		return
	for i in range(len(displayed.polygon)):
		var start = displayed.polygon[i]
		var end = ground_truth.polygon[i]
		displayed.polygon[i] = lerp(start, end, (2 / bounce_duration) * delta)
	

func cue(track: String, note: int, velocity: int):
	if track == trigger_cue and (note == trigger_note or trigger_note == -1):
		bounce()

func bounce():
	bounce_timer = bounce_duration
	for i in range(len(ground_truth.polygon)):
		displayed.polygon[i] = ground_truth.polygon[i] + Vector2(rand_range(-1.0, 1.0) * bounce_distance, rand_range(-1.0, 1.0) * bounce_distance)
