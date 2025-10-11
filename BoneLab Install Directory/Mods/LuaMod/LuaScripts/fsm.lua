-- fsm.lua
-- Simple finite state machine without metatables

local FSM = {}

-- Constructor
function FSM.new(config)
    local self = {
        name     = config and config.name or "fsm",
        host     = config and config.host or nil,
        debug    = config and config.debug or false,
        states   = {},
        current  = nil,
        previous = nil,
    }
    return self
end

-- Add a state
function FSM:add_state(name, def)
    if self.debug then
        print("FSM [" .. self.name .. "] adding state: " .. name)
    end
    self.states[name] = {
        on_enter  = def.on_enter  or function() end,
        on_update = def.on_update or function() end,
        on_exit   = def.on_exit   or function() end,
    }
end

-- Change state
function FSM:set_state(name, force)
    if not self.states[name] then
        print("FSM [" .. self.name .. "] no such state: " .. tostring(name))
        return
    end
    if not force and self.current == name then
        return
    end

    if self.current then
        local state = self.states[self.current]
        if state.on_exit then
            state.on_exit(self, name)
        end
    end

    self.previous = self.current
    self.current  = name

    local newState = self.states[self.current]
    if newState.on_enter then
        newState.on_enter(self, self.previous)
    end
end

-- Update loop
function FSM:update(dt)
    if not self.current then return end
    local state = self.states[self.current]
    if state and state.on_update then
        state.on_update(self, dt)
    end
end

-- Helpers
function FSM:get_state()
    return self.current
end

function FSM:get_previous()
    return self.previous
end

return FSM
