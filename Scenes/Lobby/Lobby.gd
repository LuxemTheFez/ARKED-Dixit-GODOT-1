extends Node

const NODE_INFOJOUEUR = preload("res://Scenes/Lobby/InfoJoueur.tscn")
const NODE_OPTIONS = preload("res://Scenes/Options/Options.tscn")
const NODE_REGLES = preload("res://Scenes/Regles/Regles.tscn")

onready var layoutJoueur = $Control/LayoutListe/VBoxContainer/LayoutJoueurs

onready var buttonPret = $Control/MainLayout/VBoxContainer/ButtonPret
onready var buttonLancer = $Control/MainLayout/VBoxContainer/ButtonLancer
onready var labelCouleur = $Control/MainLayout/VBoxContainer/VBoxContainer/LabelCouleur
onready var buttonGaucheCoul = $Control/MainLayout/VBoxContainer/VBoxContainer/LayoutCouleur/ButtonCouleurPrec
onready var buttonDroitCoul = $Control/MainLayout/VBoxContainer/VBoxContainer/LayoutCouleur/ButtonCouleurSuiv

onready var selectionCouleur = $Control/MainLayout/VBoxContainer/VBoxContainer/LayoutCouleur/CouleurSelection
onready var NbPoint = $Control/MainLayout/VBoxContainer/VBoxContainer/changePoint/LayoutPoint/NbPoint
onready var changePoint = $Control/MainLayout/VBoxContainer/VBoxContainer/changePoint
var peutLancer: bool = false

var uiOptions
var uiRegles

var joueurs: Dictionary = {}

func _ready():
	Network.connect("partieLancee", self, "_versPartie")
	Network.connect("nvUtilisateur", self, "joueurCo")
	Network.connect("nvStatuUtilisateur", self, "joueurNvStatut")
	Network.connect("decoJoueur", self, "decoJoueur")
	Network.connect("joueurChangeCouleur", self, "on_joueurChangeCouleur")
	
	if !Network.idOneNotHost and Network.id == 1:
		buttonLancer.visible = true
		changePoint.visible = true
	elif Network.id == 0 and Network.withHost == true:
		buttonLancer.visible = true
		changePoint.visible = true
	else:
		buttonLancer.visible = false
		changePoint.visible = false
		
	$Control/LayoutListe/VBoxContainer/LabelListe.text = R.getString("lobbyListe")
	$Control/MainLayout/VBoxContainer/VBoxContainer/LabelCouleur.text = R.getString("lobbyCouleur")
	
	Network.setCouleurJoueur(Network.id, Network.getCouleursPossibles()[0])
	
	if Network.id == 0 and Network.withHost == true:
		buttonDroitCoul.visible = false
		buttonGaucheCoul.visible = false
		selectionCouleur.visible = false
		labelCouleur.visible = false
		buttonPret.visible = false
	self.uiOptions = NODE_OPTIONS.instance()
	self.add_child(uiOptions)
	
	self.uiRegles = NODE_REGLES.instance()
	self.add_child(uiRegles)
	
	self.recupereJoueurs()

#==============================
func recupereJoueurs():
	for usId in Network.utilisateurs :
		if not usId in self.joueurs.keys():
			self.joueurCo(usId)


func joueurCo(idJoueur):
	if not idJoueur in self.joueurs.keys() :
		var instance = self.NODE_INFOJOUEUR.instance()
		self.joueurs[idJoueur] = instance
		self.layoutJoueur.add_child(instance)
		instance.setId(idJoueur)
		instance.setNom( Network.utilisateurs[idJoueur].nom )
		instance.setPret( Network.utilisateurs[idJoueur].estPret )
		instance.setCouleur( Network.utilisateurs[idJoueur].couleur )
		
		if idJoueur == Network.id: # le joueur local
			self.selectionCouleur.modulate = Network.utilisateurs[idJoueur].couleur
	self.majPeutLancer()

func decoJoueur(idJoueur, NomCarte, eraseCarte):
	if idJoueur in self.joueurs.keys():
		self.layoutJoueur.remove_child(self.joueurs[idJoueur])
		self.joueurs.erase(idJoueur)

func joueurNvStatut(idJoueur, statut):
	if idJoueur in self.joueurs.keys():
		self.joueurs[idJoueur].setPret(statut)
	self.majPeutLancer()

func majPeutLancer():
	self.peutLancer = true
	for usId in Network.utilisateurs:
		self.peutLancer = self.peutLancer and Network.utilisateurs[usId].estPret
	
	if self.peutLancer:
		self.buttonLancer.modulate = Color(1.0, 1.0, 1.0)
		self.buttonLancer.disabled = false
		self.buttonLancer.text = R.getString("lobbylancer")
	else:
		self.buttonLancer.modulate = Color(1.0, 0.0, 0.0)
		self.buttonLancer.disabled = true
		self.buttonLancer.text = R.getString("lobbyAttendre")

#==============================
func _on_ButtonPret_pressed():
	Network.lobby_setStatu(!Network.data.estPret)
	if Network.data.estPret == false:
		buttonPret.set_text("Prêt")
	if Network.data.estPret == true:
		buttonPret.set_text("Pas prêt")


func _on_ButtonLancer_pressed():
	if Network.estHote() and self.peutLancer:
		Network.lobby_lancerPartie()


func _versPartie():
	$Control.visible = false
	$AnimationPlayer.play("Entre")
	var timer = Timer.new()
	timer.wait_time = 1.8
	self.add_child(timer)
	timer.start()
	yield(timer, "timeout")
	Transition.transitionVers("res://Scenes/Partie/Partie.tscn")


func on_joueurChangeCouleur(id: int, coul: Color):
	if id == Network.id:
		self.selectionCouleur.modulate = coul


func _on_ButtonCouleurPrec_pressed():
	var arr = Network.getCouleursPossibles()
	if self.selectionCouleur.modulate in Globals.couleursValeurs.values():
		var index: int = arr.find(self.selectionCouleur.modulate)
		index = index-1
		if index < 0:
			index = arr.size() -1
		Network.setCouleurJoueur(Network.id, arr[index])


func _on_ButtonCouleurSuiv_pressed():
	var arr = Network.getCouleursPossibles()
	if self.selectionCouleur.modulate in Globals.couleursValeurs.values():
		var index: int = arr.find(self.selectionCouleur.modulate)
		index = (index + 1) % arr.size()
		Network.setCouleurJoueur(Network.id, arr[index])


func _on_ButtonPointPrec_pressed():
	var nbPoints = int(NbPoint.text)
	if nbPoints <=10:
		NbPoint.set_text("100")
	else:
		nbPoints-=5
		NbPoint.set_text(String(nbPoints))
		
	Network.changeObjectif(int(NbPoint.text))
	
func _on_ButtonPointSuiv_pressed():
	var nbPoints = int(NbPoint.text)
	if nbPoints >=100:
		NbPoint.set_text("10")
	else:
		nbPoints+=5
		NbPoint.set_text(String(nbPoints))
	Network.changeObjectif(int(NbPoint.text))


func _on_ButtonOptions_pressed():
	self.uiOptions.affiche()
