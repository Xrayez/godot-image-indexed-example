extends VBoxContainer

const PreviewPanel = preload("res://preview_panel.tscn")

export(bool) var populate_from_textures = true
export(Array, Texture) var textures = [] setget set_textures


func set_textures(p_textures):
	call_deferred("_populate_previews", p_textures)


func _populate_previews(p_textures):

	if not populate_from_textures:
		return

	for idx in get_child_count():
		get_child(idx).queue_free()

	for tex in p_textures:
		var pp = PreviewPanel.instance()
		pp.texture = tex
		add_child(pp)