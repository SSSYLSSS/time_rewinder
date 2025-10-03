extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -800.0

# 添加变量来跟踪跳跃状态
var is_jumping := false

@onready var rewinder: Rewinder = $Rewinder

func _ready() -> void:
	$Label.visible=false

func custom_data():
	var texture = $AnimatedSprite2D.sprite_frames.get_frame_texture($AnimatedSprite2D.animation, $AnimatedSprite2D.frame)
	return {
		"texture": texture,
		"animation": $AnimatedSprite2D.animation,
		"flip_h": $AnimatedSprite2D.flip_h
	}

func apply_data(data):
	$AnimatedSprite2D.animation = data.animation
	$AnimatedSprite2D.flip_h = data.flip_h

func _physics_process(delta: float) -> void: 
	if rewinder.is_rewinding:
		return
	# 应用重力
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		is_jumping = false
	
	# 处理跳跃输入
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		$AnimatedSprite2D.play("jump")

	var direction := Input.get_axis("left_run", "right_run")
	
	# 处理水平移动
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# 处理动画状态 - 简化逻辑
	if is_on_floor():
		if direction != 0:
			$AnimatedSprite2D.play('walk')
		else:
			$AnimatedSprite2D.play('idle')
	else:
		# 在空中时，如果正在跳跃就保持跳跃动画
		if is_jumping:
			$AnimatedSprite2D.play("jump")
	
	# 处理角色朝向
	if direction != 0:
		$AnimatedSprite2D.flip_h = direction < 0
	
	if Input.is_action_just_pressed("upsidedown"):
		$AnimatedSprite2D.flip_v = not $AnimatedSprite2D.flip_v
		$Label.visible=$AnimatedSprite2D.flip_v


	move_and_slide()
