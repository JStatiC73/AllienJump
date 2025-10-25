extends Node

signal unlock_new_skin
var billing_client
var new_skin_sku = "new_player_skin"
var new_skin_token = ""

func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		MyUtility.add_log_msg("Android IAP support is enabled")
		BillingClient.connected.connect(_on_connected) # No params
		BillingClient.disconnected.connect(_on_disconnected) # No params
		BillingClient.connect_error.connect(_on_connect_error) # response_code: int, debug_message: String
		
		BillingClient.query_product_details_response.connect(_on_product_details_query_completed)
		#BillingClient.query_purchases_response.connect(_on_query_purchases_response) # response: Dictionary
		BillingClient.on_purchase_updated.connect(_on_purchase_updated)
		BillingClient.acknowledge_purchase_response.connect(_on_acknowledge_purchase_response) # response: Dictionary
		BillingClient.consume_purchase_response.connect(_on_consume_purchase_response) # response: Dictionary
		
		BillingClient.start_connection()
		
	else:
		MyUtility.add_log_msg("Android IAP support is not available")

#region Purchase methods
func purchase_skin():
	if(BillingClient):
		var result = BillingClient.purchase(new_skin_sku)
		MyUtility.add_log_msg("Purchase attempted, response " + str(result.response_code))
		if result.response_code == BillingClient.BillingResponseCode.OK:
			MyUtility.add_log_msg("Billing flow launch success")
		else:
			MyUtility.add_log_msg("Billing flow launch failed")
			MyUtility.add_log_msg("response_code: " + str(result.response_code) +
			 "debug_message: " + str(result.debug_message))
			
func reset_purchases():
	if (BillingClient):
		if !new_skin_token.is_empty():
			BillingClient.consume_purchase(new_skin_token)
			
func _on_purchase_updated(result: Dictionary):
	MyUtility.add_log_msg(str(result))
	if result.response_code == BillingClient.BillingResponseCode.OK:
		MyUtility.add_log_msg("Purchase update received")
		for purchase in result.result_array:
			_process_purchase(purchase)
	else:
		MyUtility.add_log_msg("Purchase update error")
		MyUtility.add_log_msg("response_code: " + str(result.response_code) + 
		"debug_message: " + str(result.debug_message))
		
func _process_purchase(purchase):
	if new_skin_sku in purchase.product_ids:
		# Add code to store payment so we can reconcile the purchase token
		# in the completion callback against the original purchase
		new_skin_token = purchase.purchase_token
		BillingClient.acknowledge_purchase(purchase.purchase_token)

func _on_acknowledge_purchase_response(result: Dictionary):
	if result.response_code == BillingClient.BillingResponseCode.OK:
		MyUtility.add_log_msg("Purchase acknowledged successfully")
		
		if !new_skin_token.is_empty():
			if new_skin_token == result.token:
				unlock_new_skin.emit()
	else:
		MyUtility.add_log_msg("Acknowledge purchase failed")
		MyUtility.add_log_msg("response_code: " + str(result.response_code) +
		 "debug_message: " + str(result.debug_message) + "purchase_token: " + str(result.token))
		
func _on_consume_purchase_response(result: Dictionary):
	if result.response_code == BillingClient.BillingResponseCode.OK:
		MyUtility.add_log_msg("Consume purchase success")
	else:
		MyUtility.add_log_msg("Consume purchase failed")
		MyUtility.add_log_msg("response_code: " + str(result.response_code) + 
		"debug_message: " + str(result.debug_message) + "purchase_token: " + str(result.token))

func _on_query_purchases_response(result: Dictionary):
	if result.response_code == BillingClient.BillingResponseCode.OK:
		MyUtility.add_log_msg("Query purchases was sucessful")
		
		var purchases = result.result_array
		var purchase = purchases[0]
		var purchase_sku = purchase["product_ids"][0]
		if new_skin_sku == purchase_sku:
			new_skin_token = purchase.purchase_token
			if(!purchase.is_acknowledged):
				BillingClient.acknowledge_purchase(purchase.purchase_token)
			else:
				unlock_new_skin.emit()
				MyUtility.add_log_msg("Unlocking new skin because it was purchased previously")
#endregion

#region connection methods
func _on_connected():
	MyUtility.add_log_msg("Connected")
	
	BillingClient.query_product_details([new_skin_sku], BillingClient.ProductType.INAPP) #subs

func _on_connect_error(response_id, debug_msg):
	MyUtility.add_log_msg("Connect error, response id:" + str(response_id) + "debug msg: " + debug_msg)

func _on_disconnected():
	MyUtility.add_log_msg("Disconnected")
#endregion

#region products info
func _on_product_details_query_completed(query_result: Dictionary):
	MyUtility.add_log_msg("Sku details query completed")
	if query_result.response_code == BillingClient.BillingResponseCode.OK:
		MyUtility.add_log_msg("Product details query success")
		for available_product in query_result.result_array:
			MyUtility.add_log_msg("sku: " + str(available_product))
			
		BillingClient.query_purchases(BillingClient.ProductType.INAPP)
	else:
		MyUtility.add_log_msg("Product details query failed")
		MyUtility.add_log_msg("response_code:" + str(query_result.response_code) + 
		"debug_message: " + str(query_result.debug_message))
#endregion
	
#func _on_sku_details_query_error(response_id, error_message, skus):
#	MyUtility.add_log_msg("Sku query error, response id: " + str(response_id) + 
#	", message: " + str(error_message) + ", skus: " + str(skus))
