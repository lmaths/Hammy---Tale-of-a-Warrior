extends Node

class_name Damageable


func hit(damage: int):
	get_parent()._loseHealth(damage)
