local QuestDatabase = {}

QuestDatabase.Quests = {
	{
		id = "quest_01",
		name = "A New Arrival",
		giver = "Aldric",
		level = 1,
		description = "Prove your worth by gathering basic supplies for the village of Thornhold.",
		objectives = {
			{ type = "gather", item = "Copper Ore", amount = 5, label = "Mine 5 Copper Ore" },
			{ type = "gather", item = "Oak Log", amount = 5, label = "Chop 5 Oak Logs" },
			{ type = "gather", item = "Raw Shrimp", amount = 5, label = "Catch 5 Shrimp" },
		},
		rewards = {
			xp = {
				Mining = 600,
				Woodcutting = 600,
				Fishing = 600,
			},
			gold = 500,
			items = { "Copper Sword", "Bronze Helmet" },
		},
		nextQuest = "quest_02",
		choices = nil,
		dialog = {
			start = "Welcome to Thornhold, stranger. We could use an extra pair of hands. Bring me some copper ore, oak logs, and shrimp — prove you can pull your weight around here.",
			progress = "Still working on those supplies? We need all five of each before I can trust you with anything bigger.",
			complete = "Well done! You've got grit. Take this sword and helmet — you've earned them. Speak with Brother Elden at the chapel when you're ready for more.",
		},
	},

	{
		id = "quest_02",
		name = "The Restless Dead",
		giver = "Brother Elden",
		level = 5,
		description = "Skeletons have risen in the old cemetery. Put them to rest and consult the hermit Morath.",
		objectives = {
			{ type = "kill", target = "Skeleton", amount = 10, label = "Destroy 10 Skeletons" },
			{ type = "talk", target = "Morath", label = "Speak with Morath the Hermit" },
		},
		rewards = {
			xp = {
				Strength = 1500,
				Defense = 600,
			},
			gold = 1000,
			items = {},
		},
		nextQuest = "quest_03",
		choices = nil,
		dialog = {
			start = "The dead do not sleep, friend. Skeletons claw their way from the cemetery each night. Destroy ten of them, then seek out Morath in his cave — he may know the source of this darkness.",
			progress = "The bones still rattle in the night. Finish the job and find Morath.",
			complete = "Morath spoke of a dark energy seeping from the wilderness. Thank the Light you're here. Take this gold and steel yourself for what lies ahead.",
		},
	},

	{
		id = "quest_03",
		name = "Into the Wilderness",
		giver = "Scout Wren",
		level = 10,
		description = "Scout the dangerous wilderness beyond Thornhold and deal with the goblin menace.",
		objectives = {
			{ type = "visit", location = "Darkwood Clearing", label = "Visit Darkwood Clearing" },
			{ type = "visit", location = "Broken Bridge", label = "Visit the Broken Bridge" },
			{ type = "visit", location = "Goblin Camp", label = "Visit the Goblin Camp" },
			{ type = "kill", target = "Goblin", amount = 5, label = "Kill 5 Goblins" },
		},
		rewards = {
			xp = {
				Strength = 1200,
				Defense = 900,
			},
			gold = 1500,
			items = { "Wooden Shield" },
		},
		nextQuest = "quest_04",
		choices = nil,
		dialog = {
			start = "The wilderness is crawling with goblins and worse. I need you to scout three key locations and thin out their numbers. Take this shield when you're done — you'll need it.",
			progress = "You haven't finished scouting yet. Check all three locations and clear those goblins.",
			complete = "Excellent report. The goblins are more organized than I feared. Take this shield — a witch in the swamp may know more about what's stirring them up.",
		},
	},

	{
		id = "quest_04",
		name = "The Witch's Bargain",
		giver = "Witch Thessaly",
		level = 15,
		description = "The swamp witch Thessaly demands rare ingredients in exchange for crucial information.",
		objectives = {
			{ type = "gather", item = "Moonpetal", amount = 3, label = "Gather 3 Moonpetals" },
			{ type = "gather", item = "Swamp Fungus", amount = 5, label = "Gather 5 Swamp Fungus" },
			{ type = "gather", item = "Serpent Scale", amount = 2, label = "Collect 2 Serpent Scales" },
		},
		rewards = {
			xp = {
				Cooking = 1500,
				Fletching = 900,
			},
			gold = 2000,
			items = {},
		},
		nextQuest = "quest_05",
		choices = nil,
		dialog = {
			start = "Oh, a visitor! How delightful. You want answers? Nothing is free, dearie. Bring me moonpetals, swamp fungus, and serpent scales. Then we'll talk.",
			progress = "Incomplete ingredients make for incomplete potions. And incomplete answers. Hurry along now.",
			complete = "Mmm, perfect. Now listen closely — bandits on the north road are working for something far darker than greed. Speak with Captain Aldric. And take this gold... you'll need supplies.",
		},
	},

	{
		id = "quest_05",
		name = "The Bandit Problem",
		giver = "Captain Aldric",
		level = 20,
		description = "Bandits block the northern trade route. Choose how to resolve the crisis.",
		objectives = {
			{ type = "travel", location = "Bandit Fortress", label = "Reach the Bandit Fortress" },
			{ type = "choice", label = "Decide: Fight or Negotiate" },
		},
		rewards = {
			gold = 3000,
			items = {},
		},
		nextQuest = "quest_06",
		choices = {
			{
				id = "fight",
				label = "Storm the Fortress",
				description = "Lead an assault on the bandit fortress. A direct approach for the strong.",
				objectives = {
					{ type = "kill", target = "Bandit", amount = 15, label = "Defeat 15 Bandits" },
					{ type = "kill", target = "Bandit Chief", amount = 1, label = "Defeat the Bandit Chief" },
				},
				rewards = {
					xp = {
						Strength = 3000,
					},
				},
			},
			{
				id = "negotiate",
				label = "Negotiate a Truce",
				description = "Use cunning and diplomacy to turn the bandits into allies.",
				objectives = {
					{ type = "gather", item = "Trade Goods", amount = 10, label = "Acquire 10 Trade Goods" },
					{ type = "talk", target = "Bandit Chief", label = "Negotiate with the Bandit Chief" },
				},
				rewards = {
					xp = {
						Defense = 2400,
						Ranged = 1200,
					},
				},
			},
		},
		dialog = {
			start = "The bandits have fortified the northern pass. We can storm the fortress or try to negotiate. Your call, adventurer — but either way, that road must open.",
			progress = "The north road remains blocked. Finish what you started.",
			complete = "The road is open again. You've done Thornhold a great service. Now, there's a ghost haunting the old ruins south of here...",
		},
	},

	{
		id = "quest_06",
		name = "Echoes of Sir Aldren",
		giver = "Ghost of Sir Aldren",
		level = 25,
		description = "The restless spirit of a fallen knight begs for release — or offers forbidden power.",
		objectives = {
			{ type = "travel", location = "Aldren's Tomb", label = "Enter Aldren's Tomb" },
			{ type = "gather", item = "Soul Fragment", amount = 3, label = "Collect 3 Soul Fragments" },
			{ type = "choice", label = "Decide the knight's fate" },
		},
		rewards = {
			gold = 2000,
			items = {},
		},
		nextQuest = "quest_07",
		choices = {
			{
				id = "free",
				label = "Free the Spirit",
				description = "Reunite the soul fragments and release Sir Aldren to the afterlife.",
				objectives = {
					{ type = "interact", target = "Altar of Light", label = "Use the Altar of Light" },
				},
				rewards = {
					xp = {
						Defense = 2400,
						Smithing = 1500,
					},
				},
			},
			{
				id = "bind",
				label = "Bind His Power",
				description = "Absorb the knight's essence and claim his dark strength.",
				objectives = {
					{ type = "interact", target = "Shadow Obelisk", label = "Use the Shadow Obelisk" },
				},
				rewards = {
					xp = {
						Ranged = 2400,
						Strength = 1500,
					},
				},
			},
		},
		dialog = {
			start = "Please... I have been trapped here for centuries. My soul is shattered across this tomb. Gather the fragments and choose — set me free, or take my power for yourself.",
			progress = "The fragments... find them all. Then decide my fate.",
			complete = "It is done. Whatever you chose, the echoes have faded. Seek the Oracle in the eastern mountains — she foresaw your coming.",
		},
	},

	{
		id = "quest_07",
		name = "The Oracle's Vision",
		giver = "The Oracle",
		level = 30,
		description = "The Oracle has foreseen a great darkness. Retrieve a vision crystal and prove your strength against shadow wraiths.",
		objectives = {
			{ type = "gather", item = "Vision Crystal", amount = 1, label = "Retrieve the Vision Crystal" },
			{ type = "kill", target = "Shadow Wraith", amount = 8, label = "Destroy 8 Shadow Wraiths" },
			{ type = "talk", target = "The Oracle", label = "Return to the Oracle" },
		},
		rewards = {
			xp = {
				Ranged = 1800,
				Defense = 1200,
				Strength = 1500,
			},
			gold = 3000,
			items = {},
		},
		nextQuest = "quest_08",
		choices = nil,
		dialog = {
			start = "I have seen you in my visions, child. A dragon stirs beneath the mountain. Bring me a vision crystal from the Whispering Caves and cleanse the wraiths that guard it.",
			progress = "The shadows grow restless. You must hurry.",
			complete = "The crystal confirms my fears. A dragon wakes, and a necromancer feeds it souls. You must cross the Dark Waters to reach the Dragon's Spine. Seek the ferryman Charon.",
		},
	},

	{
		id = "quest_08",
		name = "Crossing the Dark Waters",
		giver = "Charon",
		level = 35,
		description = "Pay the ferryman and survive the crossing of the cursed sea.",
		objectives = {
			{ type = "pay", amount = 5000, label = "Pay Charon 5,000 Gold" },
			{ type = "kill", target = "Sea Serpent", amount = 1, label = "Slay the Sea Serpent" },
		},
		rewards = {
			xp = {
				Strength = 2400,
				Fishing = 1200,
			},
			gold = 4000,
			items = {},
		},
		nextQuest = "quest_09",
		choices = nil,
		dialog = {
			start = "You wish to cross? The waters are cursed, and a serpent guards the passage. Pay my fee of five thousand gold, and I will ferry you — but you must deal with the beast yourself.",
			progress = "The serpent still lives. I won't move this boat until the waters are safe.",
			complete = "Impressive. The serpent is slain and the crossing is clear. The Dragon's Spine awaits you on the far shore. Seek the ranger Lyra — she knows the mountain paths.",
		},
	},

	{
		id = "quest_09",
		name = "The Dragon's Spine",
		giver = "Lyra",
		level = 40,
		description = "Climb the treacherous Dragon's Spine mountain and defeat the necromancer who feeds the dragon.",
		objectives = {
			{ type = "visit", location = "Lower Ridge", label = "Reach the Lower Ridge" },
			{ type = "visit", location = "Frozen Pass", label = "Cross the Frozen Pass" },
			{ type = "visit", location = "Summit Plateau", label = "Reach the Summit" },
			{ type = "kill", target = "Necromancer Valkor", amount = 1, label = "Defeat Necromancer Valkor" },
		},
		rewards = {
			xp = {
				Strength = 4500,
				Smithing = 1500,
				Ranged = 1500,
			},
			gold = 8000,
			items = {},
		},
		nextQuest = "quest_10",
		choices = nil,
		dialog = {
			start = "The necromancer Valkor sits atop the Dragon's Spine, channeling souls into the sleeping dragon. We must climb the mountain and stop him before the ritual completes.",
			progress = "Keep climbing. Valkor must be stopped before the dragon fully wakes.",
			complete = "Valkor is dead, but we're too late — the dragon stirs. This is it, adventurer. The final battle. Are you ready?",
		},
	},

	{
		id = "quest_10",
		name = "The Dragon Awakens",
		giver = "Lyra",
		level = 45,
		description = "The ancient dragon has awakened. Face it and decide the fate of the realm.",
		objectives = {
			{ type = "travel", location = "Dragon's Lair", label = "Enter the Dragon's Lair" },
			{ type = "choice", label = "Choose your destiny" },
		},
		rewards = {
			gold = 25000,
			items = {},
		},
		nextQuest = nil,
		choices = {
			{
				id = "slay",
				label = "Slay the Dragon",
				description = "End the dragon's threat forever with blade and fury.",
				objectives = {
					{ type = "kill", target = "Ancient Dragon", amount = 1, label = "Slay the Ancient Dragon" },
				},
				rewards = {
					xp = {
						Strength = 15000,
					},
				},
			},
			{
				id = "bond",
				label = "Bond with the Dragon",
				description = "Forge a soul-bond with the dragon, turning ancient fury into an eternal alliance.",
				objectives = {
					{ type = "interact", target = "Dragon Soul Altar", label = "Perform the Bonding Ritual" },
					{ type = "kill", target = "Shadow Echo", amount = 5, label = "Defeat 5 Shadow Echoes" },
				},
				rewards = {
					xp = {
						Ranged = 9000,
						Defense = 6000,
					},
				},
			},
		},
		dialog = {
			start = "This is it. The dragon is awake, and only you can face it. You can try to slay the beast... or there is an ancient ritual that could bond your soul to it. Either path will decide the fate of the realm.",
			progress = "The dragon waits. There is no turning back now.",
			complete = "It's over. Whatever you chose, the realm will never forget what you've done. You are a legend now, adventurer. Welcome to the end of your story — and the beginning of your legacy.",
		},
	},
}

-- Build lookup by quest id
QuestDatabase.ById = {}
for _, quest in QuestDatabase.Quests do
	QuestDatabase.ById[quest.id] = quest
end

return QuestDatabase
