class_name ControlPanel
extends VBoxContainer

@onready var temp_amplitude_slider = $TempAmplitude/Slider
@onready var temp_amplitude_value = $TempAmplitude/HBox/Value
@onready var temp_frequency_slider = $TempFrequency/Slider
@onready var temp_frequency_value = $TempFrequency/HBox/Value
@onready var pathogen_freq_slider = $PathogenFreq/Slider
@onready var pathogen_freq_value = $PathogenFreq/HBox/Value
@onready var resource_slider = $ResourceLevel/Slider
@onready var resource_value = $ResourceLevel/HBox/Value

@onready var scenario_dropdown = $ScenarioSelector/OptionButton

var environment_manager: EnvironmentManager

func _ready():
	setup_scenarios()

func connect_to_environment(env_manager: EnvironmentManager):
	environment_manager = env_manager
	
	temp_amplitude_slider.value = env_manager.temperature_amplitude
	temp_frequency_slider.value = env_manager.temperature_frequency
	pathogen_freq_slider.value = env_manager.pathogen_frequency
	resource_slider.value = env_manager.resource_abundance
	
	update_value_labels()

func setup_scenarios():
	scenario_dropdown.clear()
	scenario_dropdown.add_item("Balanced", 0)
	scenario_dropdown.add_item("Rapid Change", 1)
	scenario_dropdown.add_item("Stability Test", 2)
	scenario_dropdown.add_item("Catastrophe Recovery", 3)

func _on_temp_amplitude_changed(value: float):
	if environment_manager:
		environment_manager.temperature_amplitude = value
		temp_amplitude_value.text = "%.1f" % value

func _on_temp_frequency_changed(value: float):
	if environment_manager:
		environment_manager.temperature_frequency = value
		temp_frequency_value.text = "%.2f" % value

func _on_pathogen_freq_changed(value: float):
	if environment_manager:
		environment_manager.pathogen_frequency = value
		pathogen_freq_value.text = "%.1f" % value

func _on_resource_changed(value: float):
	if environment_manager:
		environment_manager.resource_abundance = value
		resource_value.text = "%.1f" % value

func _on_scenario_selected(index: int):
	var sim_manager = get_node("/root/SimulationManager")
	
	match index:
		0:
			sim_manager.reset_simulation({
				"environment": {
					"temperature_amplitude": 20.0,
					"temperature_frequency": 0.1,
					"pathogen_frequency": 0.3
				}
			})
		1:
			sim_manager.reset_simulation({
				"environment": {
					"temperature_amplitude": 40.0,
					"temperature_frequency": 0.5,
					"pathogen_frequency": 1.0
				}
			})
		2:
			sim_manager.reset_simulation({
				"environment": {
					"temperature_amplitude": 5.0,
					"temperature_frequency": 0.05,
					"pathogen_frequency": 0.1
				}
			})
		3:
			sim_manager.reset_simulation({
				"environment": {
					"temperature_amplitude": 30.0,
					"temperature_frequency": 0.2,
					"pathogen_frequency": 0.5
				}
			})
	
	update_sliders_from_environment()

func update_sliders_from_environment():
	if environment_manager:
		temp_amplitude_slider.value = environment_manager.temperature_amplitude
		temp_frequency_slider.value = environment_manager.temperature_frequency
		pathogen_freq_slider.value = environment_manager.pathogen_frequency
		resource_slider.value = environment_manager.resource_abundance
		update_value_labels()

func update_value_labels():
	temp_amplitude_value.text = "%.1f" % temp_amplitude_slider.value
	temp_frequency_value.text = "%.2f" % temp_frequency_slider.value
	pathogen_freq_value.text = "%.1f" % pathogen_freq_slider.value
	resource_value.text = "%.1f" % resource_slider.value
