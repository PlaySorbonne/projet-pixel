extends VBoxContainer
class_name PlayerVictoryStats

const COMMON_TITLES : Array[String] = [
	"No.1 Weeb",
	"The Chosen One",
	"I'll be back",
	"Super Sayen",
	"Luigi Numbah 2",
	"Waluigi time",
	"Zero",
	"Hokage",
	"Fullmetal Weeb",
	"Hero Killer",
	"Professor Layton",
	"Hero of Time",
	"Procrastinator",
	"Darth Weeb",
	"Pirate King",
	"Weebborn",
	"Dom Slayer",
	"Chocoboss",
	"Overcaffeinated CEO",
	"Respawn Lord",
	"Yeeted",
	"Red Shell",
	"Electric Fox",
	"Shonen Spirit",
	"Kung Fu Buffalo",
	"AFK King",
	"Beta Tester",
	"Button Masher",
	"Joystick Rider",
	"Critical Failer",
	"Energy Drinker",
	"4chan user",
	"Cosplayer",
]

const RARE_TITLES : Array[String] = [
	"Over 9000",
	"Dora la Exploradora",
	"King of Kongs",
	"The Tarnished",
	"Biggest Chocobo",
	"The Chicken Whisperer",
	"Grass-Cutting Champion",
	"Pokemon Master",
	"Min-Maxer",
	"Linux Overlord",
	"Taco Master",
	"Hero of Rhyme",
	"Memelord",
	"Scary Shiny Glasses",
	"Hentai Anthropologist",
]

const LEGENDARY_TITLES : Array[String] = [
	"The Strongest Man in the World",
	"World Champion",
	"Anilinkz Completionist",
	"Supreme Commander",
	"Decorporater",
	"Ascended",
]

func set_player_evolution(current_ev : int):
	str(PlayerCharacter.Evolutions.keys()[current_ev])
	PlayerPortrait.PLAYER_PORTRAITS[current_ev]
