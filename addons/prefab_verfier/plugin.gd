@tool
extends EditorPlugin

const SCENE_TREE_IDX := 0
const BUTTON_WARNING_ID := 777 # arbitrary unique value
var scene_tree: Tree
var warning_dialog: AcceptDialog


func _enter_tree() -> void:
	scene_tree = find_editor_control_with_class(get_editor_interface().get_base_control(), "SceneTreeEditor").get_child(SCENE_TREE_IDX)
	scene_tree.draw.connect(_draw)
	scene_tree.button_clicked.connect(_button_warning_clicked)


func _exit_tree() -> void:
	scene_tree.draw.disconnect(_draw)
	scene_tree.button_clicked.disconnect(_button_warning_clicked)


func _draw() -> void:
	var it: TreeItem = scene_tree.get_root()
	
	var icon: Texture2D
	icon = get_editor_interface().get_base_control().get_theme_icon("NodeWarning", "EditorIcons")
	
	while (it):
		var node = get_node_or_null(it.get_metadata(0))
		if node and node.scene_file_path == "res://prefabs/custom_button.tscn":
			it = it.get_next_in_tree()
			continue
		
		if node is Button:
			var last_it_button = null
			if it.get_button_count(0) > 0:
				last_it_button =  it.get_button(0, it.get_button_count(0) -1)
			if last_it_button == null or last_it_button != icon:
				it.add_button(0, icon, BUTTON_WARNING_ID, false, "Don't Use Buttons")
		
		it = it.get_next_in_tree()


func _button_warning_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	if id == BUTTON_WARNING_ID:
		warning_dialog = AcceptDialog.new()
		warning_dialog.dialog_text = "Use the prefab when making buttons!"
		EditorInterface.popup_dialog_centered(warning_dialog)
		warning_dialog.canceled.connect(warning_dialog.queue_free)
		warning_dialog.confirmed.connect(warning_dialog.queue_free)


## General utility to find a control in the editor using an iterative search
static func find_editor_control_with_class( base: Control, p_class_name: StringName, condition := func(node: Node): return true) -> Node:
	if base.get_class() == p_class_name and condition.call(base):
		return base
		
	for child in base.get_children():
		if not child is Control:
			continue
			
		var found = find_editor_control_with_class(child, p_class_name, condition)
		if found:
			return found
		
	return null
