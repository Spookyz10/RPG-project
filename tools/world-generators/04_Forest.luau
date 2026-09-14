-- Forest / The Amberwood. Run the complete file in Studio's Command Bar, in Edit.
-- All geometry is saved, editable and deterministic. No runtime world builder.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating Forest")
local V, C = Vector3.new, Color3.fromRGB
local ORIGIN = V(0, 0, 2400)
local rng = Random.new(9281404)
local palette = {
	grass = C(94, 132, 83), moss = C(124, 153, 88), leaf = C(58, 116, 80),
	lightLeaf = C(137, 169, 94), bark = C(111, 80, 57), dark = C(63, 66, 56),
	stone = C(112, 126, 119), paleStone = C(156, 161, 135), path = C(171, 150, 110),
	water = C(63, 143, 151), mint = C(136, 209, 175), gold = C(242, 192, 101),
	ivory = C(226, 215, 171), flower = C(191, 147, 164),
}
local function group(parent, name, class)
	local object = Instance.new(class or "Folder")
	object.Name, object.Parent = name, parent
	return object
end
local map = group(nil, "Forest", "Model")
local ground = group(map, "Ground")
local paths = group(map, "Paths")
local vegetation = group(map, "Vegetation")
local landmarks = group(map, "Landmarks")
local details = group(map, "TrailDetails")
local markers = group(map, "PlanningMarkers")
local encounters = group(map, "EncounterMarkers")
local waterFolder = group(map, "Water")
local function part(parent, name, size, p, color, material, rotation, solid, class)
	local object = Instance.new(class or "Part")
	object.Name, object.Size = name, size
	object.CFrame = CFrame.new(ORIGIN + p) * (rotation or CFrame.identity)
	object.Color = color
	-- Flat colors let the authored facets carry the low-poly style.
	object.Material = material == Enum.Material.Neon and material or Enum.Material.SmoothPlastic
	object.Anchored = true
	object.CanCollide, object.CanQuery, object.CanTouch = solid == true, solid == true, false
	object.TopSurface, object.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	object.Parent = parent
	return object
end
local function ball(parent, name, p, size, color, material, rotation)
	local object = part(parent, name, size, p, color, material, rotation)
	object.Shape = Enum.PartType.Ball
	return object
end
local function rod(parent, name, a, b, width, color, solid, material)
	return part(parent, name, V(width, width, (b-a).Magnitude), (a+b)/2, color,
		material, CFrame.lookAt(V(0,0,0), b-a), solid)
end
-- Two right wedges form one exact planar triangle. Adjacent faces share vertices;
-- no unrelated rotated blocks or spheres are used to approximate foliage.
local function triangle(parent, name, a, b, c, color)
	local ab, ac, bc = b-a, c-a, c-b
	if ab:Dot(ab) > math.max(ac:Dot(ac), bc:Dot(bc)) then c,a=a,c
	elseif ac:Dot(ac) > bc:Dot(bc) then a,b=b,a end
	ab,ac,bc = b-a,c-a,c-b
	local right = ac:Cross(ab).Unit
	local back = bc.Unit
	local up = bc:Cross(right).Unit
	local height = math.abs(ab:Dot(up))
	local first = math.abs(ab:Dot(back))
	local second = math.abs(ac:Dot(back))
	if first > 0.001 then part(parent,name,V(0.05,height,first),(a+b)/2,color,nil,CFrame.fromMatrix(V(0,0,0),right,up,back),false,"WedgePart") end
	if second > 0.001 then part(parent,name,V(0.05,height,second),(a+c)/2,color,nil,CFrame.fromMatrix(V(0,0,0),-right,up,-back),false,"WedgePart") end
end
local function crown(parent, name, center, radius, height, color, yaw, beveled)
	local top = center + V(radius*0.08,height,0)
	local bottom = center - V(0,height*0.3,0)
	for i=0,5 do
		local a = yaw+i*math.pi/3
		local b = a+math.pi/3
		local p = center+V(math.cos(a)*radius,0,math.sin(a)*radius)
		local q = center+V(math.cos(b)*radius,0,math.sin(b)*radius)
		local shade=color:Lerp(palette.lightLeaf,(i%3)*0.035)
		if beveled then
			local upperP=center+V(math.cos(a)*radius*0.6,height*0.72,math.sin(a)*radius*0.6)
			local upperQ=center+V(math.cos(b)*radius*0.6,height*0.72,math.sin(b)*radius*0.6)
			triangle(parent,name,p,q,upperP,shade)
			triangle(parent,name,q,upperQ,upperP,shade)
			triangle(parent,name,top,upperP,upperQ,shade:Lerp(palette.lightLeaf,0.08))
		else
			triangle(parent,name,top,p,q,shade)
		end
		triangle(parent,name.."Underside",bottom,q,p,color:Lerp(palette.dark,0.12))
	end
