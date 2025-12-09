extends Node

var tower_data = {
	"gun_t1": {
		"damage": 20,
		"rate_of_fire": 1,
		"range": 700.0,
		"bullet_speed": 1000,
		"tower_cost": {
			"wood": 10,
			"stone": 5,
			}
		},
	
	"missile_t1":{
		"damage": 100,
		"rate_of_fire": 3,
		"range": 1000.0,
		"bullet_speed": 1500,
		"tower_cost": {
			"wood": 5,
			"stone": 10,
			}
		},
	
	"center_building_t1": {
		"damage": 0,
		"rate_of_fire": 0,
		"range": 0.0,
		"bullet_speed": 0,
		"tower_cost": {
			},
		}
	}

func return_tower_cost(tower) -> Dictionary:
	return tower_data[tower]["tower_cost"]
