---@class API_SLZ_Combat
API_SLZ_Combat = {}

---@param damage number
---@param collider Collider
---@param pos Vector3
---@param normal Vector3
---@return Attack
function API_SLZ_Combat.BL_CreateAttackStruct(damage, collider, pos, normal) end

---@param rb Rigidbody
---@param pos Vector3
---@param normal Vector3
---@param force number
---@return boolean
function API_SLZ_Combat.ApplyForce(rb, pos, normal, force) end

---@param obj GameObject
---@param damage number
---@param col Collider
---@param pos Vector3
---@param normal Vector3
---@return boolean
function API_SLZ_Combat.BL_AttackEnemy(obj, damage, col, pos, normal) end
