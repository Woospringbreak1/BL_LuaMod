---@class API_Random
API_Random = {}

---@param min float
---@param max float
---@return float
function API_Random.RangeFloat(min, max) end

---@param min int
---@param max int
---@return int
function API_Random.RangeInt(min, max) end

---@return float
function API_Random.Value() end

---@return bool
function API_Random.Bool() end

---@return Quaternion
function API_Random.Rotation() end

---@return Quaternion
function API_Random.RotationUniform() end

---@return Vector3
function API_Random.InsideUnitSphere() end

---@return Vector2
function API_Random.InsideUnitCircle() end

---@return Vector3
function API_Random.OnUnitSphere() end

---@param seed int
function API_Random.InitState(seed) end

---@return State
function API_Random.GetState() end

---@param state State
function API_Random.SetState(state) end
