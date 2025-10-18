# SearchObjectByType 🔍

A simple and efficient Godot utility for finding nodes in your scene tree. This tool lets you recursively search the current scene, a specific branch, or a sub-viewport to find nodes based on custom logic.

It's designed as a **static utility class**. You don't need to instance it; just `load` or `preload` the script and call its functions directly.

## Features

  * **Find by Filter:** Use a custom function (`Callable`) to find the *first* node or *all* nodes that match any criteria (type, name, group, properties, etc.).
  * **Find by Type:** A simple wrapper to find the *first* or *all* nodes of a specific type.
  * **Flexible Type:** Works with built-in types (`Control`), `class_name`s (`Player`), or loaded `Script`s (`preload("res://player.gd")`).
  * **Recursive Search:** Searches the entire tree from a given root.
  * **Scoped Search:** Start the search from any node, not just the scene root. Ideal for searching within `SubViewport`s.
  * **Visibility Filter:** Safely filter for visible-only nodes. It correctly handles `CanvasItem`s, `Node3D`s, and non-visual nodes.
  * **Viewport Helper:** Includes a utility to find the root scene node of any `SubViewport`.

## Basic Usage

To use the tool, `preload` or `load` the script into a constant or variable. You can then call its static functions from that variable.

```gdscript

func _ready():
	# Now you can use 'Search' to call its functions
	var player_node = SearchObjectByType.find_node_by_type(Player)
	if player_node:
		print("Found the player!")
```

## API Reference

### Core Filter Functions

`static func find_node_by_filter(filter: Callable, root_node: Node = null) -> Node`
Returns the **first** `Node` that returns `true` for the provided `filter` function. This is highly efficient as it stops searching on the first match.

  * **`filter`**: A `Callable` (function) that takes one `Node` argument and returns a `bool`.
  * **`root_node`**: (Optional) The node to start searching from. If `null`, uses the entire current scene.

`static func find_nodes_by_filter(filter: Callable, root_node: Node = null) -> Array[Node]`
Returns an **Array** of all `Node`s that return `true` for the provided `filter` function.

  * Parameters are identical to `find_node_by_filter`.

### Type-Based Wrapper Functions

`static func find_node_by_type(type: Variant, visible_only: bool = true, root_node: Node = null) -> Node`
Returns the **first** `Node` found that matches the `type`.

  * **`type`**: The class to search for (e.g., `Control`, `Player`, or `preload("player.gd")`).
  * **`visible_only`**: (Optional) If `true`, only returns nodes that are visible in the tree. Defaults to `true`.
  * **`root_node`**: (Optional) The node to start searching from. If `null`, uses the entire current scene.

`static func find_nodes_by_type(type: Variant, visible_only: bool = true, root_node: Node = null) -> Array[Node]`
Returns an **Array** of all `Node`s found that match the `type`.

  * Parameters are identical to `find_node_by_type`.

### Utility Function

`static func get_main_scene_of_viewport(obj: Node) -> Node`
Finds and returns the root scene node to which `obj` belongs, even if it's inside a `SubViewport`.

## Usage Examples

```gdscript

# --- Type-Based Examples ---

# Example 1: Find the Player node, wherever it is
var player_node: Player = SearchObjectByType.find_node_by_type(Player)
if player_node:
    player_node.heal(10)

# Example 2: Find all visible enemies in the entire scene
var all_enemies: Array[Node] = SearchObjectByType.find_nodes_by_type(Enemy, true)
for enemy in all_enemies:
    print(enemy.name)

# Example 3: Find the first "Item" node, but only inside the "Inventory" container
var inventory_node: Node = $UI/Inventory
var first_item: Item = SearchObjectByType.find_node_by_type(Item, true, inventory_node)
if first_item:
    first_item.use()

# --- Filter-Based Examples (Advanced) ---

# Example 4: Find all enemies in the "zombies" group with low health
var filter_func := func(node: Node):
    return (
        node is Enemy and
        node.is_in_group("zombies") and
        node.health < 20
    )
var low_health_zombies: Array[Node] = SearchObjectByType.find_nodes_by_filter(filter_func)
for zombie: Enemy in low_health_zombies:
    zombie.start_fleeing()

# Example 5: Find a specific button by its name
var start_button: Button = SearchObjectByType.find_node_by_filter(
    func(node: Node):
        return node is Button and node.name == "StartButton"
)
if start_button:
    start_button.grab_focus()

# --- Utility Example ---

# Example 6: Get the root node of the current scene (even if inside a SubViewport)
var my_scene_root: Node = SearchObjectByType.get_main_scene_of_viewport(self)
print(my_scene_root.name)
```

## Key Use Cases

### 1\. Decoupling Scenes

This tool is excellent for breaking hard-coded `get_node` paths. A UI scene can find the `Player` node to read its health without needing a fragile path like `get_node("../../World/Player")`.

```gdscript


func _process(delta):
    var player = SearchObjectByType.find_node_by_type(Player)
    if player:
        value = player.health
```

### 2\. Networking

When you receive a network packet, you often need to find a *local* node (like an enemy or player) based on an ID or other data. The filter functions are perfect for this.

```gdscript

func _on_packet_received(data: Dictionary):
    if data.type == "enemy_update":
        # Find the specific enemy this packet is for using its network ID
        var filter = func(node: Node):
            return node is Enemy and node.network_id == data.id
            
        var enemy_node: Enemy = SearchObjectByType.find_node_by_filter(filter)
        
		# Now that we've found the node, we can apply the networked data
		if enemy_node:
			enemy_node.global_position = data.position
```

## Additional Examples

For more detailed examples, check out the **example scenes** included in this repository. You can load and run these scenes in Godot to see `SearchObjectByType` in action.

## Notes

  * The `type` parameter is a `Variant` and can be a `class_name` (e.g., `Player`), a `StringName` (e.g., `"Player"`), or a `Script` object (e.g., `preload("res://player.gd")`).
  * The `visible_only` filter is safe. It correctly checks `is_visible_in_tree()` for `CanvasItem` and `Node3D` nodes. Non-visual nodes (like `Timer`) are considered "visible" by default.

## License

This asset is provided under the [MIT License](LICENSE).
