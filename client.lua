local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

-- QBCore Initialization
Citizen.CreateThread(function()
    while QBCore == nil do
        Citizen.Wait(10)
    end
    PlayerData = QBCore.Functions.GetPlayerData() -- Get player data when script is loaded
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData() -- Update player data when player is loaded
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job -- Update job when the player's job is updated
end)

RegisterNetEvent('seerecord:open')
AddEventHandler('seerecord:open', function()
	QBCore.Functions.TriggerCallback('jomidar-criminalrecord:fetch', function(d)
		SetNuiFocus(true, true)
		SendNUIMessage({
			action = "open",
			array  = d
		})
	end,  data, 'start')			
end)

Citizen.CreateThread(function()
	if Config.Target then 
		exports['qb-target']:AddBoxZone("policerecord", Config.Loc, 1.0, 1.0, { 
		name = "policerecord",
		heading = 0,
		debugPoly = false, 
		minZ = Config.Loc.z - 1.0, -- Adjust based on your needs
		maxZ = Config.Loc.z + 1.0, -- Adjust based on your needs
	}, {
		options = {
			{
				label = "Record",
				icon = "fas fa-book", -- Icon for the interaction (optional)
				job = Config.Job, -- Restrict access to specific jobs
				action = function()
					TriggerEvent('seerecord:open')
				end,
			},
		},
		distance = 2.0
	})
	else
	exports.interact:AddInteraction({
		coords = Config.Loc,
		distance = 4.0, 
		interactDst = 2.0, 
		id = 'policerecord', 
		name = 'policerecord', 
		groups = {
			[Config.Job] = 0,
		},
		options = {
			 {
				label = 'See Record',
				action = function(entity, coords, args)
					QBCore.Functions.TriggerCallback('jomidar-criminalrecord:fetch', function(d)
						SetNuiFocus(true, true)
						SendNUIMessage({
							action = "open",
							array  = d
						})
					end,  data, 'start')			
				end,
			},
		}
	})   
end 
end)

-- NUI Callback - Close
RegisterNUICallback('escape', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- NUI Callback - Fetch
RegisterNUICallback('fetch', function(data, cb)
    QBCore.Functions.TriggerCallback('jomidar-criminalrecord:fetch', function(d)
        cb(d)
    end, data, data.type)
end)

-- NUI Callback - Search
RegisterNUICallback('search', function(data, cb)
    QBCore.Functions.TriggerCallback('jomidar-criminalrecord:search', function(d)
        cb(d)
    end, data)
end)

-- NUI Callback - Add
RegisterNUICallback('add', function(data, cb)
    QBCore.Functions.TriggerCallback('jomidar-criminalrecord:add', function(d)
        cb(d)
    end, data)
end)

-- NUI Callback - Update
RegisterNUICallback('update', function(data, cb)
    QBCore.Functions.TriggerCallback('jomidar-criminalrecord:update', function(d)
        cb(d)
    end, data)
end)

-- NUI Callback - Remove
RegisterNUICallback('remove', function(data, cb)
    QBCore.Functions.TriggerCallback('jomidar-criminalrecord:remove', function(d)
        cb(d)
    end, data)
end)
