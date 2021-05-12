extends Spatial

export(Image) var image
onready var meshImage = $Image


func _ready():
	if self.image == null:
		return
	
	var mat = self.meshImage.get_surface_material(0)
	var txt = ImageTexture.new()
	txt.create_from_image(self.image)
	mat.albedo_texture = txt
