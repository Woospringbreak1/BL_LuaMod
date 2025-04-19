---@class API_Physics
API_Physics = {}

---@param origin Vector3
---@param direction Vector3
---@param radius number
---@param maxdistance number
---@return DynValue
function API_Physics.BL_SphereCast(origin, direction, radius, maxdistance) end

---@param start Vector3
---@param end Vector3
---@param radius number
---@return DynValue
function API_Physics.BL_SphereCast(start_pos, end_pos, radius) end

---@param start Vector3
---@param end Vector3
---@return DynValue
function API_Physics.BL_RayCast(start_pos, end_pos) end

---@param origin Vector3
---@param direction Vector3
---@param maxdistance number
---@return DynValue
function API_Physics.BL_RayCast(origin, direction, maxdistance) end