end
local function disc(parent, name, p, radius, thickness, color, material, solid)
	local object = part(parent, name, V(thickness, radius*2, radius*2), p, color, material,
		CFrame.Angles(0,0,math.pi/2), solid)
	object.Shape = Enum.PartType.Cylinder
	return object
end
local function marker(parent, name, p)
	local object = part(parent, name, V(1,1,1), p, palette.gold)
	object.Transparency = 1
	object:SetAttribute("PlanningOnly", true)
	return object
end
-- Explicit spatial plan: water, landmarks, combat pockets and routes are reserved
-- BEFORE dressing. The spawn installer consumes these exact saved positions.
local nodes = {
	Entry = V(-105,0,-202), Crossroads = V(-110,0,-115), Mosscap = V(-172,0,-43),
	Moonwater = V(92,0,-99), HeartTree = V(-18,0,0), Ruins = V(135,0,97),
	Elderbark = V(-38,0,183), Shrine = V(-193,0,105), Lookout = V(192,0,151),
	LookoutApproach = V(192,0,117),
	BridgeWest = V(105,0,-38), BridgeEast = V(183,0,-38),
}
local heroPosition = V(-25,0,40)
local campPosition = V(-166,0,-172)
local lakePosition = V(146,0,-85)
local nurseLogPosition = V(-127,0,30)
local reservations = {
	{heroPosition, 30}, {campPosition, 21}, {lakePosition, 43},
	{nurseLogPosition, 17},
	{V(219,0,-91), 26}, {nodes.Entry, 28}, {nodes.Crossroads, 24},
	{nodes.Mosscap, 38}, {nodes.Ruins, 40}, {nodes.Elderbark, 64},
	{nodes.Shrine, 33}, {nodes.Lookout, 29},
}
local encounterPlan = {
	{"Mosscap", V(-132,0,-81)}, {"Mosscap", V(-175,0,-63)},
	{"Mosscap", V(-191,0,-31)}, {"Mosscap", V(-157,0,-19)},
	{"Mosscap", V(-182,0,38)}, {"Mosscap", V(-177,0,100)},
	{"Mosscap", V(-105,0,-45)}, {"Mosscap", V(-74,0,-91)},
	{"Thornback Stag", V(64,0,-91)}, {"Thornback Stag", V(93,0,-52)},
	{"Thornback Stag", V(65,0,17)}, {"Thornback Stag", V(123,0,18)},
	{"Thornback Stag", V(-55,0,-16)}, {"Thornback Stag", V(-93,0,61)},
	{"Hollow Sentinel", V(136,0,79)}, {"Hollow Sentinel", V(172,0,92)},
	{"Hollow Sentinel", V(143,0,119)}, {"Hollow Sentinel", V(107,0,149)},
	{"Hollow Sentinel", V(174,0,159)}, {"Elderbark", nodes.Elderbark},
}
for index, entry in encounterPlan do
	local radius = entry[1] == "Elderbark" and 58 or (entry[1] == "Thornback Stag" and 17 or 13)
	table.insert(reservations, {entry[2], radius})
	local saved = marker(encounters, string.format("%02d_%s", index, entry[1]), entry[2] + V(0,3,0))
	saved:SetAttribute("Species", entry[1])
	saved:SetAttribute("ClearanceRadius", radius)
end
local function reserved(p, margin)
	for _, area in reservations do
		if (p-area[1]).Magnitude < area[2]+margin then return true end
	end
	return false
end
local function boundary(a)
	return 268 + 23*math.sin(a*3+0.3) + 12*math.cos(a*2)
