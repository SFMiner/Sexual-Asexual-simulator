class_name PopulationManager
extends Node

# Manages all organism data and lifecycle

var organisms: Array[OrganismData] = []
var object_pool: ObjectPool
var spatial_hash: SpatialHash

var max_population: int = 2000
var carrying_capacity: int = 2000

# Performance optimization
var update_batch_size: int = 100
var current_batch_offset: int = 0

var movement_tracker = {"total_x": 0.0, "total_y": 0.0, "count": 0, "frame": 0}

# Boundaries for wrapping - MUST be set externally
var world_bounds: Rect2 = Rect2(0, 0, 1152, 648)

func _ready():
	object_pool = ObjectPool.new(OrganismData, 2000)
	spatial_hash = SpatialHash.new(50.0)  # 50 pixel cell size

func set_world_bounds(bounds: Rect2):
	world_bounds = bounds
	print("PopulationManager world_bounds set to: ", world_bounds)

func spawn_initial_population(sexual_count: int, asexual_count: int):
	print("Spawning in bounds: ", world_bounds)
	
	var spawn_area = world_bounds.size
	
	# Spawn sexual organisms
	for i in sexual_count:
		var org = OrganismData.new(true)
		org.position = rand_position_organism()
		org.energy = 100.0
		org.is_alive = true
		org.id = organisms.size()
		organisms.append(org)
		spatial_hash.insert(org)
	
	# Spawn asexual organisms
	for i in asexual_count:
		var org = OrganismData.new(false)
		org.position = rand_position_organism()
		org.energy = 100.0
		org.is_alive = true
		org.id = organisms.size()
		organisms.append(org)
		spatial_hash.insert(org)
	
	print("Spawned ", organisms.size(), " organisms")

func rand_position_organism():
		var spawn_area = world_bounds.size
		var rand_pos_x = randf_range(50, spawn_area.x - 50)
		var rand_pos_y = randf_range(50, spawn_area.y - 50)
		print("organism spawned at Vector2(" + str(rand_pos_x) + str(rand_pos_y) + ")")
		return Vector2(rand_pos_x, rand_pos_y)


func update_population(delta: float, environment: Dictionary):
	# Batch updates for performance
	var batch_size = min(update_batch_size, organisms.size())
	
	for i in batch_size:
		var idx = (current_batch_offset + i) % organisms.size()
		if idx >= organisms.size():
			break
		
		var org = organisms[idx]
		if not org.is_alive:
			continue
		
		# Age and energy
		org.age += delta
		org.energy -= delta * 2.0  # Base metabolism
		
		# Fitness check
		var fitness = org.calculate_fitness(environment)
		if fitness < 0.3 or org.energy <= 0:
			kill_organism(org, idx)
			continue
		
		# Movement (simple random walk)
		var move_speed = org.mobility * 0.5
		var movement = Vector2(
			randf_range(-move_speed, move_speed),
			randf_range(-move_speed, move_speed)
		) * delta
		
		org.position += movement
		
		movement_tracker.total_x += movement.x
		movement_tracker.total_y += movement.y
		movement_tracker.count += 1
		movement_tracker.frame += 1

		if movement_tracker.frame % 300 == 0:  # Every ~5 seconds at 60fps
			var avg_x = movement_tracker.total_x / movement_tracker.count
			var avg_y = movement_tracker.total_y / movement_tracker.count
			#print("Movement averages over %d movements: x=%.4f, y=%.4f" % [movement_tracker.count, avg_x, avg_y])
			movement_tracker.total_x = 0.0
			movement_tracker.total_y = 0.0
			movement_tracker.count = 0
				
		# Wrap around boundaries instead of going off-screen
		wrap_position(org)
		
		spatial_hash.update(org)
		
		# Reproduction
		org.reproduction_cooldown -= delta
		if org.reproduction_cooldown <= 0 and org.energy > 50:
			attempt_reproduction(org)
	
	current_batch_offset = (current_batch_offset + batch_size) % max(1, organisms.size())
	
	# Enforce carrying capacity
	enforce_carrying_capacity(environment)

func wrap_position(org: OrganismData):
	# Wrap around screen boundaries
	if org.position.x < 0:
		org.position.x = world_bounds.size.x
	elif org.position.x > world_bounds.size.x:
		org.position.x = 0
	
	if org.position.y < 0:
		org.position.y = world_bounds.size.y
	elif org.position.y > world_bounds.size.y:
		org.position.y = 0

