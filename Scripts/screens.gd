extends CanvasLayer

signal start_game
signal delete_level
signal purchase_skin
signal reset_purchases
signal entry_player_name

@onready var console = $Debug/ConsoleLog
@onready var titleScreen = $TitleScreen
@onready var pauseScreen = $PauseScreen
@onready var pauseTitleLabel = $PauseScreen/PauseBox/TitleLabel
@onready var gameOverScreen = $GameOverScreen
@onready var shopScreen = $ShopScreen
@onready var entryNameScreen = $EntryHighScoreName
@onready var entryNameScreenLineEdit = $EntryHighScoreName/TextureRect/LineEdit
@onready var game_over_score_label = $GameOverScreen/Box/ScoreLabel
@onready var game_over_highScore_label = $GameOverScreen/Box/HighScoreLabel

var current_screen = null
var scores = []
var score: int = 0

func _ready():
	console.visible = false

	register_buttons()
	change_screen(titleScreen)

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("buttons")
	if (buttons.size() > 0):
		for button in buttons:
			if button is ScreenButton:
				button.clicked.connect(_on_button_pressed)

func _on_button_pressed(button):
	match button.name:
		"TitlePlay":
			change_screen(null)
			await(get_tree().create_timer(0.50).timeout)
			start_game.emit()

		"TitleShop":
			change_screen(shopScreen)

		"PauseClose":
			change_screen(null)
			await(get_tree().create_timer(0.75).timeout)
			get_tree().paused = false

		"PauseRetry":
			change_screen(null)
			await(get_tree().create_timer(0.50).timeout)
			get_tree().paused = false
			start_game.emit()

		"PauseBack":
			change_screen(titleScreen)
			await(get_tree().create_timer(0.50).timeout)
			get_tree().paused = false
			delete_level.emit()

		"GameOverRetry":
			change_screen(null)
			await(get_tree().create_timer(0.50).timeout)
			start_game.emit()

		"GameOverBack":
			delete_level.emit()
			change_screen(titleScreen)

		"ShopBack":
			change_screen(titleScreen)

		"ShopPurchaseSkin":
			purchase_skin.emit()

		"ShopResetPurchases":
			reset_purchases.emit()

		"SavePlayerName":
			change_screen(null)
			save_player_name()

func _process(_delta):
	pass


func _on_toggle_console_pressed():
	console.visible = !console.visible

func change_screen(new_screen):
	if current_screen != null:
		var disappear_tween = current_screen.disappear()
		await(disappear_tween.finished)
		current_screen.visible = false
	current_screen = new_screen

	if(current_screen != null):
		var appear_tween = current_screen.appear()
		await(appear_tween.finished)
		get_tree().call_group("buttons", "set_disabled", false)

func game_over(_score, _scores):
	var scoreList = ""
	var scoreCounter = 1
	game_over_score_label.text = "Score: " + str(_score)
	for storeScore in _scores:
		scoreList += str(scoreCounter) + ". " + storeScore.name + ": " + str(storeScore.score) + "\n"
		scoreCounter += 1

	game_over_highScore_label.text = scoreList
	change_screen(gameOverScreen)

func request_player_name(_score, _scoreList):
	score = _score
	scores = _scoreList
	change_screen(entryNameScreen)

func save_player_name():
	var player_name = entryNameScreenLineEdit.text
	entry_player_name.emit(player_name, score)
	entryNameScreenLineEdit.text = ""

func pause_game():
	#pauseTitleLabel.text = tr("pause")
	change_screen(pauseScreen)
