extends Node

var resources := {
	"stone": 0,
	"wood": 0,
	"iron": 0
}

func add_resource(type: String, amount: int):
	if not resources.has(type):
		resources[type] = 0

	resources[type] += amount
	print(type, ":", resources[type])
