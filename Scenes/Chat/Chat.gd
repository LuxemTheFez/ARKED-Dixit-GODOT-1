extends Control

onready var MessageBox = $Chat/Layout
onready var message1=$Chat/Layout/Message1
onready var message2=$Chat/Layout/Message2
onready var message3=$Chat/Layout/Message3
onready var message4=$Chat/Layout/Message4
onready var ChatDisplay = $ChatDisplay

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Network.connect("updateChat", self, "afficheUpdateChat") # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Chat_pressed():
	MessageBox.visible = !MessageBox.visible # Replace with function body.


func _on_Message1_pressed():
	Network.envoieMessage(message1.get_text())


func _on_Message2_pressed():
	Network.envoieMessage(message2.get_text())


func _on_Message3_pressed():
	Network.envoieMessage(message3.get_text())


func _on_Message4_pressed():
	Network.envoieMessage(message4.get_text())
	
func afficheUpdateChat(id, msg):
	ChatDisplay.text += "msg de %s : %s \n" % [id,msg]
