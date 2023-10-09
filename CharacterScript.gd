extends CharacterBody2D
#D:\Games\Game Dev sprites
var crouching = false
var gravity = 50
var terminalVelocity = 888
var knockback = 0

var facing = 1

var strength = -1000
var attacking = false
var blocking = false

#states
var state = "standing"
var action = "idle"
var movement = "idle"
var attack = "LP"
var jumpState = "rising"
var hit = "hit"

#cancel states
var normalCancel = false
var specialCancel = true
var superCancel = true

var hitstun = 0

var speed = 500;

@onready var parent = $".."
@onready var animatedSprite = $AnimatedSprite2D
@onready var animatedPlayer = $AnimatedSprite2D/AnimationPlayer
@onready var animatedTree : AnimationTree = $AnimatedSprite2D/AnimationTree
@onready var hitboxes = $AnimatedSprite2D/Hitboxes

#animationTree
@onready var A_State = "parameters/State/transition_request"
@onready var A_StandingAction = "parameters/StandingAction/transition_request"
@onready var A_CrouchingAction = "parameters/CrouchingAction/transition_request"
@onready var A_JumpingAction = "parameters/JumpingAction/transition_request"
@onready var A_Jump = "parameters/Jump/transition_request"
@onready var A_Movement = "parameters/Movement/transition_request"
@onready var A_Attacking = "parameters/Attacking/transition_request"
@onready var A_Hit = "parameters/Hit/transition_request"
@onready var A_JumpAttacking = "parameters/JumpAttacking/transition_request"
@onready var A_CrouchAttacking = "parameters/CrouchAttacking/transition_request"
#controller
@onready var virtualController = parent.virtualController

# Called when the node enters the scene tree for the first time.
func _ready():
	setAnimation()
	animatedTree.active = true
	
func _physics_process(delta):
	endHitstun()
	gravity_fall()
	
	if parent.virtualController != null:
		if (!attacking || normalCancel && action == "attacking") && action != "hit":
			isAttacking()
		jump()
		walk()
		
	set_velocity(velocity)
#	set_up_direction(Vector2.UP)
	move_and_slide()
	
	setAnimation()
	flip()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func gravity_fall():
	velocity.y += gravity
	
	if velocity.y > terminalVelocity:
		velocity.y = terminalVelocity
	elif is_on_floor():
		velocity.y = 5
	if state == "jumping" && is_on_floor():
		state = "standing"
		action = "idle"
		animationFinished()
		

func isAttacking():
	if parent.virtualController.LP == 1:
		attack = "LP"
		attacking = 1
	if parent.virtualController.MP == 1: 
		attack = "MP"
		attacking = 1
	if parent.virtualController.HP == 1: 
		attack = "HP"
		attacking = 1
	neutralAnimation()
	if attacking:
		action = "attacking"
		return
	attacking = 0

func animationFinished():
	set_deferred("attacking", 0)
	action = "idle"
	normalCancel = false

func neutralAnimation():
	blocking = parent.virtualController.directionX * facing < 0
	if is_on_floor():
		if crouching:
			state = "crouching"
		elif parent.virtualController.directionX == 0:
			state = "standing"
			movement = "idle"
		else:
			state = "standing"
			if parent.virtualController.directionX * facing > 0:
				movement = "walk"
			else:
				movement = "walkback"
				
	
func flip():
	if is_on_floor() && !attacking && parent.facing != facing:
		scale.x = -1
		facing = parent.facing

func walk():
	#apply movement
	if action == "hit":
		if hit == "block":
			applyKnockback(knockback/2)
		else:
			applyKnockback(knockback)
		return
	crouching = parent.virtualController.directionY > 0
	if is_on_floor() && !crouching && !attacking: 
		velocity.x = parent.virtualController.directionX*speed
	elif abs(velocity.x) > 0 && state != "jumping":
		velocity.x = velocity.x - 150 * (velocity.x/speed)
	elif state != "jumping":
		velocity.x = 0

func applyKnockback(knockbackApplied):
	if abs(knockback) > 0:
		velocity.x = velocity.x+knockbackApplied
		knockback = 0
	elif abs(velocity.x) > 0:
		velocity.x = velocity.x - 1 
	else:
		velocity.x = 0
	return


func jump():
	if action == "hit":
		return
	if parent.virtualController.directionY < 0 and is_on_floor() and !attacking:
		velocity.y = +strength
		state = "jumping"
	if velocity.y > 0:
		jumpState = "falling"
	else:
		jumpState = "rising"

func setAnimation():
	animatedTree.set(A_State, state)
	animatedTree.set(A_StandingAction, action)
	animatedTree.set(A_CrouchingAction, action)
	animatedTree.set(A_JumpingAction, action)
	animatedTree.set(A_Jump, jumpState)
	animatedTree.set(A_Movement, movement)
	animatedTree.set(A_Attacking, attack)
	animatedTree.set(A_Hit, hit)
	animatedTree.set(A_JumpAttacking, attack)
	animatedTree.set(A_CrouchAttacking, attack)

func _on_hitboxes_area_entered(hitbox):
	if hitbox.get_parent() != animatedSprite:
		hitbox.get_parent().get_parent().getHit()
		normalCancel = true
	
func getHit():
	if action == "hit":
		#TODO loop hit animation
		print(animatedTree)
	hitboxes.disableHitboxes()
	action = "hit"
	if !blocking:
		parent.HP = parent.HP - 10
		attacking = 0
		hitstun = 19
		knockback = 35 * -parent.facing
		hit = "hit"
	else:
		knockback = 35 * -parent.facing
		hitstun = 19
		hit = "block"
	
func endHitstun():
	if hitstun == 0 && action == "hit":
		action = "idle"
		hitboxes.enableHitboxes()
	elif hitstun > 0:
		hitstun = hitstun - 1
