extends CharacterBody2D

@export var SPEED = 100.0
@export var JUMP_VELOCITY = -200.0
var direction : float = 0
var movement_lock : bool = false
var animation_lock : bool = false
var health : float = 5
var is_dead : bool  = false
var has_died : bool = false

@onready var animatedsprite2D : AnimatedSprite2D = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if not movement_lock :
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		
		direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	update_animation()
	move_and_slide()
	update_animation_jump()
	Attack()

func update_animation() :
	if direction <0 && not animation_lock:
		animatedsprite2D.flip_h = true
		animatedsprite2D.play("Walk")
		$AttackHitBox.scale.x = -1
	elif direction > 0 && not animation_lock:
		animatedsprite2D.flip_h = false
		animatedsprite2D.play("Walk")
		$AttackHitBox.scale.x = 1
	elif direction ==0 && not animation_lock :
		animatedsprite2D.play("Idle")


func update_animation_jump() :
		if velocity.y < 0 :
			animatedsprite2D.play("Jump")
		elif velocity.y > 0 :
			animatedsprite2D.play("Fall")

func Attack() :
	if Input.is_action_just_pressed("Attack") :
		velocity.x = 0
		animation_lock = true
		movement_lock = true
		$AttackHitBox/CollisionShape2D.disabled = false
		animatedsprite2D.play("Attack")

func _on_animated_sprite_2d_animation_finished():
	if animatedsprite2D.animation == 'Attack' :
		animation_lock = false
		movement_lock = false
		$AttackHitBox/CollisionShape2D.disabled = true
	if animatedsprite2D.animation == 'Hurt' :
		animation_lock = false
		movement_lock = false


func _on_attack_hit_box_body_entered(body):
	if body.is_in_group('Enemy'):
		body.is_dead = true
		
func take_hit() :
	health -= 1
	movement_lock = true
	animation_lock = true
	animatedsprite2D.play("Hurt")
	
	
func dead():
	pass
	
