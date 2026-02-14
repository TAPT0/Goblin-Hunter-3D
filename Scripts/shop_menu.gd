extends ColorRect

@onready var player=get_tree().get_first_node_in_group("Player")
# Called when the node enters the scene tree for the first time.
func _ready():
	$BuyHealthButton.pressed.connect(_on_buy_health)
	$BuySpeedButton.pressed.connect(_on_buy_speed)
	$CloseButton.pressed.connect(_on_close)

func _on_buy_health():
	if player.gold>=20:
		if player.hp<player.maxhp:
			player.gold-=20
			player.hp+=20
			if player.hp>player.maxhp:
				player.hp=player.maxhp
			player.update_HUD()
			
func _on_buy_speed():
	if player.gold>=100:
		player.gold-=100
		player.SPEED+=3.0
		player.dash_speed+=10.0
		player.update_HUD()
		
		$BuySpeedButton.disabled=true
		$BuySpeedButton.text="SOLD OUT"
		
func _on_close():
	visible=false
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
