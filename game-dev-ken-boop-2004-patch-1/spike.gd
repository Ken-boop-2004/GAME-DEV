extends Area2D
## Spike trap - kills player on contact

func _ready():
	body_entered.connect(_on_body_entered)
	# Put in "traps" group for easy identification
	add_to_group("traps")


func _on_body_entered(body):
	if body.has_method("die"):
		body.die()
