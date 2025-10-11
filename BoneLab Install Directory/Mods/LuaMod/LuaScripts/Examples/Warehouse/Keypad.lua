function Start()
CodeTextHolder = API_GameObject.BL_FindInChildren(BL_Host,"Code")
CodeText = API_GameObject.BL_GetComponent(CodeTextHolder,"Text")
CorrectCodeEvent = API_GameObject.BL_GetComponent(BL_Host,"UltEventHolder")
end


function TriggerCorrectCodeEvent()
    if(IsValid(CorrectCodeEvent)) then
        CorrectCodeEvent.Invoke()
    end
end

function TriggerIncorrectCodeEvent()

end

function GenerateDisplayString(partialCodeString)
    local codeLength = string.len(partialCodeString)
    local remainingLength = MaxCodeLength - codeLength
    local padding = string.rep("█ ", remainingLength)
    local codeTextString = partialCodeString .. padding
    return codeTextString
end

MaxCodeLength = 4
CorrectCode = "0451"
CodeString = ""
function KeyButton(key,nil1,nil2,nil3)
    CodeString = CodeString .. tostring(key)
    
    if(string.len(CodeString) >= MaxCodeLength) then
        if(CodeString == CorrectCode) then
            print("correct code entered: " .. tostring(CodeString))
            TriggerCorrectCodeEvent()
        else
            print("incorrect code entered: " .. tostring(CodeString))
            TriggerIncorrectCodeEvent()
        end
        CodeString = ""
    end

    CodeText.text = GenerateDisplayString(CodeString)

end

