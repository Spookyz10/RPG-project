-- Server dispatch only: no tracks, keyframes, joint writes or animation loops.
local RS = game:GetService("ReplicatedStorage")
local Remote = require(RS.Shared.Utils.RemoteManager)
local Timings = require(RS.Shared.Combat.MotionTimings)
return {
	Play = function(_, character, name)
		local duration = assert(Timings[name], "Missing combat timing: " .. name)
		Remote.SendClientEvent("SkillAnimation", { All = true }, character, name, workspace:GetServerTimeNow())
		return duration
	end,
}
