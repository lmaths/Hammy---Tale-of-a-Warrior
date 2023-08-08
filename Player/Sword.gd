extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func cause_damage():
	$AudioStreamPlayer2D.play()
	var overlapping_objects = self.get_overlapping_bodies()
	for area in overlapping_objects:
		for child in area.get_children():
			if child is Damageable:
				child.hit(50)
		print(area.name)
