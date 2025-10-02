extends Node

# AutoLoad singleton - orchestrates everything

signal simulation_state_changed(is_running: bool)
signal speed_changed(new_speed: float)
signal population_update(sexual: int, asexual: int)

@export var target_fps: int = 60
@export var max_population: int = 2000

var simulation_speed: float = 1.0
var is_running: bool = false
var elapsed_time: float = 0.0
var frame_count: int = 0

# Manager references (set by main scene)
var population_manager: PopulationManager
var environment_manager: EnvironmentManager
var statistics_collector: StatisticsCollector
var visual_manager: VisualManager

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float):
	if not is_running:
		return
	
	var scaled_delta = delta * simulation_speed
	elapsed_time += scaled_delta
	frame_count += 1
	
	# Update in order
	environment_manager.update_environment(elapsed_time, scaled_delta)
	population_manager.update_population(scaled_delta, environment_manager.get_conditions())
	
	# Update visuals every frame
	visual_manager.update_visuals(population_manager)
	
	# Collect statistics and emit updates every 30 frames
	if frame_count % 30 == 0:
		var stats = population_manager.get_population_stats()
		statistics_collector.collect_sample(stats, environment_manager.get_conditions())
		population_update.emit(stats.sexual_count, stats.asexual_count)

func start_simulation():
	is_running = true
	simulation_state_changed.emit(true)

func pause_simulation():
	is_running = false
	simulation_state_changed.emit(false)

func set_speed(speed: float):
	simulation_speed = clamp(speed, 0.1, 10.0)
	speed_changed.emit(simulation_speed)

func reset_simulation(scenario_config: Dictionary = {}):
	is_running = false
	elapsed_time = 0.0
	frame_count = 0
	
	population_manager.reset()
	environment_manager.reset()
	statistics_collector.reset()
	
	# Apply scenario if provided
	if scenario_config:
		apply_scenario(scenario_config)
	
	# Spawn initial populations
	population_manager.spawn_initial_population(100, 100)  # 100 each

func apply_scenario(config: Dictionary):
	if config.has("environment"):
		environment_manager.apply_settings(config.environment)
	if config.has("population"):
		population_manager.apply_settings(config.population)
