---@class API_Player
API_Player = {}

---@return Avatar
function API_Player.BL_GetAvatar() end

---@return GameObject
function API_Player.BL_GetAvatarGameObject() end

---@return DynValue
function API_Player.BL_GetAvatarCenter() end

---@return PhysicsRig
function API_Player.BL_GetPhysicsRig() end

---@return ControllerRig
function API_Player.BL_GetControllerRig() end

---@return Health
function API_Player.BL_PlayerHealth() end

---@param pos Vector3
---@param rot Quaternion
function API_Player.BL_SetAvatarPosition(pos, rot) end

---@param pos Vector3
function API_Player.BL_SetAvatarPosition(pos) end
