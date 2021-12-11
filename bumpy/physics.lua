local bump = require((...):gsub("physics", "bump"))

local physics = {}
local world = nil

local MAX_GRAVITY = love.graphics.getHeight()
local WORLD_CELL_SIZE = 16

local function parseConfig(config)
    if not config then
        return
    end

    MAX_GRAVITY     = config.gravity
    WORLD_CELL_SIZE = config.cellSize
end

--[[
- @brief Loads the physics module
- @param table: `objects` List of tables that act as objects
- @param table: `config` Configuration options:
    - @field number: `gravity`  max gravity for objects
    - @field number: `cellSize` the bump world cell size
--]]
function physics.load(objects, config)
    parseConfig(config)

    world = bump.newWorld(WORLD_CELL_SIZE)

    for _, entity in pairs(objects) do
        local x, y, width, height = entity:bounds()
        world:add(entity, x, y, width, height)
    end
end

local function defaultFilter(first, second)
    if second:passive() then
        if first.passiveCollide then
            first:passiveCollide(second:name(), second)
        end
        return false
    end
    return "slide"
end

--[[
- @brief Get the entities from the world
- @return: table: `entities` in the world
- @return: number: `length` length of `entities`
--]]
function physics.getEntities()
    return world:getItems()
end

--[[
- @brief Add an entity to the world
- @param table `entity` Entity object
--]]
function physics.addEntity(entity)
    local x, y, width, height = entity:bounds()

    world:add(entity, x, y, width, height)
end

--[[
- @brief Remove an entity from the world
- @param table `entity` Entity object
    - @return boolean `success`
--]]
function physics.removeEntity(entity)
    local items, len = physics.getEntities()

    for index = 1, len do
        if entity == items[index] then
            world:remove(entity)
            return true
        end
    end
    return false
end

--[[
- @brief Query a rectangle in the world
- @param number `x` Left coordinate
- @param number `y` Top coordinate
- @param number `width` Right coordinate
- @param number `height` Bottom coordinate
- @note Think of this as a rectangle box
    - @return list `entities` List of entities from the query
    - @return number `length` Length of `entities` result
--]]
function physics.queryWorld(x, y, width, height)
    return world:queryRect(x, y, width, height)
end

--[[
- @brief Update the world
- @param number `dt` Deltatime from LÖVE
--]]
function physics.update(dt)
    local entities = world:getItems()

    for _, entity in pairs(entities) do
        if entity and not entity:static() then
            if entity:deleted() then
                world:remove(entity)
                return
            end

            local x,   y = entity:position()
            local dx, dy = entity:velocity()

            local filter = defaultFilter
            if entity.filter then
                filter = entity.filter
            end

            local ax, ay, collisions, _ = world:move(entity, x + dx * dt, y + dy * dt, filter)

            -- hit something, resolve
            local horizontal, vertical = false, false

            for index = 1, #collisions do
                local collision = collisions[index].other

                if collisions[index].normalY ~= 0 then
                    vertical = physics.resolveVertical(entity, collision)
                elseif collisions[index].normalX ~= 0 then
                    horizontal = physics.resolveHorizontal(entity, collision)
                end

                entity:setGrounded(vertical)
            end

            if not entity:grounded() then
                local gravity = entity:gravity()

                if gravity ~= 0 then
                    entity:setVelocity(dx, math.min(dy + gravity * dt, MAX_GRAVITY))
                end
            end

            if entity and ax and ay then
                entity:setPosition(ax, ay)
            end
        end
    end
end

-- Internal resolution functions --

function physics.resolveVertical(entity, against)
    local name = against:name()
    local x, velocity = entity:velocity()

    if velocity > 0 then
        if entity.floorCollide then
            if entity:floorCollide(name, against) then
                entity:setVelocity(x, 0)
                return true
            end
        end
        entity:setVelocity(x, 0)
        return true
    else
        if entity.ceilCollide then
            if entity:ceilCollide(name, against) then
                entity:setVelocity(x, 0)
                return true
            end
        end
        entity:setVelocity(x, 0)
        return true
    end
end

function physics.resolveHorizontal(entity, against)
    local name = against:name()
    local velocity, y = entity:velocity()

    if velocity > 0 then
        if entity.rightCollide then
            entity:rightCollide(name, against)
        end
        entity:setVelocity(0, y)
    else
        if entity.leftCollide then
            entity:leftCollide(name, against)
        end
        entity:setVelocity(0, y)
    end
end

return physics
