local EventBus = {}

local Listeners: { [string]: { { Callback: (...any) -> (), Priority: number, ID: number } } } = {}
local NextID = 0

local function sortListeners(eventName: string)
	table.sort(Listeners[eventName], function(a, b)
		return a.Priority > b.Priority
	end)
end

function EventBus:Subscribe(eventName: string, callback: (...any) -> (), priority: number?): () -> ()
	if not Listeners[eventName] then
		Listeners[eventName] = {}
	end

	NextID += 1
	local ID = NextID

	table.insert(Listeners[eventName], {
		Callback = callback,
		Priority = priority or 0,
		ID = ID,
	})

	sortListeners(eventName)

	return function()
		EventBus:Unsubscribe(eventName, ID)
	end
end

function EventBus:Unsubscribe(eventName: string, id: number)
	local list = Listeners[eventName]
	if not list then
		return
	end

	for index, entry in list do
		if entry.ID == id then
			table.remove(list, index)
			break
		end
	end
end

function EventBus:Fire(eventName: string, ...: any)
	local list = Listeners[eventName]
	if not list then
		return
	end

	for _, entry in table.clone(list) do
		entry.Callback(...)
	end
end

function EventBus:Clear(eventName: string)
	Listeners[eventName] = nil
end

return EventBus