func attempt_reproduction(org: OrganismData):
	if org.is_sexual:
		# Find nearby mate
		if not org.seeking_mate:
			org.seeking_mate = true
			return
		
		var nearby = spatial_hash.query_radius(org.position, 50.0)
		for other in nearby:
			if other.is_sexual and other.seeking_mate and other.id != org.id:
				# Found mate!
				var offspring = org.recombine_with(other)
				spawn_offspring(offspring, org.position)
				org.seeking_mate = false
				other.seeking_mate = false
				org.reproduction_cooldown = randf_range(15.0, 25.0)
				other.reproduction_cooldown = randf_range(15.0, 25.0)
				org.energy -= 30
				other.energy -= 30
				return
	else:
		# Asexual reproduction
		var offspring = org.clone_with_mutations()
		spawn_offspring(offspring, org.position)
		org.reproduction_cooldown = randf_range(5.0, 10.0)
		org.energy -= 25

func spawn_offspring(offspring: OrganismData, near_position: Vector2):
	if organisms.size() >= max_population:
		return
	
	offspring.position = near_position + Vector2(
		randf_range(-10, 10),
		randf_range(-10, 10)
	)
	
	# Wrap offspring position instead of clamping to prevent edge accumulation
	wrap_position(offspring)
	print("organism spawned at " + str(offspring.position))
	
	offspring.energy = 50.0
	offspring.is_alive = true
	offspring.id = organisms.size()  # Simple ID assignment
	
	organisms.append(offspring)
	spatial_hash.insert(offspring)

func kill_organism(org: OrganismData, index: int):
	org.is_alive = false
	spatial_hash.remove(org)
	organisms.remove_at(index)
	# Could return to pool here if needed

func enforce_carrying_capacity(environment: Dictionary):
	# Reduce capacity based on resources
	carrying_capacity = int(max_population * (environment.resource_abundance / 100.0))
	
	while organisms.size() > carrying_capacity:
		# Kill weakest organisms
		var weakest_idx = find_weakest_organism(environment)
		if weakest_idx >= 0:
			kill_organism(organisms[weakest_idx], weakest_idx)

func find_weakest_organism(environment: Dictionary) -> int:
	var min_fitness = 1.0
	var min_idx = -1
	
	for i in organisms.size():
		var fitness = organisms[i].calculate_fitness(environment)
		if fitness < min_fitness:
			min_fitness = fitness
			min_idx = i
	
	return min_idx

func get_organism_positions() -> PackedVector2Array:
	var positions = PackedVector2Array()
	positions.resize(organisms.size())
	
	for i in organisms.size():
		positions[i] = organisms[i].position
	
	return positions

func get_population_counts() -> Dictionary:
	var sexual = 0
	var asexual = 0
	
	for org in organisms:
		if org.is_sexual:
			sexual += 1
		else:
			asexual += 1
	
	return {"sexual": sexual, "asexual": asexual}

func get_population_stats() -> Dictionary:
	var stats = {
		"sexual_count": 0,
		"asexual_count": 0,
		"avg_generation": 0.0,
		"avg_traits": {}
	}
	
	var trait_sums = {
		"temperature_tolerance": 0.0,
		"pathogen_resistance": 0.0,
		"resource_efficiency": 0.0,
		"mobility": 0.0,
		"reproduction_speed": 0.0
	}
	
	var total_generation = 0
	
	for org in organisms:
		if org.is_sexual:
			stats.sexual_count += 1
		else:
			stats.asexual_count += 1
		
		total_generation += org.generation
		
		for a_trait in trait_sums.keys():
			trait_sums[a_trait] += org.get(a_trait)
	
	var total = organisms.size()
	if total > 0:
		stats.avg_generation = float(total_generation) / total
		for a_trait in trait_sums.keys():
			stats.avg_traits[a_trait] = trait_sums[a_trait] / total
	
	return stats

func apply_settings(settings: Dictionary):
	# Apply any population-specific settings from scenarios
	pass

func reset():
	for org in organisms:
		spatial_hash.remove(org)
	organisms.clear()
	spatial_hash.clear()
	current_batch_offset = 0
