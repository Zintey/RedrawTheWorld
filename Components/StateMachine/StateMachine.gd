extends Node
class_name StateMachine

@export var agent : Node
@export var initial_state : StateBase
var states : Dictionary = {}
var current_state : StateBase
var pause : bool = false

func _ready() -> void:
	for child in get_children():
		if child is StateBase:
			states[child.name.to_lower()] = child
			child.switched_to.connect(on_child_switched_to)
	
	if initial_state:
		await agent.ready
		initial_state.enter()
		current_state = initial_state
	else:
		printerr("%s's StateMachine not assign initial_state" % owner.name)


func _input(event: InputEvent) -> void:
	if pause:
		return
	if current_state:
		current_state.take_input(event)

func _unhandled_input(event: InputEvent) -> void:
	if pause:
		return
	if current_state:
		current_state.take_unhandled_input(event)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.take_physics_process(delta)

func _process(delta: float) -> void:
	if pause:
		return
	if current_state:
		current_state.take_process(delta)


func on_child_switched_to(state : StateBase, new_state_name : String) -> void:
	# if state != current_state:
		# return
	
	var new_state : StateBase = states.get(new_state_name.to_lower())
	if new_state == null:
		return
	
	if current_state:
		current_state.exit()
	# if agent as Player:
		# print("%s switch to %s" % [current_state, new_state.name])
	
	new_state.enter()
	current_state = new_state

func switch_to(new_state_name : String):
	on_child_switched_to(current_state, new_state_name)
