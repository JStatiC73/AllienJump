extends Node

signal unlock_new_skin
var google_payment = null

func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		var google_payment = Engine.get_singleton("GodotGooglePlayBilling")
		MyUtility.add_log_msg("Android IAP support is enabled")
		google_payment.connected.connect(_on_connected)
		google_payment.startConnection()
	else:
		MyUtility.add_log_msg("Android IAP support is not available")

func purchase_skin():
	unlock_new_skin.emit()

func _on_connected():
	MyUtility.add_log_msg("Connected")
