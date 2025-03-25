local World = {}
World.__index = World

function World.new()
    local self = setmetatable({}, World)
    self.entities = {}
    self.components = {}
    self.systems = {}
    self.nextEntityId = 1
    self.entitiesToDestroy = {}
    return self
end

function World:createEntity()
    local entityId = self.nextEntityId
    self.nextEntityId = self.nextEntityId + 1
    self.entities[entityId] = true
    return entityId
end

function World:destroyEntity(entityId)
    table.insert(self.entitiesToDestroy, entityId)
end

function World:registerComponent(componentName)
    self.components[componentName] = {}
end

function World:addComponent(entityId, componentName, data)
    if not self.components[componentName] then
        self:registerComponent(componentName)
    end
    self.components[componentName][entityId] = data
    return data
end

function World:getComponent(entityId, componentName)
    if not self.components[componentName] then return nil end
    return self.components[componentName][entityId]
end

function World:removeComponent(entityId, componentName)
    if not self.components[componentName] then return end
    self.components[componentName][entityId] = nil
end

function World:addSystem(system)
    table.insert(self.systems, system)
    system.world = self
    if system.init then system:init() end
    return system
end

function World:update(dt)
    for _, system in ipairs(self.systems) do
        if system.update then
            system:update(dt)
        end
    end

    -- Process entities queued for destruction
    for _, entityId in ipairs(self.entitiesToDestroy) do
        self.entities[entityId] = nil
        for componentName, _ in pairs(self.components) do
            self.components[componentName][entityId] = nil
        end
    end
    self.entitiesToDestroy = {}
end

function World:draw()
    for _, system in ipairs(self.systems) do
        if system.draw then
            system:draw()
        end
    end
end

return World
