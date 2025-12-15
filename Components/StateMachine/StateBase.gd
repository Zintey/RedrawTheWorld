extends Node
class_name StateBase

signal switched_to(state, new_state_name : String)

func enter() -> void:
    pass

func exit() -> void:
    pass

func take_physics_process(delta: float) -> void:
    pass

func take_process(delta : float) -> void:
    pass

func take_input(event: InputEvent) -> void:
    pass

func take_unhandled_input(event: InputEvent) -> void:
    pass