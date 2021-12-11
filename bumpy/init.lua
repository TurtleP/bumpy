local path = ...

local success = require(path .. ".physics")
if success then
    return success
end
return error(success)
