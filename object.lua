local object = {}
object.__index = object

function object:new(x, y, width, height, options)
    self._x = x
    self._y = y

    self._width  = width
    self._height = height

    self._velocity = {x = 0, y = 0}
    self._deleted  = false
    self._grounded = false

    if not options then
        return
    end

    self._gravity = options.gravity or 0
    self._static  = options.static  or false
    self._name    = options.name    or ("unnamed class: " .. tostring(self))
    self._passive = options.passive or false
end

function object:draw()
    love.graphics.rectangle("fill", self._x, self._y, self._width, self._height)
end

function object:onCollision(other)
    if other:passive() then
        return false
    end
    return "slide"
end

function object:interact(other, x, y)
    if self._velocity.y > 0 and y > 0 then
        self._velocity.y = 0
        self._grounded = true
    end
end

function object:passiveCollide(name, data)
    print(self:name() .. " passively collided with " .. name)
end

function object:static()
    return self._static
end

function object:passive()
    return self._passive
end

function object:deleted()
    return self._deleted
end

function object:setVelocity(x, y)
    local old_vel_x, old_vel_y = self:velocity()

    self._velocity.x = x or old_vel_x
    self._velocity.y = y or old_vel_y
end

function object:velocity()
    return self._velocity.x, self._velocity.y
end

function object:velocityY()
    return self._velocity.y
end

function object:gravity()
    return self._gravity
end

function object:setPosition(x, y)
    self._x = x
    self._y = y
end

function object:setGrounded(grounded)
    self._grounded = grounded
end

function object:grounded()
    return self._grounded
end

function object:position()
    return self._x, self._y
end

function object:size()
    return self._width, self._height
end

function object:bounds()
    return self._x, self._y, self._width, self._height
end

function object:name()
    return self._name
end

local function instance(self, ...)
    local _instance = setmetatable({}, self)
    _instance:new(...)
    return _instance
end

return setmetatable(object, {__call = function(self, ...) return instance(self, ...) end })
