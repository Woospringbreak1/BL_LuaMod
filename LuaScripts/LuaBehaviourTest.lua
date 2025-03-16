--LuaBehaviour
i = 0
function Start()
    print("Hello, World!")
end

function Update()
   -- print("update " .. BL_GetAvatarName())
    i = i + 1
    --print('i = ' .. i)

    if(BL_IsKeyDown(97)) then
        print("A is down")
    end
    
    
end