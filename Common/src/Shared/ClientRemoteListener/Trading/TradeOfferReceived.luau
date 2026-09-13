local Trading = require(game:GetService("ReplicatedStorage").Shared.UI.Logic.Trading)

local Remote = {}

function Remote:Activate(offer)
	Trading.OnOfferReceived(offer)
end

return Remote
