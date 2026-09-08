-- Executed by verify_ui.py, which prepends the current shared-module sources.
-- Models Instance hierarchy/events and replicated data; does not emulate rendering/physics.
local function signal()
	local listeners = {}
	return {
		Connect = function(_, callback)
			local connection = { Connected = true }
			function connection:Disconnect() self.Connected = false end
			table.insert(listeners, { callback, connection })
			return connection
		end,
		Fire = function(_, ...)
			for _, entry in table.clone(listeners) do if entry[2].Connected then entry[1](...) end end
		end,
	}
end

local function enumGroup(group)
	return setmetatable({}, { __index = function(t, key)
		local item = { Name = key, EnumType = group }
		rawset(t, key, item)
		return item
	end })
end
local Enum = setmetatable({}, { __index = function(t, key) local g = enumGroup(key); rawset(t, key, g); return g end })
local UDim = { new = function(s, o) return { Scale = s, Offset = o } end }
local UDim2 = {}
function UDim2.new(xs, xo, ys, yo) return { X = UDim.new(xs or 0, xo or 0), Y = UDim.new(ys or 0, yo or 0) } end
function UDim2.fromScale(x, y) return UDim2.new(x, 0, y, 0) end
function UDim2.fromOffset(x, y) return UDim2.new(0, x, 0, y) end
local Vector2 = { new = function(x, y) return { X = x, Y = y } end }
local vector3Meta = { __add = function(a, b) return { X = a.X + b.X, Y = a.Y + b.Y, Z = a.Z + b.Z } end }
local Vector3 = { new = function(x, y, z) return setmetatable({ X = x, Y = y, Z = z }, vector3Meta) end }
local CFrame = { Angles = function() return {} end, lookAt = function(position, target) return { Position = position, Target = target } end }
local Color3 = { fromRGB = function(r, g, b) return { R = r / 255, G = g / 255, B = b / 255 } end }
local ColorSequence = { new = function(...) return { ... } end }
local ColorSequenceKeypoint = { new = function(...) return { ... } end }
local inherited = {
	Frame = "GuiObject", ScrollingFrame = "GuiObject", TextLabel = "GuiObject", TextBox = "GuiObject",
	TextButton = "GuiButton", ImageButton = "GuiButton", ImageLabel = "GuiObject", ViewportFrame = "GuiObject", GuiButton = "GuiObject",
	ScreenGui = "LayerCollector", BillboardGui = "LayerCollector",
}
local methods = {}
local Instance = {}
local viewport = Vector2.new(1280, 720)
function methods:IsA(class)
	local current = self.ClassName
	while current do if current == class then return true end; current = inherited[current] end
	return class == "Instance"
end
function methods:GetChildren() return table.clone(self._children) end
function methods:GetDescendants()
	local result = {}
	for _, child in self._children do
		table.insert(result, child)
		for _, descendant in child:GetDescendants() do table.insert(result, descendant) end
	end
	return result
end
function methods:FindFirstChild(name, recursive)
	for _, child in self._children do if child.Name == name then return child end end
	if recursive then for _, child in self._children do local found = child:FindFirstChild(name, true); if found then return found end end end
	return nil
end
function methods:WaitForChild(name) return assert(self:FindFirstChild(name), self.Name .. " missing child " .. name) end
function methods:FindFirstChildOfClass(class)
	for _, child in self._children do if child.ClassName == class then return child end end
	return nil
end
function methods:FindFirstChildWhichIsA(class, recursive)
	for _, child in recursive and self:GetDescendants() or self._children do if child:IsA(class) then return child end end
	return nil
end
function methods:FindFirstAncestorWhichIsA(class)
	local p = self.Parent
	while p do if p:IsA(class) then return p end; p = p.Parent end
	return nil
end
function methods:FindFirstAncestor(name)
	local p = self.Parent
	while p do if p.Name == name then return p end; p = p.Parent end
	return nil
