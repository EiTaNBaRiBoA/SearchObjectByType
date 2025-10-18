extends Control


func _ready() -> void:
	print("--- SearchObjectByType Examples ---")
	
	# --- Find by Type (Simple) ---


	print("\n1. Find first node by class_name 'Player':")
	var player: PlayerExample = SearchObjectByType.find_node_by_type(PlayerExample)
	if player:
		print("  - Found: %s" % player.name)


	print("\n2. Find all *visible* nodes by class_name 'Enemy':")
	# visible_only defaults to 'true', so we don't need to add it.
	var visible_enemies: Array[Node] = SearchObjectByType.find_nodes_by_type(EnemyExample)
	for enemy: EnemyExample in visible_enemies:
		print("  - Found visible enemy: %s" % enemy.name)


	print("\n3. Find *all* nodes by class_name 'Enemy' (including invisible):")
	var all_enemies: Array[Node] = SearchObjectByType.find_nodes_by_type(EnemyExample, false)
	for enemy: EnemyExample in all_enemies:
		print("  - Found enemy: %s (Visible: %s)" % [enemy.name, enemy.visible])


	# --- Scoped Search ---


	print("\n4. Find first 'Player' *only* inside the 'group' node:")
	var group: Node2D = $"../Group"
	var playerfind: PlayerExample = SearchObjectByType.find_node_by_type(PlayerExample, true, group)
	if playerfind:
		print("  - Found player: %s" % playerfind.name)


	# --- Advanced Filter Search ---


	print("\n5. (Advanced) Find first *low-health zombie* using a filter:")
	# We want an Enemy, in group "zombies", with health < 50
	var filter_func := func(node: Node):
		return (
			node is EnemyExample and
			node.health < 50
		)
	var low_health_zombie: EnemyExample = SearchObjectByType.find_node_by_filter(filter_func)
	if low_health_zombie:
		print("  - Found low-health zombie: %s (Health: %s)" % [low_health_zombie.name, low_health_zombie.health])


	print("\n6. (Advanced) Find *all* nodes using a filter:")
	var nodes_filter := func(node: Node):
		return node.visible == false
	var nodes_found: Array[Node] = SearchObjectByType.find_nodes_by_filter(nodes_filter)
	print("  - Total nodes found: %s" % nodes_found.size())
	for node_found: Node in nodes_found:
		print("    - %s" % node_found.name)

	# --- Common Errors (Do Not Do This) ---
	
	print("\n7. Invalid Calls (will produce errors):")
	print("  - Search.find_node_by_type(Player.new()) # ERROR: Do not pass an instance.")
	print("  - Search.find_node_by_type(null) # ERROR: Do not pass null.")
	print("  - Search.find_node_by_type(123) # ERROR: Do not pass a non-type Variant.")
