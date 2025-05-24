-- Lua Event Listener Template for API_Events

function Start()
    -- Core BoneLib + game lifecycle
    API_Events.BL_SubscribeEvent("OnPlayerDeath", BL_This, "OnPlayerDeath")
    API_Events.BL_SubscribeEvent("OnPlayerDeathImminent", BL_This, "OnPlayerDeathImminent")
    API_Events.BL_SubscribeEvent("OnMarrowGameStarted", BL_This, "OnMarrowGameStarted")
    API_Events.BL_SubscribeEvent("OnWarehouseReady", BL_This, "OnWarehouseReady")
    API_Events.BL_SubscribeEvent("OnUIRigCreated", BL_This, "OnUIRigCreated")
    API_Events.BL_SubscribeEvent("OnSwitchAvatarPrefix", BL_This, "OnSwitchAvatarPrefix")
    API_Events.BL_SubscribeEvent("OnSwitchAvatarPostfix", BL_This, "OnSwitchAvatarPostfix")

    -- Combat and damage
    API_Events.BL_SubscribeEvent("Player_OnReceiveDamage", BL_This, "Player_OnReceiveDamage")
    API_Events.BL_SubscribeEvent("Object_OnReceiveDamage", BL_This, "Object_OnReceiveDamage")
    API_Events.BL_SubscribeEvent("OnGrabObject", BL_This, "OnGrabObject")
    API_Events.BL_SubscribeEvent("OnGripAttached", BL_This, "OnGripAttached")
    API_Events.BL_SubscribeEvent("OnGripDetached", BL_This, "OnGripDetached")
    API_Events.BL_SubscribeEvent("OnPreFireGun", BL_This, "OnPreFireGun")
    API_Events.BL_SubscribeEvent("OnPostFireGun", BL_This, "OnPostFireGun")

    -- NPC lifecycle
    API_Events.BL_SubscribeEvent("OnNPCBrainDie", BL_This, "OnNPCBrainDie")
    API_Events.BL_SubscribeEvent("OnNPCBrainResurrected", BL_This, "OnNPCBrainResurrected")
    API_Events.BL_SubscribeEvent("OnNPCKillStart", BL_This, "OnNPCKillStart")
    API_Events.BL_SubscribeEvent("OnNPCKillEnd", BL_This, "OnNPCKillEnd")

    -- Projectiles
    API_Events.BL_SubscribeEvent("OnProjectileFired", BL_This, "OnProjectileFired")
    API_Events.BL_SubscribeEvent("OnRigidProjectileEnabled", BL_This, "OnRigidProjectileEnabled")

    -- Magazines
    API_Events.BL_SubscribeEvent("OnMagazineEject", BL_This, "OnMagazineEject")
    API_Events.BL_SubscribeEvent("OnMagazineGrab", BL_This, "OnMagazineGrab")
    API_Events.BL_SubscribeEvent("OnMagazineInsert", BL_This, "OnMagazineInsert")

    -- CrateSpawner
    API_Events.BL_SubscribeEvent("OnCrateSpawnerSpawned", BL_This, "OnCrateSpawnerSpawned")
    API_Events.BL_SubscribeEvent("OnCrateSpawnerDespawned", BL_This, "OnCrateSpawnerDespawned")
    API_Events.BL_SubscribeEvent("OnCrateSpawnerRecycle", BL_This, "OnCrateSpawnerRecycle")

    -- DevTools
    API_Events.BL_SubscribeEvent("OnDevToolSpawned", BL_This, "OnDevToolSpawned")

    -- BoneMenu
    API_Events.BL_SubscribeEvent("BoneMenu_Dialog_OnDialogClosed", BL_This, "BoneMenu_Dialog_OnDialogClosed")
    API_Events.BL_SubscribeEvent("BoneMenu_Float_OnValueChanged", BL_This, "BoneMenu_Float_OnValueChanged")
end

-- Stub implementations (override as needed)

function OnPlayerDeath() end
function OnPlayerDeathImminent(isDying) end
function OnMarrowGameStarted() end
function OnWarehouseReady() end
function OnUIRigCreated() end
function OnSwitchAvatarPrefix(avatar) end
function OnSwitchAvatarPostfix(avatar) end

function Player_OnReceiveDamage(attack) end
function Object_OnReceiveDamage(object, attack) end
function OnGrabObject(obj, hand) end
function OnGripAttached(grip, hand) end
function OnGripDetached(grip, hand) end
function OnPreFireGun(gun) end
function OnPostFireGun(gun) end

function OnNPCBrainDie(brain) end
function OnNPCBrainResurrected(brain) end
function OnNPCKillStart(ai) end
function OnNPCKillEnd(ai) end

function OnProjectileFired(projectile) end
function OnRigidProjectileEnabled(projectile) end

function OnMagazineEject(mag) end
function OnMagazineGrab(hand, mag) end
function OnMagazineInsert(mag) end

function OnCrateSpawnerSpawned(spawner, obj) end
function OnCrateSpawnerDespawned(spawner, obj) end
function OnCrateSpawnerRecycle(spawner, obj) end

function OnDevToolSpawned(devtool) end

function BoneMenu_Dialog_OnDialogClosed(dialog) end
function BoneMenu_Float_OnValueChanged(element, value) end
