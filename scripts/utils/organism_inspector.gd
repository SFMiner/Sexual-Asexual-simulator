class_name OrganismInspector
extends VBoxContainer

# Displays detailed information about a selected organism

var selected_organism: OrganismData = null

@onready var title_label = $TitleLabel
@onready var type_label = $TypeLabel
@onready var stats_container = $StatsContainer
@onready var traits_container = $TraitsContainer
@onready var close_button = $CloseButton

func _ready():
	close_button.pressed.connect(_on_close_pressed)
	hide()

func show_organism(organism: OrganismData):
	if not organism or not organism.is_alive:
		hide()
		return

	selected_organism = organism

	# Title
	title_label.text = "Organism #%d" % organism.id

	# Type and basic stats
	var type_text = "Sexual" if organism.is_sexual else "Asexual"
	var type_color = Color(0.2, 0.5, 1.0) if organism.is_sexual else Color(1.0, 0.3, 0.3)
	type_label.text = type_text
	type_label.add_theme_color_override("font_color", type_color)

	# Clear previous stats
	for child in stats_container.get_children():
		child.queue_free()

	# Basic stats
	add_stat_label(stats_container, "Generation", str(organism.generation))
	add_stat_label(stats_container, "Age", "%.1fs" % organism.age)
	add_stat_label(stats_container, "Energy", "%.1f" % organism.energy)
	add_stat_label(stats_container, "Position", "%.0f, %.0f" % [organism.position.x, organism.position.y])

	# Add separator
	var separator = HSeparator.new()
	stats_container.add_child(separator)

	# Clear previous traits
	for child in traits_container.get_children():
		child.queue_free()

	# Traits with bars
	add_trait_bar(traits_container, "Temperature Tolerance", organism.temperature_tolerance)
	add_trait_bar(traits_container, "Pathogen Resistance", organism.pathogen_resistance)
	add_trait_bar(traits_container, "Resource Efficiency", organism.resource_efficiency)
	add_trait_bar(traits_container, "Mobility", organism.mobility)
	add_trait_bar(traits_container, "Reproduction Speed", organism.reproduction_speed)
	if not organism.is_sexual:
		add_trait_bar(traits_container, "Mutation Rate", organism.mutation_rate)

	show()

func add_stat_label(container: Container, label: String, value: String):
	var hbox = HBoxContainer.new()

	var label_node = Label.new()
	label_node.text = label + ":"
	label_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(label_node)

	var value_node = Label.new()
	value_node.text = value
	value_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(value_node)

	container.add_child(hbox)

func add_trait_bar(container: Container, trait_name: String, value: float):
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)

	# Label with value
	var hbox = HBoxContainer.new()
	var label = Label.new()
	label.text = trait_name
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(label)

	var value_label = Label.new()
	value_label.text = "%.1f" % value
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(value_label)

	vbox.add_child(hbox)

	# Progress bar
	var progress = ProgressBar.new()
	progress.min_value = 0
	progress.max_value = 100
	progress.value = value
	progress.show_percentage = false
	progress.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(progress)

	container.add_child(vbox)

func _on_close_pressed():
	hide()
	selected_organism = null

func _process(_delta):
	# Update stats in real-time if organism is selected
	if selected_organism and is_visible() and selected_organism.is_alive:
		show_organism(selected_organism)
	elif selected_organism and not selected_organism.is_alive:
		hide()
