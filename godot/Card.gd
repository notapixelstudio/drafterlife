extends Area2D

"""
Draggable card. Fires 'picked' at drag start and 'dropped' at drag end.
Appearance and effect are both defined by a single 'title' string.
"""

###
# CARD DEFINITION
###

var title setget set_title
onready var label = $Label

func set_title(v):
	title = v
	label.text = v

###
# DRAG AND DROP
###

signal picked
signal dropped

var previous_mouse_position = Vector2()
var is_dragging = false

func _on_Card_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('ui_touch'):
		# Start dragging
		get_tree().set_input_as_handled()
		previous_mouse_position = event.position
		is_dragging = true
		emit_signal('picked', self)

func _input(event):
	if not is_dragging:
		return
		
	if event is InputEventMouseMotion:
		# Continue dragging
		# update position relative to the picked point
		position += event.position - previous_mouse_position
		previous_mouse_position = event.position
	
	if event.is_action_released('ui_touch'):
		# End dragging
		previous_mouse_position = Vector2()
		is_dragging = false
		
		# Check if dropped onto target
		for area in get_overlapping_areas():
			if area.is_in_group('targets'):
				var interacted = area.interact(self)
				if interacted:
					queue_free() # cards are single use
				
		emit_signal('dropped', self)
	
###
# AUTOMATIC MOVEMENT
###

onready var tween = $Tween

func gracefully_go_to(point):
	tween.interpolate_property(self, 'position',
		position, point, 0.5,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
