extends Node2D


var build_mode = false #talar om ifall vi håller på att bygga något just nu
var build_valid = false #säger ifall vi får bygga det vi vill bygga
var build_tile # tilen på kartan är tornet ska byggas
var build_location # globala positionen för det blivande tornet
var build_type # vilken typ av torn som ska byggan (ex. gun_t1 osv)

var center_pos: Vector2 #positionen av center_building, används ex. vid placering av fiende-spawnersarna
var center_building: StaticBody2D #centerbuilding-noden, defineras när tornet byggs, används som referens i andra script

var possible_builds = {"center_building_t1": 1, "gun_t1": 0, "missile_t1": 0, "wall_t1": 0} #hur många torn av varje sort som får byggas, updateras när center-tornet upgraderas
var buildings = {"center_building_t1": 0, "gun_t1": 0, "missile_t1": 0, "wall_t1": 0} # hur mpnga torn per sort som byggts

var cb_upgrade_nr: int = 0 # enter_building uppgrade nr, = hur många gånger cetner building upgraderats
# {"center_building_t1": 1, "gun_t1": 4, "missile_t1": 2, "wall_t1": 10}

enum passive_towers { 
	center_building_t1,
	wall_t1
}
# en samling namn på torn som är passiva -> de har inte de vanliga sjutfunktionerna som de skjutande tornen har, används vid bygge av tornen

var inventory = {
	"wood": 20,
	"stone": 20,
}
# spelarens inventory

@export var BaseLayer: TileMapLayer # lagret där bakgrunden är på
@export var BuildingLayer: TileMapLayer # lagret där alla byggnader är på, detta används för att kolla om en tile är occuperad
@export var WallLayer: TileMapLayer # här byggs väggarna, då de måste länka samman blev det lättare att ha dem på ett separat lager, om jag lägger till dörrar av något slag få de också hamna här

@export var lose_screen: Control # en UI som dyker upp om man förlorat
@export var win_screen: Control # samma men för vinst

@onready var enemy_spawner_scene = preload("res://Scenes/MainScenes/enemy_spawner.tscn") # enemy-spawner scenen
@onready var ui = $UI # ui-noden
@onready var spawn_pos: Marker2D = $WorldMap/SpawnPos
@onready var player: CharacterBody2D = $Player

signal center_building_built #sänds ut när centertornet blivit byggt, används i tornscripten så de inte ska försöka sätta en mittposition som inte finns, lite av en relik dåp det nu inte går att sätta ut torn innan mittbyggnaden
signal main_menue # signal som säns ut från ui när man vill tillbaka till main manue
signal retry # samma men för att försöka igen direkt

func _ready() -> void:
	player.global_position = spawn_pos.global_position
	ui.update_inventory() # visa startvärden i ui
	for i in get_tree().get_nodes_in_group("build_buttons"): # skapar en array med noderna i "build_buttons"
		i.pressed.connect(initiate_build_mode.bind(i.name)) # skapar en referens så torn kan byggast genom att klicka på knapparna i ui:n, behöver inte mauellt koppla för varje nytt torn utan det här sköter det automatiskt
	
	check_building_validity() # stänga av knappar om tornen inte går att bygga än

func _on_new_attempt():
	_ready()

func _process(_delta: float) -> void:
	if build_mode: 
		update_tower_preview()
		# om vi bygger -> uppdatera var vi vill bygga


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("RightClick") and build_mode:
		cancel_build_mode() # högerklick samtidigt som vi håller på att bygga -> gå ur byggläget
	
	if event.is_action_released("LeftClick") and build_mode:
		verify_and_build() # kolla först så vi kan bygga sedan bygg
		if build_type == "wall_t1": # om v ibygger väggar får vi vara kvar i byggläget så det inte blir så irriterande
			return
		cancel_build_mode() # gå tillbaka till normalt läge

##### Build Functions #############

