local Toast = require(game:GetService("ReplicatedStorage").Shared.UI.Toast)
local Remote = {}

function Remote:Activate(message)
	Toast.Show(message)
end

return Remote