end
-- A continuous, level combat surface. Relief belongs to the edges and lookout;
-- this avoids accidental steps, wedged humanoids and floating decoration.
for z = -304, 304, 8 do
	local left, right
	for x = -312, 312, 4 do
		if V(x,0,z).Magnitude < boundary(math.atan2(z,x))+12 then left = left or x; right = x end
	end
	if left then
		part(ground, "ForestFloor", V(right-left+4,14,8), V((left+right)/2,-7,z), palette.grass, Enum.Material.Grass, nil, true)
	end
end
-- Two staggered cliff layers avoid the repeated box-wall silhouette.
local cliffPlantings = {}
for i = 0, 79 do
	local a = i*math.pi*2/80
	local direction = V(math.cos(a),0,math.sin(a))
	local h = 24 + 15*(0.5+0.5*math.sin(a*5)) + rng:NextNumber(0,9)
	local p = direction*boundary(a)
	local rotation = CFrame.Angles(0,-a,0)
	part(ground, "Bedrock", V(29,h,30), p+V(0,h/2-2,0), palette.stone, Enum.Material.Rock, rotation, true)
	part(ground, "BrokenEscarpment", V(24,h+12,26), p+direction*13+V(0,(h+12)/2-1,0),
		palette.stone:Lerp(palette.dark,0.22), Enum.Material.Slate, rotation, true, "WedgePart")
	part(details, "CliffMoss", V(27,1.2,27), p+V(0,h-1.9,0), palette.moss, nil, rotation)
	if i%4==0 then table.insert(cliffPlantings,p+V(0,h-2,0)) end
end
local routes = {
	{"Entry","Crossroads",V(-84,0,-156),16},
	{"Crossroads","Mosscap",V(-174,0,-116),13},
	{"Crossroads","HeartTree",V(-30,0,-92),15},
	{"Mosscap","HeartTree",V(-89,0,-8),13},
	{"Moonwater","BridgeWest",V(88,0,-66),13},
	{"BridgeWest","BridgeEast",V(144,0,-38),12},
	{"BridgeWest","HeartTree",V(52,0,-24),14},
	{"BridgeEast","Ruins",V(209,0,39),14},
	{"Ruins","Elderbark",V(71,0,183),15},
	{"Mosscap","Shrine",V(-213,0,29),11},
	{"Shrine","Elderbark",V(-160,0,192),12},
	{"Ruins","LookoutApproach",V(180,0,105),12},
}
local segments = {}
local function trail(name, a, b, control, width, bridge)
	local model = group(paths,name,"Model")
	local previous = a
	for step = 1, 24 do
		local t = step/24
		local current = a*(1-t)^2 + control*(2*(1-t)*t) + b*t^2
		table.insert(segments,{previous,current,width})
		if not bridge then
			part(model,"PackedEarth",V(width,0.1,(current-previous).Magnitude+0.35),
				(current+previous)/2+V(0,0.06,0),palette.path,Enum.Material.Ground,
				CFrame.lookAt(V(0,0,0),current-previous))
		end
		previous = current
	end
end
for _, route in routes do
	trail(route[1].."_"..route[2],nodes[route[1]],nodes[route[2]],route[3],route[4],route[1]=="BridgeWest" and route[2]=="BridgeEast")
end
trail("BotanistApproach",nodes.Entry+V(4,0,20),campPosition,V(-137,0,-179),8)
local function routeDistance(p)
	local best = math.huge
	for _, segment in segments do
		local d = segment[2]-segment[1]
		local t = math.clamp((p-segment[1]):Dot(d)/d:Dot(d),0,1)
		best = math.min(best,(p-segment[1]-d*t).Magnitude-segment[3]/2)
	end
	return best
end
for _, name in {"Entry","Crossroads","Mosscap","Ruins","Elderbark","Shrine"} do
	local radius = name=="Elderbark" and 54 or (name=="Mosscap" and 32 or 19)
	disc(paths,name.."Glade",nodes[name]+V(0,0.04,0),radius,0.05,palette.moss,Enum.Material.Grass)
end
-- Water has a complete course: cliff spring -> pool -> north outlet -> bridge.
local waterDiscs = {}
local function water(p,r)
	table.insert(waterDiscs,{p,r})
	local surface = disc(waterFolder,"WaterSurface",p+V(0,0.2,0),r,0.12,palette.water,Enum.Material.Glass)
	surface.Transparency = 0.22
	surface.Reflectance = 0.08
	return surface
