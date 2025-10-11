function Start()
BudgetLine = API_GameObject.BL_FindInChildren(BL_Host,"BudgetLine")
BudgetText = API_GameObject.BL_GetComponent(BudgetLine,"Text")
ItemSpawnpoint = API_GameObject.BL_FindInChildren(BL_Host,"ItemSpawnpoint")
WarehouseManager = API_GameObject.BL_GetComponent(API_GameObject.BL_FindInWorld("WarehouseManager"),"LuaBehaviour")
IntroPage = API_GameObject.BL_FindInChildren(BL_Host,"Intro")
PackagesPage = API_GameObject.BL_FindInChildren(BL_Host,"Packages")
StorePage = API_GameObject.BL_FindInChildren(BL_Host,"Store")

AudioList = API_GameObject.BL_GetComponents(BL_Host,"AudioSource")
PurchaseSound = AudioList[1]
FailSound = AudioList[2]



IntroButton(nil,nil,nil,nil)
end


function SlowUpdate()
    RefreshShop()
end

function RefreshShop()
    ShopItems = API_GameObject.BL_FindAllInChildren(StorePage,"StoreItem")
    AdjustBudgetDisplay()
    if(ShopItems == nil or #ShopItems == 0) then
        print("No shop items found in store page")
        return
    end
    
    for index, value in ipairs(ShopItems) do

        if(not IsValid(value)) then
            print("Invalid shop item at index: " .. tostring(index))
        else
            local purchaseResource = API_GameObject.BL_GetComponent(value,"LuaResources")
            local itemName = purchaseResource.GetString("ItemName")
            local itemCost = purchaseResource.GetFloat("ItemCost")
            local itemDescription = purchaseResource.GetString("ItemDescription")
            
            local StoreItemText = API_GameObject.BL_FindInChildren(value,"StoreItemText")
            local StoreItemTextComp = API_GameObject.BL_GetComponent(StoreItemText,"Text")
            StoreItemTextComp.text = itemName .. " - $" .. tostring(itemCost) .. "\n" .. itemDescription
            UpdateItemInStock(value)
        end
    end
end

function AdjustBudgetDisplay()
    if(WarehouseManager ~= nil) then
        local currentBudget = WarehouseManager.GetScriptVariable("WarehouseBudget")
        if(currentBudget ~= nil) then
            BudgetText.text = "Budget: $" .. tostring(math.floor(currentBudget))
        else
            BudgetText.text = "Budget: $0"
        end
    else
        BudgetText.text = "Budget: $0"
    end
end


function IntroButton(nil1,nil2,nil3,nil4)
    IntroPage.setActive(true)
    PackagesPage.setActive(false)
    StorePage.setActive(false)
end

function PackageButton(nil1,nil2,nil3,nil4)
    IntroPage.setActive(false)
    PackagesPage.setActive(true)
    StorePage.setActive(false)
end

function StoreButton(nil1,nil2,nil3,nil4)
    RefreshShop()
    IntroPage.setActive(false)
    PackagesPage.setActive(false)
    StorePage.setActive(true)
end

function PlayPurchaseSound()
    if(IsValid(PurchaseSound)  and not PurchaseSound.isPlaying) then
        PurchaseSound.Play()
    end
end

function PlayFailSound()
    if(IsValid(FailSound) and not FailSound.isPlaying) then
        FailSound.Play()
    end
end

function UpdateItemInStock(item)
    if(IsValid(item)) then
        local purchaseResource = API_GameObject.BL_GetComponent(item,"LuaResources")
        if(IsValid(purchaseResource)) then
           local stock =  purchaseResource.getFloat("ItemStock")

            if(stock <= 0) then
                local soldOutText = API_GameObject.BL_FindInChildren(item,"SoldOutText")
                local purchaseButton = API_GameObject.BL_FindInChildren(item,"Button_Purchase")
                if(IsValid(purchaseButton)) then
                    purchaseButton.setActive(false)
                end
                if(IsValid(soldOutText)) then
                    soldOutText.setActive(true)
                end
            end

        end
    end
end

function SetItemStockStatus(item, stock)
    if(IsValid(item)) then
        local purchaseResource = API_GameObject.BL_GetComponent(item,"LuaResources")
        if(IsValid(purchaseResource)) then
            purchaseResource.setFloat("ItemStock", stock)

            UpdateItemInStock(item)

        end
    end
end

function PurchaseButton(nil1,nil2,nil3,ITP)
    
    print("Purchase button pressed " .. tostring(ITP))
    if(IsValid(ITP) and IsValid(WarehouseManager))then
        local itemToPurchase = API_Utils.BL_ConvertObjectToType(ITP, "GameObject")
        print("Purchasing item gameObject: " .. itemToPurchase.name)
        local purchaseResource = API_GameObject.BL_GetComponent(itemToPurchase,"LuaResources")
        if(IsValid(purchaseResource))then
            local itemName = purchaseResource.GetString("ItemName")
            local itemCost = purchaseResource.GetFloat("ItemCost")
            local itemBarcode = purchaseResource.GetString("ItemBarcode")
            local itemStock = purchaseResource.GetFloat("ItemStock")
            print("Item to purchase: " .. itemName .. " Cost: " .. tostring(itemCost) .. " Barcode: " .. itemBarcode)
            local currentBudget = WarehouseManager.GetScriptVariable("WarehouseBudget")
            
            if(itemBarcode ~= nil and itemBarcode ~= "" and currentBudget >= itemCost and itemStock >= 1.0) then
                API_GameObject.BL_SpawnByBarcode(BL_This,"SpawnedItem",itemBarcode, ItemSpawnpoint.transform.position, ItemSpawnpoint.transform.rotation,nil, true)
                WarehouseManager.CallFunction("AddBudget",-itemCost)
                SetItemStockStatus(itemToPurchase, itemStock - 1.0)
                AdjustBudgetDisplay()
                PlayPurchaseSound()
            else
                print("Cannot afford item or invalid barcode")
                PlayFailSound()
            end

        else
            print("No LuaResources component found on item to purchase or WarehouseManager is not valid")
        end
    end
end