# arete le pogo dash quand touche sol/ennemis

extends CharacterBody2D

@export_category("movement variable")
@export var move_speed: float = 120.0
@export var deceleration: float = 0.05
@export var gravity: float = 500.0
var movement: float = 0.0
@onready var right_ray: RayCast2D = $raycast/right_ray

@export_category("jump variable")
@export var jump_speed: float = 190.0
@export var acceleration: float = 290.0
@export var jump_amount: int = 1

@export_category("wall jump variable")
@export var wall_slide: float = 50.0
@export var wall_x_force: float = 300.0
@export var wall_y_force: float = -220.0
@export var is_wall_jumping: bool = false

@export_category("dash variable")
@export var dash_speed: float = 400.0
@export var facing_right: bool = true
@export var dash_gravity: float = 0.0
@export var dash_air: int = 1
var dash_key_pressed = 0
var is_dashing = false

@export_category("sword variable")
@export var is_attacking: bool = false
var is_pogo = false
var pogo_jump = false

func _ready() -> void:
	$sword/sword_colider.disabled = true
	$sword/sword_pogo.disabled = true

func _physics_process(delta: float) -> void:
	if not is_dashing:
		velocity.y += 500.0 * delta
		
		if is_pogo == true :
			velocity.y = 500
			$sword/sword_pogo.disabled = false
			if pogo_jump == true or is_on_floor():
				reset_stats()
				velocity.y += 500.0 * delta
				is_pogo = false
	
	else:
		velocity.y = dash_gravity

	horizontal_movement()
	jump_logic()
	wall_logic()
	set_animation()
	flip()
	move_and_slide()

func _process(delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack") :
		is_attacking = true
	if Input.is_action_just_pressed("Pogo") :
		is_pogo = true

func horizontal_movement():
	if is_wall_jumping == false and is_dashing == false:
		movement = Input.get_axis("Left", "Right")
		if movement :
			velocity.x = movement * move_speed
		else :
			#velocity.x = move_toward(velocity.x, 0, move_speed*deceleration) # ne se stop pas instant 
			velocity.x = move_toward(velocity.x, 0, move_speed) 

	if Input.is_action_just_pressed("dash") and dash_key_pressed == 0 and dash_air >= 1:
		dash_air -= 1
		dash_key_pressed = 1
		dash()

func set_animation():
	if not pogo_jump :
		if not is_attacking:
			if velocity.x != 0 :
				$AnimationPlayer.play("move")
			if velocity.x == 0 :
				$AnimationPlayer.play("idle")
			if velocity.y < 0 :
				$AnimationPlayer.play("jump")
			if velocity.y > 10 :
				$AnimationPlayer.play("fall")
			if is_dashing == true:
				$AnimationPlayer.play("fall")
		if is_attacking:
			$AnimationPlayer.play("sword")
	else :
		$AnimationPlayer.play("pogo")
	
func flip():  
	if velocity.x > 0.0 :
		facing_right = true
		scale.x = scale.y * 1
		wall_x_force = 200.0
	if velocity.x < 0.0 :
		facing_right = false
		scale.x = scale.y * -1
		wall_x_force = -200.0

func jump_logic():
	if is_on_floor():
		jump_amount = 1 #nb de jump possible(double jump)
		dash_air = 1
		if Input.is_action_just_pressed("Jump"):
			jump_amount -= 1
			velocity.y -= lerp(jump_speed, acceleration, 0.1)
	
	if not is_on_floor():
		if jump_amount > 0 :
			if Input.is_action_just_pressed("Jump"):
				jump_amount -= 1
				velocity.y -= lerp(jump_speed, acceleration, 0.1)
			if Input.is_action_just_released("Jump"):
				velocity.y = lerp(velocity.y, gravity, 0.2)
				velocity.y *= 0.3
	else:
		return

func wall_logic():
	if is_on_wall_only():
		velocity.y = wall_slide
		dash_air = 1
		if Input.is_action_just_pressed("Jump"):
			if right_ray.is_colliding() :
				velocity = Vector2(-wall_x_force, wall_y_force)
				wall_jumping()

func wall_jumping():
	is_wall_jumping = true
	await get_tree().create_timer(0.1).timeout
	is_wall_jumping = false

func dash():
	if dash_key_pressed == 1 :
		is_dashing = true
	else:
		is_dashing = false
		
	if facing_right == true:
		velocity.x = dash_speed
		dash_started()
	if facing_right == false:
		velocity.x = -dash_speed
		dash_started()

func dash_started():
	if is_dashing == true:
		dash_key_pressed = 1
		await get_tree().create_timer(0.15).timeout
		is_dashing = false
		dash_key_pressed = 0
	else:
		return


func _on_pogo_area_entered(area: Area2D) -> void:
	if area.is_in_group("tiktik") :
		pogo_jump = true

func reset_stats():
	is_attacking = false
	is_pogo = false
	move_speed = 120.0
	$sword/sword_pogo.disabled = true
