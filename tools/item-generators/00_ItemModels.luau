assert(not game:GetService("RunService"):IsRunning(), "Stop Play before generating the study.")

local V, CF, A = Vector3.new, CFrame.new, CFrame.Angles
local M = Enum.Material
local TAU = math.pi * 2
local ORIGIN = V(0, 20, -180)
local C = {
 oak = Color3.fromRGB(153, 102, 53), grain = Color3.fromRGB(78, 43, 25),
 leather = Color3.fromRGB(70, 44, 30),
 ivory = Color3.fromRGB(228, 212, 171), root = Color3.fromRGB(123, 99, 66),
 iron = Color3.fromRGB(60, 70, 80),
 edge = Color3.fromRGB(164, 174, 175), brass = Color3.fromRGB(174, 128, 58),
 gold = Color3.fromRGB(224, 179, 83), green = Color3.fromRGB(42, 89, 57),
 leaf = Color3.fromRGB(70, 137, 72), red = Color3.fromRGB(159, 30, 49),
 blue = Color3.fromRGB(38, 112, 175), violet = Color3.fromRGB(111, 50, 163),
 thread = Color3.fromRGB(191, 162, 111), stone = Color3.fromRGB(50, 54, 65),
}

local gallery = Instance.new("Model")
gallery.Name = "ItemModelStudy"
gallery:SetAttribute("GeneratedBy", "ItemModelStudyV2")
local sculptures = {}
local rng = Random.new(47291)

local function group(parent, name)
 local g = Instance.new("Model"); g.Name = name; g.Parent = parent
 return g
end
local function newItem(name)
 local m = group(gallery, name)
 table.insert(sculptures, m)
 return m
end
local function part(parent, name, size, cf, color, material, shape)
 local p = Instance.new("Part")
 p.Name, p.Size, p.CFrame = name, size, cf
 p.Color, p.Material = color, material or M.SmoothPlastic
 p.Shape = shape or Enum.PartType.Block
 p.Anchored, p.CanCollide, p.CanTouch = true, false, false
 p.CanQuery = true
 p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
 p.Parent = parent
 return p
end
local function ball(p, n, size, cf, c, mat)
 return part(p, n, size, cf, c, mat, Enum.PartType.Ball)
end
local function rod(p, n, a, b, diameter, c, mat)
 local d = b - a
 if d.Magnitude < 0.001 then return end
 return part(p, n, V(d.Magnitude, diameter, diameter),
  CFrame.lookAt((a + b) / 2, b) * A(0, math.pi / 2, 0), c, mat, Enum.PartType.Cylinder)
end
local function line(p, n, points, width, c, mat)
 for i = 1, #points - 1 do rod(p, n, points[i], points[i+1], width, c, mat) end
end
local function ellipse(p, n, cf, rx, ry, wire, c, mat, count)
 local points = {}
 for i = 0, count or 40 do
  local t = i / (count or 40) * TAU
  table.insert(points, cf:PointToWorldSpace(V(math.cos(t)*rx, math.sin(t)*ry, 0)))
 end
 line(p, n, points, wire, c, mat)
end
local function horn(p, n, cf, length, bend, radius, color, flatten)
 local count = 34
 for i = 0, count-1 do
  local t = i / count
  local r = radius * (1-t)^0.72 + 0.012
  local pos = V(bend*t*t, length*t, 0)
  local angle = -math.atan(2*bend*t/length)
  ball(p, n, V(r*2, length/count*2.6, r*2*(flatten or 1)),
   cf * CF(pos) * A(0, 0, angle), C.root:Lerp(color, math.min(1, t*3+0.25)), M.SmoothPlastic)
 end