end
water(lakePosition,34)
for i=0,8 do water(V(220-i*7.8,0,-91+math.sin(i*0.45)*4),8) end
for i=0,10 do water(V(146+math.sin(i*0.25)*4,0,-61+i*6),7) end
-- The outlet settles in a reed-filled soakaway, rather than ending on dry grass.
water(V(149,0,5),11)
local function wet(p,margin)
	for _, area in waterDiscs do
		if (p-area[1]).Magnitude < area[2]+margin then return true end
	end
	return false
end
local occupied = {}
local function claim(p,radius)
	if reserved(p,radius) or wet(p,radius) or routeDistance(p)<radius+3 then return false end
	if p.Magnitude>boundary(math.atan2(p.Z,p.X))-24-radius then return false end
	for _, other in occupied do if (p-other[1]).Magnitude<radius+other[2] then return false end end
	table.insert(occupied,{p,radius})
	return true
end
local function mushroom(parent,p,s,color)
	local model = group(parent,"WoodlandFungus","Model")
	-- A single six-sided umbrella; stem meets the underside and starts below ground.
	rod(model,"Stem",p-V(0,0.12*s,0),p+V(0,1.72*s,0),0.42*s,palette.ivory,false)
	local center=p+V(0,1.82*s,0)
	local apex=p+V(0.08,2.8,0)*s
	for i=0,5 do
		local a=i*math.pi/3
		local b=a+math.pi/3
		local u=center+V(math.cos(a)*1.6,0,math.sin(a)*1.6)*s
		local w=center+V(math.cos(b)*1.6,0,math.sin(b)*1.6)*s
		triangle(model,"CapFacet",apex,u,w,color:Lerp(palette.ivory,(i%2)*0.05))
		triangle(model,"Gills",center-V(0,0.18*s,0),w,u,palette.ivory)
	end
	return model
end
local function fern(parent,p,s)
	local model=group(parent,"Fern","Model")
	-- Five continuous pointed fronds grow from one buried crown.
	for i=0,4 do
		local a=i*math.pi*2/5
		local direction=V(math.cos(a),0,math.sin(a))
		local side=V(-direction.Z,0,direction.X)*0.48*s
		local base=p-V(0,0.08,0)
		local middle=p+direction*0.9*s+V(0,1.1*s,0)
		local tip=p+direction*2.2*s+V(0,0.7*s,0)
		triangle(model,"Frond",base,middle+side,tip,palette.moss)
		triangle(model,"Frond",base,tip,middle-side,palette.leaf:Lerp(palette.moss,0.6))
	end
end
local function tree(p,h,hero)
	local model=group(vegetation,hero and "AmberwoodMatriarch" or "CanopyTree","Model")
	local w=h*(hero and 0.08 or 0.062)
	local yaw=rng:NextNumber(0,math.pi*2)
	local trunkTop=p+V(h*0.025,h*0.64,0)
	rod(model,"RootTrunk",p-V(0,1,0),trunkTop,w,palette.bark,true)
	-- Wedge roots have flat buried bases. The high end touches the trunk;
	-- the pointed end disappears under the floor instead of floating above it.
	for i=0,3 do
		local a=yaw+i*math.pi/2
		local direction=V(math.sin(a),0,math.cos(a))
		local rootHeight=w*0.9
		local depth=w*1.3
		local root=part(model,"Buttress",V(w*0.48,rootHeight,depth),
			p+direction*(w*0.28+depth/2)+V(0,rootHeight/2-0.55,0),
			palette.bark,nil,CFrame.Angles(0,a+math.pi,0),false,"WedgePart")
		root:SetAttribute("BuriedBase",true)
	end
	local main=p+V(h*0.025,h*0.72,0)
	rod(model,"CrownLeader",trunkTop,main+V(0,h*0.02,0),w*0.63,palette.bark,false)
	crown(model,"LeafCluster",main,h*0.26,h*0.18,palette.leaf,yaw,true)
	local branchTip=p+V(-h*0.16,h*0.6,h*0.045)
	rod(model,"Bough",p+V(0,h*0.45,0),branchTip,w*0.48,palette.bark,false)
	crown(model,"SideCrown",branchTip+V(0,h*0.025,0),h*0.18,h*0.11,palette.leaf:Lerp(palette.moss,0.22),yaw+0.35)
	if hero then
		local tip=p+V(h*0.19,h*0.65,-h*0.04)
		rod(model,"Bough",trunkTop,tip,w*0.5,palette.bark,false)
		crown(model,"ThirdCrown",tip,h*0.2,h*0.17,palette.leaf:Lerp(palette.moss,0.12),yaw-0.3)
	end
	model:SetAttribute("FootprintRadius",w*1.9)
	return model
