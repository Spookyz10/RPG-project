local T = require(script.Parent.Theme)
local Bootstrap = require(script.Parent.Bootstrap)
local Toast = {}

function Toast.Show(message)
	local container = Bootstrap.Ensure().Notifications.Container
	local entries = {}
	for _, child in container:GetChildren() do
		if child:IsA("GuiObject") then table.insert(entries, child) end
	end
	if #entries >= 3 then entries[1]:Destroy() end
	local label = Bootstrap.GetTemplates().ToastTemplate:Clone()
	label.Name = "Message"
	label.Text = tostring(message)
	label.Parent = container
	game:GetService("Debris"):AddItem(label, 5)
end

return Toast