end
local function gem(p, cf, color, size)
 local s = size or 1
 ellipse(p, "Bezel", cf, .34*s, .45*s, .07*s, C.gold, M.Metal, 32)
 for i=0,7 do
  local t = i/8*TAU
  local w = Instance.new("WedgePart")
  w.Name = "Cut gemstone"
  w.Size = V(.27*s, .24*s, .47*s)
  w.CFrame = cf * A(0,0,t) * CF(0,.13*s,-.10*s) * A(math.pi/2,0,0)
  w.Color = color:Lerp(Color3.new(1,1,1), i%3*.06)
  w.Material = M.SmoothPlastic
  w.Anchored, w.CanCollide, w.CanTouch = true, false, false
  w.Parent = p
 end
end
local function leaf(p, cf, scale, color)
 local s = scale
 ball(p, "Leaf blade", V(.46*s,.95*s,.065*s), cf, color, M.Grass)
 rod(p,"Midrib",cf:PointToWorldSpace(V(0,-.42*s,-.04*s)),
  cf:PointToWorldSpace(V(0,.4*s,-.04*s)),.018*s,C.thread,M.Wood)
 for _, sign in {-1,1} do
  for i=1,3 do
   local y = -.32+i*.18
   rod(p,"Vein",cf:PointToWorldSpace(V(0,y*s,-.045*s)),
    cf:PointToWorldSpace(V(sign*.17*s,(y+.14)*s,-.045*s)),.012*s,C.green,M.Grass)
  end
 end
end
local function wrap(p, cf, radius, length, turns, color)
 local points = {}
 for i=0,turns*18 do
  local t = i/(turns*18)
  table.insert(points,cf:PointToWorldSpace(V(math.cos(t*TAU*turns)*radius,
   t*length,math.sin(t*TAU*turns)*radius)))
 end
 line(p,"Spiral binding",points,.065,color,M.Fabric)
end
local function studs(p, cf, width, count)
 for i=0,count-1 do
  ball(p,"Rivet",V(.08,.08,.045),cf*CF(-width/2+i*width/(count-1),0,0),C.brass,M.Metal)
 end
end

do
 local m = newItem("Wooden Sword")
 part(m,"Oak blade",V(.70,3.7,.20),CF(0,1.25,0),C.oak,M.Wood)
 ball(m,"Rounded point",V(.70,.65,.20),CF(0,3.08,0),C.oak,M.Wood)
 for _, side in {-1,1} do
  rod(m,"Carved edge",V(side*.29,-.55,0),V(side*.29,2.93,0),.12,C.thread,M.Wood)
 end
 ball(m,"Carved oak guard",V(1.9,.30,.44),CF(0,-.72,0),C.grain,M.Wood)
 studs(m,CF(0,-.72,-.23),1.1,3)
 rod(m,"Handle",V(0,-2.1,0),V(0,-.83,0),.32,C.grain,M.Wood)
 wrap(m,CF(0,-2.06,0),.175,1.12,10,C.thread)
 ball(m,"Wooden pommel",V(.48,.34,.40),CF(0,-2.15,0),C.grain,M.Wood)
 for j=1,9 do
  local points={}
  for i=0,22 do
   local y=-.5+i*.15
   table.insert(points,V(-.25+j*.05+math.sin(y*3+j)*.012,y,-.105))
  end
  line(m,"Carved wood grain",points,.009,C.grain,M.Wood)
 end
 for i=1,3 do
  ellipse(m,"Wood knot",CF(.06,1.2,-.108),.022*i,.055*i,.008,C.grain,M.Wood,24)
 end
end

local function fangWeapon(p, cf, length, bend)
 horn(p,"Carved ivory blade",cf,length,bend,.37,C.ivory,.32)
 ellipse(p,"Root collar",cf*A(math.pi/2,0,0),.39,.16,.08,C.brass,M.Metal,32)
 rod(p,"Dark handle",cf:PointToWorldSpace(V(0,-1.3,0)),cf.Position,.24,C.leather,M.Wood)
 wrap(p,cf*CF(0,-1.25,0),.15,1.15,9,C.leather)
 for _, sign in {-1,1} do
  horn(p,"Guard claw",cf*CF(sign*.21,-.05,0)*A(0,0,-sign*.8),.52,sign*.2,.13,C.ivory,.6)
 end
 gem(p,cf*CF(0,-.18,-.20),C.red,.42)
 for i=1,3 do
  line(p,"Ivory growth line",{
   cf:PointToWorldSpace(V(-.19+i*.07,.15,-.13)),
   cf:PointToWorldSpace(V(-.16+i*.06,.5,-.11)),
   cf:PointToWorldSpace(V(-.10+i*.05,.86,-.10))},.011,C.root,M.SmoothPlastic)
 end
