extends Node

var tower_data = {
	"gun_t1": {
		"damage": 20,
		"rate_of_fire": 1,
		"range": 700.0,
		"bullet_speed": 1000,
		"health": 100,
		"tower_cost": {
			"wood": 10,
			"stone": 5,
		},
		"upgrade_cost": {
			"wood": 3,
			"stone": 3,
			},
		},
	"missile_t1":{
		"damage": 100,
		"rate_of_fire": 3,
		"range": 1000.0,
		"bullet_speed": 1500,
		"health": 70,
		"tower_cost": {
			"wood": 5,
			"stone": 10,
		},
		"upgrade_cost": {
			"wood": 3,
			"stone": 3,
		},
	},
	"center_building_t1":{
		"health": 150,
		"tower_cost":{
			"wood": 10,
			"stone": 10,
		},
		"upgrade_cost":{
			"wood":5,
			"stone":3
		},
	},
}
func return_tower_cost(tower) -> Dictionary:
	return tower_data[tower]["tower_cost"]

func return_upgrade_cost(tower) -> Dictionary:
	var costs = {}
	for res in tower_data[tower]["upgrade_cost"]:
		costs[res] = tower_data[tower]["upgrade_cost"][res]
	var upgrade_cost = tower_data[tower]["upgrade_cost"]
	update_upgrade_cost(tower)
	return costs

func update_upgrade_cost(tower):
	for resource in tower_data[tower]["upgrade_cost"]:
		tower_data[tower]["upgrade_cost"][resource] += 1
