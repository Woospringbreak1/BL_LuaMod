--LuaBehaviour


function Start()
    print("Hello, World from Bonemenu Test!")
    print("I am " .. tostring(BL_This) .. " " .. BL_This.name)

    MainPage = API_BoneMenu.BL_Page.CreatePage("LuaMenu", Color.white);
    func1 = API_BoneMenu.BL_CreateFunction(MainPage,"test 1", Color.white,BL_This,"GUITestFunction");
    SpidermanToggle = MainPage.CreateBool("Enable Spiderman mode", Color.white,false, nil)
    SpidermanHandToggle = MainPage.CreateBool("Webslinger on left hand?", Color.white,false, nil)
    JetpackToggle = MainPage.CreateBool("Enable Jetpack", Color.white,false, nil)
    VertigoToggle = MainPage.CreateBool("Enable Vertigo 2 teleportation", Color.white,false, nil)
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
   else
      SpiderManSkills = locate
   end
end

function SetupJetpack()
   local locate = GameObject.Find("AbioticFactorJetpack")
   if(locate == nil or not API_GameObject.BL_IsValid(locate)) then
      AbioticFactorJetpack = API_GameObject.BL_CreateEmptyGameObject()
      AbioticFactorJetpack.SetActive(false)
      AbioticFactorJetpack.name = "AbioticFactorJetpack"
      AbioticFactorJetpackBehaviour = API_GameObject.BL_AddComponent(AbioticFactorJetpack,"LuaBehaviour")
      AbioticFactorJetpackBehaviour.ScriptName = ("AbioticFactor_Jetpack_AvatarAttachment.lua")
      AbioticFactorJetpack.SetActive(true)      
   else
      AbioticFactorJetpack = locate
   end
end

function SetupVertigoTeleporter()
   local locate = GameObject.Find("VertigoTeleporter")
   if(locate == nil or not API_GameObject.BL_IsValid(locate)) then
      VertigoTeleporter = API_GameObject.BL_CreateEmptyGameObject()
      VertigoTeleporter.SetActive(false)
      VertigoTeleporter.name = "VertigoTeleporter"
      VertigoTeleporterBehaviour = API_GameObject.BL_AddComponent(VertigoTeleporter,"LuaBehaviour")
      VertigoTeleporterBehaviour.ScriptName = ("Vertigo2_Teleporter_AvatarAttachment.lua")
      VertigoTeleporter.SetActive(true)      
   else
      VertigoTeleporter = locate
   end
end

function SpidermanToggleUpdate()

   if(SpidermanToggle == nil) then
      return
   end

   if(SpiderManSkills ~= nil and API_GameObject.BL_IsValid(SpiderManSkills) and SpiderBehaviour.Ready) then
      SpiderBehaviour.CallFunction("SetLeftHanded", SpidermanHandToggle.value) --should really be an event
   end

   if(SpidermanToggle.value) then
      if(SpiderManSkills == nil or not API_GameObject.BL_IsValid(SpiderManSkills)) then
         SetupSpidermanSkills()
      end
   else
      if(SpiderManSkills ~= nil) then
         API_GameObject.BL_DestroyGameObject(SpiderManSkills)
      end
   end

end

function JetpackToggleUpdate()

   if(JetpackToggle == nil) then
      return
   end

   if(JetpackToggle.value) then
      if(AbioticFactorJetpack == nil or not API_GameObject.BL_IsValid(AbioticFactorJetpack)) then
         SetupJetpack()
      end
   else
      if(AbioticFactorJetpack ~= nil ) then
         API_GameObject.BL_DestroyGameObject(AbioticFactorJetpack)
      end
   end

end

function VertigoTeleporterToggleUpdate()

   if(VertigoToggle == nil) then
      return
   end

   if(VertigoToggle.value) then
      if(VertigoTeleporter == nil or not API_GameObject.BL_IsValid(VertigoTeleporter)) then
         SetupVertigoTeleporter()
      end
   else
      if(VertigoTeleporter ~= nil ) then
         API_GameObject.BL_DestroyGameObject(VertigoTeleporter)
      end
   end

end

function Update()

   if(BL_This == nil or not API_GameObject.BL_IsValid(BL_Host) or not BL_This.Ready) then
      return
  end

   SpidermanToggleUpdate()
   JetpackToggleUpdate()
   VertigoTeleporterToggleUpdate()
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

