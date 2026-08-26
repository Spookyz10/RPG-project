local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).client
local TutorialCutscene = require(ReplicatedStorage.Shared.TutorialCutscene)

TutorialCutscene:Play()