end
tree(heroPosition,78,true)
-- Wider spacing keeps the faceted crowns readable and leaves pockets of sunlight.
local planted=0
for _=1,360 do
	local a=rng:NextNumber(0,math.pi*2)
	local r=math.sqrt(rng:NextNumber())*249
	local p=V(math.cos(a)*r,0,math.sin(a)*r)
	local h=rng:NextNumber(34,49)
	if planted<54 and claim(p,18) then tree(p,h,false); planted+=1 end
end
-- Background trees are planted on the actual cliff top, with complete trunks.
for i,p in cliffPlantings do
	local background=tree(p,30+i%3*3,false)
	background.Name="ClifftopTree"
end
local fungiCount=0
for _=1,400 do
	local p=V(rng:NextNumber(-245,245),0,rng:NextNumber(-245,245))
	if claim(p,3.5) then
		local choice=rng:NextInteger(1,5)
		if choice==1 and fungiCount<22 then
			mushroom(details,p,rng:NextNumber(0.55,1.0),palette.flower)
			fungiCount+=1
		elseif choice==2 then fern(details,p,rng:NextNumber(0.65,1.0))
		elseif choice==3 then
			part(details,"TrailStone",V(3.8,2.2,3),p+V(0,0.8,0),palette.stone,nil,CFrame.Angles(0,p.X,0),false,"WedgePart")
		else
			for j=1,3 do
				local fp=p+V(j*0.55,0,j%2*0.4)
				rod(details,"FlowerStem",fp,fp+V(0,0.95,0),0.08,palette.moss,false)
				part(details,"Wildflower",V(0.4,0.18,0.4),fp+V(0,0.97,0),palette.ivory,nil,CFrame.Angles(0,j,0))
			end
		end
	end
end
local function lantern(parent,p)
	rod(parent,"LanternPost",p,p+V(0,5.6,0),0.38,palette.bark,true)
	local center=p+V(0,6.1,0)
	part(parent,"LanternBase",V(1.5,0.2,1.5),center-V(0,0.8,0),palette.dark,Enum.Material.Metal)
	local glass=part(parent,"AmberGlass",V(1.05,1.35,1.05),center,palette.gold,Enum.Material.Neon)
	for _, x in {-1,1} do for _, z in {-1,1} do
		part(parent,"LanternMullion",V(0.12,1.6,0.12),center+V(x*0.61,0,z*0.61),palette.dark,Enum.Material.Metal)
	end end
	part(parent,"LanternRoof",V(1.8,0.3,1.8),center+V(0,0.9,0),palette.dark,Enum.Material.Metal)
	return glass
end
for _, p in {nodes.Entry+V(-16,0,4),nodes.Entry+V(16,0,4),nodes.Crossroads+V(13,0,-10),V(86,0,-37),V(197,0,-38),nodes.Elderbark+V(-41,0,-35)} do
	lantern(details,p)
end
local function arch(parent,p,width,height)
	for _, side in {-1,1} do
		part(parent,"PierFoot",V(5.5,1,6),p+V(side*(width/2+1.6),0.5,0),palette.dark,Enum.Material.Slate,nil,true)
		part(parent,"StonePier",V(3.2,height,4),p+V(side*(width/2+1.6),height/2,0),palette.stone,Enum.Material.Limestone,nil,true)
		part(parent,"PierCapital",V(4.7,1.2,5),p+V(side*(width/2+1.6),height,0),palette.paleStone,Enum.Material.Limestone,nil,true)
	end
	local r=width/2+1.6
	for i=0,10 do
		local a=(i+0.5)*math.pi/11
		part(parent,"ArchStone",V(r*math.pi/11+0.1,2.7,4.3),p+V(math.cos(a)*r,height+math.sin(a)*r,0),
			palette.paleStone,Enum.Material.Limestone,CFrame.Angles(0,0,a+math.pi/2),true)
	end
