local PreloadStatus = {}

local Completed = false
local CompletedEvent = Instance.new("BindableEvent")
local LoadingClosed = false
local LoadingClosedEvent = Instance.new("BindableEvent")

function PreloadStatus:MarkLoadingClosed()
	if LoadingClosed then return end
	LoadingClosed = true
	LoadingClosedEvent:Fire()
end

function PreloadStatus:WaitUntilLoadingClosed()
	if LoadingClosed then return end
	LoadingClosedEvent.Event:Wait()
end

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
