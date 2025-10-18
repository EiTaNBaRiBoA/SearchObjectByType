@abstract class_name SearchObjectByType
## This is a utility class (singleton) for finding nodes in the scene tree.
## This upgraded version uses a generic 'filter' (Callable) as its core
## to provide highly flexible and efficient node searching.

#region Public API


## (Find First) Finds the first node that returns true for a given filter function.
## This is highly efficient as it stops searching as soon as a match is found.
static func find_node_by_filter(filter: Callable, root_node: Node = null) -> Node:
	var root: Node = root_node
	if root == null:
		root = Engine.get_main_loop().root.get_tree().current_scene
		if root == null:
			push_error("SearchObjectByType: Cannot find current scene.")
			return null
	
	# Start the recursive search
	return _find_first_node_by_filter_recursive(root, filter)


## (Find All) Finds all nodes that return true for a given filter function (Callable).
static func find_nodes_by_filter(filter: Callable, root_node: Node = null) -> Array[Node]:
	var results: Array[Node] = []
	var root: Node = root_node
	if root == null:
		root = Engine.get_main_loop().root.get_tree().current_scene
		if root == null:
			push_error("SearchObjectByType: Cannot find current scene.")
			return results
	
	# Start the recursive search
	_find_nodes_by_filter_recursive(root, filter, results)
	return results


## Finds the first node of a given type.
static func find_node_by_type(_type: Variant, visible_only: bool = true, root_node: Node = null) -> Node:
	if not _check_type_is_valid(_type):
		push_error("SearchObjectByType: Invalid type. Do not pass an instantiated object.")
		return null
	
	# Create a filter function (lambda) to pass to the core search
	var filter := func(node: Node):
		if not is_instance_of(node, _type):
			return false
		# This logic is now: "return true if visible_only is false, OR if _is_node_visible is true"
		return not visible_only or _is_node_visible(node)
		
	return find_node_by_filter(filter, root_node)


## Finds all nodes of a given type.
static func find_nodes_by_type(_type: Variant, visible_only: bool = true, root_node: Node = null) -> Array[Node]:
	if not _check_type_is_valid(_type):
		push_error("SearchObjectByType: Invalid type. Do not pass an instantiated object.")
		return []
	
	# Create a filter function (lambda)
	var filter := func(node: Node):
		if not is_instance_of(node, _type):
			return false
		return not visible_only or _is_node_visible(node)
	
	return find_nodes_by_filter(filter, root_node)


## Gets the root node of the scene containing the given object.
static func get_main_scene_of_viewport(obj: Node) -> Node:
	if not obj:
		return null
	var parent: Node = obj.get_parent()
	if not parent:
		return obj
	if parent is Viewport:
		return obj
	else:
		return get_main_scene_of_viewport(parent)

#endregion


#region Private Methods 

## Recursive helper for finding the FIRST node.
static func _find_first_node_by_filter_recursive(parent: Node, filter: Callable) -> Node:
	for child: Node in parent.get_children():
		# Check the child first
		if filter.call(child):
			return child # Found it! Stop searching.
		
		# If not found, recurse into its children
		if child.get_child_count() > 0:
			var found_in_child: Node = _find_first_node_by_filter_recursive(child, filter)
			if found_in_child:
				return found_in_child # Found it nested deep.
	
	return null # Not found in this branch


## Recursive helper for finding ALL nodes.
static func _find_nodes_by_filter_recursive(parent: Node, filter: Callable, results: Array[Node]) -> void:
	for child: Node in parent.get_children():
		# Check the child
		if filter.call(child):
			results.append(child)
		
		# Always recurse, even if the parent matched
		if child.get_child_count() > 0:
			_find_nodes_by_filter_recursive(child, filter, results)


## Safe, robust check to see if a node is visible.
static func _is_node_visible(node: Node) -> bool:
	if node is CanvasItem:
		return (node as CanvasItem).is_visible_in_tree()
	elif node is Node3D:
		return (node as Node3D).is_visible_in_tree()
	
	# Non-visual nodes (Timer, etc.) are considered "visible"
	return true


## Checks if the provided variant is a valid *type* (Class, Script, StringName)
## and not an *instance* of an object.
static func _check_type_is_valid(type: Variant) -> bool:
	if type == null:
		return false
		
	var var_type: int = typeof(type)
	
	# Allows "Control" or "MyNode" as a string
	if var_type == TYPE_STRING or var_type == TYPE_STRING_NAME:
		return true
	
	if var_type == TYPE_OBJECT:
		# Allows MyPlayer (as class_name) or preload("my_player.gd")
		if type is Script:
			return true
		else:
			# This is an instance (e.g., Control.new()). Block it.
			return false
	
	# Not a valid type (e.g., an int, float, Vector2)
	return false

#endregion
