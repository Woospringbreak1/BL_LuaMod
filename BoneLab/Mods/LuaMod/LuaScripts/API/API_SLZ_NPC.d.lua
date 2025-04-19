---@class API_SLZ_NPC
API_SLZ_NPC = {}

---@param position Vector3
---@param maxDistance number
---@param areaMask integer
---@return Vector3
function API_SLZ_NPC.BL_SamplePosition(position, maxDistance, areaMask) end

---@param start Vector3
---@param end Vector3
---@param areaMask integer
---@return NavMeshPath
function API_SLZ_NPC.BL_CalculatePath(start_pos, end_pos, areaMask) end

---@param NPC GameObject
---@param Target GameObject
---@return boolean
function API_SLZ_NPC.BL_SetNPCAnger(NPC, Target) end
