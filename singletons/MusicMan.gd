extends Node

onready var player: AudioStreamPlayer = AudioStreamPlayer.new()
var started_at: int = 0
var midi: SMF.SMFData
var notes: Array = []
var cursor: int = 0
var position = 0.0
var elapsed = 0.0

const seconds_to_timebase: float = 3.0

signal cue(track, note, velocity)

func _ready():
	add_child(player)
	pass # Replace with function body.

func _process(_delta):
	if notes.empty():
		return
	elapsed = player.get_playback_position() - 2.5
	self.position = float( midi.timebase ) * elapsed * self.seconds_to_timebase
	var notes_this_frame = []
	while notes[cursor].time < position:
		notes_this_frame.push_back(notes[cursor])
		cursor += 1
		if cursor >= len(notes):
			notes = []
			cursor = 0
			return
	if not notes_this_frame.empty() or position < 0:
		print("Human time: ", elapsed)
		print("MIDI time: ", position)
		print("Next note: ", notes[cursor].time)
	for i in notes_this_frame:
		emit_signal("cue", i.track, i.note, i.velocity)
	pass

func stop():
	player.stop()
	cursor = 0
	notes = []
	pass

func play(path: String):
	stop()
	player.stream = load(path + "/song.ogg")
	var parsed = SMF.new().read_file(path + "/song.midi")
	if parsed.error:
		print(parsed.error)
		return
	midi = parsed.data
	print(midi.timebase)
	for track in midi.tracks:
		var notes = []
		var name = "unknown"
		for i in range(len(track.events)):
			var chunk: SMF.MIDIEventChunk = track.events[i]
			var event: SMF.MIDIEvent = chunk.event
			if event.type == SMF.MIDIEventType.system_event and event.args.type == SMF.MIDISystemEventType.text_event and len(event.args.text) > 4:
				name = event.args.text
				if not name.begins_with("CUE "):
					print("Discarding track ", name, " as non-cue. Ideally it should be removed, but it won't hurt to keep it.")
					break
				print(name)
			if event.type == SMF.MIDIEventType.note_on:
				var note = event.note
				var vel = event.velocity
				var start = chunk.time
				var end = 0
				for o in range(i, len(track.events)):
					var later_chunk = track.events[o]
					var later_event = later_chunk.event
					if not later_event.type == SMF.MIDIEventType.note_off:
						continue
					if later_event.note == note:
						end = later_chunk.time
						break
				notes.push_back(Note.new(name.substr(4), note, vel, start, end))
			pass
		if name.begins_with("CUE "):
			self.notes.append_array(notes)
		pass
	self.notes.sort_custom(self, "note_cmp")
	started_at = OS.get_ticks_msec()
	player.play()
	self.position = 0
	pass

func nearby_notes(back: float, forward: float):
	if notes.empty() or not midi:
		return []
	var back_time = notes[cursor].time - (float( midi.timebase ) * back * self.seconds_to_timebase)
	var forward_time = notes[cursor].time + (float( midi.timebase ) * forward * self.seconds_to_timebase)
	var output = []
	for note in notes:
		if note.end > back_time and note.time < forward_time:
			output.push_back(note)
	return output

class Note:
	var track: String
	var note: int
	var velocity: int
	var time: int
	var end: int
	var length: int
	func _init(track, note, vel, time, end):
		self.track = track
		self.note = note
		self.velocity = vel
		self.time = time
		self.end = end

func note_start_sec(note: Note):
	return note.time / (float( midi.timebase ) * seconds_to_timebase)

func note_end_sec(note: Note):
	return note.end / (float( midi.timebase ) * seconds_to_timebase)

func note_len_sec(note: Note):
	return note_end_sec(note) - note_start_sec(note)

func note_cmp(a, b):
	return a.time < b.time
