class_name VisualManager
extends Node2D

# Handles all organism rendering using MultiMeshInstance2D

signal organism_clicked(organism: OrganismData)

var sexual_multimesh: MultiMeshInstance2D
var asexual_multimesh: MultiMeshInstance2D

var sexual_color = Color(0.2, 0.5, 1.0)  # Blue
var asexual_color = Color(1.0, 0.3, 0.3)  # Red

var current_population_manager: PopulationManager  # Store reference for click detection
var population_manager: PopulationManager
var selected_organism: OrganismData = null  # Track selected organism for highlighting

# Zoom and pan properties
var zoom_level: float = 1.0
var min_zoom: float = 0.5
var max_zoom: float = 10.0
var zoom_speed: float = 0.1

# Panning
var is_panning: bool = false
var pan_start_pos: Vector2 = Vector2.ZERO
var pan_start_offset: Vector2 = Vector2.ZERO

func _input(event):
	# Handle mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_at_mouse(event.position, 1.0 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_at_mouse(event.position, 1.0 - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				# Start panning
				is_panning = true
				pan_start_pos = event.position
				pan_start_offset = position
			else:
				# Stop panning
				is_panning = false
		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not is_panning:
			# Handle organism click
			if not population_manager:
				return
				
			var click_pos = get_local_mouse_position()
			print("Visual Manager: Click at ", click_pos)
			
			var closest_org = null
			var min_dist = 15.0 / zoom_level  # Adjust click radius based on zoom

			for org in population_manager.organisms:
				if not org.is_alive:
					continue

				var dist = org.position.distance_to(click_pos)
				
				if dist < min_dist:
					closest_org = org
					min_dist = dist
			
			if closest_org:
				print("Visual Manager: Found organism #", closest_org.id)
				selected_organism = closest_org
				organism_clicked.emit(closest_org)
				queue_redraw()
			else:
				print("Visual Manager: No organism found near click")
	
	# Handle panning
	if event is InputEventMouseMotion and is_panning:
		var delta = event.position - pan_start_pos
		position = pan_start_offset + delta
		queue_redraw()

func zoom_at_mouse(mouse_pos: Vector2, zoom_factor: float):
	var old_zoom = zoom_level
	var new_zoom = clamp(zoom_level * zoom_factor, min_zoom, max_zoom)
	
	if old_zoom == new_zoom:
		return
	
	# Convert mouse position to world coordinates before zoom
	var world_pos_before = (mouse_pos - position) / old_zoom
	
	# Apply new zoom
	zoom_level = new_zoom
	scale = Vector2(zoom_level, zoom_level)
	
	# Convert the same world position to screen coordinates after zoom
	var world_pos_after = world_pos_before * new_zoom
	
	# Adjust position so the world point stays under the mouse
	position = mouse_pos - world_pos_after
	
	queue_redraw()
	print("Zoom level: %.2fx" % zoom_level)

func _ready():
	setup_multimeshes()

func setup_multimeshes():
	# Sexual organisms
	sexual_multimesh = MultiMeshInstance2D.new()
	sexual_multimesh.multimesh = MultiMesh.new()
	sexual_multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_2D
	sexual_multimesh.multimesh.instance_count = 1000
	sexual_multimesh.multimesh.visible_instance_count = 0
	add_child(sexual_multimesh)
	
	# Create simple circle mesh
	var sexual_mesh = create_circle_mesh(3.0, sexual_color)
	sexual_multimesh.multimesh.mesh = sexual_mesh
	
	# Asexual organisms
	asexual_multimesh = MultiMeshInstance2D.new()
	asexual_multimesh.multimesh = MultiMesh.new()
	asexual_multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_2D
	asexual_multimesh.multimesh.instance_count = 1000
	asexual_multimesh.multimesh.visible_instance_count = 0
	add_child(asexual_multimesh)
	
	var asexual_mesh = create_circle_mesh(3.0, asexual_color)
	asexual_multimesh.multimesh.mesh = asexual_mesh

func create_circle_mesh(radius: float, color: Color) -> ArrayMesh:
	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertices = PackedVector2Array()
	var colors = PackedColorArray()
	
	# Create circle vertices
	var segments = 12
	for i in segments:
		var angle = (i / float(segments)) * TAU
		vertices.append(Vector2(cos(angle), sin(angle)) * radius)
		colors.append(color)
	
	# Center vertex
	vertices.append(Vector2.ZERO)
	colors.append(color)
	
	# Create indices for triangle fan
	var indices = PackedInt32Array()
	for i in segments:
		indices.append(segments)  # Center
		indices.append(i)
		indices.append((i + 1) % segments)
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func update_visuals(p_manager: PopulationManager):
	self.population_manager = p_manager
	var sexual_count = 0
	var asexual_count = 0
	
	# Count and prepare transforms
	var sexual_transforms: Array[Transform2D] = []
	var asexual_transforms: Array[Transform2D] = []

	for org in population_manager.organisms:
		if not org.is_alive:
			continue
		
		# Create fresh transform for each organism
		var scale_factor = remap(org.energy, 0, 100, 0.5, 1.5)
		var transform = Transform2D(
			Vector2(scale_factor, 0),      # X basis vector (scaled)
			Vector2(0, scale_factor),      # Y basis vector (scaled)
			org.position                    # Origin (stays at organism position)
		)		
		
		if org.is_sexual:
			sexual_transforms.append(transform)
			sexual_count += 1
		else:
			asexual_transforms.append(transform)
			asexual_count += 1
	
	# Update multimeshes
	update_multimesh(sexual_multimesh, sexual_transforms, sexual_count)
	update_multimesh(asexual_multimesh, asexual_transforms, asexual_count)
	
	# Redraw to update selection highlight if needed
	if selected_organism and not selected_organism.is_alive:
		selected_organism = null
	queue_redraw()

func _draw():
	# Draw selection highlight
	if selected_organism and selected_organism.is_alive:
		var highlight_color = Color(1.0, 1.0, 0.0, 0.3)  # Yellow with transparency
		draw_circle(selected_organism.position, 12.0, highlight_color)
		draw_arc(selected_organism.position, 15.0, 0, TAU, 32, Color(1.0, 1.0, 0.0, 1.0), 2.0)

func update_multimesh(multimesh_instance: MultiMeshInstance2D, transforms: Array[Transform2D], count: int):
	# Expand if needed
	if count > multimesh_instance.multimesh.instance_count:
		multimesh_instance.multimesh.instance_count = count + 500
	
	multimesh_instance.multimesh.visible_instance_count = count
	
	for i in count:
		multimesh_instance.multimesh.set_instance_transform_2d(i, transforms[i])

func reset_zoom():
	zoom_level = 1.0
	scale = Vector2.ONE
	position = Vector2.ZERO
	is_panning = false
	queue_redraw()
