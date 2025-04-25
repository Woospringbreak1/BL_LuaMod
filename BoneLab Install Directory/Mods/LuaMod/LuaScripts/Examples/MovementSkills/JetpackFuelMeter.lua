--LuaBehaviour
i = 0
function Start()
    RandSeed = Time.time
    math.randomseed(RandSeed)

    TextMeshProA = API_GameObject.BL_GetComponentInChildren(BL_Host,"TextMeshPro")
    --print(tostring(TextMeshProA))
   -- print(TextMeshProA.text)

    CurrentReading = 1.0
    
    colorHigh = Color.green
    colorMed = Color.yellow
    colorLow = Color.red
    colorLow_flash_on = Color.red
    colorLow_flash_on.r = 0.2
    colorLow_flash_off = Color.red
    --colorLow_flash = Color.blue

    threshholdHigh = 0.8
    threshholdMed = 0.5
    threshholdLow = 0.3

    MaxNumberOfSegments = 10


end

flashing = false
flashON = true
FlashPeriod = 0.1
FlashONTime = 0

function UpdateTextMesh(numberOfSegments)
    local NumberOfSegments = numberOfSegments
    if(numberOfSegments < 1) then
        NumberOfSegments = 1
    end

    TextMeshProA.text = string.rep("▌", NumberOfSegments)
    TextMeshProA.ForceMeshUpdate() 
end

function HandleFlashing()
    if not flashing then return end
    if Time.time > FlashONTime then
        flashON = not flashON
        FlashONTime = Time.time + FlashPeriod
        --print("flashing")
    else
       -- print("time " .. tostring(Time.time) .. " FlashONTime " .. tostring(FlashONTime))
    end

    if flashON then
        TextMeshProA.m_fontColor = colorLow_flash_on
    else
        TextMeshProA.m_fontColor = colorLow_flash_off
    end
    UpdateTextMesh(round(CurrentReading*MaxNumberOfSegments))

end

function Update()
    HandleFlashing()
end

function round(num)
    --why is this not in the standard library
    return math.floor(num + 0.5)
end


function SetOverheated(overheated, dispnumber)
    if(overheated) then
        flashing = true
        CurrentReading = dispnumber
    else
        flashing = false
        SetDisplayNumber(dispnumber)
    end
end

function SetDisplayNumber(dispnumber)
    flashing = false
    CurrentReading = dispnumber
    if(CurrentReading > 1) then
        CurrentReading = 1
    elseif CurrentReading < 0 then
        CurrentReading = 0
    end

    UpdateTextMesh(round(CurrentReading*MaxNumberOfSegments))

    if(CurrentReading <= threshholdLow) then
        TextMeshProA.m_fontColor = colorLow
    elseif(CurrentReading <= threshholdMed) then
        TextMeshProA.m_fontColor = colorMed
    else
        TextMeshProA.m_fontColor = colorHigh
    end
end


