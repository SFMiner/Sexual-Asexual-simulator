class_name Genetics
extends RefCounted

# Centralized genetics system for trait inheritance and mutation

# Trait definitions
const TRAITS = [
	"temperature_tolerance",
	"pathogen_resistance", 
	"resource_efficiency",
	"mobility",
	"reproduction_speed",
	"mutation_rate"
]

const TRAIT_MIN = 0.0
const TRAIT_MAX = 100.0

# Mutation parameters
const DEFAULT_MUTATION_CHANCE = 0.10  # 10% per trait
const DEFAULT_MUTATION_MAGNITUDE = 5.0
const MUTATION_MAGNITUDE_VARIANCE = 2.0

# Sexual reproduction parameters
const RECOMBINATION_VARIANCE = 3.0

# Initialize random traits for a new organism
static func initialize_random_traits(organism: OrganismData) -> void:
	for a_trait in TRAITS:
		organism.set(a_trait, randf_range(30.0, 70.0))
	
	# Mutation rate special case - used only by asexual
	organism.mutation_rate = randf_range(5.0, 15.0)

# Asexual reproduction: clone with mutations
static func asexual_reproduction(parent: OrganismData) -> OrganismData:
	var offspring = OrganismData.new(false)
	offspring.generation = parent.generation + 1
	
	# Copy all traits with potential mutations
	for a_trait in TRAITS:
		var value = parent.get(a_trait)
		
		# Apply mutation based on parent's mutation_rate
		if randf() < (parent.mutation_rate / 100.0):
			var magnitude = randf_range(
				DEFAULT_MUTATION_MAGNITUDE - MUTATION_MAGNITUDE_VARIANCE,
				DEFAULT_MUTATION_MAGNITUDE + MUTATION_MAGNITUDE_VARIANCE
			)
			value += randf_range(-magnitude, magnitude)
		
		offspring.set(a_trait, clamp(value, TRAIT_MIN, TRAIT_MAX))
	
	return offspring

# Sexual reproduction: recombination with variance
static func sexual_reproduction(parent1: OrganismData, parent2: OrganismData) -> OrganismData:
	var offspring = OrganismData.new(true)
	offspring.generation = max(parent1.generation, parent2.generation) + 1
	
	for a_trait in TRAITS:
		# Average parental values
		var avg = (parent1.get(a_trait) + parent2.get(a_trait)) / 2.0
		
		# Add small random variance (genetic shuffling)
		var variance = randf_range(-RECOMBINATION_VARIANCE, RECOMBINATION_VARIANCE)
		
		offspring.set(a_trait, clamp(avg + variance, TRAIT_MIN, TRAIT_MAX))
	
	return offspring

# Calculate fitness given organism traits and environment
static func calculate_fitness(organism: OrganismData, environment: Dictionary) -> float:
	var fitness = 1.0
	
	# Temperature stress
	var temp_diff = abs(environment.temperature - organism.temperature_tolerance)
	fitness *= clamp(1.0 - (temp_diff / 100.0), 0.0, 1.0)
	
	# Pathogen stress
	if environment.pathogen_intensity > 0:
		var resistance_factor = organism.pathogen_resistance / 100.0
		fitness *= clamp(resistance_factor, 0.0, 1.0)
	
	# Resource stress
	if environment.resource_abundance < 50:
		var efficiency_factor = organism.resource_efficiency / 100.0
		fitness *= clamp(efficiency_factor, 0.0, 1.0)
	
	# Predation stress
	if environment.predation_pressure > 0:
		var mobility_factor = organism.mobility / 100.0
		fitness *= clamp(mobility_factor, 0.0, 1.0)
	
	return fitness

# Get trait statistics for a population
static func get_population_trait_stats(organisms: Array[OrganismData]) -> Dictionary:
	var stats = {}
	
	for a_trait in TRAITS:
		var values = []
		for org in organisms:
			if org.is_alive:
				values.append(org.get(a_trait))
		
		if values.is_empty():
			stats[a_trait] = {
				"mean": 0.0,
				"min": 0.0,
				"max": 0.0,
				"stddev": 0.0
			}
			continue
		
		# Calculate statistics
		var mean = values.reduce(func(sum, val): return sum + val, 0.0) / values.size()
		var min_val = values.min()
		var max_val = values.max()
		
		# Standard deviation
		var variance = 0.0
		for val in values:
			variance += pow(val - mean, 2)
		variance /= values.size()
		var stddev = sqrt(variance)
		
		stats[a_trait] = {
			"mean": mean,
			"min": min_val,
			"max": max_val,
			"stddev": stddev
		}
	
	return stats

# Apply directional selection pressure
static func apply_selection_pressure(organism: OrganismData, a_trait: String, target: float, intensity: float) -> void:
	var current = organism.get(a_trait)
	var diff = target - current
	var adjustment = diff * intensity
	organism.set(a_trait, clamp(current + adjustment, TRAIT_MIN, TRAIT_MAX))

# Genetic distance between two organisms (useful for mate compatibility)
static func genetic_distance(org1: OrganismData, org2: OrganismData) -> float:
	var distance = 0.0
	
	for a_trait in TRAITS:
		var diff = org1.get(a_trait) - org2.get(a_trait)
		distance += diff * diff
	
	return sqrt(distance)