end
fangWeapon(newItem("Direfang Sword"),CF(0,-.7,0),3.8,.75)
do
 local m = newItem("Fang Daggers")
 fangWeapon(m,CF(-.85,-.4,0)*A(0,0,.18),2,.40)
 fangWeapon(m,CF(.85,-.4,.15)*A(0,math.pi,-.18),2,.40)
end

local ringSpecs = {
 {"Bloodfang Ring",C.brass,C.red,"fang"},
 {"Briar Ring",C.green,C.green,"briar"},
 {"Crown of the Hunt",C.gold,C.red,"crown"},
 {"Ironhide Band",C.iron,C.edge,"iron"},
 {"Talisman of the Wild",C.brass,C.green,"wild"},
}
for _,spec in ringSpecs do
 local name,metal,color,kind=table.unpack(spec)
 local m=newItem(name)
 for _,z in {-.14,0,.14} do ellipse(m,"Open ring band",CF(0,0,z),.83,.83,.14,metal,M.Metal,56) end
 for _,z in {-.22,.22} do ellipse(m,"Raised rim",CF(0,0,z),.83,.83,.035,C.gold,M.Metal,56) end
 if kind=="iron" then
  part(m,"Hammered signet",V(.78,.48,.28),CF(0,.85,-.12),C.iron,M.DiamondPlate)
  studs(m,CF(0,.86,-.28),.52,3)
  for i=1,8 do
   local t=i/8*TAU
   ball(m,"Band rivet",V(.075,.075,.08),CF(math.cos(t)*.84,math.sin(t)*.84,-.23),C.edge,M.Metal)
  end
 else
  gem(m,CF(0,.93,-.17),color,.85)
  if kind=="fang" then
   for _,s in {-1,1} do horn(m,"Fang setting",CF(s*.38,1.02,-.15)*A(0,0,math.pi+s*.2),.65,-s*.19,.11,C.ivory,.7) end
  elseif kind=="briar" then
   for i=1,7 do
    local t=i/8*TAU
    horn(m,"Briar thorn",CF(math.cos(t)*.84,math.sin(t)*.84,0)*A(0,0,t-math.pi/2),.29,.12,.08,C.root,.7)
   end
   leaf(m,CF(-.4,.83,-.2)*A(0,0,.8),.65,C.leaf)
  elseif kind=="crown" then
   for i=-2,2 do horn(m,"Crown tine",CF(i*.20,1.12,.04),.4+(.2-math.abs(i)*.08),i*.06,.08,C.gold,.6) end
  else
   for _,s in {-1,1} do leaf(m,CF(s*.42,.82,-.15)*A(0,0,-s*.8),.7,C.leaf) end
  end
 end
end

