extends VBoxContainer

const PreviewPanel = preload("res://preview_panel.tscn")

export(bool) var populate_from_textures = true
export(Array, Texture) var textures = [] setget set_textures

export(bool) var save_screenshot = false


func _ready():
	if save_screenshot:
		call_deferred("_save_screenshot")


func _save_screenshot():
	# Render
	get_viewport().render_target_v_flip = true # hmm
	yield(VisualServer, "frame_post_draw")
	get_viewport().render_target_v_flip = false

	var screenshot = get_viewport().get_texture().get_data()
	screenshot.save_png("res://export_indexed/screenshot.png") # regular

	screenshot.convert(Image.FORMAT_RGBA8)
	screenshot.generate_palette()
	screenshot.save_png("res://export_indexed/screenshot_indexed.png")

	# Indexed "lossy compression" ratio: at least 4/1


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