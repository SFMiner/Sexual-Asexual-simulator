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

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not population_manager:
			return
			
		var click_pos = get_local_mouse_position()
		var closest_org = null
		var min_dist_sq = 100.0 # Max click distance (squared)

		for org in population_manager.organisms:
			if not org.is_alive:
				continue

			var dist_sq = org.position.distance_squared_to(click_pos)
			var radius = 3.0 * remap(org.energy, 0, 100, 0.5, 1.5) # Base radius * scale
			
			if dist_sq < radius * radius and dist_sq < min_dist_sq:
				closest_org = org
				min_dist_sq = dist_sq
		
		if closest_org:
			organism_clicked.emit(closest_org)


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
	
	# In visual_manager.gd, in update_visuals(), replace the entire organism loop:

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



func update_multimesh(multimesh_instance: MultiMeshInstance2D, transforms: Array[Transform2D], count: int):
	# Expand if needed
	if count > multimesh_instance.multimesh.instance_count:
		multimesh_instance.multimesh.instance_count = count + 500
	
	multimesh_instance.multimesh.visible_instance_count = count
	
	for i in count:
		multimesh_instance.multimesh.set_instance_transform_2d(i, transforms[i])
