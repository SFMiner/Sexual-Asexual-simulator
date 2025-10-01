class_name DebugConsole
extends CanvasLayer

# In-game console for parameter tweaking

@onready var console_text = $Panel/VBox/ConsoleText
@onready var input_field = $Panel/VBox/InputField
@onready var output_label = $Panel/VBox/OutputLabel

var visible_console = false
var command_history: Array[String] = []
var history_index: int = 0

func _ready():
	visible = false

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_QUOTELEFT:  # Tilde key
			toggle_console()

func toggle_console():
	visible_console = not visible_console
	visible = visible_console
	
	if visible_console:
		input_field.grab_focus()

func _on_input_field_text_submitted(text: String):
	if text.is_empty():
		return
	
	command_history.append(text)
	history_index = command_history.size()
	
	execute_command(text)
	input_field.clear()

func execute_command(cmd: String):
	output_label.text = "Command: " + cmd
	
	var parts = cmd.split(" ")
	var command = parts[0]
	
	match command:
		"spawn":
			if parts.size() >= 3:
				var sexual = int(parts[1])
				var asexual = int(parts[2])
				var sim = get_node("/root/SimulationManager")
				sim.population_manager.spawn_initial_population(sexual, asexual)
				output_label.text = "Spawned %d sexual, %d asexual" % [sexual, asexual]
		
		"kill":
			if parts.size() >= 2:
				var count = int(parts[1])
				var sim = get_node("/root/SimulationManager")
				for i in min(count, sim.population_manager.organisms.size()):
					var org = sim.population_manager.organisms[0]
					sim.population_manager.kill_organism(org, 0)
				output_label.text = "Killed %d organisms" % count
		
		"speed":
			if parts.size() >= 2:
				var speed = float(parts[1])
				var sim = get_node("/root/SimulationManager")
				sim.set_speed(speed)
				output_label.text = "Speed set to %.1fx" % speed
		
		"temp":
			if parts.size() >= 2:
				var temp = float(parts[1])
				var sim = get_node("/root/SimulationManager")
				sim.environment_manager.temperature = temp
				output_label.text = "Temperature set to %.1f" % temp
		
		"export":
			var sim = get_node("/root/SimulationManager")
			var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
			var filename = "user://simulation_data_%s.csv" % timestamp
			sim.statistics_collector.export_to_csv(filename)
			output_label.text = "Exported to: " + filename
		
		"help":
			output_label.text = """Available commands:
spawn [sexual] [asexual] - Spawn organisms
kill [count] - Kill organisms
speed [multiplier] - Set simulation speed
temp [value] - Set temperature
export - Export statistics to CSV
help - Show this message"""
		
		_:
			output_label.text = "Unknown command. Type 'help' for commands."
