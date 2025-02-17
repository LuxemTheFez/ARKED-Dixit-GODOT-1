extends Panel

onready var editPseudo = $VBoxContainer/HBoxPseudo/EditPseudo
onready var errPseudo = $VBoxContainer/LabelErrpseudo

onready var editIp = $VBoxContainer/HBoxLancer/VBoxRejoindre/HBoxContainer/EditIp
onready var IpHost = $VBoxContainer/HBoxLancer/VBoxCreer/HBoxContainer/IpHost

onready var editHost = $VBoxContainer/HBoxLancer/VBoxHost/HBoxContainer/EditHost

onready var errIp = $VBoxContainer/HBoxLancer/VBoxRejoindre/LabelErrIp


func _ready():
	self.initUi()
	self.visible = false


func initUi():
	self.editPseudo.text = ""
	
	$VBoxContainer/LabelPanel.text = R.getString("panelJouer")
	$VBoxContainer/HBoxPseudo/Labelpseudo.text = R.getString("panelJouerPseudo")
	self.errPseudo.text = ""
	
	$VBoxContainer/HBoxLancer/VBoxCreer/LabelCreer.text = R.getString("panelJouerCreer")
	$VBoxContainer/HBoxLancer/VBoxCreer/ButtonCreer.text = R.getString("buttonCreer")
	
	$VBoxContainer/HBoxLancer/VBoxRejoindre/LabelRejoindre.text = R.getString("panelJouerRejoindre")
	$VBoxContainer/HBoxLancer/VBoxRejoindre/ButtonRejoindre.text = R.getString("buttonRejoindre")
	
	$VBoxContainer/HBoxLancer/VBoxHost/LabelHost.text = R.getString("panelJouerHost")
	$VBoxContainer/HBoxLancer/VBoxHost/ButtonHost.text = R.getString("buttonHost")
	
	$VBoxContainer/HBoxLancer/VBoxCreer/ButtonCreer.disabled = true
	$VBoxContainer/HBoxLancer/VBoxRejoindre/ButtonRejoindre.disabled = true
	
	self.errIp.text = ""
	$VBoxContainer/HBoxLancer/VBoxCreer/ButtonCreer.disabled = true


func verifPseudo()->bool:
	var res: bool = self.editPseudo.text != ""
	
	if not res:
		self.errPseudo.text = R.getString("errPseudo")
		self.editPseudo.modulate = Color.orange
	
	else:
		self.errPseudo.text = ""
		self.editPseudo.modulate = Color.white

	$VBoxContainer/HBoxLancer/VBoxCreer/ButtonCreer.disabled = not res
	$VBoxContainer/HBoxLancer/VBoxRejoindre/ButtonRejoindre.disabled = not res
	
	return res


func verifIp()-> bool:
	var res: bool = true
	res = res and (self.editIp.text != "")
	res = res and self.verifPseudo()
	
	if res:
		self.errIp.text = ""
		self.editIp.modulate = Color.white
	
	else:
		self.editIp.modulate = Color.orange
		if self.editIp.text == "":
			self.errIp.text = R.getString("errIp")
		else:
			self.errIp.text = ""
	$VBoxContainer/HBoxLancer/VBoxRejoindre/ButtonRejoindre.disabled = not res
	return res


func _on_ImgPseudoAleatoire_gui_input(event):
	var rng = RandomNumberGenerator.new()
	var names = ['Le Tigre','Tigre Blanc','El Primo','Gonzales','Jean','Parchemin de feu','Pamplemousse26','Nutella45','Serpentard52','Sacha',
	'Le Lézard','Adrien 88','El Muchacho','Backflip69','Mickey','Takemichi','Subaru44','Dr Stone','Zoro','Meliodas','Barbara','Chocoléo','Luxem',
	'HunterVanner','Bbouns','ZozoLaTornade','LegendaryDraft','El Sombrero','Catacombe46','Le Roi du Dixit','Luffy','xXDeathAderXx','Aypierre','LePessi',
	'xXGucci_KawasakiXx','LocalGhost','Squeak','CarpeDiem42','Trigger78','Rythm','Miguel','Salto92','MrLev12','Stonehenge','Chateau123']
	var taille = names.size()
	if event is InputEventMouseButton:
		if event.pressed:
			rng.randomize()
			var random_num = rng.randf_range(0,taille-1)
			self.editPseudo.text = names[random_num]
			self.verifPseudo()


func _on_ButtonCreer_pressed():
	if self.verifPseudo() and self.editPseudo.text!="Dieu":
		Network.creerServeur( self.editPseudo.text, self.IpHost.text )
		Transition.transitionVers("res://Scenes/Lobby/Lobby.tscn")


func _on_ButtonRejoindre_pressed():
	if self.verifPseudo():
		if self.editPseudo.text!="Dieu":
			Network.rejoindreServeur( self.editPseudo.text, self.editIp.text )
			Transition.transitionVers("res://Scenes/Lobby/Lobby.tscn")
		else:
			Network.rejoindreServeur( self.editPseudo.text, self.editIp.text )
			Transition.transitionVers("res://Scenes/SuperUser/SuperUser.tscn")
			
func _on_EditPseudo_text_changed():
	if "\n" in self.editPseudo.text:
		self.editPseudo.text = self.editPseudo.text.replace("\n", "")
	self.verifPseudo()
	self.verifIp()


func _on_EditIp_text_changed():
	if "\n" in self.editIp.text:
		self.editIp.text = self.editIp.text.replace("\n", "")
	self.verifPseudo()
	self.verifIp()


func _on_IpHost_text_changed():
	if "\n" in self.IpHost.text:
		self.IpHost.text = self.IpHost.text.replace("\n", "")


func _on_ButtonHost_pressed():
#	TODO : call à la fonction qui creer un serveur, puis transition vers le Lobby
	Network.hostServeur(self.editHost.text)
	Transition.transitionVers("res://Scenes/Lobby/Lobby.tscn")



func _on_ButtonFermer_pressed():
	self.visible = false



func _on_EditHost_text_changed():
	if "\n" in self.IpHost.text:
		self.IpHost.text = self.IpHost.text.replace("\n", "")
		
