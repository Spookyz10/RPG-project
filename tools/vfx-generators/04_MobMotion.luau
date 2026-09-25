-- Run in Studio Edit Mode after syncing scripts. Produces native, editable clips.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play first")
local RS = game:GetService("ReplicatedStorage")
local resources = RS.Resources
local library = Instance.new("Folder")
library.Name = "MobMotion"
library:SetAttribute("Version", 1)
local function pose(x, y, z, height, forward)
	return CFrame.new(0, height or 0, forward or 0) * CFrame.Angles(math.rad(x or 0), math.rad(y or 0), math.rad(z or 0))
end
local profiles = {
	Bushling = { Speed=12, Cycle=0.7, Stride=26, Bob=0.15, Basic=0.3, Skills={Spikes=2.25} },
	Wolf = { Speed=18, Cycle=0.52, Stride=34, Bob=0.16, Basic=0.3, Skills={TailSpin=3} },
	Boar = { Speed=15, Cycle=0.6, Stride=25, Bob=0.13, Basic=0.3, Skills={Rush=2.12} },
	["Dire Bear"] = { Speed=12, Cycle=0.9, Stride=24, Bob=0.17, Basic=0.3, Skills={Jump=3.24,Roar=2.04,Stomp=1.74,Cavefall=5.25} },
	Mosscap = { Speed=11, Cycle=0.72, Stride=24, Bob=0.2, Basic=0.65, Skills={SporeBloom=2.25} },
	["Thornback Stag"] = { Speed=18, Cycle=0.64, Stride=31, Bob=0.13, Basic=0.65, Skills={AntlerRush=2.4} },
	["Hollow Sentinel"] = { Speed=10, Cycle=1.05, Stride=22, Bob=0.11, Basic=0.65, Skills={RootLanes=2.1} },
	Elderbark = { Speed=9, Cycle=1.35, Stride=17, Bob=0.16, Basic=0.85, Skills={HeartSlam=1.76,MarkedRoots=1.88,RootSweep=1.48} },
}
local function smooth(a) a=math.clamp(a,0,1);return a*a*(3-2*a) end
local function envelope(t, peak, hold, finish)
	if t < peak then return smooth(t/peak) end
	if t < hold then return 1 end
	return 1-smooth((t-hold)/math.max(0.01,finish-hold))
end
local function poses(name,p,category,t)
	local q={}
	local quad = name=="Bushling" or name=="Wolf" or name=="Boar" or name=="Dire Bear" or name=="Thornback Stag"
	if category=="Idle" then
		local b=math.sin(t*math.pi*2/3.2)
		q.Torso=pose(0.7*b,0,0,p.Bob*0.32*b)
		q.Head=pose(-1.2*b,1.5*math.sin(t*math.pi*2/3.2),0)
		q.Neck=pose(0.8*b)
		q.Tail=pose(0,8*b,2*b)
		q.LeftArm=pose(1.5*b,0,-2);q.RightArm=pose(-1.5*b,0,2)
	elseif category=="Walk" then
		local phase=t*math.pi*2/p.Cycle
		local a,b=math.sin(phase),math.cos(phase*2)
		q.Torso=pose(quad and 1.8*b or 2,0,quad and 1.8*a or 2.8*a,p.Bob*(1-b))
		q.Head=pose(-1.5*b,-2*a,quad and -a or -2*a)
		q.Neck=pose(-2*b);q.Tail=pose(4*b,12*a,0)
		if quad then
			for limb,offset in {FrontLeftLeg=0,BackRightLeg=0,FrontRightLeg=math.pi,BackLeftLeg=math.pi} do
				local s=math.sin(phase+offset)
				q[limb]=pose(s*p.Stride,0,0,math.max(0,-s)*p.Bob)
				q[string.gsub(limb,"Leg","Shin")]=pose(math.max(0,-s)*32)
			end
		else
			q.LeftLeg=pose(a*p.Stride);q.RightLeg=pose(-a*p.Stride)
			q.LeftArm=pose(-a*p.Stride*0.65,0,-4);q.RightArm=pose(a*p.Stride*0.65,0,4)
			q.LeftForearm=pose(-8-math.max(0,a)*12);q.RightForearm=pose(-8-math.max(0,-a)*12)
		end
	else
		local windup=p.Basic
		if category=="Basic" or category=="RootSweep" then
			if category=="RootSweep" then windup=1.2 end
			local wind=envelope(t,windup*0.8,windup*0.85,windup)
			local hit=envelope(t,windup,windup+0.035,windup+0.22)
			if quad then
				local bite=name=="Wolf" or name=="Boar" or name=="Thornback Stag"
				q.Torso=pose(-7*wind+10*hit,0,-4*wind+4*hit,0.12*wind,-0.55*hit)
				q.Head=pose(12*wind-24*hit);q.Neck=pose(10*wind-22*hit)
				q.FrontLeftLeg=pose((bite and 12 or -36)*wind+25*hit)
				q.FrontRightLeg=pose(12*wind-16*hit)
			else
				q.Torso=pose(-6*wind+12*hit,-18*wind+24*hit,0,0,-0.35*hit)
				q.RightArm=pose(-72*wind+36*hit,0,28*wind-14*hit)
				q.LeftArm=pose(-12*wind+10*hit,0,-8)
				q.RightForearm=pose(-30*wind+15*hit);q.RightHand=pose(-20*wind)
				q.Head=pose(4*wind-6*hit,12*wind-12*hit)
			end
		elseif category=="Rush" or category=="AntlerRush" then
			local launch=category=="Rush" and 1.1 or 1.3
			local charge=envelope(t,0.45,launch+0.65,launch+0.95)
			q=poses(name,p,"Walk",math.max(0,t-launch)*1.6)
			if t<launch then q={} end
			q.Torso=pose(9*charge,0,0,-0.2*charge)
			q.Head=pose(-20*charge);q.Neck=pose(-16*charge)
		elseif category=="TailSpin" then
			local wind=envelope(t,0.65,0.72,0.9)
			q.Torso=pose(0,-25*wind,0,-0.18)
			q.Head=pose(0,18*wind);q.Tail=pose(0,-48*wind+30*(1-wind),12)
			q.FrontLeftLeg=pose(-18);q.FrontRightLeg=pose(18)
			q.BackLeftLeg=pose(18);q.BackRightLeg=pose(-18)
		elseif category=="Jump" then
			local crouch=envelope(t,1.9,2.2,2.38)
			local air=envelope(t-2.25,0.18,0.42,0.75)
			local land=envelope(t-2.93,0.07,0.1,0.3)
			q.Torso=pose(-8*crouch+8*air+12*land,0,0,-0.65*crouch-0.6*land)
			q.Head=pose(10*crouch-12*air)
			q.FrontLeftLeg=pose(-20*crouch-48*air+25*land);q.FrontRightLeg=q.FrontLeftLeg
			q.BackLeftLeg=pose(24*crouch+42*air);q.BackRightLeg=q.BackLeftLeg
		elseif category=="Roar" or category=="Cavefall" then
			local finish=category=="Roar" and 2.04 or 5.25
			local lift=envelope(t,0.65,finish-0.35,finish)
			q.Torso=pose(-15*lift,0,0,0.35*lift)
			q.Head=pose(24*lift+2*math.sin(t*28)*lift)
			q.FrontLeftLeg=pose(-28*lift);q.FrontRightLeg=pose(-28*lift)
		elseif category=="Stomp" or category=="HeartSlam" then
			local lift=envelope(t,1.12,1.3,1.49)
			local hit=envelope(t,1.5,1.54,1.76)
			q.Torso=pose(-18*lift+18*hit,0,0,0.3*lift-0.45*hit)
			q.Head=pose(10*lift-12*hit)
			q.FrontLeftLeg=pose(-54*lift+30*hit);q.FrontRightLeg=q.FrontLeftLeg
			q.LeftArm=pose(-135*lift+28*hit,0,-12*lift);q.RightArm=pose(-135*lift+28*hit,0,12*lift)
			q.LeftForearm=pose(-32*lift);q.RightForearm=q.LeftForearm
		else
			local duration=p.Skills[category] or 2
			local peak=category=="Spikes" and 1.8 or category=="MarkedRoots" and 1.4 or 0.95
			local cast=envelope(t,peak,peak+0.12,duration)
			q.Torso=pose(-8*cast,0,0,0.2*cast)
			q.Head=pose(12*cast);q.LeftArm=pose(-64*cast,0,-35*cast);q.RightArm=pose(-64*cast,0,35*cast)
			q.FrontLeftLeg=pose(-25*cast);q.FrontRightLeg=q.FrontLeftLeg
			q.LeftHand=pose(-25*cast);q.RightHand=q.LeftHand
		end
	end
	return q
