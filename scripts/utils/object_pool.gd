class_name ObjectPool
extends RefCounted

# Generic object pooling system

var pool: Array = []
var object_type: Variant
var pool_size: int

func _init(type: Variant, initial_size: int = 100):
	object_type = type
	pool_size = initial_size

func get_object():
	if pool.is_empty():
		# Pool exhausted, create new (or return null to enforce limit)
		return object_type.new()
	return pool.pop_back()

func return_object(obj):
	if pool.size() < pool_size:
		pool.append(obj)
