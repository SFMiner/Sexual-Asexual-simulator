class_name SpatialHash
extends RefCounted

# Fast O(1) proximity queries using grid-based hashing

var cell_size: float
var cells: Dictionary = {}  # Key: Vector2i (grid coords), Value: Array[OrganismData]

func _init(grid_cell_size: float = 50.0):
	cell_size = grid_cell_size

func world_to_grid(position: Vector2) -> Vector2i:
	return Vector2i(
		int(floor(position.x / cell_size)),
		int(floor(position.y / cell_size))
	)

func insert(organism: OrganismData):
	var grid_pos = world_to_grid(organism.position)
	if not cells.has(grid_pos):
		cells[grid_pos] = []
	cells[grid_pos].append(organism)

func remove(organism: OrganismData):
	var grid_pos = world_to_grid(organism.position)
	if cells.has(grid_pos):
		cells[grid_pos].erase(organism)
		if cells[grid_pos].is_empty():
			cells.erase(grid_pos)

func update(organism: OrganismData):
	# Simple update: remove and re-insert
	# Could optimize by tracking previous position
	remove(organism)
	insert(organism)

func query_radius(position: Vector2, radius: float) -> Array[OrganismData]:
	var results: Array[OrganismData] = []
	var center_grid = world_to_grid(position)
	
	# Calculate how many cells to check
	var cell_range = int(ceil(radius / cell_size))
	
	for x in range(-cell_range, cell_range + 1):
		for y in range(-cell_range, cell_range + 1):
			var check_pos = center_grid + Vector2i(x, y)
			if cells.has(check_pos):
				for organism in cells[check_pos]:
					if organism.position.distance_to(position) <= radius:
						results.append(organism)
	
	return results

func clear():
	cells.clear()
