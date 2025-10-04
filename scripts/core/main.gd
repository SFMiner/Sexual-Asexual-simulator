extends Control

# Main scene controller - handles initialization and viewport sizing

@onready var sub_viewport = $SimulationView/SubViewport
@onready var sim_manager = SimulationManager

func _ready():
	# Initialize managers
	sim_manager.population_manager = $Managers/PopulationManager
	sim_manager.environment_manager = $Managers/EnvironmentManager
	sim_manager.statistics_collector = $Managers/StatisticsCollector
	sim_manager.visual_manager = $SimulationView/SubViewport/SimulationSpace/VisualManager
	
	# Setup HUD
	var hud = $HUD
	hud.sim_manager = sim_manager
	
	# Defer viewport sizing until after layout is ready
	sim_manager.visual_manager.organism_clicked.connect(hud.show_organism_details)

	call_deferred("_initialize_viewport")

func _initialize_viewport():
	# Set initial viewport size to match window
	_update_viewport_size()
	
	# Connect to window resize
	get_viewport().size_changed.connect(_on_window_resized)
	
	# Start simulation
	sim_manager.reset_simulation()

func _on_window_resized():
	_update_viewport_size()
	
	# Update population manager bounds
	if sim_manager and sim_manager.population_manager:
		sim_manager.population_manager.world_bounds = Rect2(Vector2.ZERO, sub_viewport.size)

func _update_viewport_size():
	if sub_viewport:
		# Get the actual window size
		var window_size = get_viewport().get_visible_rect().size
		sub_viewport.size = Vector2i(int(window_size.x), int(window_size.y))
		
		print("SubViewport resized to: ", sub_viewport.size)
		
func _process(_delta):
	# Continuously sync viewport size (fallback in case resize signal doesn't fire)
	if sub_viewport:
		var window_size = get_viewport().get_visible_rect().size
		var target_size = Vector2i(int(window_size.x), int(window_size.y))
		if sub_viewport.size != target_size:
			sub_viewport.size = target_size
			if sim_manager and sim_manager.population_manager:
				sim_manager.population_manager.world_bounds = Rect2(Vector2.ZERO, window_size)