end
local gate=group(landmarks,"PilgrimGate","Model")
arch(gate,nodes.Entry+V(0,0,-8),22,12)
for _, side in {-1,1} do
	part(gate,"GardenWall",V(16,3,4),nodes.Entry+V(side*25,1.5,-8),palette.stone,Enum.Material.Limestone,nil,true)
	part(gate,"WallIvy",V(15,0.18,4),nodes.Entry+V(side*25,3.09,-8),palette.moss)
end
local camp=group(landmarks,"BotanistRest","Model")
for _, side in {-1,1} do
	-- Roof lengths and angles are derived from endpoints, so canvas meets its ridge.
	local edge=campPosition+V(side*5,0.6,0)
	local ridge=campPosition+V(0,7,0)
	part(camp,"Canvas",V((ridge-edge).Magnitude,0.15,11),(ridge+edge)/2,C(174,147,97),Enum.Material.Fabric,
		CFrame.Angles(0,0,math.atan2((ridge-edge).Y,(ridge-edge).X)))
	for _, z in {-5.3,5.3} do rod(camp,"TentPole",edge+V(0,0,z),ridge+V(0,0,z),0.22,palette.bark,true) end
end
rod(camp,"RidgePole",campPosition+V(0,7,-5.8),campPosition+V(0,7,5.8),0.25,palette.bark,false)
for i=1,3 do
	part(camp,"SupplyCrate",V(2.6,2.6,2.6),campPosition+V(8,1.3,5+i*3.4),palette.bark,Enum.Material.WoodPlanks,nil,true)
end
lantern(camp,campPosition+V(-9,0,3))
local fungi=group(landmarks,"SporeGarden","Model")
for _, p in {nodes.Mosscap+V(-28,0,-18),nodes.Mosscap+V(1,0,-35),nodes.Mosscap+V(28,0,5)} do
	mushroom(fungi,p,1.6,palette.flower)
	mushroom(fungi,p+V(3.6,0,2),0.85,palette.ivory)
end
local nurseLog=group(landmarks,"NurseLog","Model")
local logA,logB=nurseLogPosition+V(-11,2.1,-2),nurseLogPosition+V(11,2.1,2)
rod(nurseLog,"FallenTrunk",logA,logB,4.5,palette.bark,true)
local logDirection=(logB-logA).Unit
rod(nurseLog,"DarkHeartwood",logA-logDirection*0.05,logA,3.7,palette.dark,false)
for i=1,5 do
	local p=logA:Lerp(logB,i/6)
	part(nurseLog,"MossSaddle",V(4,0.15,3),p+V(0,2.25,0),palette.moss)
	mushroom(nurseLog,p+V(0,2.37,0),0.6+i%2*0.25,palette.gold)
end
fern(nurseLog,nurseLogPosition+V(5,0,6),1.1)
local falls=group(landmarks,"SilverthreadFalls","Model")
for _, side in {-1,1} do
	part(falls,"SpringButtress",V(13,32,20),V(225,16,-91+side*13),palette.stone,Enum.Material.Rock,nil,true,"WedgePart")
end
local veil=part(waterFolder,"Waterfall",V(0.25,27,11),V(217,14.5,-91),palette.water,Enum.Material.Glass)
veil.Transparency=0.32
for i=1,4 do
	part(waterFolder,"FallingThread",V(0.1,25,0.3),V(216.8,14,-97+i*2.4),palette.ivory,Enum.Material.Glass).Transparency=0.45
end
for i=1,5 do ball(waterFolder,"SpringFoam",V(213-i*1.2,0.38,-95+i*1.4),V(3,0.1,1.2),palette.ivory) end
for i=0,17 do
	local a=i*math.pi*2/18
	local p=lakePosition+V(math.cos(a)*35,0,math.sin(a)*35)
	part(details,"ShoreStone",V(5,1.8,3.6),p+V(0,0.5,0),palette.stone,nil,CFrame.Angles(0,-a,0),false,"WedgePart")
	if i%3==0 then
		local lily=lakePosition+V(math.cos(a)*23,0.34,math.sin(a)*23)
		disc(details,"LilyPad",lily,2,0.1,palette.moss)
		for j=0,3 do
			local angle=j*math.pi/2
			triangle(details,"LotusPetal",lily+V(0,0.12,0),lily+V(math.cos(angle)*0.8,0.6,math.sin(angle)*0.8),
				lily+V(math.cos(angle+0.7)*0.65,0.25,math.sin(angle+0.7)*0.65),palette.flower)
		end
	end
