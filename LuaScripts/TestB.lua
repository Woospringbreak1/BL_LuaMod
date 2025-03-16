--LuaBehaviour
i = 0
function Start()
    print("Hello, World from TestB!")
end

function Update()
    if(API_Input.BL_IsKeyDown(98)) then
        print("B is down")
        PlayerAvatar = API_Player.BL_GetAvatarGameObject();
        NewPosition = API_Player.BL_GetAvatarPosition() + API_Vector3.BL_Vector3(0, 0.01, 0);
        API_Player.BL_SetAvatarPosition(NewPosition);
        print("Player avatar name: " .. PlayerAvatar.name .. " located at: " .. tostring(NewPosition))
    end

    function OnEnable()
        print("OnEnable")
    end

    function OnDisable()
        print("OnDisable")
    end

    function OnDestroy()
        print("OnDestroy")
    end
    
end