class_name EnvironmentManager
extends Node

# All environmental factors in one manager - data driven, not class-heavy

var temperature: float = 50.0
var pathogen_intensity: float = 0.0
var resource_abundance: float = 100.0
var toxicity_level: float = 0.0
var predation_pressure: float = 0.0
var fragmentation_level: float = 0.0

# Configuration
var temperature_amplitude: float = 20.0
var temperature_frequency: float = 0.1  # Cycles per minute
var pathogen_frequency: float = 0.3  # Outbreaks per minute
var pathogen_duration: float = 60.0

# State
var current_pathogen_timer: float = 0.0
var next_pathogen_time: float = 0.0

func _ready():
	randomize_next_pathogen()

func update_environment(elapsed_time: float, delta: float):
	# Temperature - sine wave
	var cycle_speed = temperature_frequency * TAU / 60.0  # Convert to radians per second
	temperature = 50.0 + sin(elapsed_time * cycle_speed) * temperature_amplitude
	
	# Pathogens - random outbreaks
	if current_pathogen_timer > 0:
		current_pathogen_timer -= delta
		pathogen_intensity = 50.0  # Active outbreak
	else:
		pathogen_intensity = 0.0
		if elapsed_time >= next_pathogen_time:
			trigger_pathogen_outbreak()
	
	# Resource abundance - gradual changes with occasional dips
	resource_abundance += randf_range(-2.0, 3.0) * delta
	resource_abundance = clamp(resource_abundance, 20.0, 100.0)
	
	# Occasional resource crash
	if randf() < 0.001:  # Low probability each frame
		resource_abundance = max(resource_abundance * 0.5, 20.0)

func trigger_pathogen_outbreak():
	current_pathogen_timer = pathogen_duration
	randomize_next_pathogen()

func randomize_next_pathogen():
	var avg_interval = 60.0 / pathogen_frequency
	next_pathogen_time = Time.get_ticks_msec() / 1000.0 + randf_range(avg_interval * 0.5, avg_interval * 1.5)

func get_conditions() -> Dictionary:
	return {
		"temperature": temperature,
		"pathogen_intensity": pathogen_intensity,
		"resource_abundance": resource_abundance,
		"toxicity_level": toxicity_level,
		"predation_pressure": predation_pressure,
		"fragmentation_level": fragmentation_level
	}

func apply_settings(settings: Dictionary):
	if settings.has("temperature_amplitude"):
		temperature_amplitude = settings.temperature_amplitude
	if settings.has("temperature_frequency"):
		temperature_frequency = settings.temperature_frequency
	if settings.has("pathogen_frequency"):
		pathogen_frequency = settings.pathogen_frequency
	# ... etc

func reset():
	temperature = 50.0
	pathogen_intensity = 0.0
	resource_abundance = 100.0
	toxicity_level = 0.0
	predation_pressure = 0.0
	fragmentation_level = 0.0
	current_pathogen_timer = 0.0
	randomize_next_pathogen()
