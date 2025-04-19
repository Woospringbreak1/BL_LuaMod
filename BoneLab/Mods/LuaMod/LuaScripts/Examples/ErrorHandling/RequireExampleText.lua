Example = require("Examples\\ErrorHandling\\RequireExample.lua")

function Start()
    print("starting require() tests")
    print(tostring(Example))
    TestMessage()
    print("TestMessage2: " .. TestMessage2)
end