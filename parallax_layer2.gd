extends ParallaxLayer
@export var CLOUD_SPEED: float = -30.0
func _process(delta) -> void:
	self.motion_offset.x += CLOUD_SPEED * delta
