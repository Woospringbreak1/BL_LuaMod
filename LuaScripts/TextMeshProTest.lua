--LuaBehaviour
i = 0
function Start()
    RandSeed = API_GameObject.TimeSinceOpen()
    math.randomseed(RandSeed)

    print("Hello, World from Text mesh pro!")
    TextMeshProA = API_GameObject.BL_GetComponent2(BL_Host,"TextMeshPro")
    print(tostring(TextMeshProA))
    print(TextMeshProA.text)

    CurrentReading = 10
    
    colorHigh = Color.green
    colorMed = Color.yellow
    colorLow = Color.red
    threshholdHigh = 8
    threshholdMed = 5
    threshholdLow = 3

    SliderCrate = GameObject.Find("CrateSpawner (Slider)")
    if(SliderCrate ~= nil) then
        SliderCircuitComponent = API_GameObject.BL_GetComponent2(SliderCrate,"SwitchDecorator")
        SliderPoseComponent = API_GameObject.BL_GetComponent2(SliderCrate,"MarrowEntityPoseDecorator")
        print("SliderCircuitComponent " .. tostring(SliderCircuitComponent))
        print("SliderPoseComponent " .. tostring(SliderPoseComponent))
    else
        print("SliderCrate is nil")
    end

    ValueCircuit = API_GameObject.BL_GetComponent2(BL_Host,"ValueCircuit")
    if(ValueCircuit ~= nil) then
        print("ValueCircuit " .. tostring(ValueCircuit))
    else
        print("ValueCircuit is nil")
    end
end


function round(num)
    --why is this not in the standard library
    return math.floor(num + 0.5)
end


function SetDisplayNumber(dispnumber)

    TextMeshProA.text = string.rep("▌", dispnumber)

    if(dispnumber <= threshholdLow) then
        TextMeshProA.m_fontColor = colorLow
    elseif(dispnumber <= threshholdMed) then
        TextMeshProA.m_fontColor = colorMed
    else
        TextMeshProA.m_fontColor = colorHigh
    end

    if(ValueCircuit ~= nil) then
        if(dispnumber > threshholdLow and dispnumber <= threshholdMed) then
            ValueCircuit.Value = 0.0
           -- print("setting ValueCircuit.Value to 0.0")
        else
            ValueCircuit.Value = 1.0
           -- print("setting ValueCircuit.Value to 1.0")
        end
    else
        print("ValueCircuit is nil")
    end


end


onlyonce = false
function Update()


    if(SliderCircuitComponent ~= nil) then
        SliderPosition = SliderCircuitComponent._inlineValue
        DisplayValue = round(SliderPosition*10.0)
        SetDisplayNumber(DisplayValue)
    end


    if(API_Input.BL_IsKeyDown(98)) then
        if(onlyonce == false) then
            onlyonce = true
            CurrentReading = CurrentReading - 1
            if(CurrentReading <= 0) then
                CurrentReading = 10
            end
            SetDisplayNumber(CurrentReading)
        end

    else
        onlyonce = false
    end
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
    
