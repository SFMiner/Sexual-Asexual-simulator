class_name GraphRenderer
extends Control

# Real-time line graph using draw commands

var sexual_data: Array[float] = []
var asexual_data: Array[float] = []
var max_points: int = 200
var max_value: float = 500.0

var sexual_color = Color(0.2, 0.5, 1.0, 0.8)
var asexual_color = Color(1.0, 0.3, 0.3, 0.8)
var grid_color = Color(0.3, 0.3, 0.3, 0.5)

func _ready():
	set_process(false)  # Only redraw when data changes

func add_data_point(sexual: int, asexual: int):
	sexual_data.append(float(sexual))
	asexual_data.append(float(asexual))
	
	if sexual_data.size() > max_points:
		sexual_data.pop_front()
		asexual_data.pop_front()
	
	# Update max value for scaling
	max_value = max(sexual_data.max(), asexual_data.max(), 100.0)
	
	queue_redraw()

func _draw():
	var graph_size = size
	var margin = 20.0
	
	# Draw background
	draw_rect(Rect2(Vector2.ZERO, graph_size), Color(0.1, 0.1, 0.1, 0.9))
	
	# Draw grid
	for i in 5:
		var y = margin + (graph_size.y - 2 * margin) * i / 4
		draw_line(
			Vector2(margin, y),
			Vector2(graph_size.x - margin, y),
			grid_color
		)
	
	# Draw data
	if sexual_data.size() > 1:
		draw_data_line(sexual_data, sexual_color, graph_size, margin)
		draw_data_line(asexual_data, asexual_color, graph_size, margin)
	
	# Draw legend
	draw_legend(graph_size, margin)

func draw_data_line(data: Array[float], color: Color, graph_size: Vector2, margin: float):
	var points = PackedVector2Array()
	var usable_width = graph_size.x - 2 * margin
	var usable_height = graph_size.y - 2 * margin
	
	for i in data.size():
		var x = margin + usable_width * i / max(data.size() - 1, 1)
		var normalized = clamp(data[i] / max_value, 0.0, 1.0)
		var y = graph_size.y - margin - usable_height * normalized
		points.append(Vector2(x, y))
	
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], color, 2.0)

func draw_legend(graph_size: Vector2, margin: float):
	var legend_x = margin + 10
	var legend_y = margin + 10
	
	draw_rect(Rect2(legend_x, legend_y, 15, 15), sexual_color)
	draw_string(ThemeDB.fallback_font, Vector2(legend_x + 20, legend_y + 12), "Sexual", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	
	draw_rect(Rect2(legend_x, legend_y + 20, 15, 15), asexual_color)
	draw_string(ThemeDB.fallback_font, Vector2(legend_x + 20, legend_y + 32), "Asexual", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

func clear():
	sexual_data.clear()
	asexual_data.clear()
	queue_redraw()
