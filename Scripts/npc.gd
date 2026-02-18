extends CharacterBody3D

var player_in_range = false
var dialogue_box_node = null
var text_label_node = null

func _ready():
	# Make sure the TalkZone exists
	if has_node("TalkZone"):
		$TalkZone.body_entered.connect(_on_body_entered)
		$TalkZone.body_exited.connect(_on_body_exited)

	$Label3D.visible = false

func _on_body_entered(body):
	
	if body.is_in_group("Player"):
		player_in_range = true
		$Label3D.visible=true
		
		# Try to find the box
		if body.has_node("HUD/DialogueBox"):
			dialogue_box_node = body.get_node("HUD/DialogueBox")
			text_label_node = dialogue_box_node.get_node("TextLabel")

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false

		$Label3D.visible = false
		if dialogue_box_node:
			dialogue_box_node.visible = false
		Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

@warning_ignore("unused_parameter")
func _input(event):
	if Input.is_action_just_pressed("interact")and$Label3D.visible:
		handle_interaction()

func handle_interaction():
	var player=get_tree().get_first_node_in_group("Player")
	if dialogue_box_node.visible and player.quest_status=="completed":
		open_shop()
		return
	
	dialogue_box_node=player.get_node("HUD/DialogueBox")
	text_label_node=dialogue_box_node.get_node("TextLabel")
	
	dialogue_box_node.visible=true
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	
	if player.quest_status=="none":
		text_label_node.text="The Goblins are attacking! Kill 5 of them and I will pay you 500 Gold."
		start_quest(player)
	elif player.quest_status=="started":
		if player.goblins_killed>=player.quest_goal:
			text_label_node.text="You did it! Here is your 500 Gold."
			finish_quest(player)
		else:
			var left=player.quest_goal-player.goblins_killed
			text_label_node.text="Hurrry! There are still"+str(left)+"goblins left."
	elif player.quest_status =="completed":
		text_label_node.text="Thank you for saving us.Would you like to buy potions?"

func start_quest(player):
	player.quest_status="started"
	player.quest_active=true
	player.goblins_killed=0
	player.get_node("HUD/QuestLabel").visible=true
	player.get_node("HUD/QuestLabel").text="Mission: Kill Goblins(0/5)"
	
func finish_quest(player):
	player.quest_status = "completed"
	player.quest_active = false
	
	if "gold" in player:
		player.gold += 500
		if player.has_method("update_HUD"):
			player.update_HUD()
	
	if player.has_node("HUD/QuestLabel"):
		player.get_node("HUD/QuestLabel").visible = false

func open_shop():
	dialogue_box_node.visible=false
	var shop=dialogue_box_node.get_parent().get_node("ShopMenu")
	shop.visible=true
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
