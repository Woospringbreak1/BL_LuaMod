---@class API_Input
API_Input = {}

---@return boolean
function API_Input.BL_IsAButtonDown() end
function API_Input.BL_IsAButtonDownOnce() end
function API_Input.BL_IsAButtonUpOnce() end
function API_Input.BL_IsBButtonDown() end
function API_Input.BL_IsBButtonDownOnce() end
function API_Input.BL_IsBButtonUpOnce() end
function API_Input.BL_IsXButtonDown() end
function API_Input.BL_IsXButtonDownOnce() end
function API_Input.BL_IsXButtonUpOnce() end
function API_Input.BL_IsYButtonDown() end
function API_Input.BL_IsYButtonDownOnce() end
function API_Input.BL_IsYButtonUpOnce() end

---@return GameObject
function API_Input.BL_LeftHand() end
function API_Input.BL_RightHand() end

---@return boolean
function API_Input.BL_LeftHandEmpty() end
function API_Input.BL_RightHandEmpty() end
function API_Input.BL_LeftController_IsGrabbed() end
function API_Input.BL_RightController_IsGrabbed() end

---@param keyCodeArg integer
---@return boolean
function API_Input.BL_IsKeyDown(keyCodeArg) end
