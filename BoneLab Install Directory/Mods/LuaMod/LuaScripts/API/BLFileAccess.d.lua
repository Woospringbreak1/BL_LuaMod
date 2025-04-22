---@class BLFileAccess
BLFileAccess = {}

---@param contents string
---@param append bool
---@return bool
function BLFileAccess.Write(contents, append) end

---@param line string
---@param append bool
---@return bool
function BLFileAccess.WriteLine(line, append) end

---@return string
function BLFileAccess.ReadToEnd() end

---@return string
function BLFileAccess.ReadLine() end

function BLFileAccess.Close() end
