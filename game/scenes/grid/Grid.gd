tool
extends Spatial
class_name Grid

export (Vector2) var size: = Vector2(15, 15)
export (Array, PackedScene) var cell_scenes: = []

onready var tile_map: TileMap = $TileMap
onready var cells: Spatial = $Cells
onready var tween: Tween = $Tween


func _on_UpdateTimer_timeout() -> void:
	update()


func _ready() -> void:
	init_grid()


func init_grid() -> void:
	var y: = size.y - 1
	while y >= 0:
		var x: = size.x - 1
		
		while x >= 0:
			var cell_id: = tile_map.get_cell(x, y)
			
			if cell_id == TileMap.INVALID_CELL or cell_id >= cell_scenes.size():
				x -= 1
				continue
			
			create_cell_at(cell_id, Vector2(x, y))
			
			x -= 1
		y -= 1


func update() -> void:
	var y: = size.y - 1
	while y >= 0:
		var x: = size.x - 1
		while x >= 0:
			var cell: = get_cell_at(Vector2(x, y))
			
			if not cell:
				x -= 1
				continue
			
			apply_gravity(cell)
			
			x -= 1
		y -= 1


func get_cell_at(pos: Vector2) -> Cell:
	if not is_valid_cell(pos):
		return null
	
	var cell_id: = tile_map.get_cell(pos.x, pos.y)
	
	if cell_id == TileMap.INVALID_CELL:
		return null
	
	for cell_instance in cells.get_children():
		if cell_instance is Cell:
			if cell_instance.position == pos:
				return cell_instance
	
	return create_cell_at(cell_id, pos)


func create_cell_at(cell_id: int, pos: Vector2) -> Cell:
	if cell_id < 0 or cell_id >= cell_scenes.size():
		return null
	
	var scene: PackedScene = cell_scenes[cell_id] as PackedScene
	var cell_instance: Cell = scene.instance() as Cell
	cells.add_child(cell_instance)
	cell_instance.transform.origin = Vector3(pos.x, -pos.y, 0)
	cell_instance.position = Vector2(pos.x, pos.y)
	
	
	return cell_instance


func is_valid_cell(pos: Vector2) -> bool:
	if pos.x < 0 or pos.y < 0:
		return false
	
	return pos.x < size.x and pos.y < size.y


func apply_gravity(cell: Cell) -> void:
	var bottom: = cell.position + Vector2.DOWN
	
	if not is_valid_cell(bottom):
		return
	
	var bottom_cell: = get_cell_at(bottom)
	
	if bottom_cell:
		return
	
	tile_map.set_cell(bottom.x, bottom.y, cell.id)
	tile_map.set_cell(cell.position.x, cell.position.y, TileMap.INVALID_CELL)
	cell.position = bottom
