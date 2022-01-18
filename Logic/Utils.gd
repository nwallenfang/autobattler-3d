extends Node

# mainly for duplicating resources
# see https://github.com/godotengine/godot/issues/37222
func deep_clone(source: Object):
	var clone = source.duplicate()
	# copy all property values
	for property in source.get_property_list():
		var property_name = property["name"]
		clone.set(property_name, source.get(property_name))
	
	if source is Node:
		# remove incomplete duplicated childs
		for child in clone.get_children():
			clone.remove_child(child)
			child.free()
		assert(clone.get_child_count() == 0)
		# clone childs
		for child in source.get_children():
			clone.add_child(deep_clone(child))
			
	return clone
