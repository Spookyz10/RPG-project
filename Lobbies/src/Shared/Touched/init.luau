local Touched = {}

for _, touch in script:GetDescendants() do
    if touch:IsA("ModuleScript") then
        Touched[touch.Name] = require(touch)
    end
end

return Touched