end
local count=0
for name,p in profiles do
	local rig=RS.Mobs:FindFirstChild(name,true)
	assert(rig and rig:IsA("Model"),"Missing rig "..name)
	local folder=Instance.new("Folder");folder.Name=name;folder.Parent=library
	folder:SetAttribute("RigScale",rig:GetScale());folder:SetAttribute("WalkSpeed",p.Speed)
	local joints={}
	for _,j in rig:GetDescendants() do
		if j:IsA("Motor6D") and j.Part0 and j.Part1 then joints[j.Part1.Name]=j end
	end
	local clips={Idle=3.2,Walk=p.Cycle,Basic=p.Basic+0.24}
	for skill,duration in p.Skills do clips[skill]=duration end
	for category,duration in clips do
		local sequence=Instance.new("KeyframeSequence");sequence.Name=category
		sequence.Loop=category=="Idle" or category=="Walk"
		sequence.Priority=sequence.Loop and Enum.AnimationPriority.Movement or Enum.AnimationPriority.Action
		local steps=math.ceil(duration*24)
		for i=0,steps do
			local time=duration*i/steps
			local values=poses(name,p,category,time)
			local frame=Instance.new("Keyframe");frame.Time=time;frame.Parent=sequence
			local made={}
			local function ensure(partName)
				if made[partName] then return made[partName] end
				local v=Instance.new("Pose");v.Name=partName;v.CFrame=values[partName] or CFrame.identity
				v.Weight=partName=="HumanoidRootPart" and 0 or 1
				v.EasingStyle=Enum.PoseEasingStyle.Linear;made[partName]=v
				local j=joints[partName];v.Parent=j and ensure(j.Part0.Name) or frame
				return v
			end
			-- Every core joint has a neutral key, preventing stale poses between clips.
			for _,partName in {"Torso","Head","Neck","Tail","FrontLeftLeg","FrontRightLeg","BackLeftLeg","BackRightLeg","FrontLeftShin","FrontRightShin","BackLeftShin","BackRightShin","LeftArm","RightArm","LeftLeg","RightLeg","LeftHand","RightHand","LeftForearm","RightForearm"} do
				if joints[partName] then ensure(partName) end
			end
		end
		sequence.Parent=folder;count+=1
	end
end
local old=resources:FindFirstChild("MobMotion")
if old then old.Name="MobMotion_"..os.time();old.Parent=game.ServerStorage.RPGVFXBackups end
library.Parent=resources
return "Installed "..count.." editable mob clips"
