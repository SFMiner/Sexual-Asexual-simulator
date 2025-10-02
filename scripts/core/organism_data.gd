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
	Genetics.initialize_random_traits(self)

func initialize_random_traits():
	Genetics.initialize_random_traits(self)


func calculate_fitness(environment: Dictionary) -> float:
	
	return Genetics.calculate_fitness(self, environment)


func clone_with_mutations() -> OrganismData:
	return Genetics.asexual_reproduction(self)

func recombine_with(partner: OrganismData) -> OrganismData:
	return Genetics.sexual_reproduction(self, partner)
