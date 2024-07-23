extends CharacterBody2D

@export var speed = 50.0
@export var walk_speed = 100
var is_dead : bool = false
var has_died : bool = false
var is_walking : bool = false
var is_attacking : bool = false
var is_going_to_left : bool = false
var is_stacking : bool = false
var knockback_floor : float = 200.0
var knovkback_duration : float = 0.5
var knockback_timer = 0.0
var knockback_direction :Vector2 = Vector2.ZERO
var knockback_power : float = 200.0

@onready var timer : Timer = $Timer
@onready var animatedsprite2D : AnimatedSprite2D = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting('physics/2d/default_gravity')

func _physics_process(delta):
	if not is_dead and not has_died :
		if knockback_timer > 0.0 :
			knockback_timer -= delta 
			var knockback_velocity = knockback_direction * knockback_power
		if not is_on_floor() :
			velocity.y += gravity * delta
		move_and_slide()
		update_animation()
		attack()
	elif is_dead and not has_died :
		animatedsprite2D.play("Died")
	
func _on_timer_timeout():
	if not is_dead and not has_died :
		if not is_attacking :
			if not is_walking :
				if not is_going_to_left :
					velocity.x = walk_speed
					is_walking = true
					is_going_to_left = true
					timer.wait_time = 4.0
				else :
					velocity.x = -walk_speed
					is_walking = true
					is_going_to_left = false
					timer.wait_time = 4.0
			else :
				velocity.x = 0
				is_walking = false
				timer.wait_time = 1.0




func update_animation() :
	if velocity.x <0 :
		$DirectionArea.scale.x = -1
		$HitBox.scale.x = -1
		animatedsprite2D.flip_h = true
		animatedsprite2D.play("Walk")
	elif velocity.x > 0 :
		$DirectionArea.scale.x = 1
		$HitBox.scale.x = 1
		animatedsprite2D.flip_h = false
		animatedsprite2D.play("Walk")
	elif velocity.x ==0 :
		animatedsprite2D.play("Idle")
		
func attack() :
	if is_attacking :
		if not is_going_to_left :
			speed += 0.3
			velocity.x = -speed
			speed += 0.3
		else :
			speed += 0.3
			velocity.x = speed
			speed += 0.3
			

func _on_direction_area_body_entered(body):
	if body.is_in_group("Player") :
		is_attacking = true


func _on_direction_area_body_exited(body):
	if body.is_in_group("Player") :
		is_attacking = false
		speed = 50.0


func _on_animated_sprite_2d_animation_finished():
	if animatedsprite2D.animation == 'Died' :
		is_dead = false
		has_died = true
		queue_free()



func _on_hit_box_area_entered(area):
	if area.get_parent().is_in_group('Player'):
		area.get_parent().take_hit()
		is_stacking = false
		var knockback_calc = (global_position - area.global_position)
		apply_knockback(knockback_calc.normalized())
		speed = 50.0
		
func apply_knockback(direction : Vector2):
	knockback_direction = direction.normalized()
	knockback_timer = knockback_direction

