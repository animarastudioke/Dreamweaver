# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does swipe-based lane dodging + boost/brake feel responsive and satisfying?
# Date: 2026-09-02
#
# Whole scene is built in code (_build_scene) rather than hand-authored in a
# .tscn, so there's no scene-file authoring to get wrong for a throwaway build.
# Everything is placeholder geometry (colored boxes) — no real art.
#
# Desktop testing: "input_devices/pointing/emulate_touch_from_mouse" is set in
# project.godot, so mouse click+drag in the editor generates real
# InputEventScreenTouch/Drag events — the same code path a phone would use.

extends Node3D

const LANE_COUNT := 3
const LANE_WIDTH := 3.0
const BASE_SPEED := 14.0
const BOOST_MULTIPLIER := 1.8
const BOOST_DURATION := 1.0
const BRAKE_MULTIPLIER := 0.45
const BRAKE_DURATION := 0.4
const OBSTACLE_SPAWN_Z := -70.0
const OBSTACLE_DESPAWN_Z := 8.0
const OBSTACLE_SPAWN_INTERVAL := 0.9
const SWIPE_MIN_DISTANCE := 40.0  # pixels
const LANE_LERP_RATE := 12.0  # <-- #1 tuning knob for "input delay" feel

var player: Node3D
var player_collider: Area3D
var hud_label: Label
var flash_rect: ColorRect

var current_lane := 1
var target_x := 0.0
var boost_timer := 0.0
var brake_timer := 0.0
var distance := 0.0
var run_count := 1
var alive := true

var touch_start := Vector2.ZERO
var touch_active := false

var obstacles: Array = []
var spawn_timer := 0.0


func _ready() -> void:
	_build_scene()
	_reset_run()


func _build_scene() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -30, 0)
	light.light_energy = 1.1
	add_child(light)

	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.55, 0.75, 0.95)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.6, 0.65)
	env_node.environment = env
	add_child(env_node)

	var road := MeshInstance3D.new()
	var road_mesh := BoxMesh.new()
	road_mesh.size = Vector3(LANE_WIDTH * LANE_COUNT, 0.2, 400.0)
	road.mesh = road_mesh
	road.position = Vector3(0, -0.1, -150)
	var road_mat := StandardMaterial3D.new()
	road_mat.albedo_color = Color(0.25, 0.25, 0.28)
	road.material_override = road_mat
	add_child(road)

	for i in range(1, LANE_COUNT):
		var marker := MeshInstance3D.new()
		var marker_mesh := BoxMesh.new()
		marker_mesh.size = Vector3(0.1, 0.22, 400.0)
		marker.mesh = marker_mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1, 1, 1)
		marker.material_override = mat
		marker.position = Vector3(-LANE_WIDTH * LANE_COUNT / 2.0 + i * LANE_WIDTH, 0.01, -150)
		add_child(marker)

	player = Node3D.new()
	add_child(player)

	var player_mesh := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(1.6, 1.2, 2.6)
	player_mesh.mesh = body_mesh
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.9, 0.65, 0.1)
	player_mesh.material_override = body_mat
	player_mesh.position.y = 0.6
	player.add_child(player_mesh)

	player_collider = Area3D.new()
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(1.6, 1.2, 2.6)
	shape.shape = box_shape
	shape.position.y = 0.6
	player_collider.add_child(shape)
	player.add_child(player_collider)
	player_collider.area_entered.connect(_on_player_hit)

	var camera := Camera3D.new()
	camera.position = Vector3(0, 3.2, 6.5)
	camera.rotation_degrees = Vector3(-18, 0, 0)
	camera.current = true
	player.add_child(camera)

	var canvas := CanvasLayer.new()
	add_child(canvas)

	hud_label = Label.new()
	hud_label.position = Vector2(16, 16)
	hud_label.add_theme_font_size_override("font_size", 22)
	canvas.add_child(hud_label)

	flash_rect = ColorRect.new()
	flash_rect.color = Color(1, 0, 0, 0.0)
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(flash_rect)


func _reset_run() -> void:
	alive = true
	current_lane = 1
	target_x = 0.0
	player.position = Vector3(0, 0, 0)
	boost_timer = 0.0
	brake_timer = 0.0
	distance = 0.0
	for o in obstacles:
		if is_instance_valid(o):
			o.queue_free()
	obstacles.clear()
	spawn_timer = 0.0


func _lane_x(lane: int) -> float:
	return (lane - (LANE_COUNT - 1) / 2.0) * LANE_WIDTH


func _unhandled_input(event: InputEvent) -> void:
	if not alive:
		if event is InputEventScreenTouch and event.pressed:
			run_count += 1
			_reset_run()
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.position
			touch_active = true
		else:
			if touch_active:
				_handle_swipe(event.position - touch_start)
			touch_active = false


func _handle_swipe(delta_vec: Vector2) -> void:
	if delta_vec.length() < SWIPE_MIN_DISTANCE:
		return
	if abs(delta_vec.x) > abs(delta_vec.y):
		if delta_vec.x > 0:
			current_lane = min(current_lane + 1, LANE_COUNT - 1)
		else:
			current_lane = max(current_lane - 1, 0)
		target_x = _lane_x(current_lane)
	else:
		if delta_vec.y < 0:
			boost_timer = BOOST_DURATION
		else:
			brake_timer = BRAKE_DURATION


func _physics_process(delta: float) -> void:
	if not alive:
		return

	player.position.x = lerp(player.position.x, target_x, clamp(delta * LANE_LERP_RATE, 0.0, 1.0))

	var speed := BASE_SPEED
	if boost_timer > 0.0:
		boost_timer -= delta
		speed *= BOOST_MULTIPLIER
	elif brake_timer > 0.0:
		brake_timer -= delta
		speed *= BRAKE_MULTIPLIER

	distance += speed * delta

	spawn_timer -= delta
	if spawn_timer <= 0.0:
		_spawn_obstacle()
		spawn_timer = OBSTACLE_SPAWN_INTERVAL

	for o in obstacles.duplicate():
		if not is_instance_valid(o):
			obstacles.erase(o)
			continue
		o.position.z += speed * delta
		if o.position.z > OBSTACLE_DESPAWN_Z:
			obstacles.erase(o)
			o.queue_free()

	if flash_rect.color.a > 0.0:
		flash_rect.color.a = max(0.0, flash_rect.color.a - delta * 2.5)

	hud_label.text = "Run %d\nDistance: %d m\nSwipe L/R = dodge, swipe up = boost, swipe down = brake" % [run_count, int(distance)]


func _spawn_obstacle() -> void:
	var lane := randi() % LANE_COUNT
	var obstacle := Area3D.new()

	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.4, 1.0, 1.4)
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.1, 0.1)
	mesh.material_override = mat
	mesh.position.y = 0.5
	obstacle.add_child(mesh)

	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(1.4, 1.0, 1.4)
	shape.shape = box_shape
	shape.position.y = 0.5
	obstacle.add_child(shape)

	obstacle.position = Vector3(_lane_x(lane), 0, OBSTACLE_SPAWN_Z)
	add_child(obstacle)
	obstacles.append(obstacle)


func _on_player_hit(area: Area3D) -> void:
	if not alive:
		return
	if area in obstacles:
		alive = false
		flash_rect.color = Color(1, 0, 0, 0.6)
		hud_label.text = "Run %d ended\nDistance: %d m\n\nTap/click to restart" % [run_count, int(distance)]
