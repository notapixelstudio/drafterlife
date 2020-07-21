extends Area2D


func interact(card):
	if card.title == 'KILL':
		queue_free()
		return true
	
	return false
