class_name OrganismData
extends RefCounted

# Pure data class - no Node overhead
# Stored in packed arrays where possible

var id: int
var is_sexual: bool
var generation: int

# Traits (0-100)
var temperature_tolerance: float
var pathogen_resistance: float
var resource_efficiency: float
var mobility: float
var reproduction_speed: float
var mutation_rate: float  # Only used by asexual

# State
var age: float
var energy: float
var reproduction_cooldown: float
var position: Vector2
var is_alive: bool

# Mating (sexual only)
var seeking_mate: bool
var mate_id: int = -1

func _init(sexual: bool = false):
	is_sexual = sexual
	initialize_random_traits()

func initialize_random_traits():
	temperature_tolerance = randf_range(30.0, 70.0)
	pathogen_resistance = randf_range(30.0, 70.0)
	resource_efficiency = randf_range(30.0, 70.0)
	mobility = randf_range(30.0, 70.0)
	reproduction_speed = randf_range(30.0, 70.0)
	mutation_rate = randf_range(5.0, 15.0)

func calculate_fitness(environment: Dictionary) -> float:
	var fitness = 1.0
	
	# Temperature stress
	var temp_diff = abs(environment.temperature - temperature_tolerance)
	fitness *= clamp(1.0 - (temp_diff / 100.0), 0.0, 1.0)
	
	# Pathogen stress
	if environment.pathogen_intensity > 0:
		fitness *= clamp(pathogen_resistance / 100.0, 0.0, 1.0)
	
	# Resource stress
	if environment.resource_abundance < 50:
		fitness *= clamp(resource_efficiency / 100.0, 0.0, 1.0)
	
	# Predation
	if environment.predation_pressure > 0:
		fitness *= clamp(mobility / 100.0, 0.0, 1.0)
	
	return fitness

func clone_with_mutations() -> OrganismData:
	var offspring = OrganismData.new(false)
	offspring.generation = generation + 1
	
	# Copy traits with potential mutations
	var traits = [
		"temperature_tolerance", "pathogen_resistance",
		"resource_efficiency", "mobility",
		"reproduction_speed", "mutation_rate"
	]
		
	for a_trait in traits:
		var value = get(a_trait)
		if randf() < (mutation_rate / 100.0):
			value += randf_range(-5.0, 5.0)
		offspring.set(a_trait, clamp(value, 0.0, 100.0))
	
	return offspring

func recombine_with(partner: OrganismData) -> OrganismData:
	var offspring = OrganismData.new(true)
	offspring.generation = max(generation, partner.generation) + 1
	
	var traits = [
		"temperature_tolerance", "pathogen_resistance",
		"resource_efficiency", "mobility",
		"reproduction_speed", "mutation_rate"
	]
	
	for a_trait in traits:
		# Average with small variance
		var avg = (get(a_trait) + partner.get(a_trait)) / 2.0
		var variance = randf_range(-3.0, 3.0)
		offspring.set(a_trait, clamp(avg + variance, 0.0, 100.0))
	
	return offspring