end
for i=0,10 do
	local a=i*math.pi*2/11
	local p=V(149,0,5)+V(math.cos(a)*11,0,math.sin(a)*11)
	for j=1,3 do
		local stem=p+V(j*0.3,0,0)
		local top=stem+V(0.35,2+j*0.45,0.15)
		rod(details,"MarshReed",stem,top,0.09,palette.moss,false)
		rod(details,"ReedHead",top,top+V(0,0.5,0),0.2,palette.bark,false)
	end
end
local bridge=group(landmarks,"MoonwaterBridge","Model")
-- A 12 stud deck crosses the outlet rather than cutting through the pool.
for i=0,38 do
	local x=105+i*2
	local y=0.2+1.2*math.sin(i/38*math.pi)
	part(bridge,"DeckPlank",V(2.04,0.3,12),V(x,y,-38),palette.bark,Enum.Material.WoodPlanks,nil,true)
	if i%6==0 then
		for _, side in {-1,1} do rod(bridge,"RailingPost",V(x,y,-38+side*6),V(x,y+3.5,-38+side*6),0.4,palette.bark,true) end
	end
end
for _, side in {-1,1} do
	for i=0,5 do
		local x=105+i*12
		rod(bridge,"Handrail",V(x,3.7+1.2*math.sin(i*6/38*math.pi),-38+side*6),
			V(x+12,3.7+1.2*math.sin((i+1)*6/38*math.pi),-38+side*6),0.3,palette.bark,true)
	end
end
local ruins=group(landmarks,"SunkenObservatory","Model")
-- One ruined rectangular pavilion: corner plinths, common foundation and rear
-- masonry all follow the same axes. Missing roof and broken columns read as age.
for _, side in {-1,1} do
	part(ruins,"BuriedFoundation",V(3,0.18,57),nodes.Ruins+V(side*28,0.04,0),palette.paleStone)
end
part(ruins,"RearFoundation",V(59,0.18,4),nodes.Ruins+V(0,0.04,28),palette.paleStone)
for i=-2,2 do
	local p=nodes.Ruins+V(i*9.5,0,33)
	part(ruins,"RearWallCourse",V(9.3,2.2,3),p+V(0,1,0),palette.stone,nil,nil,true)
	if i~=0 then part(ruins,"BrokenWallCourse",V(8.8,1.6,2.9),p+V(0,2.9,0),palette.paleStone,nil,nil,true) end
end
-- Relic is on the north rim; the middle stays open for Sentinel lane attacks.
for _, offset in {V(-28,0,-24),V(29,0,-24),V(32,0,22),V(-29,0,25)} do
	local p=nodes.Ruins+offset
	if routeDistance(p)>6 then
		local h=offset.X<0 and 8 or 14
		part(ruins,"ColumnFoot",V(6,1,6),p+V(0,0.5,0),palette.stone,Enum.Material.Limestone,nil,true)
		rod(ruins,"ColumnShaft",p+V(0,1,0),p+V(0,h,0),3.3,palette.paleStone,true,Enum.Material.Limestone)
		part(ruins,"BrokenCapital",V(5,1.2,5),p+V(0,h,0),palette.stone,Enum.Material.Limestone,nil,true)
		fern(ruins,p+V(0,h+0.6,0),0.7)
	end
end
local relicPosition=nodes.Ruins+V(0,0,30)
disc(ruins,"RelicPlinth",relicPosition+V(0,0.5,0),3,1,palette.stone,Enum.Material.Limestone,true)
for i=0,15 do
	local a=i*math.pi/8
	rod(ruins,"Astrolabe",relicPosition+V(math.cos(a)*3,4+math.sin(a)*3,0),
		relicPosition+V(math.cos(a+math.pi/8)*3,4+math.sin(a+math.pi/8)*3,0),0.2,palette.gold,false,Enum.Material.Metal)
	local rp=nodes.Ruins+V(math.cos(a)*21,0.14,math.sin(a)*21)
	part(ruins,"CompassInlay",V(0.3,0.06,2.6),rp,palette.paleStone,nil,CFrame.Angles(0,-a+math.pi/2,0))