local function necklace(name,style)
 local m=newItem(name)
 for i=0,31 do
  local t=i/32*TAU
  ellipse(m,"Chain link",CF(math.sin(t)*1.03,math.cos(t)*1.18+.7,0)*A(0,(i%2)*.8,-t),
   .09,.14,.033,C.brass,M.Metal,12)
 end
 ellipse(m,"Pendant bail",CF(0,-.57,0),.10,.16,.046,C.gold,M.Metal,20)
 local base=CF(0,-1.10,-.02)
 if style=="bloom" then
  for i=0,7 do
   local t=i/8*TAU
   ball(m,"Flower petal",V(.26,.63,.13),base*A(0,0,t)*CF(0,.29,0),C.violet:Lerp(C.red,i%2*.25),M.SmoothPlastic)
  end
  gem(m,base*CF(0,0,-.13),C.gold,.45)
 elseif style=="claw" then
  for i=-1,1 do horn(m,"Three claw pendant",base*CF(i*.22,.32,0)*A(0,0,math.pi-i*.2),.87,-i*.13,.16,C.ivory,.65) end
  part(m,"Claw mounting bar",V(.85,.16,.22),base*CF(0,.35,0),C.brass,M.Metal)
 elseif style=="heart" then
  for _,s in {-1,1} do
   ball(m,"Heart lobe",V(.52,.65,.24),base*CF(s*.18,.08,0)*A(0,0,-s*.5),C.red,M.SmoothPlastic)
  end
  horn(m,"Heart point",base*CF(0,-.04,0)*A(0,0,math.pi),.56,0,.30,C.red,.38)
  for _,s in {-1,1} do horn(m,"Protective ivory",base*CF(s*.40,.30,.05)*A(0,0,math.pi-s*.2),.85,-s*.25,.09,C.ivory,.65) end
 else
  ellipse(m,"Hunter medallion",base,.43,.43,.065,C.brass,M.Metal,40)
  for _,s in {-1,1} do
   line(m,"Antler", {V(s*.08,-1.35,-.07),V(s*.25,-1.06,-.07),V(s*.28,-.79,-.07)},.06,C.ivory,M.SmoothPlastic)
   rod(m,"Antler tine",V(s*.22,-1.11,-.07),V(s*.38,-1,-.07),.045,C.ivory,M.SmoothPlastic)
  end
  gem(m,base*CF(0,-.1,-.09),C.green,.36)
 end
end
necklace("Bloom Pendant","bloom")
necklace("Clawed Pendant","claw")
necklace("Direheart Pendant","heart")
necklace("Hunter's Charm","hunter")

local potionSpecs={
 {"Small Health Potion",C.red,1.05,1.15,"cross"},
 {"Small Attack Potion",Color3.fromRGB(206,88,28),.8,1.45,"sword"},
 {"Small Defense Potion",C.blue,1.12,1.05,"shield"},
 {"Small Critical Potion",C.violet,.80,1.25,"star"},
 {"Small Speed Potion",Color3.fromRGB(91,166,80),.68,1.65,"wing"},
}
for _,spec in potionSpecs do
 local name,color,w,h,mark=table.unpack(spec)
 local m=newItem(name)
 local body=ball(m,"Blown glass",V(w*1.5,h*1.55,w*1.22),CF(0,0,0),Color3.fromRGB(200,220,213),M.SmoothPlastic)
 body.Transparency=.60
 ball(m,"Elixir",V(w*1.30,h*1.03,w*1.04),CF(0,-h*.18,0),color,M.SmoothPlastic)
 rod(m,"Bottle neck",V(0,h*.52,0),V(0,h*.95,0),w*.48,Color3.fromRGB(166,194,184),M.Glass).Transparency=.35
 ellipse(m,"Glass lip",CF(0,h*.94,0)*A(math.pi/2,0,0),w*.26,w*.26,.07,C.thread,M.Glass,32)
 rod(m,"Cork stopper",V(0,h*.89,0),V(0,h*1.12,0),w*.41,C.oak,M.Wood)
 wrap(m,CF(0,h*.72,0),w*.26,.18,3,C.thread)
 part(m,"Leather label",V(w*.62,h*.49,.055),CF(0,-.05,-w*.60),C.leather,M.Fabric)
 local z=-w*.60-.04
 if mark=="cross" then
  part(m,"Cross upright",V(.10,.40,.035),CF(0,-.03,z),C.ivory,M.SmoothPlastic)
  part(m,"Cross arms",V(.32,.10,.035),CF(0,-.03,z),C.ivory,M.SmoothPlastic)
 elseif mark=="sword" then
  rod(m,"Sword mark",V(-.12,-.24,z),V(.12,.15,z),.055,C.gold,M.Metal)
  rod(m,"Sword guard",V(-.15,-.08,z),V(.04,-.19,z),.045,C.gold,M.Metal)
 elseif mark=="shield" then
  line(m,"Shield mark",{V(-.19,.14,z),V(.19,.14,z),V(.16,-.14,z),V(0,-.26,z),V(-.16,-.14,z),V(-.19,.14,z)},.04,C.edge,M.Metal)
 elseif mark=="star" then
  for i=0,3 do
   local t=i/4*TAU
   rod(m,"Star ray",V(0,-.04,z),V(math.cos(t)*.17,-.04+math.sin(t)*.23,z),.045,C.gold,M.Metal)
  end
 else
  for i=0,2 do rod(m,"Wing feather",V(-.13,-.2+i*.10,z),V(.14,.02+i*.10,z),.045,C.ivory,M.SmoothPlastic) end
 end
 for i=1,14 do
  local t=rng:NextNumber()*TAU
  local y=rng:NextNumber(h*.94,h*1.10)
  ball(m,"Cork pore",V(.02,.02,.02),CF(math.cos(t)*w*.207,y,math.sin(t)*w*.207),C.grain,M.Wood)
 end