end
function methods:SetAttribute(name, value) self._attributes[name] = value; self:GetAttributeChangedSignal(name):Fire() end
function methods:GetAttribute(name) return self._attributes[name] end
function methods:GetAttributeChangedSignal(name)
	self._signals["attr:" .. name] = self._signals["attr:" .. name] or signal()
	return self._signals["attr:" .. name]
end
function methods:GetPropertyChangedSignal(name)
	self._signals[name] = self._signals[name] or signal()
	return self._signals[name]
end
function methods:Destroy()
	self.Destroying:Fire()
	for _, child in self:GetChildren() do child:Destroy() end
	self.Parent = nil
end
function methods:Clone()
	local clone = Instance.new(self.ClassName)
	for key, value in self._properties do if key ~= "Parent" then clone[key] = value end end
	for key, value in self._attributes do clone:SetAttribute(key, value) end
	for _, child in self._children do child:Clone().Parent = clone end
	return clone
end
function Instance.new(class)
	local object = { _properties = { ClassName = class, Name = class }, _children = {}, _attributes = {}, _signals = {} }
	setmetatable(object, {
		__index = function(self, key)
			if methods[key] then return methods[key] end
			if key == "IgnoreGuiInset" then return false end
			if key == "AbsolutePosition" then
				if self:IsA("LayerCollector") or self.ClassName == "PlayerGui" then return Vector2.new(0, 0) end
				local parentSize = self.Parent.AbsoluteSize
				local origin = self.Parent.AbsolutePosition
				local anchor = self._properties.AnchorPoint or Vector2.new(0, 0)
				return Vector2.new(origin.X + self.Position.X.Scale * parentSize.X + self.Position.X.Offset - anchor.X * self.AbsoluteSize.X, origin.Y + self.Position.Y.Scale * parentSize.Y + self.Position.Y.Offset - anchor.Y * self.AbsoluteSize.Y)
			end
			if key == "AbsoluteSize" then
				if self:IsA("LayerCollector") or self.ClassName == "PlayerGui" then return viewport end
				local parent = self.Parent and self.Parent.AbsoluteSize or viewport
				local size = self.Size or UDim2.new()
				local result = Vector2.new(parent.X * size.X.Scale + size.X.Offset, parent.Y * size.Y.Scale + size.Y.Offset)
				local bounds = self:FindFirstChildOfClass("UISizeConstraint")
				if bounds then result.X = math.min(result.X, bounds.MaxSize.X); result.Y = math.min(result.Y, bounds.MaxSize.Y) end
				return result
			end
			if self._properties[key] ~= nil then return self._properties[key] end
			if key == "Parent" then return nil end
			if key == "MouseEnter" or key == "MouseLeave" or key == "SelectionGained" or key == "SelectionLost" or key == "CharacterAppearanceLoaded" or key == "Activated" or key == "InputBegan" or key == "InputEnded" or key == "Destroying" or key == "DescendantAdded" or key == "ChildAdded" or key == "ChildRemoved" or key == "CharacterAdded" or key == "Changed" or key == "PlayerAdded" or key == "PlayerRemoving" then
				self._signals[key] = self._signals[key] or signal(); return self._signals[key]
			end
			local child = self:FindFirstChild(key)
			if child then return child end
			error(self.ClassName .. " " .. self.Name .. ": unknown property/child " .. tostring(key), 2)
		end,
		__newindex = function(self, key, value)
			local old = self._properties[key]
			if key == "Parent" and old ~= value then
				if old then local i = table.find(old._children, self); if i then table.remove(old._children, i) end end
				self._properties.Parent = value
				if value then
					table.insert(value._children, self)
					local p = value
					while p do
						p.DescendantAdded:Fire(self)
						for _, descendant in self:GetDescendants() do p.DescendantAdded:Fire(descendant) end
						p = p.Parent
					end
				end
			else self._properties[key] = value end
			if old ~= value and self._signals[key] then self._signals[key]:Fire() end
		end,
	})
	if object:IsA("GuiObject") then
		object.Visible = true; object.Active = object:IsA("GuiButton"); object.Size = UDim2.new(); object.Position = UDim2.new()
		object.AnchorPoint = Vector2.new(0, 0); object.BackgroundTransparency = 0; object.LayoutOrder = 0; object.ZIndex = 1
	end
	if class == "TextLabel" or class == "TextBox" or class == "TextButton" then object.Text = "" end
	if class == "ImageLabel" or class == "ImageButton" then object.Image = "" end
	if object:IsA("LayerCollector") then object.Enabled = true end
	return object
