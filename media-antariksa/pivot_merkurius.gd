extends Node3D

# Kamu bisa mengubah kecepatan ini langsung dari panel Inspector nanti
@export var kecepatan_putar: float = 0.16

func _process(delta):
	# Memutar node pada sumbu Y (atas) setiap frame
	rotate_y(kecepatan_putar * delta)
