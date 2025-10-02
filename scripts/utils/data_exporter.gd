class_name DataExporter
extends RefCounted

# Advanced data export system for simulation analysis

# Export full simulation state to JSON
static func export_to_json(
	population_manager: PopulationManager,
	environment_manager: EnvironmentManager,
	statistics_collector: StatisticsCollector,
	filepath: String
) -> bool:
	var data = {
		"metadata": {
			"export_time": Time.get_datetime_string_from_system(),
			"simulation_time": Time.get_ticks_msec() / 1000.0,
			"godot_version": Engine.get_version_info()
		},
		"environment": environment_manager.get_conditions(),
		"population": {
			"total_count": population_manager.organisms.size(),
			"sexual_count": 0,
			"asexual_count": 0,
			"organisms": []
		},
		"statistics": {
			"trait_stats": Genetics.get_population_trait_stats(population_manager.organisms),
			"history": statistics_collector.get_history(100)
		}
	}
	
	# Export individual organisms
	for org in population_manager.organisms:
		if not org.is_alive:
			continue
		
		if org.is_sexual:
			data.population.sexual_count += 1
		else:
			data.population.asexual_count += 1
		
		data.population.organisms.append({
			"id": org.id,
			"is_sexual": org.is_sexual,
			"generation": org.generation,
			"age": org.age,
			"energy": org.energy,
			"position": {"x": org.position.x, "y": org.position.y},
			"traits": {
				"temperature_tolerance": org.temperature_tolerance,
				"pathogen_resistance": org.pathogen_resistance,
				"resource_efficiency": org.resource_efficiency,
				"mobility": org.mobility,
				"reproduction_speed": org.reproduction_speed,
				"mutation_rate": org.mutation_rate
			}
		})
	
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if not file:
		push_error("Could not open file for JSON export: " + filepath)
		return false
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("Exported simulation state to JSON: " + filepath)
	return true

# Export detailed CSV with trait information
static func export_detailed_csv(
	statistics_collector: StatisticsCollector,
	filepath: String
) -> bool:
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if not file:
		push_error("Could not open file for detailed CSV export: " + filepath)
		return false
	
	# Header
	var header = "time,sexual_count,asexual_count,total_count,avg_generation,"
	header += "temperature,pathogens,resources,"
	header += "avg_temp_tolerance,avg_pathogen_resist,avg_resource_efficiency,"
	header += "avg_mobility,avg_reproduction_speed,avg_mutation_rate"
	file.store_line(header)
	
	# Data
	for sample in statistics_collector.get_history(1000):
		if not sample.has("avg_traits"):
			continue
		
		var traits = sample.avg_traits
		var line = "%f,%d,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f" % [
			sample.time,
			sample.sexual_count,
			sample.asexual_count,
			sample.total_count,
			sample.avg_generation,
			sample.environment.temperature,
			sample.environment.pathogen_intensity,
			sample.environment.resource_abundance,
			traits.get("temperature_tolerance", 0),
			traits.get("pathogen_resistance", 0),
			traits.get("resource_efficiency", 0),
			traits.get("mobility", 0),
			traits.get("reproduction_speed", 0),
			traits.get("mutation_rate", 0)
		]
		file.store_line(line)
	
	file.close()
	print("Exported detailed statistics to CSV: " + filepath)
	return true

# Export trait distribution histogram data
static func export_trait_distributions(
	population_manager: PopulationManager,
	filepath: String,
	bins: int = 20
) -> bool:
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if not file:
		push_error("Could not open file for trait distribution export: " + filepath)
		return false
	
	# Header
	file.store_line("trait,reproductive_type,bin_min,bin_max,count")
	
	var traits_list = [
		"temperature_tolerance", "pathogen_resistance",
		"resource_efficiency", "mobility",
		"reproduction_speed", "mutation_rate"
	]
	
	for a_trait in traits_list:
		# Separate by reproductive type
		var sexual_values = []
		var asexual_values = []
		
		for org in population_manager.organisms:
			if not org.is_alive:
				continue
			var value = org.get(a_trait)
			if org.is_sexual:
				sexual_values.append(value)
			else:
				asexual_values.append(value)
		
		# Create histograms
		_write_histogram(file, a_trait, "sexual", sexual_values, bins)
		_write_histogram(file, a_trait, "asexual", asexual_values, bins)
	
	file.close()
	print("Exported trait distributions to CSV: " + filepath)
	return true

# Helper: Write histogram data
static func _write_histogram(file: FileAccess, a_trait: String, type: String, values: Array, bins: int) -> void:
	if values.is_empty():
		return
	
	var bin_counts = []
	bin_counts.resize(bins)
	bin_counts.fill(0)
	
	var bin_size = 100.0 / bins
	
	for value in values:
		var bin_index = int(value / bin_size)
		bin_index = clamp(bin_index, 0, bins - 1)
		bin_counts[bin_index] += 1
	
	for i in bins:
		var bin_min = i * bin_size
		var bin_max = (i + 1) * bin_size
		file.store_line("%s,%s,%f,%f,%d" % [a_trait, type, bin_min, bin_max, bin_counts[i]])

# Export spatial heatmap data
static func export_spatial_heatmap(
	population_manager: PopulationManager,
	filepath: String,
	grid_size: int = 20
) -> bool:
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if not file:
		push_error("Could not open file for spatial heatmap export: " + filepath)
		return false
	
	var bounds = population_manager.world_bounds
	var cell_width = bounds.size.x / grid_size
	var cell_height = bounds.size.y / grid_size
	
	# Initialize grid
	var sexual_grid = []
	var asexual_grid = []
	for i in grid_size:
		sexual_grid.append([])
		asexual_grid.append([])
		for j in grid_size:
			sexual_grid[i].append(0)
			asexual_grid[i].append(0)
	
	# Count organisms in each cell
	for org in population_manager.organisms:
		if not org.is_alive:
			continue
		
		var grid_x = int(org.position.x / cell_width)
		var grid_y = int(org.position.y / cell_height)
		grid_x = clamp(grid_x, 0, grid_size - 1)
		grid_y = clamp(grid_y, 0, grid_size - 1)
		
		if org.is_sexual:
			sexual_grid[grid_y][grid_x] += 1
		else:
			asexual_grid[grid_y][grid_x] += 1
	
	# Write header
	file.store_line("grid_x,grid_y,pos_x,pos_y,sexual_count,asexual_count,total_count")
	
	# Write data
	for y in grid_size:
		for x in grid_size:
			var pos_x = (x + 0.5) * cell_width
			var pos_y = (y + 0.5) * cell_height
			var sexual_count = sexual_grid[y][x]
			var asexual_count = asexual_grid[y][x]
			var total_count = sexual_count + asexual_count
			
			file.store_line("%d,%d,%f,%f,%d,%d,%d" % [
				x, y, pos_x, pos_y, sexual_count, asexual_count, total_count
			])
	
	file.close()
	print("Exported spatial heatmap to CSV: " + filepath)
	return true

# Export all data formats at once
static func export_all(
	population_manager: PopulationManager,
	environment_manager: EnvironmentManager,
	statistics_collector: StatisticsCollector,
	base_filename: String
) -> void:
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var base = "user://%s_%s" % [base_filename, timestamp]
	
	export_to_json(population_manager, environment_manager, statistics_collector, base + ".json")
	export_detailed_csv(statistics_collector, base + "_detailed.csv")
	export_trait_distributions(population_manager, base + "_distributions.csv")
	export_spatial_heatmap(population_manager, base + "_heatmap.csv")
	
	print("All export formats completed. Base path: " + ProjectSettings.globalize_path(base))
