extends Node2D

export var towers = []
export (PackedScene) var map
var world
var state = "playing" setget state_set
var current_map
var tower_index = 0
var money setget money_set

signal state_change(state)
signal scene_change(scene)
signal money_change(amount)

func state_set(new_value):
	state = new_value
	emit_signal("state_change", state)
	
func money_set(new_value):
	money = new_value
	emit_signal("money_change", money)

func _ready():
	set_map(map)

func _unhandled_input(event):
	if !world: return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed && towers.size():
			var cost = towers[tower_index].cost
			if cost > money: return
			var new_tower = towers[tower_index].scene.instance()
			new_tower.menu_index = tower_index
			var entity = world.add_entity(new_tower, event.position)
			if entity: money_set(money - cost)
		if event.button_index == BUTTON_RIGHT && event.pressed:
			var tile_pos = world.tile_map.world_to_map(event.position)
			if tile_pos.x > 0 && tile_pos.x < world.width && tile_pos.y > 0 && tile_pos.y < world.height && world.entities[tile_pos.x][tile_pos.y]:
				var entity = world.entities[tile_pos.x][tile_pos.y]
				if entity is Tower:
					money_set(money + towers[entity.menu_index].cost / 2)
					world.remove_entity(entity)
	if Input.is_action_just_pressed("toggle_debug"):
		get_node("DebugDrawing").cycle()
	if Input.is_action_just_pressed("force_reload"):
		set_map(current_map)
		
func set_map(scene):
	if world: world.queue_free()
	world = scene.instance()
	current_map = scene
	money_set(world.starting_money)
	add_child(world)
	emit_signal("scene_change", world)
