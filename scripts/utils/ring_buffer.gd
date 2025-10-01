class_name RingBuffer
extends RefCounted

# Efficient circular buffer for time-series data

var buffer: Array
var max_size: int
var head: int = 0
var size: int = 0

func _init(capacity: int):
	max_size = capacity
	buffer.resize(capacity)

func push(item):
	buffer[head] = item
	head = (head + 1) % max_size
	size = min(size + 1, max_size)

func get_last_n(n: int) -> Array:
	var result = []
	var count = min(n, size)
	
	for i in range(count):
		var idx = (head - 1 - i + max_size) % max_size
		result.append(buffer[idx])
	
	return result

func get_all() -> Array:
	return get_last_n(size)

func clear():
	size = 0
	head = 0
