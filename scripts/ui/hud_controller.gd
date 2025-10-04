class_name HUDController
extends CanvasLayer

@onready var sexual_label = $TopPanel/MarginContainer/HBoxContainer/Stats/SexualCount
@onready var asexual_label = $TopPanel/MarginContainer/HBoxContainer/Stats/AsexualCount
@onready var total_label = $TopPanel/MarginContainer/HBoxContainer/Stats/TotalCount
@onready var generation_label = $TopPanel/MarginContainer/HBoxContainer/Stats/Generation

@onready var graph_renderer = $RightPanel/MarginContainer/VBoxContainer/GraphRenderer
@onready var control_panel = $RightPanel/MarginContainer/VBoxContainer/HBoxContainer/ControlPanel
@onready var organism_inspector = $RightPanel/MarginContainer/VBoxContainer/OrganismInspector/InspectorContent

@onready var play_button = $TopPanel/MarginContainer/HBoxContainer/Controls/PlayButton
@onready var pause_button = $TopPanel/MarginContainer/HBoxContainer/Controls/PauseButton
@onready var reset_button = $TopPanel/MarginContainer/HBoxContainer/Controls/ResetButton
@onready var speed_slider = $TopPanel/MarginContainer/HBoxContainer/Controls/SpeedSlider
@onready var speed_value = $TopPanel/MarginContainer/HBoxContainer/Controls/SpeedValue

@onready var graph_button = $RightPanel/MarginContainer/VBoxContainer/ViewToggle/GraphButton
@onready var inspector_button = $RightPanel/MarginContainer/VBoxContainer/ViewToggle/InspectorButton

var sim_manager: SimulationManager:
	set(value):
		sim_manager = value
		if is_node_ready():
			setup_connections()

var selected_organism: OrganismData = null
var inspector_update_timer: float = 0.0

func _ready():
	if sim_manager:
		setup_connections()

func setup_connections():
	sim_manager.population_update.connect(_on_population_update)
	sim_manager.simulation_state_changed.connect(_on_state_changed)
	
	control_panel.connect_to_environment(sim_manager.environment_manager)

func show_graph_view():
	graph_renderer.show()
	organism_inspector.get_parent().hide()

func show_organism_details(organism):
	if organism_inspector:
		organism_inspector.show_organism(organism)

func _on_play_pressed():
	sim_manager.start_simulation()

func _on_pause_pressed():
	sim_manager.pause_simulation()

func _on_reset_pressed():
	sim_manager.reset_simulation()
	graph_renderer.clear()

func _on_speed_changed(value: float):
	sim_manager.set_speed(value)
	speed_value.text = "%.1fx" % value

func _on_population_update(sexual: int, asexual: int):
	sexual_label.text = "Sexual: %d" % sexual
	asexual_label.text = "Asexual: %d" % asexual
	total_label.text = "Total: %d" % (sexual + asexual)
	
	# Update average generation from current stats
	if sim_manager.statistics_collector.current_stats.has("avg_generation"):
		generation_label.text = "Avg Generation: %.1f" % sim_manager.statistics_collector.current_stats.avg_generation
	
	graph_renderer.add_data_point(sexual, asexual)

func _on_state_changed(is_running: bool):
	play_button.disabled = is_running
	pause_button.disabled = not is_running

func _on_export_pressed():
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	
	# Export all formats
	DataExporter.export_all(
		sim_manager.population_manager,
		sim_manager.environment_manager,
		sim_manager.statistics_collector,
		"simulation_data" 
	)
	
	print("All data exported successfully!")
	print("Files saved to: " + ProjectSettings.globalize_path("user://"))

func _on_inspector_closed():
	# Clear selected organism
	selected_organism = null
	
	# Switch back to graph view
	graph_button.button_pressed = true
	inspector_button.button_pressed = false
	show_graph_view()
