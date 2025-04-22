function Start()
    --after the map has loaded, we can set up our button references
    API_Events.BL_SubscribeEvent("OnSceneWasInitialized",BL_This,"Test")

    local saveFileName = "SaveSystemTest_SaveGame.txt"
    FileAccess = API_FileAccess.BL_OpenFile(saveFileName)

    local saveLoadResource = API_GameObject.BL_GetComponent(BL_Host,"LuaResources")

    --load references to the button crate spawner pose decorators from the attached LuaResources
    Button1Decorator = API_GameObject.BL_GetComponent(saveLoadResource.GetObject("button1","GameObject"),"MarrowEntityPoseDecorator")
    Button2Decorator = API_GameObject.BL_GetComponent(saveLoadResource.GetObject("button2","GameObject"),"MarrowEntityPoseDecorator")
    Button3Decorator = API_GameObject.BL_GetComponent(saveLoadResource.GetObject("button3","GameObject"),"MarrowEntityPoseDecorator")
    Button4Decorator = API_GameObject.BL_GetComponent(saveLoadResource.GetObject("button4","GameObject"),"MarrowEntityPoseDecorator")

    if(API_FileAccess.BL_FileExists(saveFileName)) then
        Load()
    else
        print("no file to load")
    end

end

function Test()
    print("should be called...")
end
function Update()
    
    ---wait until everything has spawned and all scripts are loaded
    if(not IsValid(Button1Controller) or not IsValid(Button2Controller) or not IsValid(Button3Controller) or not IsValid(Button4Controller)) then
        if(IsValid(Button1) and IsValid(Button2) and IsValid(Button3) and IsValid(Button4)) then
            SetupButtonReferences()
        end
    end
    

end

function RegisterButton(nil1,nil2,SpawnName,spawnedObject)
    ---this function is called by an OnSpawn ULTEvent on the crate spawner
    ---The parameter is a UnityEngine.Object, which needs to be cast to a GameObject

    spawnedGameObject = API_Utils.BL_ConvertObjectToType(spawnedObject,"GameObject")
    if(not IsValid(spawnedGameObject)) then
        print("failed to register button: " .. SpawnName)
        return
    else
        print("registered button: " .. SpawnName)
        _G[SpawnName] = spawnedGameObject
    end


    
end

function SetupButtonReferences()
    print("setting up button references")

    Button1Controller = API_GameObject.BL_GetComponentInChildren(Button1,"ButtonController")
    Button2Controller = API_GameObject.BL_GetComponentInChildren(Button2,"ButtonController")
    Button3Controller = API_GameObject.BL_GetComponentInChildren(Button3,"ButtonController")
    Button4Controller = API_GameObject.BL_GetComponentInChildren(Button4,"ButtonController")
end


function Save()
    print("Saving...")
    FileAccess.WriteLine("BEGIN SAVE INFO",false) --append is false, so it will overwrite the file
    FileAccess.WriteLine(tostring(Button1Controller._charged),true)
    FileAccess.WriteLine(tostring(Button2Controller._charged),true)
    FileAccess.WriteLine(tostring(Button3Controller._charged),true)
    FileAccess.WriteLine(tostring(Button4Controller._charged),true)
end

function Load()

    ---set button dectorators, this will set if the button is up or down
    
    print("Loading...")
    FileAccess.ReadLine() --skip the first line, which is the header

    local Button1Status = (FileAccess.ReadLine()=="true")
    local Button2Status = (FileAccess.ReadLine()=="true")
    local Button3Status = (FileAccess.ReadLine()=="true")
    local Button4Status = (FileAccess.ReadLine()=="true")

    SetButtonDecorator(Button1Decorator,Button1Status)
    SetButtonDecorator(Button2Decorator,Button2Status)
    SetButtonDecorator(Button3Decorator,Button3Status)
    SetButtonDecorator(Button4Decorator,Button4Status)

end
    

function SetButtonDecorator(button,status)
    if(status) then
        API_SLZ_VoidLogic.BL_SetMarrowEntityPoseDectoratorPose(button,"SLZ.Backlot.EntityPose.Button3xDown")
    else
        API_SLZ_VoidLogic.BL_SetMarrowEntityPoseDectoratorPose(button,"SLZ.Backlot.EntityPose.Button3xUp")
    end
end

function Haxxor()
    ---should throw an exception.
    ---let me know if it doesn't
    print("attempting to open file outside of sandbox")
    local fileAccessHack = API_FileAccess.BL_OpenFile("..\\..\\..\\..\\..\\..\\..\\SaveSystemTest.txt")
    fileAccessHack.WriteLine("Line1")
    fileAccessHack.WriteLine("Line2")
    fileAccessHack.WriteLine("Line3")
end
    