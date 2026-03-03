extends Node

var scene_data : Dictionary = {
	
}


func save_data_by_UID(UID : String, data : Dictionary):
	if !get_tree().current_scene:
		return
	var current_scene_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
	if !scene_data.has(current_scene_name):
		scene_data[current_scene_name] = {}
	scene_data[current_scene_name][UID] = data

func load_data_by_UID(UID : String) -> Dictionary:
	var current_scene_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
	if current_scene_name and scene_data.has(current_scene_name) and scene_data[current_scene_name].has(UID):
		return scene_data[current_scene_name][UID]
	else:
		return {} 

func switch_to(scene_path : String, enter_point_name : String):

	var tree : SceneTree = get_tree()

	UIManager.scene_switch_transition_requested.emit(true)
	tree.paused = true
	await UIManager.transition_finished
	tree.change_scene_to_file(scene_path)
	tree.paused = false
	UIManager.scene_switch_transition_requested.emit(false)
	UIManager.inventory_ui_close.emit()
	await  get_tree().scene_changed
	


	var enter_points = get_tree().get_nodes_in_group("EnterPoint")
	for enter_point in enter_points:
		# print("found ", enter_point.name)
		if enter_point.name.to_lower() == enter_point_name.to_lower():
			EventBus.enter_scene.emit({
				"enter_point" : enter_point
			})
			return
	# print("no found enter_name : ", enter_point_name)