end

local function folder(parent, name, class)
	local object = Instance.new(class or "Folder"); object.Name = name; object.Parent = parent; return object
end
local services = {}
local game = { GetService = function(_, name) return assert(services[name], "Missing service " .. name) end }
local rs = folder(nil, "ReplicatedStorage")
services.ReplicatedStorage = rs
local shared = folder(rs, "Shared")
local gui = folder(nil, "PlayerGui", "PlayerGui")
local players = folder(nil, "Players")
services.Players = players
local player = folder(players, "Tester", "Player")
player.DisplayName = "Aster"; player.UserId = 123; player.Character = false
gui.Parent = player
players.LocalPlayer = player
players.GetPlayers = function() return { player } end
players.GetUserThumbnailAsync = function() return "" end
local avatarRequests = 0
local resources = folder(rs, "Resources")
folder(resources, "Weapons")
folder(resources, "Animations")
players.CreateHumanoidModelFromUserIdAsync = function(_, userId)
	assert(userId == player.UserId)
	avatarRequests += 1
	local model = Instance.new("Model")
	model.PivotTo = function() end
	model.GetBoundingBox = function() return { Position = Vector3.new(0, 0, 0) }, Vector3.new(4, 6, 2) end
	return model
end
local stats = folder(player, "PublicStats")
folder(stats, "Level", "NumberValue").Value = 25
folder(stats, "Honor", "NumberValue").Value = 0
services.RunService = { IsClient = function() return true end, IsRunning = function() return false end, RenderStepped = signal() }
services.StarterGui = folder(nil, "StarterGui")
services.ServerStorage = folder(nil, "ServerStorage")
services.Selection = { Set = function() end }
services.ChangeHistoryService = { TryBeginRecording = function() return "test-recording" end, FinishRecording = function() end }
services.GuiService = { GetGuiInset = function() return Vector2.new(0, 36) end }
services.UserInputService = { TouchEnabled = false, MouseEnabled = true, InputBegan = signal(), GetMouseLocation = function() return Vector2.new(400, 200) end }
services.Debris = { AddItem = function() end }
services.TweenService = { Create = function(_, object, _, properties) return { Play = function() for k, v in properties do object[k] = v end end, Cancel = function() end } end }
local workspace = folder(nil, "Workspace")
local modules = {}
for name in sources do
	local parts = string.split(name, "/")
	local parent = shared
	for index, part in parts do
		local object = parent:FindFirstChild(part) or folder(parent, part)
		if index == #parts then object.ClassName = "ModuleScript"; modules[name] = object end
		parent = object
	end
end

