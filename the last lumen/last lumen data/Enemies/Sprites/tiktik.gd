# tiktik.gd

extends CharacterBody2D

@export var health: int = 2

func _process(_delta: float) -> void:
	if health <= 0 :
		
		queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Sword"):
		health -= 1
