class_name StatisticsCollector
extends Node

# Efficient sampling and data aggregation

var population_history: RingBuffer  # Custom circular buffer
var sample_interval: float = 0.5  # Sample twice per second
var last_sample_time: float = 0.0

var current_stats: Dictionary = {}

func _ready():
	population_history = RingBuffer.new(1000)  # Keep last 1000 samples

func collect_sample(population_stats: Dictionary, environment: Dictionary):
	var time = Time.get_ticks_msec() / 1000.0
	
	if time - last_sample_time < sample_interval:
		return
	
	last_sample_time = time
	
	var sample = {
		"time": time,
		"sexual_count": population_stats.sexual_count,
		"asexual_count": population_stats.asexual_count,
		"total_count": population_stats.sexual_count + population_stats.asexual_count,
		"avg_generation": population_stats.avg_generation,
		"avg_traits": population_stats.avg_traits.duplicate(),
		"environment": environment.duplicate()
	}
	
	population_history.push(sample)
	current_stats = sample

func get_history(count: int = 100) -> Array:
	return population_history.get_last_n(count)

func export_to_csv(filepath: String):
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if not file:
		push_error("Could not open file for export: " + filepath)
		return
	
	# Header
	file.store_line("time,sexual_count,asexual_count,total_count,avg_generation,temperature,pathogens,resources")
	
	# Data
	for sample in population_history.get_all():
		var line = "%f,%d,%d,%d,%f,%f,%f,%f" % [
			sample.time,
			sample.sexual_count,
			sample.asexual_count,
			sample.total_count,
			sample.avg_generation,
			sample.environment.temperature,
			sample.environment.pathogen_intensity,
			sample.environment.resource_abundance
		]
		file.store_line(line)
	
	file.close()
	print("Exported statistics to: " + filepath)

func reset():
	population_history.clear()
	current_stats.clear()
	last_sample_time = 0.0
