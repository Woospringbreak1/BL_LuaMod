--LuaBehaviour


function Start()
    print("Hello, World from Bonemenu Test!")
    print("I am " .. tostring(BL_This) .. " " .. BL_This.name)

    MainPage = API_BoneMenu.BL_Page.CreatePage("LuaMenu", Color.white);
    func1 = API_BoneMenu.BL_CreateFunction(MainPage,"test 1", Color.white,BL_This,"GUITestFunction");
    SpidermanToggle = MainPage.CreateBool("Enable Spiderman mode", Color.white,false, nil)
    SpidermanHandToggle = MainPage.CreateBool("Webslinger on left hand?", Color.white,false, nil)
    newFloat = MainPage.CreateFloat("floatval", Color.white, 15.2, 0.1, 1, 18, nil)
    newFloat2 = MainPage.CreateFloat("ignore this float", Color.white, 15.2, 0.1, 1, 18, nil)
    secondPage = MainPage.CreatePage("LuaMenu 2nd", Color.red);
    func2 = API_BoneMenu.BL_CreateFunction(secondPage,"test 2", Color.white,BL_This,"GUITestFunction2");

    API_Events.BL_SubscribeEvent("BoneMenu_Float_OnValueChanged",BL_This,"BoneMenu_Float_Changed")
    
end

function SetupSpidermanSkills()
   local locate = GameObject.Find("SpidermanSkills")
   if(locate == nil or not API_GameObject.BL_IsValid(locate)) then
      SpiderManSkills = API_GameObject.BL_CreateEmptyGameObject()
      SpiderManSkills.SetActive(false)
      SpiderManSkills.name = "SpidermanSkills"
      SpiderBehaviour = API_GameObject.BL_AddComponent(SpiderManSkills,"LuaBehaviour")
      SpiderBehaviour.ScriptName = ("Spiderman_WebShooter_AvatarAttachment.lua")
      SpiderManSkills.SetActive(true)
      SpiderBehaviour.CallFunction("SetLeftHanded", SpidermanHandToggle.value)
      
   else
      SpiderManSkills = locate
   end
end

function Update()

   if(SpiderManSkills ~= nil and API_GameObject.BL_IsValid(SpiderManSkills)) then
      SpiderBehaviour.CallFunction("SetLeftHanded", SpidermanHandToggle.value) --should really be an event
   end

   if(BL_This ~= nil and BL_This.Ready and SpidermanToggle ~= nil) then

      if(SpidermanToggle.value) then
         if(SpiderManSkills == nil or not API_GameObject.BL_IsValid(SpiderManSkills)) then
            SetupSpidermanSkills()
         else
            SpiderManSkills.SetActive(true)
         end
      else
         if(SpiderManSkills ~= nil and API_GameObject.BL_IsValid(SpiderManSkills)) then
            SpiderManSkills.SetActive(false)
         end
      end
   else
   end
end

function GUITestFunction()
    print("GUI Test Function called")
 end

 function GUITestFunction2()
    print("GUI Test Function called from secondary page")
 end

 function BoneMenu_Float_Changed(FloatElement,value)
    if(FloatElement == newFloat ) then
        print("Float value changed to: " .. tostring(value))
    end
 end

function  OnDisable()

   -- print("deleting lua test menu from OnDisable")
    --MainPage.removeAll()
   -- API_BoneMenu.BL_DeletePage(MainPage) 
    
end

 function OnDestroy()
  --  print("deleting lua test menu from OnDestroy")
    --MainPage.removeAll()
    --API_BoneMenu.BL_DeletePage(MainPage) 
 end

function PlayerEventTest(Attack)
   -- print("PlayerHealth_OnReceivedDamage event received! " .. tostring(Attack))
   -- print("attack damage: " .. tostring(Attack.damage))
end

function PlayerEventTest2(Attack)
    --print("custom event from LUA")
end

function PlayerEventTest3(NPC)
   -- print("NPC Killed :( " .. NPC.name)
end

function PlayerEventTest4(Object, Attack)
   -- print(Object.name .. " received damage: ")
   -- print(" received damage: " .. tostring(Attack.damage))
end


function TriggerPulled()
    -- Note: TriggerPulled is called every frame when the trigger is held down
    -- regardless of magazine status, bullet chambered etc.

end

