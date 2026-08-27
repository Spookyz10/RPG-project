local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LightingManager = {}

local TemplatesFolder = ReplicatedStorage:WaitForChild("Resources"):WaitForChild("LightingTemplates")

local TWEENABLE_PROPERTIES = {
	"Ambient",
	"OutdoorAmbient",
	"Brightness",
	"ColorShift_Bottom",
	"ColorShift_Top",
	"ClockTime",
	"EnvironmentDiffuseScale",
	"EnvironmentSpecularScale",
	"ExposureCompensation",
	"FogColor",
	"FogEnd",
	"FogStart",
	"GlobalShadows",
	"ShadowSoftness",
}

local DefaultProperties: { [string]: any } = {}
local DefaultChildren: { Instance } = {}
local Captured = false

local function ClearLightingChildren()
	for _, child in Lighting:GetChildren() do
		child:Destroy()
	end
end

function LightingManager:CaptureDefault()
	if Captured then
		return
	end
	Captured = true

	for _, propertyName in TWEENABLE_PROPERTIES do
		local ok, value = pcall(function()
			return Lighting[propertyName]
		end)
		if ok then
			DefaultProperties[propertyName] = value
		end
	end

	for _, child in Lighting:GetChildren() do
		table.insert(DefaultChildren, child:Clone())
	end
end

function LightingManager:ApplyProperties(properties: { [string]: any })
	if not properties then
		return
	end

	for propertyName, value in properties do
		local ok = pcall(function()
			Lighting[propertyName] = value
		end)
		if not ok then
			warn("[LightingManager] Falha ao aplicar a propriedade '" .. propertyName .. "'")
		end
	end
end

function LightingManager:ApplyTemplate(templateName: string)
	local Template = TemplatesFolder:FindFirstChild(templateName)
	if not Template then
		return
	end

	for _, child in Template:GetChildren() do
		child:Clone().Parent = Lighting
	end
end

function LightingManager:Apply(templateName: string, properties: { [string]: any }?)
	ClearLightingChildren()
	self:ApplyTemplate(templateName)
	self:ApplyProperties(properties)
end

function LightingManager:ResetToDefault()
	if not Captured then
		return
	end

	ClearLightingChildren()

	for _, child in DefaultChildren do
		child:Clone().Parent = Lighting
	end

	self:ApplyProperties(DefaultProperties)
end

LightingManager:CaptureDefault()

return LightingManager
