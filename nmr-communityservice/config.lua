Config = {}

Config.Services = {
    {
		type = 'cleaning',
        item = 'prop_tool_broom', --service item
		itempos = vector3(360.0, 360.0, 0.0), --position of the item while in the player's hand
		animation = { -- animation infos, if not scenario
			mom = 'idle_a',
			child = 'amb@world_human_janitor@male@idle_a',
		},
		scenario = nil, -- scenario infos, if not animation
		eventtime = 10000, -- animation or scenario time (second * 10000) Ex: anim = 5 second, eventtime = 5000
		servicelocation = vector3(170.43, -990.7, 30.09), --  Teleport Area when add community service
        areas = { -- Mission areas
			vector3(170.0, -1006.0, 29.34),
			vector3(177.0, -1007.94, 29.33),
			vector3(181.58, -1009.46, 29.34),
			vector3(189.33, -1009.48, 29.34),
			vector3(195.31, -1016.0, 29.34),
			vector3(169.97, -1001.29, 29.34),
			vector3(164.74, -1008.0, 29.43),
			vector3(163.28, -1000.55, 29.35),
        },
    },
	{
		type = 'gardening',
        item = 'bkr_prop_coke_spatula_04',
		itempos = vector3(190.0, 190.0, -50.0),
		animation = nil,
		scenario = 'world_human_gardener_plant',
		eventtime = 10000,
		servicelocation = vector3(170.43, -990.7, 30.09),
        areas = {
            vector3(181.38, -1000.05, 29.29),
			vector3(188.43, -1000.38, 29.29),
			vector3(194.81, -1002.0, 29.29),
			vector3(198.97, -1006.85, 29.29),
			vector3(201.47, -1004.37, 29.29),
        },
    }
}

Config.Uniforms = {
	prison_wear = {
		male = {
			['t-shirt'] = {item = 1,	texture = 0},
			['torso2']  = {item = 1,	texture = 0},
			['decals'] = {item = 0,   texture = 0},
			['arms']     = {item = 119, texture = 0},
			['pants']  = {item = 7,	texture = 0},
			['shoes']  = {item = 12,	texture = 0},
		},
		female = {
			['t-shirt'] = {item = 2,  texture = 0},
			['torso2']  = {item = 54,	texture = 0},
			['decals'] = {item = 0,   texture = 0},
			['arms']     = {item = 166, texture = 0},
			['pants']  = {item = 1,	texture = 0},
			['shoes']  = {item = 3,	texture = 0},
		}
	}
}