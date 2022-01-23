local physics = require("bumpy")
local object  = require("object")

local player = nil
function love.load()
    player = object(296, 16, 32, 48, {gravity = 300, name = "player"})

    local floor = object(0, 240 - 32, 400, 32, {name = "floor", static = true})
    local passthrough = object(200, 240 - 32 - 64, 32, 64, {name = "wall", passive = true, static = true})

    local floor2 = object(296, 240 - 32 - 64, 32, 64, {name = "floorWall", static = true})

    local objects = {player, floor, passthrough, floor2}

    physics.load(objects)
end

function love.update(dt)
    physics.update(dt)
end

function love.draw()
    local objects = physics.getEntities()

    for _, value in ipairs(objects) do
        value:draw()
    end
end

function love.keypressed(key)
    if key == "space" then
        if player:grounded() then
            player:setGrounded(false)
            player:setVelocity(nil, -100)
        end
    elseif key == "d" then
        player:setVelocity(100, nil)
    elseif key == "a" then
        player:setVelocity(-100, nil)
    end
end

function love.keyreleased(key)
    if key == "d" or key == "a" then
        player:setVelocity(0, nil)
    end
end
