function Start()

    ExternalActuator = API_GameObject.BL_GetComponent(BL_Host,"ExternalActuator")

end

function SlowUpdate()
    if(not BL_This.Ready) then
        return
    end


    if IsValid(ExternalActuator) and IsValid(ExternalActuator.input) then
       -- print("ExternalActuator.input.inlineValue: " .. tostring(ExternalActuator.input.inlineValue))

        if (ExternalActuator.input.inlineValue > 0.95) then
            SetStatus(true)
        else
            SetStatus(false)
        end
    end
end


function SetStatus(status)
    print("base setStatus called")
end