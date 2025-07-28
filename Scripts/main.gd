extends Node

@onready var game = $Game
@onready var screens = $Screens
@onready var iap_manager = $IAPManager

var game_in_progress = false

func _ready():
	DisplayServer.window_set_window_event_callback(_on_window_event)
	screens.start_game.connect(_on_screens_start_game)
	game.player_died.connect(_on_player_died)
	screens.delete_level.connect(_on_screens_delete_level)
	game.hud.game_paused.connect(_on_game_paused)
	
	#region	IAP signal
	iap_manager.unlock_new_skin.connect(_iap_manager_unlock_new_skin)
	screens.purchase_skin.connect(_on_screens_purchase_skin)
	#endregion
	
func _on_screens_start_game():
	game_in_progress = true
	game.new_game()
	
func _on_player_died(score, highScore):
	game_in_progress = false
	await(get_tree().create_timer(0.75).timeout)
	screens.game_over(score, highScore)

func _on_screens_delete_level():
	game_in_progress = false
	game.reset_game	()
	
	
func _on_game_paused():
	get_tree().paused = true
	screens.pause_game()

func _on_window_event(event):
	match event:
		DisplayServer.WINDOW_EVENT_FOCUS_IN:
			print("focus in")
		DisplayServer.WINDOW_EVENT_FOCUS_OUT:
			if(game_in_progress && !get_tree().paused):
				_on_game_paused()
				print("focus out")
				MyUtility.add_log_msg("Focus out")
		DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
			get_tree().quit()


#region IAP Signal 
func _iap_manager_unlock_new_skin():
	if game.new_skin == false :
		game.new_skin = true
		print("Unlocking the new skin...")
		
func _on_screens_purchase_skin():
	iap_manager.purchase_skin()
#endregion