end
local shrine=group(landmarks,"ForgottenOffering","Model")
local shrinePosition=nodes.Shrine+V(-19,0,0)
arch(shrine,shrinePosition+V(0,0,7),10,8)
disc(shrine,"OfferingPlinth",shrinePosition+V(0,0.6,0),3,1.2,palette.stone,Enum.Material.Limestone,true)
for i=1,3 do ball(shrine,"OfferingPearl",shrinePosition+V(math.sin(i*2)*1.4,1.6,math.cos(i*2)*1.4),V(0.6,0.6,0.6),palette.mint,Enum.Material.Neon) end
local lookout=group(landmarks,"CanopyOverlook","Model")
local op=nodes.Lookout+V(0,0,8)
part(lookout,"Terrace",V(24,8,20),op+V(0,4,0),palette.stone,Enum.Material.Rock,nil,true)
part(lookout,"TerracePaving",V(24,0.2,20),op+V(0,8.1,0),palette.paleStone,Enum.Material.Limestone,nil,true)
local ramp=part(lookout,"AccessRamp",V(12,8,32),op+V(0,4,-26),palette.stone,Enum.Material.Limestone,nil,true,"WedgePart")
ramp:SetAttribute("WalkableRamp",true)
for _, side in {-1,1} do
	rod(lookout,"Balustrade",op+V(side*11,10,-7),op+V(side*11,10,9),0.65,palette.bark,true)
	for _, z in {-7,9} do rod(lookout,"Baluster",op+V(side*11,8,z),op+V(side*11,10,z),0.6,palette.bark,true) end
end
rod(lookout,"RearRail",op+V(-11,10,9),op+V(11,10,9),0.65,palette.bark,true)
local arena=group(landmarks,"ElderbarkHeartgrove","Model")
for i=0,13 do
	local a=i*math.pi*2/14
	local p=nodes.Elderbark+V(math.cos(a)*62,0,math.sin(a)*62)
	if routeDistance(p)>9 and p.Magnitude<boundary(math.atan2(p.Z,p.X))-24 then
		local h=5+i%3*1.5
		part(arena,"WeatheredBoundaryStone",V(4,h,5),p+V(0,h/2-0.4,0),palette.stone,nil,CFrame.Angles(0,-a,0),true,"WedgePart")
	end
end
-- Ambient life uses native emitters, no scripts or permanent per-frame loops.
for _, p in {nodes.Mosscap+V(0,3,0),nodes.Shrine+V(0,3,0),heroPosition+V(14,4,-6),lakePosition+V(0,3,0),nodes.Elderbark+V(0,4,30)} do
	local anchor=marker(details,"FireflyAnchor",p)
	local attachment=Instance.new("Attachment")
	attachment.Parent=anchor
	local fireflies=Instance.new("ParticleEmitter")
	fireflies.Name="DriftingFireflies"
	fireflies.Texture="rbxasset://textures/particles/sparkles_main.dds"
	fireflies.Color=ColorSequence.new(palette.gold,palette.mint)
	fireflies.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.3,0.12),NumberSequenceKeypoint.new(1,0)})
	fireflies.Transparency=NumberSequence.new(0.25)
	fireflies.Rate=1.5
	fireflies.Lifetime=NumberRange.new(4,7)
	fireflies.Speed=NumberRange.new(0.3,1.1)
	fireflies.SpreadAngle=Vector2.new(180,180)
	fireflies.LightEmission=0.8
	fireflies.Parent=attachment
end
for name,p in nodes do marker(markers,name,p+V(0,3,0)) end
map:SetAttribute("AssetStage","AuthoredWorld")
map:SetAttribute("DesignVersion",4)
map:SetAttribute("EncounterCount",#encounterPlan)
map:SetAttribute("ArtDirection","Low-poly woodland / connected crowns, buried roots, coherent ruins")
local maps=workspace:FindFirstChild("Maps") or group(workspace,"Maps")
local old=maps:FindFirstChild("Forest")
if old then
	local storage=game:GetService("ServerStorage")
	local backups=storage:FindFirstChild("WorldGeneratorBackups") or group(storage,"WorldGeneratorBackups")
	old.Parent=group(backups,"Forest_"..os.date("%Y%m%d_%H%M%S"))
end
map.Parent=maps
game:GetService("Selection"):Set({map})
print("Low-poly Forest v4 authored. Run 05, 06 and 08 next; previous map retained in ServerStorage.")
