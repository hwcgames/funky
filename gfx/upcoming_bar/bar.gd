extends Control

export var cue: String = "player"
export var note: int = 49
export var lookahead: float = 0.5
export var start_anchor = "anchor_top"
export var end_anchor = "anchor_bottom"
export var reverse_anchors = false
onready var timer: Timer = $Timer
onready var tween: Tween = $Tween
onready var bar_box: Control = $BarBox

const ARROW = preload("res://gfx/arrows/base.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = lookahead
	timer.start()
	timer.connect("timeout", self, "rebake")
	rebake()
	pass # Replace with function body.

func rebake():
	timer.start()
	var notes = MusicMan.nearby_notes(lookahead * 0.5, lookahead * 2.5)
	tween.stop_all()
	for i in $BarBox.get_children():
		destroy(i)
	if notes.empty():
		return
	for i in notes:
		if i.track == cue and i.note == note:
			put_note(i)
	tween.start()
	pass

func put_note(note: MusicMan.Note):
	var note_start_rel = (MusicMan.note_start_sec(note) - MusicMan.elapsed) / lookahead
	var note_end_rel = (MusicMan.note_end_sec(note) - MusicMan.elapsed) / lookahead
	var note_len = MusicMan.note_len_sec(note)
	var long = note_len > 0.2
	var c = Control.new()
	var arrow = ARROW.instance()
	arrow.direction = self.note - 49
	bar_box.add_child(c)
	c.add_child(arrow)
	c.margin_right = 10
	c.margin_bottom = 0
	c.anchor_bottom = 0.5
	c.anchor_left = 0.5
	c.anchor_right = 0.5
	c.anchor_top = 0.5
	if long:
		print("LONG NOTE, adding long bar")
		var bar = ColorRect.new()
		arrow.note = 04357098234
		arrow._process(0)
		bar.color = arrow.color
		bar.color.a = 0.5
		bar.margin_right = 0
		bar.margin_left = -10
		bar.margin_bottom = 0
		bar.anchor_bottom = 1
		bar.anchor_right = 1
		c.add_child(bar)
	var note_start_pos = note_start_rel
	var note_end_pos = note_end_rel
	var note_start_goal = note_start_rel - 1
	var note_end_goal = note_end_rel - 1
	if reverse_anchors:
		note_start_rel = 1 - note_start_rel
		note_end_rel = 1 - note_end_rel
		note_start_goal += 2
		note_end_goal += 2
	tween.interpolate_property(c, start_anchor, note_start_pos, note_start_goal, lookahead, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.0)
	tween.interpolate_property(c, end_anchor, note_end_pos, note_end_goal, lookahead, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.0)
	pass

func destroy(node: Node):
	for i in node.get_children():
		destroy(i)
	node.remove_and_skip()
