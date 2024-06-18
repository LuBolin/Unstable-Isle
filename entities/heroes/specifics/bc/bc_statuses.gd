class_name BcStatuses
extends HeroStatus


# Status should have
# a reference to og script
# state of the status (most important is probably time, but might have others)
# Return a function that applies some effect to self

func attack_dot(unit):
	return func(): unit.
