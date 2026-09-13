local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ViewportCache = require(script.Parent.ViewportCache)

local Preview = {}
local connections: { [ViewportFrame]: RBXScriptConnection } = {}
setmetatable(connections, { __mode = "k" })

function Preview.Show(viewport: ViewportFrame, name: string)
	local previous = connections[viewport]
	if previous then
		previous:Disconnect()
		connections[viewport] = nil
	end
	local world = viewport:FindFirstChild("World") :: WorldModel?
	if not world then
		world = Instance.new("WorldModel")
		world.Name = "World"
		world.Parent = viewport
	end
	local camera = viewport:FindFirstChild("Camera") :: Camera?
	if not camera then
		camera = Instance.new("Camera")
		camera.Name = "Camera"
		camera.FieldOfView = 35
		camera.Parent = viewport
	end
	world:ClearAllChildren()
	local folder = ReplicatedStorage:FindFirstChild("Mobs")
	local source = folder and folder:FindFirstChild(name, true)
	local unavailable = not source or not source:IsA("Model")
	local missing = viewport:FindFirstChild("Missing")
	if missing and missing:IsA("GuiObject") then
		missing.Visible = unavailable
	end
	if unavailable then
		return
	end

	local model = ViewportCache.GetModel(source :: Model)
	model.Parent = world
	model:PivotTo(CFrame.identity)
	local bounds, size = model:GetBoundingBox()
	viewport.CurrentCamera = camera

	local function frame()
		ViewportCache.Fit(viewport, model, camera, 1.08, bounds, size, Vector3.new(0.55, 0.25, -1))
	end

	frame()
	local connection = viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(frame)
	connections[viewport] = connection
	viewport.Destroying:Once(function()
		connection:Disconnect()
		if connections[viewport] == connection then
			connections[viewport] = nil
		end
	end)
end

return Preview
