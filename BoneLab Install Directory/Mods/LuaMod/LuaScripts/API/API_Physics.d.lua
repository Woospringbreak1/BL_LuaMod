---@class API_Physics
API_Physics = {}

---@param origin Vector3
---@param direction Vector3
---@param radius float
---@param maxdistance float
---@return DynValue
function API_Physics.BL_SphereCast(origin, direction, radius, maxdistance) end

---@param start_pos Vector3
---@param end_pos Vector3
---@param radius float
---@return DynValue
function API_Physics.BL_SphereCast(start_pos, end_pos, radius) end

---@param origin Vector3
---@param radius float
---@param direction Vector3
---@param maxDistance float
---@param layerMask int
---@return DynValue
function API_Physics.BL_SphereCastAll(origin, radius, direction, maxDistance, layerMask) end

---@param start_pos Vector3
---@param end_pos Vector3
---@param radius float
---@param layerMask int
---@return DynValue
function API_Physics.BL_SphereCastAll(start_pos, end_pos, radius, layerMask) end

---@param start_pos Vector3
---@param end_pos Vector3
---@return DynValue
function API_Physics.BL_RayCast(start_pos, end_pos) end

---@param origin Vector3
---@param direction Vector3
---@param maxdistance float
---@return DynValue
function API_Physics.BL_RayCast(origin, direction, maxdistance) end

---@param center Vector3
---@param halfExtents Vector3
---@param direction Vector3
---@param orientation Quaternion
---@param maxDistance float
---@param layerMask int
---@return DynValue
function API_Physics.BL_BoxCast(center, halfExtents, direction, orientation, maxDistance, layerMask) end

---@param center Vector3
---@param halfExtents Vector3
---@param direction Vector3
---@param orientation Quaternion
---@param maxDistance float
---@param layerMask int
---@return DynValue
function API_Physics.BL_BoxCastAll(center, halfExtents, direction, orientation, maxDistance, layerMask) end

---@param point1 Vector3
---@param point2 Vector3
---@param radius float
---@param direction Vector3
---@param maxDistance float
---@param layerMask int
---@return DynValue
function API_Physics.BL_CapsuleCast(point1, point2, radius, direction, maxDistance, layerMask) end

---@param point1 Vector3
---@param point2 Vector3
---@param radius float
---@param direction Vector3
---@param maxDistance float
---@param layerMask int
---@return DynValue
function API_Physics.BL_CapsuleCastAll(point1, point2, radius, direction, maxDistance, layerMask) end