func initiate_build_mode(tower_type):
	var passive_tower: bool = false # passive tower är false som standard
	if build_mode: # om vi redan är i build mode -> avsluta det innan vi fortsätter
		cancel_build_mode()
	build_mode = true # vi bygger
	build_type = tower_type # vi bygger det som ui:n säger att vi ska bygga
	for tower in passive_towers: # sätt passive_tower till true om den matchar med någgon av tornen vi definierat som passiva
		if build_type == tower: 
			passive_tower = true
	
	$PreviewLayer.set_tower_preview(build_type, get_global_mouse_position(), passive_tower) # vi sätter ut en tower preview på det speciella canvas lagret för previews
	# vi säger till den vad vi vill bygga, var musen är till en början samt om det är ett skjutande torn

func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var current_tile = BuildingLayer.local_to_map(mouse_position) # detta ger oss en tile på tilemapen (ex. (0,2), (4, 7), osv)
	var tile_position = BuildingLayer.map_to_local(current_tile) # detta ger oss positonen på mitten av tilen vi är inne på

	# get_cell_source_id() gör att vi kan få tag på en cell, om den är tom blir resultatet == -1
	if BuildingLayer.get_cell_source_id(current_tile) == -1 and WallLayer.get_cell_source_id(current_tile) == -1 and buildings[build_type] < possible_builds[build_type] and enough_resources(): # Det vi kollar här är ifall det finns någon tile i vårat building lager
	# vi kollar även om vi har nog med resurser vi enough_resources() som returnar false om vi inte har nog
		$PreviewLayer.update_tower_preview(tile_position, "91ff63ca") # vi uppdateras positionen och skickar med en grön färg
		build_valid = true # vi får bygga
		build_location = tile_position #om vi bygger ska det vara på tilens position
		build_tile = current_tile # tilen vi ska bygga på (ifall vi bygger) är den vi nu är på
	else: # Något finns på den tilen/vi har byggt max antalet av den byggnaden / vi har inte nog med resurser
		$PreviewLayer.update_tower_preview(tile_position, "ff2016a7") # samma som innan fast röd
		build_valid = false #vi kan ej byga

func cancel_build_mode():
	build_mode = false # vi bygger inte
	build_valid = false # build_valid går tillbaka till grundtillståndet
	$PreviewLayer/BuildingPreview.free()
	# spännande fel är tidigare, queue free fungerade ej utan free() behövdes, handlade om att vi refererar till
	# namnet på noden i UI och då blir det skumt om man entrar build mode från build mode, nya noden hinner skapas innan
	# den gamla togs bort -> namnen kommer bli fel

func verify_and_build():
	if build_valid: # om vi kan bygga
		if enough_resources() == false: # vi kollar en sista gång så vi har nog med resurser
			return
		buildings[build_type] += 1 # vi har nu byggt tornet och därför lägger vi till en på antalet byggda torn
		if buildings[build_type] == possible_builds[build_type]: # om vi byggt maxantalet av detta torn ska vi :
			ui.disable_button(build_type) # stänga av bygg-knappen till det tornet
		
		if build_type == "wall_t1": # om vi bygger en vägg ska vi avsluta här och göra på ett lite annat sätt
			build_wall()
			return
		
		var new_tower = load("res://Scenes/Buildings/" +build_type+ ".tscn").instantiate() # vi instansierar det nya tornet
		new_tower.global_position = build_location # tornets position är där vi ska bygga
		$WorldMap/Buildings.add_child(new_tower, true) # readable name används när den raderas
		BuildingLayer.set_cell(build_tile, 0, Vector2i(0,0)) # vi sätter bygg-tilen till ocuperad
		spend_resource() # vi spenderar resurcerna som krävdes
		if build_type ==  "center_building_t1": # om vi bygger mittbyggnadem:
			center_pos = new_tower.global_position # mitt pos = byggtornets pos
			center_building_built.emit() # center building är nu byggd
			center_building = new_tower # nu defenieras vilket torn center building är, ej relevant innan detta
			update_possible_builds(possible_builds) # vi vill nu updatera hur många torn som kan byggas då center building är starten på spelet
			await get_tree().create_timer(2, false).timeout # vi väntar lite innan vi börjar mde fienderna, (..., false) då vi vill att timern ska pausas om spelet pausas
			var enemy_spawner = enemy_spawner_scene.instantiate() # nu vill vi spawna enemies
			add_child(enemy_spawner) # vi lägger till spawnern
			ui.connect_to_spawner(enemy_spawner) # vi kopplar ui:n till spawnern (för att ex. tiden mellan vågorna ska vara synligt)
			enemy_spawner.start(new_tower.position) # vi startar timern, mitten av "spawnern" är mitt i center building