end

horn(newItem("Boar Tusk"),"Curved tusk",CF(-.6,-1,0)*A(0,0,-.45),2.5,1.35,.42,C.ivory)
horn(newItem("Wolf's Fang"),"Wolf canine",CF(0,-.9,0),2.2,.32,.36,C.ivory,.75)
do
 local m=newItem("Dire Claw")
 horn(m,"Hooked keratin claw",CF(-.5,-1,0)*A(0,0,-.35),2.2,1.3,.52,C.iron,.60)
 for i=1,4 do
  line(m,"Keratin striation",{V(-.65+i*.10,-.8,-.3),V(-.4+i*.08,-.1,-.27),V(.1+i*.05,.65,-.13)},.016,C.root,M.SmoothPlastic)
 end
end
do
 local m=newItem("Wilderbone")
 rod(m,"Bone shaft",V(-.32,-1,0),V(.32,1,0),.42,C.ivory,M.SmoothPlastic)
 for _,s in {-1,1} do
  for _,x in {-.18,.18} do ball(m,"Joint condyle",V(.49,.46,.54),CF(s*.32+x,s*1,0),C.ivory,M.SmoothPlastic) end
 end
 for i=1,9 do ball(m,"Bone pore",V(.026,.04,.01),CF(rng:NextNumber(-.22,.22),rng:NextNumber(-.9,.9),-.215),C.root,M.SmoothPlastic) end
end
do
 local m=newItem("Dark Ivy")
 local stem={}
 for i=0,24 do table.insert(stem,V(math.sin(i*.18)*.20,-1.5+i*.12,0)) end
 line(m,"Twisting vine",stem,.07,C.root,M.Wood)
 for i=1,7 do
  local s=i%2==0 and 1 or -1
  leaf(m,CF(s*.26,-1.4+i*.36,-.04)*A(0,.15*s,-s*.70),.85,C.green:Lerp(C.leaf,i/12))
 end
 wrap(m,CF(0,-1.25,0),.12,.35,3,C.thread)
end

