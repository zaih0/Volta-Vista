extends Button

signal catagory_changed(catagory: int)

var catagory: int

func setup(value: int, display_name: String):
	catagory = value
	text = display_name

func _pressed():
	catagory_changed.emit(catagory)
