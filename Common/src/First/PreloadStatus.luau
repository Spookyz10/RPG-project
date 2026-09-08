local PreloadStatus = {}

local Completed = false
local CompletedEvent = Instance.new("BindableEvent")

function PreloadStatus:MarkComplete()
	if Completed then
		return
	end
	Completed = true
	CompletedEvent:Fire()
end

function PreloadStatus:WaitUntilReady()
	if Completed then
		return
	end
	CompletedEvent.Event:Wait()
end

return PreloadStatus
