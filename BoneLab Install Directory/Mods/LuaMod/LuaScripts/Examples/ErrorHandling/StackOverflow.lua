require("Examples\\ErrorHandling\\BaseExample.lua")

StackOverflow = false
function SetStatus(status)
StackOverflow = status
end

function Update()

    if(not BL_This.Ready) then
        return
    end

    if(StackOverflow) then
        print("triggering stack overflow")
        Update()
    end
end