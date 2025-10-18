extends Node


func _ready() -> void:
	print(SearchObjectByType.get_main_scene_of_viewport(self).name) # will return current MainScene of a specific viewport
	#print(self.get_viewport().name) # will return viewport but not the MainScene or subMainScenes
	#print(get_tree().current_scene.name) # Will always return the currentScene "MainScene"
