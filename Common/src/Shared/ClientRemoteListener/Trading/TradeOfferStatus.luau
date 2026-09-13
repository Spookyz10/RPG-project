local Trading = require(game:GetService("ReplicatedStorage").Shared.UI.Logic.Trading)

local Remote = {}

function Remote:Activate(offerId: string, status: string, reason: string)
	Trading.OnOfferStatus(offerId, status, reason)
end

return Remote