local changes = {}
local state = {
	Level = 25, XP = 50, Equipment = { Weapon = "", Armor = "", Ring = "", Necklace = "", Aura = "", Rune = "" },
	Vanity = { Weapon = "", Aura = "" }, Skills = { Q = "", E = "", R = "" },
	Inventory = {
		sword = { ID = "Paper Sword", Name = "Paper Sword", Amount = 1 },
		potions = { ID = "Small Health Potion", Name = "Small Health Potion", Amount = 8 },
	},
	Storage = { stored = { ID = "Small Health Potion", Name = "Small Health Potion", Amount = 3 } },
	CurrentInventorySpace = 2, MaxInventorySpace = 100, CurrentStorageSpace = 1, MaxStorageSpace = 100,
	Currencies = { Gold = 500, ["Raid Coins"] = 0, Tokens = 0, ["Rune Crystals"] = 0 },
	RaidAutoDelete = {}, RaidRecords = {}, RaidRuns = {}, Quests = {}, CompletedQuests = {},
}
local function dataNode(path)
	local function read()
		local value = state
		for _, key in path do value = value and value[key] end
		return value
	end
	local id = table.concat(path, ".")
	changes[id] = changes[id] or signal()
	return setmetatable({}, {
		__call = function(_, value)
			if value == nil then return read() end
			local parent = state
			for i = 1, #path - 1 do parent = parent[path[i]] end
			parent[path[#path]] = value
			changes[id]:Fire(value)
		end,
		__index = function(_, key)
			if key == "Changed" then return function(callback) return changes[id]:Connect(callback) end end
			if key == "OnKeyAdded" or key == "OnKeyRemoved" then return function() end end
			local nested = table.clone(path); table.insert(nested, key); return dataNode(nested)
		end,
	})
end
local data = dataNode({})
local calls = {}
local remotes = { SendServerEvent = function(...) table.insert(calls, { ... }) end, InvokeServerFunction = function() return nil end }
local overrides = {
	[modules.Data] = { client = data },
	[modules["Utils/RemoteManager"]] = remotes,
	[modules.LightingManager] = { Apply = function() end, ResetToDefault = function() end },
	[modules.MusicManager] = { PlayZone = function() end, PlayLobby = function() end },
	[modules["Utils/Functions"]] = { FormatTime = tostring, GetXPNeeded = function() return 100 end, GetTotalStats = function() return { Attack = 12, Defense = 5, Health = 100, Speed = 16, Critical = 2 } end },
}
local jobs = {}
local task = { spawn = function(callback, ...) return callback(...) end, delay = function(_, callback) table.insert(jobs, callback) end, wait = function() coroutine.yield() end }
-- Typewriter/countdown coroutines are started but not timed in these contract checks.
task.spawn = function(callback, ...)
	local co = coroutine.create(callback)
	local ok, err = coroutine.resume(co, ...)
	assert(ok, err)
	return co
end
local cache = {}
local env = setmetatable({ game = game, workspace = workspace, Instance = Instance, Enum = Enum, UDim = UDim, UDim2 = UDim2, Vector2 = Vector2, Vector3 = Vector3, CFrame = CFrame, Color3 = Color3, ColorSequence = ColorSequence, ColorSequenceKeypoint = ColorSequenceKeypoint, TweenInfo = { new = function() return {} end }, task = task, warn = print }, { __index = getfenv() })
local function loadModule(module)
	if overrides[module] then return overrides[module] end
	if cache[module] then return cache[module] end
	local name
	for key, value in modules do if value == module then name = key; break end end
	assert(name, "Unknown module")
	local fn = assert(loadstring(sources[name], name))
	setfenv(fn, setmetatable({ script = module, require = loadModule }, { __index = env }))
	cache[module] = fn()
	return cache[module]
end

-- Execute the actual standalone Command Bar bundle. It must need no game modules.
local command = assert(loadstring(sources.StandaloneGenerator, "00_All"))
setfenv(command, env)
command()
local original = services.StarterGui.Inventory
for _, service in { services.StarterGui, rs.RPGUITemplates } do
	for _, object in service:GetDescendants() do
		if object:IsA("GuiObject") then
			for _, key in { "Position", "Size" } do
				local value = object[key]
				assert(value.X.Offset == 0 and value.Y.Offset == 0, object.Name .. "." .. key .. " must use Scale")
			end
			for _, key in { "WidePosition", "WideSize", "NarrowPosition", "NarrowSize" } do
				local value = object:GetAttribute(key)
				assert(not value or (value.X.Offset == 0 and value.Y.Offset == 0), key .. " must use Scale")
			end
		end
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			assert(object.TextScaled, object.Name .. " must use TextScaled")
		end
	end
end
original:SetAttribute("UserEdit", "preserve this")
command()
assert(services.StarterGui.Inventory ~= original, "Generator did not replace the selected screens")
assert(original:GetAttribute("UserEdit") == "preserve this" and original.Parent.Parent == services.ServerStorage.RPGUIBackups, "Regeneration lost the user's editable UI")
assert(rs.RPGUITemplates and not services.StarterGui:FindFirstChild("RPGUITemplates"), "Templates placed in wrong service")
for _, screen in services.StarterGui:GetChildren() do screen.Parent = gui end
local bootstrap = loadModule(modules["UI/Bootstrap"])
-- Simulate personal Studio edits, including grid dimensions.
gui.Inventory.Main.Position = UDim2.fromScale(0.48, 0.49)
gui.Inventory.Main.Body.Content.Items.Container.Size = UDim2.fromScale(0.91, 0.51)
gui.Inventory.Main.Body.Content.Items.Container.UIGridLayout.CellSize = UDim2.fromScale(0.22, 0.31)
local savedGeometry = {}
for _, object in gui:GetDescendants() do
	if object:IsA("GuiObject") then
		savedGeometry[object] = { Position = object.Position, Size = object.Size }
	elseif object:IsA("UIGridLayout") then
		savedGeometry[object] = { CellSize = object.CellSize, CellPadding = object.CellPadding }
	end
end
local before = #gui:GetDescendants()
bootstrap.Ensure()
assert(#gui:GetDescendants() == before, "Bootstrap duplicated the UI")
local logic = loadModule(modules["UI/Logic"])
local windows = loadModule(modules["UI/WindowManager"])
local function last(name) local call = calls[#calls]; assert(call and call[1] == name, "Expected remote " .. name); return call end
local function click(button) assert(button:IsA("GuiButton"), "Not a button"); button.Activated:Fire() end

windows.Open("Inventory")
assert(gui.Inventory.Main.Visible and gui:GetAttribute("UIWindowOpen"))
local content = gui.Inventory.Main.Body.Content
local inv = content.Items
assert(inv.Container.sword.ItemName.Text == "Paper Sword")
for _, job in jobs do job() end
table.clear(jobs)
assert(content.Hero.Stats.Attack.Value.Text == "12", "Hero stats did not update")
assert(avatarRequests == 1, "Preview must load the user avatar once")
local cachedAvatar = content.Hero.CharacterPreview.World.HeroPreview
windows.Close()
windows.Open("Inventory")
for _, job in jobs do job() end
table.clear(jobs)
assert(avatarRequests == 1 and content.Hero.CharacterPreview.World.HeroPreview == cachedAvatar, "Reopening rebuilt cached avatar")
inv.Container.sword.MouseEnter:Fire()
assert(gui.Inventory.ItemTooltip.Visible, "Item hover did not show details")
local tooltipPosition = gui.Inventory.ItemTooltip.AbsolutePosition
assert(math.abs(tooltipPosition.X - 412) < 0.01 and math.abs(tooltipPosition.Y - 176) < 0.01, "Tooltip is not beside mouse after topbar inset")
services.RunService.RenderStepped:Fire()
assert(math.abs(gui.Inventory.ItemTooltip.AbsolutePosition.Y - 176) < 0.01, "Tooltip drifts each frame")
assert(gui.Inventory.ItemTooltip.ItemName.Text == "Paper Sword")
inv.Container.sword.MouseLeave:Fire()
assert(not gui.Inventory.ItemTooltip.Visible, "Item tooltip did not close")
click(inv.Container.sword)
assert(gui.Inventory.Main.ActionFrame.Visible)
click(gui.Inventory.Main.ActionFrame.Inner.Action)
assert(last("EquipItem")[2] == "sword")
data.Equipment({ Weapon = "sword", Armor = "", Ring = "", Necklace = "", Aura = "", Rune = "" })
click(inv.Container.sword)
click(gui.Inventory.Main.ActionFrame.Inner.Action)
assert(last("UnequipItem")[2] == "sword")
inv.Search.Text = "no such item"
assert(not inv.Container.sword.Visible and inv.Empty.Visible)
inv.Search.Text = ""
click(inv.Container.potions)
click(gui.Inventory.Main.UsableFrame.Inner["Use All"])
assert(last("UseItem")[3] == true)
click(inv.Bottom.Storage.Storage)
assert(inv.Bank.Visible)
click(inv.Container.potions)
local quantity = gui.Inventory.Main.StackMove
quantity.Text = "2"
click(quantity.TextButton)
assert(last("StorageDeposit")[3] == 2)
click(inv.Bank.ScrollingFrame.stored)
local bankQuantity = gui.Inventory.Main.BankStackMove
bankQuantity.Text = "1"
click(bankQuantity.TextButton)
assert(last("StorageWithdraw")[3] == 1)
click(inv.Container.potions)
click(quantity.Cancel)
assert(not quantity.Visible)
click(inv.Bottom.Storage.Cancel)
click(inv.Bottom.Sell.Sell)
click(inv.Container.potions)
local sellQuantity = gui.Inventory.Main.StackSell
sellQuantity.Text = "2"
click(sellQuantity.TextButton)
click(inv.Bottom.Advanced.Confirm)
assert(last("SellItem")[2].potions == 2)
click(gui.Inventory.Main.Close)
assert(not gui:GetAttribute("UIWindowOpen"))

windows.Open("SkillSelector")
click(gui.SkillSelector.Frame.Body.Content.Holder.Attack.Cyclone.Slot1)
assert(last("EquipSkill")[2] == "Cyclone")
local sent = #calls
click(gui.SkillSelector.Frame.Body.Content.Holder.Attack.Cyclone.Slot3)
assert(#calls == sent, "Locked slot sent a remote")
windows.Open("RaidsGUI")
assert(not gui.SkillSelector.Frame.Visible)
local raid = gui.RaidsGUI.Main.Body.Content.RaidContainers.RaidDisplay.Clicked
click(raid.Mode.Frame.Switch)
assert(string.find(raid.Mode.Current.Text, "Hardcore"))
click(raid.Enter)
assert(last("RaidEvent")[4] == "Hardcore")
logic.Party.OnUpdate({ Tester = true, Friend = true }, "Tester")
assert(gui.Partylist.Panel.Body.Content.Frame.Friend)
logic.Party.OnInvite("Friend", 30)
click(gui.Partylist.PartyInvite.YES)
assert(last("AcceptPartyInvite")[2] == "Friend")
logic.Party.OnLeave()
assert(gui.Partylist.Panel.Body.Content.Empty.Visible)
-- Persistent roster: local priority, descending levels, colors, Rank and card data.
assert(gui.Playerlist.ScreenInsets == Enum.ScreenInsets.DeviceSafeInsets)
click(gui.Playerlist.List.Toggle)
assert(gui.Playerlist.List.Position.X.Scale == 1.251 and gui.Playerlist.List.Position.Y.Scale == 0)
assert(gui.Playerlist.List.Toggle.Arrow.Rotation == 180)
click(gui.Playerlist.List.Toggle)
assert(gui.Playerlist.List.Visible and gui.Playerlist.List.Toggle.Arrow.Rotation == 0)
assert(gui.Playerlist.List.Position.X.Scale == 1 and gui.Playerlist.List.Position.Y.Scale == 0)
local roster = gui.Playerlist.List.Container
assert(roster.Tester.Level.Text == "Lvl 25")
local function otherPlayer(name, id, level)
	local other = folder(players, name, "Player")
	other.UserId = id; other.DisplayName = name
	folder(folder(other, "PublicStats"), "Level", "NumberValue").Value = level
	players.PlayerAdded:Fire(other)
	return other
end
local veteran = otherPlayer("Veteran", 456, 30)
local novice = otherPlayer("Novice", 789, 2)
assert(roster.Tester.LayoutOrder == 1 and roster.Veteran.LayoutOrder == 2 and roster.Novice.LayoutOrder == 3)
assert(roster.Tester.Rank:IsA("ImageLabel"))
assert(roster.Tester.PlayerName.TextColor3 == loadModule(modules["UI/Theme"]).Blue)
assert(roster.Veteran.PlayerName.TextColor3 == loadModule(modules["UI/Theme"]).Gold)
local previousInvoke = remotes.InvokeServerFunction
remotes.InvokeServerFunction = function(name, target)
	assert(name == "GetPlayerInfo" and target == player)
	return { Level = 25, Gold = 150, Kills = 10, Deaths = 2, PlayTime = 3600, SessionTime = 60, Stats = { Attack = 12 }, Equipment = {} }
end
click(roster.Tester)
assert(gui.PlayerCard.Main.Visible and gui.PlayerCard.Main.Body.Content.Record.Deaths.Value.Text == "2")
assert(gui.PlayerCard.Main.Body.Content.Record.PlayTime.Value.Text == "01:00:00")
assert(gui.PlayerCard.Main.Body.Content.Record.SessionTime.Value.Text == "00:01:00")
windows.Close()
remotes.InvokeServerFunction = previousInvoke
players.PlayerRemoving:Fire(veteran); veteran.Parent = nil
players.PlayerRemoving:Fire(novice); novice.Parent = nil
assert(not roster:FindFirstChild("Veteran"))
local dialogues = loadModule(modules.Dialogues)
logic.Dialog.Open(dialogues["Tutorial Guy"], "Tutorial Guy")
assert(logic.Dialog.IsOpen())
logic.Dialog.Close()
data.Quests({ Tutorial1 = { Objectives = { 2 } } })
assert(gui.Journal.Main.Body.Content.Container.Tutorial1.Objective1.Text == "Bushling  2 / 3")
click(gui.Journal.Main.Body.Content.Container.Tutorial1.Abandon)
click(gui.Journal.Main.Body.Content.Container.Tutorial1.Abandon)
assert(last("AbandonQuest")[2] == "Tutorial1")
logic.Shop.Open("SwordsmanShop")
assert(gui.Shop.Main.Visible)
assert(gui.Shop.Main.Body.Content.Container["Vital Jab"].Buy.Text == "Not available yet")
logic.Bars.UpdateBar(0, 0, "HP")
assert(gui.HUD.Main.HP.Main.Bar.Size.X.Scale == 0)
logic.Buffs:Start("Safeguard", 5)
assert(gui.Attack.Buffs.Safeguard)
logic.Buffs:Stop("Safeguard")
assert(not gui.Attack.Buffs:FindFirstChild("Safeguard"))

for _, size in { { 1280, 720 }, { 844, 326 }, { 390, 760 }, { 320, 568 } } do
	viewport = Vector2.new(size[1], size[2])
	services.UserInputService.TouchEnabled = size[1] < 1000
	for _, object in gui:GetDescendants() do object:GetPropertyChangedSignal("AbsoluteSize"):Fire() end
	for _, object in gui:GetDescendants() do
		if object:IsA("GuiObject") and object:GetAttribute("Window") then
			assert(object.AbsoluteSize.X <= viewport.X and object.AbsoluteSize.Y <= viewport.Y, "Window outside viewport")
		end
		if object:IsA("UIGridLayout") and object:GetAttribute("CellMinWidth") then
			assert(object.CellSize.X.Scale > 0 and object.CellSize.X.Offset == 0, "Negative grid width")
		end
	end
	for object, properties in savedGeometry do
		if object.Parent and object ~= gui.Inventory.ItemTooltip and object ~= gui.Playerlist.List and not object:FindFirstAncestor("Attack") and object.Name ~= "Bar" then
			for key, value in properties do
				assert(object[key] == value, object.Name .. "." .. key .. " overwrote Studio layout")
			end
		end
	end
	assert(content.Hero.Visible and content.Items.Visible and not content.MobileTabs.Visible, "Viewport changed saved visibility")

end
print("PASS: 19 standalone Edit generators, backup preservation, saved-UI bootstrap, hero stats, item hovers, saved layout preservation, UI initialization, inventory/equipment/search/quantities/sale, skill locks, raids, party, dialogue, journal, shop, bars, buffs, and 4 viewport sizes.")