local function mantle(name,armored)
 local m=newItem(name)
 local cloth=armored and Color3.fromRGB(67,64,53) or C.leather
 for i=0,20 do
  local t=-1.4+i/20*2.8
  local x=math.sin(t)*1.14
  local z=math.cos(t)*.52+.15
  local length=2.6+.18*math.cos(i*1.7)
  ball(m,"Draped hide fold",V(.26,length,.25),CF(x,-.25,z)*A(-.08,0,-t*.07),cloth:Lerp(C.grain,(i%3)*.04),M.Fabric)
  line(m,"Hem stitches",{V(x-.035,-.25-length/2+.15,z-.12),V(x+.035,-.25-length/2+.11,z-.12)},.022,C.thread,M.Fabric)
 end
 ellipse(m,"Open collar",CF(0,1.14,0)*A(math.pi/2,0,0),.57,.40,.18,C.leather,M.Fabric,44)
 for i=0,32 do
  local t=i/32*TAU
  ball(m,"Fur collar tuft",V(.20,.27,.22),CF(math.cos(t)*.64,1.10,math.sin(t)*.40)*A(0,0,t),
   C.root:Lerp(C.ivory,(i%4)*.15),M.Fabric)
 end
 for _,s in {-1,1} do
  ball(m,"Shoulder leather",V(.87,.5,.85),CF(s*.94,.88,0),cloth,M.Fabric)
  if armored then
   for j=0,2 do
    ball(m,"Layered shoulder plate",V(.85-j*.10,.19,.77),CF(s*(.85+j*.10),1.04-j*.16,-.08),C.iron:Lerp(C.edge,j*.06),M.Metal)
   end
   horn(m,"Shoulder tusk",CF(s*1.13,1.15,0)*A(0,0,-s*.4),.95,s*.32,.22,C.ivory,.7)
   studs(m,CF(s*.85,.76,-.43),.48,3)
  end
 end
 rod(m,"Chest clasp chain",V(-.5,.85,-.42),V(.5,.85,-.42),.055,C.brass,M.Metal)
 gem(m,CF(0,.85,-.48),armored and C.ivory or C.gold,.40)
end
mantle("Cloak of Hide",false)
mantle("Tuskguard Mantle",true)
do
 local m=newItem("Rune of the Silencer")
 ball(m,"Weathered rune stone",V(1.7,2.25,.46),CF(),C.stone,M.Slate)
 ellipse(m,"Inlaid seal",CF(0,0,-.23),.64,.82,.025,C.brass,M.Metal,48)
 line(m,"Silence glyph",{V(-.24,.43,-.25),V(0,.12,-.25),V(.24,.43,-.25),V(0,.12,-.25),V(0,-.45,-.25)},.065,C.violet,M.Neon)
 line(m,"Cross stroke",{V(-.25,-.14,-.25),V(.25,-.14,-.25)},.04,C.violet,M.Neon)
 for _,s in {-1,1} do
  line(m,"Hairline fissure",{V(s*.6,.55,-.20),V(s*.49,.33,-.23),V(s*.57,.12,-.22)},.015,C.root,M.Slate)
 end
end

assert(#sculptures==25,"Expected 25 item sculptures.")
for i,m in sculptures do
 local bounds,size=m:GetBoundingBox()
 local scale=4.4/math.max(size.X,size.Y,size.Z)
 m:ScaleTo(scale)
 bounds,size=m:GetBoundingBox()
 local location=V(((i-1)%5)*7,0,math.floor((i-1)/5)*8)
 local target=location+V(0,.7+size.Y/2,0)
 m:PivotTo(CF(target-bounds.Position)*m:GetPivot())
 m:SetAttribute("StudyOnly",true)
 local stand=group(gallery,string.format("Plinth %02d - %s",i,m.Name))
 part(stand,"Stone base",V(5.8,.4,5.8),CF(location+V(0,.2,0)),C.stone,M.Slate)
 part(stand,"Brass reveal",V(5.6,.045,5.6),CF(location+V(0,.42,0)),C.brass,M.Metal)
 part(stand,"Display top",V(5.5,.16,5.5),CF(location+V(0,.52,0)),Color3.fromRGB(29,30,34),M.Slate)
end
local previous=workspace:FindFirstChild("ItemModelStudy")
if previous then
 assert(previous:GetAttribute("GeneratedBy")=="ItemModelStudyV2","ItemModelStudy already exists and is not this generator's gallery.")
 previous.Name="ItemModelStudy_Backup_"..os.date("!%Y%m%d_%H%M%S")
 previous.Parent=game:GetService("ServerStorage")
end
gallery:PivotTo(CF(ORIGIN)*gallery:GetPivot())
gallery.Parent=workspace
pcall(function() game:GetService("Selection"):Set({gallery}) end)
print("25 sculptures in Workspace.ItemModelStudy. Select a model and press F to inspect.")
