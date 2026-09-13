local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Definitions = require(script.Parent.PassiveBehaviors)
local Events = require(script.Parent.EventBus)
local Functions = require(ReplicatedStorage.Shared.Utils.Functions)

local Passives = {}
local states = setmetatable({}, { __mode = "k" })
local listeners = setmetatable({}, { __mode = "k" })

function Passives:Clear(character: Model)
	local state = states[character]
	if not state then return end
	for id, entry in state do
		local definition = Definitions[id]
		if definition.OnUnequip then definition.OnUnequip(character, entry.Data) end
	end
	states[character] = nil
end

function Passives:Get(character: Model, data)
	local state = states[character]
	if not state then
		state = {}
		states[character] = state
	end
	local sources = {}
	for slot, uuid in data.Equipment do
		local item = Functions:GetItemInfo(data.Inventory[uuid])
		local id = item and item.Passive
		if id and Definitions[id] then
			sources[id] = sources[id] or {}
			table.insert(sources[id], slot .. ":" .. uuid)
		end
	end
	for id, entry in state do
		if not sources[id] then
			local definition = Definitions[id]
			if definition.OnUnequip then definition.OnUnequip(character, entry.Data) end
			state[id] = nil
		end
	end
	local active = {}
	for id, equippedSources in sources do
		table.sort(equippedSources)
		local source = table.concat(equippedSources, "|")
		local definition = Definitions[id]
		local entry = state[id]
		if not entry or entry.Source ~= source then
			if entry and definition.OnUnequip then definition.OnUnequip(character, entry.Data) end
			entry = { Source = source, Data = {} }
			state[id] = entry
			if definition.OnEquip then definition.OnEquip(character, entry.Data) end
		end
		table.insert(active, { ID = id, Definition = definition, State = entry.Data })
	end
	table.sort(active, function(a, b)
		local aPriority = a.Definition.Priority or 0
		local bPriority = b.Definition.Priority or 0
		return aPriority > bPriority or (aPriority == bPriority and a.ID < b.ID)
	end)
	return active
end

function Passives:Run(active, hook: string, context)
	for _, entry in active do
		local callback = entry.Definition[hook]
		if callback then callback(context, entry.State) end
	end
end

function Passives:Listen(player: Player, data)
	if listeners[player] then return end
	local connections = {}
	listeners[player] = connections
	local function refresh()
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			self:Get(character, data())
		elseif character then
			self:Clear(character)
		end
	end
	local equipmentConnection = data.Equipment.Changed(refresh)
	if equipmentConnection then table.insert(connections, equipmentConnection) end
	table.insert(connections, player.CharacterAdded:Connect(function(character)
		task.spawn(function()
			character:WaitForChild("Humanoid")
			if player.Character == character then refresh() end
		end)
	end))
	table.insert(connections, player.CharacterRemoving:Connect(function(character)
		self:Clear(character)
	end))
	if player.Character then refresh() end
end

function Passives.OnPlayerRemoved(player: Player)
	local connections = listeners[player]
	if connections then
		for _, connection in connections do connection:Disconnect() end
	end
	listeners[player] = nil
	if player.Character then Passives:Clear(player.Character) end
end

Events:Subscribe("BeforeAttack", function(context) Passives:Run(context.AttackerPassives, "BeforeAttack", context) end)
Events:Subscribe("BeforeIncomingDamage", function(context) Passives:Run(context.DefenderPassives, "BeforeIncomingDamage", context) end)
Events:Subscribe("HitConfirmed", function(context) Passives:Run(context.AttackerPassives, "OnHitConfirmed", context) end)
Events:Subscribe("HitApplied", function(context)
	Passives:Run(context.AttackerPassives, "AfterHit", context)
	Passives:Run(context.DefenderPassives, "AfterDamageReceived", context)
end)

return Passives
