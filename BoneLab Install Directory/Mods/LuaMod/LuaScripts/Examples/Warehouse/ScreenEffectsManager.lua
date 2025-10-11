local FSM = loadmodule("fsm.lua")


FadedOutAlpha = 1.0
FadedInAlpha = 0.0
FadeSpeed = 0.3
CurrentFadeAlpha = 0.0

function Start()

    FadeFSM = FSM.new({ name = "FadeInOut", host = BL_Host, debug = false })
    FSM.add_state(FadeFSM, "FadeIn",   { on_update = FadeIn_Update })
    FSM.add_state(FadeFSM, "Waiting",   {on_enter = Waiting_Enter, on_update = Waiting_Update })
    FSM.add_state(FadeFSM, "FadeOut",  { on_update = FadeOut_Update  })
    ChangeState("Waiting", true)
end

function ChangeState(name, force)
    FSM.set_state(FadeFSM, name, force)
end

function GetState()
    return FSM.get_state(FadeFSM)
end

function Waiting_Enter()
    WaitingStartTime = Time.time
end

function Waiting_Update()
    
    if(CurrentFadeAlpha >= (FadedOutAlpha*0.8)) then
        if(Time.time > WaitingStartTime+5.0) then
            ChangeState("FadeIn",true)
        end
    end
end

-- fade INTO game world (to transparent)
function FadeIn_Update(self, dt)
    CurrentFadeAlpha = math.max(FadedInAlpha, CurrentFadeAlpha - FadeSpeed * dt)
    if CurrentFadeAlpha <= FadedInAlpha then
        ChangeState("Waiting", true)
    end

    FadeColor.a = CurrentFadeAlpha
    ScreenOverlayImage.color = FadeColor
end

-- fade OUT OF game world (to opaque)
function FadeOut_Update(self, dt)
    CurrentFadeAlpha = math.min(FadedOutAlpha, CurrentFadeAlpha + FadeSpeed * dt)
    if CurrentFadeAlpha >= FadedOutAlpha then
        ChangeState("Waiting", true)
    end

    FadeColor.a = CurrentFadeAlpha
    ScreenOverlayImage.color = FadeColor
end

CameraSetup = false
FadeColor = nil
function Update()

    if(not IsValid(EffectsCamera)) then
        EffectsCamera =  Camera.main
        return
    end

    if(not IsValid(ScreenOverlayCanvas)) then
        local screenOverlayCanvasGO = API_GameObject.BL_FindInChildren("FadeoutOverlay")
        ScreenOverlayCanvas = API_GameObject.BL_GetComponent(screenOverlayCanvasGO,"Canvas")
        ScreenOverlayImage = API_GameObject.BL_GetComponent(screenOverlayCanvasGO,"Image")
        return
    else
        if(not CameraSetup) then
            ScreenOverlayCanvas.worldCamera = EffectsCamera
            CameraSetup = true
            FadeColor = ScreenOverlayImage.color
            ScreenOverlayCanvas.planeDistance = 0.1
            return
        end
    end

    FSM.update(FadeFSM, Time.deltaTime)

end



function FadeOut(nil1,nl2,nil3,nil4)
    print("initiating fade to black")
    ChangeState("FadeOut")
end

function SnapOut(nil1,nil2,nil3,nil4)
    CurrentFadeAlpha = FadedOutAlpha
end

function FadeIn(nil1,nl2,nil3,nil4)
    print("initiating fade into game")
    ChangeState("FadeIn")
end

function SnapIn(nil1,nil2,nil3,nil4)
    CurrentFadeAlpha = FadedInAlpha
end
