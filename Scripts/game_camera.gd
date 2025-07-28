extends Camera2D

@onready var destroyer = $Destroyer 
@onready var destroyer_shape = $Destroyer/CollisionShape2D

var player: Player = null
var viewPortSize

func _ready():	
	if player:
		global_position.y = player.global_position.y
		
	viewPortSize = get_viewport_rect().size
	global_position.x =  viewPortSize.x / 2
	
	limit_bottom = viewPortSize.y
	limit_left = 0
	limit_right = viewPortSize.x
	
	destroyer.position.y = viewPortSize.y
	var rect_shape = RectangleShape2D.new()
	var rect_shape_size = Vector2(viewPortSize.x, 200)
	rect_shape.set_size(rect_shape_size)
	destroyer_shape.shape = rect_shape
	
func _process(_delta):
	if player:
		var limit_distance = 420
		if limit_bottom > player.global_position.y + limit_distance:
			limit_bottom =  int(player.global_position.y + limit_distance)
			
	var overlapping_areas = destroyer.get_overlapping_areas()
	if (overlapping_areas.size() > 0):
		for area in overlapping_areas:
			if(area is Platform):
				area.queue_free()
				print("Deleting" + area.name)
	
func _physics_process(_delta):
	if player:
		global_position.y = player.global_position.y
	
func setup_camera(_player: Player):
	if _player:
		player = _player
