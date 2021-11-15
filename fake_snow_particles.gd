tool
class_name FakeSnowParticles
extends Node2D

## If `true`, particles are being emitted.
export (bool) var emitting = false setget _set_emitting
## The number of particles.
export (int) var amount = 200 setget _set_amount
## Controls the visibility of the particles.
export (Rect2) var visibility_rect = Rect2(0.0, -100.0, 320.0, 180.0) setget _set_visibility_rect
## The color/s of the particles.
## 
## If there is more than 1 color, these colors will be applied randomly \
## on the "background" particles along with the main color.
export (PoolColorArray) var colors = [Color(1.0, 1.0, 1.0, 1.0)] setget _set_colors
## The possible minimum velocity of the particles.
export (float) var min_velocity = 10.0 setget _set_min_velocity
## The possible maximum velocity of the particles.
export (float) var max_velocity = 50.0 setget _set_max_velocity
## The amount of time (in seconds) until the next cycle of particles is emitted.
export (float) var timer_wait_time = 5.0 setget _set_timer_wait_time
## If `true`, @link_name {visibility_rect} will be full of particles when loading the scene.
export (bool) var preprocess = false

var colors_weights = []
var direction = Vector2.DOWN
var initial_visibility_rect = visibility_rect
var initial_timer_wait_time = timer_wait_time
var particles = []
var timer = 0.0


func _ready():
	if preprocess:
		visibility_rect = Rect2(
			0.0,
			initial_visibility_rect.size.y,
			initial_visibility_rect.size.x,
			initial_visibility_rect.size.y
		)

		timer_wait_time = 0.1

	set_process(false)
	self.emitting = not Engine.editor_hint


func _process(delta):
	timer += delta

	if timer > timer_wait_time:
		if preprocess:
			preprocess = false
			timer_wait_time = initial_timer_wait_time
			visibility_rect = initial_visibility_rect

		timer = 0.0
		_create_particles(amount / 2)

	for particle in particles:
		particle.sin_wave_time += delta
		particle.timer += delta

		if particle.timer > particle.timer_wait_time:
			particle.timer = 0.0
			particle.timer_wait_time = rand_range(1.0, 5.0)
			particle.sin_wave_freq = rand_range(1.0, 5.0)

		particle.position.x += (
			cos(particle.sin_wave_time * particle.sin_wave_freq)
			* particle.sin_wave_amplitude
		)
		particle.position += particle.velocity * direction * delta

		if particle.position.y > visibility_rect.size.y:
			particles.erase(particle)

	update()


func _draw():
	for particle in particles:
		draw_rect(Rect2(particle.position, particle.size), particle.color)

	if Engine.editor_hint:
		draw_polyline(
			PoolVector2Array(
				[
					Vector2(visibility_rect.position.x, visibility_rect.position.y),
					Vector2(
						(
							visibility_rect.position.x
							+ (visibility_rect.size.x + abs(visibility_rect.position.x))
						),
						visibility_rect.position.y
					),
					Vector2(
						(
							visibility_rect.position.x
							+ (visibility_rect.size.x + abs(visibility_rect.position.x))
						),
						visibility_rect.size.y
					),
					Vector2(visibility_rect.position.x, visibility_rect.size.y),
					Vector2(visibility_rect.position.x, visibility_rect.position.y),
				]
			),
			Color.gold,
			2.0
		)
		draw_polyline(
			PoolVector2Array(
				[
					Vector2(0.0, 0.0),
					Vector2(visibility_rect.size.x, 0.0),
					Vector2(visibility_rect.size.x, visibility_rect.size.y),
					Vector2(0.0, visibility_rect.size.y),
					Vector2(0.0, 0.0)
				]
			),
			Color.aqua,
			2.0
		)


func _create_particles(particles_ammount):
	for _i in particles_ammount:
		var particle = {
			color = colors[0],
			position = Vector2(
				rand_range(
					visibility_rect.position.x,
					(
						visibility_rect.position.x
						+ (visibility_rect.size.x + abs(visibility_rect.position.x))
					)
				),
				rand_range(0.0, visibility_rect.position.y)
			),
			sin_wave_time = 0.0,
			sin_wave_freq = rand_range(1.0, 5.0),
			sin_wave_amplitude = rand_range(0.1, 0.5),
			size = Vector2.ONE * (randi() % 2 + 1),
			timer = 0.0,
			timer_wait_time = rand_range(1.0, 5.0),
			velocity = rand_range(min_velocity, max_velocity),
		}

		if particle.size == Vector2.ONE:
			particle.color = _rand_array(colors_weights)

		particles.append(particle)


func _create_colors_weights():
	colors_weights.clear()
	for i in colors.size():
		colors_weights.append([(colors.size() - i * 1) * colors.size(), colors[i]])


func _rand_array(array):
	# Code from @CowThing (https://pastebin.com/HhdBuUzT).
	# Arrays must be [weight, value].

	var sum_of_weights = 0
	for t in array:
		sum_of_weights += t[0]

	var x = randf() * sum_of_weights

	var cumulative_weight = 0
	for t in array:
		cumulative_weight += t[0]

		if x < cumulative_weight:
			return t[1]


func _set_emitting(new_value):
	if new_value != emitting:
		emitting = new_value

		if emitting:
			set_process(true)
			_create_colors_weights()
			_create_particles(amount)
		else:
			set_process(false)
			particles.clear()
			timer = 0.0
			update()


func _set_amount(new_value):
	if new_value != amount:
		amount = new_value

		update()


func _set_visibility_rect(new_value):
	if new_value != visibility_rect:
		visibility_rect = new_value

		update()


func _set_colors(new_value):
	if new_value != colors:
		colors = new_value

		_create_colors_weights()

		update()


func _set_min_velocity(new_value):
	if new_value != min_velocity:
		min_velocity = new_value

		update()


func _set_max_velocity(new_value):
	if new_value != max_velocity:
		max_velocity = new_value

		update()


func _set_timer_wait_time(new_value):
	if new_value != timer_wait_time:
		timer_wait_time = new_value

		update()
