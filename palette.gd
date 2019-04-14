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

const EXPORT_PNG_PATH = "res://export_indexed/"
const IMPORT_PNG_PATH = "res://import_indexed/"

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

	var import_path = IMPORT_PNG_PATH + import_png_filename + ".png"
	var file = File.new()

	if not import_png_filename.empty() and file.file_exists(import_path):
		image = Image.new()
		image.load(import_path)
	else:
		image = texture.get_data()

	image.convert(Image.FORMAT_RGBA8) # must convert

	var _mean_error = image.generate_palette(
		num_colors, dithering, account_for_alpha, high_quality)

	image.apply_palette()

	# Visualize palette
	for idx in get_child_count():
		get_child(idx).queue_free()

	var palette = image.palette

	for color in palette:
		var cr = ColorRect.new()
		cr.rect_min_size = color_size
		cr.color = color
		add_child(cr)

	if not export_png_filename.empty():
		image.save_png(EXPORT_PNG_PATH + export_png_filename + ".png")

	emit_signal("palette_applied", image)

	_update_queued = false
