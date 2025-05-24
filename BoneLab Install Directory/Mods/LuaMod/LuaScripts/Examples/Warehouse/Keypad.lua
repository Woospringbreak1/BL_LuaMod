function Start()
Code = API_GameObject.BL_FindInChildren(BL_Host,"Code")
CodeText = API_GameObject.BL_GetComponent(Code,"Text")

print("Code: " .. tostring(Code))
print("CodeText: " .. tostring(CodeText))
end

function KeyButton(key,nil1,nil2,nil3)
print("button pressed: " .. tostring(key))
CodeText.text = CodeText.text .. tostring(key)
print("code text: " .. CodeText.text)
end

