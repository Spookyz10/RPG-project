local RS = game:GetService("ReplicatedStorage")
local Preview = {}
function Preview.Show(viewport, name)
	local folder = RS:FindFirstChild("Mobs")
	local source = folder and folder:FindFirstChild(name, true)
	viewport.Missing.Visible = not source or not source:IsA("Model")
	if viewport.Missing.Visible then return end
	local world = Instance.new("WorldModel")
	world.Parent = viewport
	local model = source:Clone()
	for _, child in model:GetDescendants() do
		if child:IsA("BaseScript") then child:Destroy()
		elseif child:IsA("BasePart") then child.Anchored = true; child.CanCollide = false end
	end
	model.Parent = world
	model:PivotTo(CFrame.identity)
	local bounds, size = model:GetBoundingBox()
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35; camera.Parent = viewport; viewport.CurrentCamera = camera
	local function frame()
		local aspect = viewport.AbsoluteSize.X / math.max(1, viewport.AbsoluteSize.Y)
		local distance = size.Magnitude * 0.5 / math.sin(math.atan(math.tan(math.rad(17.5)) * math.min(1, aspect))) * 1.08
		camera.CFrame = CFrame.lookAt(bounds.Position + Vector3.new(0.55, 0.25, -1).Unit * distance, bounds.Position)
	end
	frame()
	local connection = viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(frame)
	viewport.Destroying:Once(function() connection:Disconnect() end)
end
return Preview