func update_possible_builds(builds_dict: Dictionary, is_cb_upgrade: bool = false): # denna används när vi vill updatera hur många av varje torn som kan byggas
	#builds_dict är en dictionary med tornen som kan byggas, is_cb_upgrade är en bool som används för att säga till om funktionen används för att ändra hur många torn som kan byggas-
	#eller om den bara används för att kolla hur många torn som kommer kunna byggas om center building upgraderas ( för att visa detta i center building upgraderingsmeny
	if cb_upgrade_nr == 0 and ! is_cb_upgrade: # om vi uppgraderat center building noll gånger och vi vill ändra hur många torn som kan byggas:
		builds_dict = {"center_building_t1": 1, "gun_t1": 4, "missile_t1": 2, "wall_t1": 20}
		center_building.cur_possible_builds = builds_dict
	elif is_cb_upgrade:
		builds_dict["gun_t1"] += 2
		builds_dict["missile_t1"] += 1
		builds_dict["wall_t1"] += 10
		return builds_dict
	
	else:
		builds_dict["gun_t1"] += 2
		builds_dict["missile_t1"] += 1
		builds_dict["wall_t1"] += 1
		center_building.cur_possible_builds = builds_dict
	
	if is_cb_upgrade:
		return
	
	possible_builds = builds_dict
	cb_upgrade_nr += 1
	
	for building in possible_builds:
		if buildings[building] < possible_builds[building]:
			ui.re_enable_button(building)

func build_wall():
	WallLayer.set_cells_terrain_connect([build_tile], 0, 0)
	var new_tower = load("res://Scenes/Buildings/" +build_type+ ".tscn").instantiate()
	new_tower.position = build_location
	$WorldMap/Buildings.add_child(new_tower, true) # readable name används när den raderas
	BuildingLayer.set_cell(build_tile, 0, Vector2i(0,0))
	spend_resource()


func delete_tower(building_id:String, is_wall: bool = false):
	var building = $WorldMap/Buildings.get_node(building_id)
	if ! is_instance_valid(building):
		return
	var building_cell = $WorldMap/BuildingLayer.local_to_map(building.global_position)
	
	var building_type = building.building_name
	buildings[building_type] -= 1
	if buildings[building_type] < possible_builds[building_type]:
			ui.re_enable_button(building_type)
	
	building.queue_free()
	$WorldMap/BuildingLayer.erase_cell(building_cell)
	if is_wall:
		WallLayer.set_cells_terrain_connect([building_cell], 0, -1) # erase_cell fungerade inte då det blev problem med att cellerna runt inte uppdaterade sig


###### INVENTORY FUNKCTIONS ########
func _gain_resource(type:String, amount):
	inventory[type] += amount
	ui.update_inventory()


func spend_resource():
	var cost = GameData.return_tower_cost(build_type)
	for resource in cost:
		inventory[resource] -= cost[resource]
	ui.update_inventory()


func enough_resources():
	var cost = GameData.return_tower_cost(build_type)
	for resource in cost:
		if inventory[resource] < cost[resource]:
			return false
	return true

func spend_resource_upgrade(cost: Dictionary):
	for resource in cost:
		inventory[resource] -= cost[resource]
	ui.update_inventory()

func enough_resources_upgrade(upgrade_cost: Dictionary):
	for resource in upgrade_cost:
		if inventory[resource] < upgrade_cost[resource]:
			return false
	spend_resource_upgrade(upgrade_cost)
	return true

###### BUILDING CHECK ##############

func check_building_validity():
	for building in possible_builds:
		if possible_builds[building] <= buildings[building]:
			ui.disable_button(building)


########## Signals #################
func register_single_mineable(mineable: Mineable):
	mineable.add_resource.connect(_gain_resource)

############

func game_lost():
	# ):
	get_tree().paused = true
	if is_instance_valid(ui.pause_menue):
		ui.pause_menue.queue_free()
	lose_screen.visible = true
	ui.lost()

func game_won():
	# (:
	get_tree().paused= true
	if is_instance_valid(ui.pause_menue):
		ui.pause_menue.queue_free()
	win_screen.visible = true
