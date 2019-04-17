extends Node

signal palette_applied()

enum DitherMode {
	DITHER_NONE,
	DITHER_ORDERED,
	DITHER_RANDOM,
}

var texture setget set_texture
export var color_size = Vector2(32, 32) setget set_color_size
export var num_colors = 256 setget set_num_colors
export(DitherMode) var dithering = DitherMode.DITHER_NONE setget set_dithering
export(bool) var account_for_alpha = true setget set_account_for_alpha
export(bool) var high_quality = false setget set_high_quality

export(bool) var can_generate = true
export(bool) var can_modify = false

const IMPORT_PNG_PATH = "res://import_indexed/"
const EXPORT_PNG_PATH = "res://export_indexed/"

export(String) var import_png_filename = "" setget set_import_png_filename
export(String) var export_png_filename = "" setget set_export_png_filename

var _update_queued = false


func set_texture(p_texture):
	texture = p_texture
	_queue_update()


func set_color_size(p_size):
	color_size = p_size
	_queue_update()


func set_num_colors(p_num_colors):
	num_colors = p_num_colors
	_queue_update()


func set_dithering(p_dithering):
	dithering = p_dithering
	_queue_update()


func set_account_for_alpha(p_account_for_alpha):
	account_for_alpha = p_account_for_alpha
	_queue_update()


func set_high_quality(p_high_quality):
	high_quality = p_high_quality
	_queue_update()


func set_import_png_filename(p_import_png_filename):
	import_png_filename = p_import_png_filename
	_queue_update()


func set_export_png_filename(p_export_png_filename):
	export_png_filename = p_export_png_filename
	_queue_update()


func _queue_update():

	if not is_inside_tree():
		return

	if _update_queued:
		return

	_update_queued = true

	call_deferred("_build_palette")


func _ready():
	_queue_update()


func _build_palette():

	var image

	var import_path = IMPORT_PNG_PATH + import_png_filename
	var file = File.new()

	var imported = false

	if not import_png_filename.empty():
		if file.file_exists(import_path):
			image = Image.new()
			image.load(import_path)
			imported = true
			print("Loaded: ", import_path)
		else:
			print("Could not load image: ", import_path)
			return
	else:
		image = texture.get_data()

	assert(image)

	if can_generate:
		image.convert(Image.FORMAT_RGBA8) # must convert

		var _mean_error = image.generate_palette(
			num_colors, dithering, account_for_alpha, high_quality)

		image.apply_palette()

	if can_modify:
		modify_palette(image)

	var palette = PoolColorArray([])
	if image.has_palette():
		palette = image.palette
		print("Palette size: ", image.get_palette_size())
		print("First color: ", palette[0])
		print("Last color: ", palette[-1])

	# Visualize palette
	for idx in get_child_count():
		get_child(idx).queue_free()

	var c_idx = 0

	for color in palette:
		var color_test = image.get_palette_color(c_idx)
		assert(color == color_test)

		var cr = ColorRect.new()
		cr.rect_min_size = color_size
		cr.color = color
		add_child(cr)

		c_idx += 1

	if not export_png_filename.empty():
		assert(export_png_filename.get_extension() == "png")
		image.save_png(EXPORT_PNG_PATH + export_png_filename)

	emit_signal("palette_applied", image)

	_update_queued = false


func modify_palette(p_image):
	assert(p_image.has_palette())
#	_modify_palette_custom(p_image)


func _modify_palette_custom(p_image):
	p_image.set_palette_color(0, Color.black)
