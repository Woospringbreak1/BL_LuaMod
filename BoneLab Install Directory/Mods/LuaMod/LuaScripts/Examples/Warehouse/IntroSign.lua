function Start()
IntroPage = API_GameObject.BL_FindInChildren(BL_Host,"Intro")
PackagesPage = API_GameObject.BL_FindInChildren(BL_Host,"Packages")
StorePage = API_GameObject.BL_FindInChildren(BL_Host,"Store")
IntroButton(nil,nil,nil,nil)
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
    IntroPage.setActive(false)
    PackagesPage.setActive(false)
    StorePage.setActive(true)
end