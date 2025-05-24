using Il2Cpp;
using Il2CppOculus.Platform;
using Il2CppSLZ.Bonelab;
using Il2CppSLZ.Marrow;
using Il2CppSLZ.Marrow.Pool;
using Il2CppSLZ.Marrow.Warehouse;
using Il2CppSLZ.VRMK;
using MelonLoader;
using MoonSharp.Interpreter;

using UnityEngine;

namespace LuaMod.LuaAPI
{

    public class API_Player
    {

        public static readonly API_Player Instance = new API_Player();
        public static SlotContainer Slot_Left_Pistol;
        public static SlotContainer Slot_Right_Pistol;
        public static SlotContainer Slot_Butt;
        public static SlotContainer Slot_BackLeft;
        public static SlotContainer Slot_BackRight;
        public static SlotContainer Slot_AmmoBelt;

        public static void Update()
        {

            if (API_Player.BL_GetPhysicsRig() != null)
            {

                GameObject PhysicsRig = API_Player.BL_GetPhysicsRig().gameObject;

                if (Slot_Left_Pistol == null)
                {
                    Slot_Left_Pistol = API_GameObject.Instance.FindInChildren(PhysicsRig, "SideLf").GetComponent<SlotContainer>();
                }

                if (Slot_Right_Pistol == null)
                {
                    Slot_Right_Pistol = API_GameObject.Instance.FindInChildren(PhysicsRig, "SideRt").GetComponent<SlotContainer>();
                }

                if (Slot_Butt == null)
                {
                    Slot_Butt = API_GameObject.Instance.FindInChildren(PhysicsRig, "BackCt").GetComponent<SlotContainer>();
                }

                if (Slot_BackLeft == null)
                {
                    Slot_BackLeft = API_GameObject.Instance.FindInChildren(PhysicsRig, "BackLf").GetComponent<SlotContainer>();
                }


                if (Slot_BackRight == null)
                {
                    Slot_BackRight = API_GameObject.Instance.FindInChildren(PhysicsRig, "BackRt").GetComponent<SlotContainer>();
                }

                if (Slot_AmmoBelt == null)
                {
                    GameObject ammoBelt = API_GameObject.Instance.FindInChildren(PhysicsRig, "BeltLf1");

                    if (ammoBelt == null)
                    {
                        ammoBelt = API_GameObject.Instance.FindInChildren(PhysicsRig, "BeltRt1");
                    }

                    Slot_AmmoBelt = ammoBelt.GetComponent<SlotContainer>();

                }
            }

        }
        public static GameObject BL_GetBodyLog()
        {
            if (BoneLib.Player.PhysicsRig != null)
            {
                GameObject BodyLog = BoneLib.Player.PhysicsRig.transform.Find("ElbowLf/BodyLogSlot/BodyLog").gameObject;
                return BodyLog;
            }
            else
            {
                return null;
            }
        }

        public static GameObject BL_GetSlotContents(SlotContainer slot)
        {
            if(slot != null && slot.inventorySlotReceiver != null && slot.inventorySlotReceiver._slottedWeapon != null)
            {
                return (slot.inventorySlotReceiver._slottedWeapon.interactableHost.gameObject);
            }
            return null;
        }


        public static bool BL_SetAvatar(string barcode)
        {
            LuaSafeCall.Run(() =>
            {
                
                if(String.IsNullOrEmpty(barcode))
                {
                    throw new ScriptRuntimeException("blank or invalid avatar barcode " + barcode);
                } 
               
                if(Barcode.IsValidString(barcode))
                {
                    AvatarCrateReference a = new AvatarCrateReference(barcode);
                    Barcode Avbarcode = new Barcode(barcode);
                    BoneLib.Player.RigManager.AvatarCrate = new AvatarCrateReference(Avbarcode);
                    BoneLib.Player.RigManager.SwapAvatarCrate(Avbarcode,true);
                    //BoneLib.Player.RigManager.SwitchAvatar(BoneLib.Player.RigManager._avatar);
                }
                else
                {
                    MelonLogger.Warning("Invalid avatar barcode " + barcode);
                }

                
            }, $"BL_SetAvatar(index: {barcode})");
            return false;
        }

     
        public static string BL_GetAvatarBarcode()
        {
           return LuaSafeCall.Run(() =>
            {
                if (BoneLib.Player.RigManager != null)
                {
                    string AvatarID = BoneLib.Player.RigManager._avatarCrate._barcode._id;
                    return (AvatarID);
                }
                MelonLogger.Warning("Rigmanager not valid");
                return null;
            }, $"BL_GetAvatarBarcode()");;
        }

        public static Il2CppSLZ.VRMK.Avatar BL_GetAvatar()
        {
            if(BoneLib.Player.Avatar != null)
            {
                return BoneLib.Player.Avatar;
            }    
            else
            {
                return null;
            }

        }

        public static GameObject BL_GetAvatarGameObject()
        {
            if (BoneLib.Player.Avatar != null)
            {
                return BoneLib.Player.Avatar.gameObject;
            }
            return null;

        }

        public static DynValue BL_GetAvatarCenter()
        {
            if (BoneLib.Player.Avatar != null)
            {
                return UserData.Create(BoneLib.Player.PhysicsRig.m_chest.position);
            }
            return null;

        }


        public static PhysicsRig BL_GetPhysicsRig()
        {
            if (BoneLib.Player.PhysicsRig != null)
            {   
                return (BoneLib.Player.PhysicsRig);
            }
            return null;

        }

        public static ControllerRig BL_GetControllerRig()
        {
            if (BoneLib.Player.ControllerRig != null)
            {
                return (BoneLib.Player.ControllerRig);

            }
            return null;

        }

        public static RigManager BL_GetRigManager()
        {
            if (BoneLib.Player.RigManager != null)
            {
                return (BoneLib.Player.RigManager);

            }
            return null;

        }

        public static RemapRig BL_GetRemapRig()
        {
            if (BoneLib.Player.RemapRig != null)
            {
                return (BoneLib.Player.RemapRig);
            }
            return null;
        }

        public static Health BL_PlayerHealth()
        {
            if (BoneLib.Player.RigManager != null && BoneLib.Player.RigManager.health != null)
            {
                return (BoneLib.Player.RigManager.health);

            }
            return null;

        }

        public static bool BL_SetAvatarPosition(Vector3 pos, Vector3 fwd,bool zeroVelocity=true)
        {
            if (BoneLib.Player.PhysicsRig != null)
            {
                Transform currentpos = BoneLib.Player.PhysicsRig.transform;
                BoneLib.Player.RigManager.Teleport(pos,fwd, zeroVelocity);
                return true;
            }
            return false;
        }


        public static bool BL_SetAvatarPosition(Vector3 pos, bool zeroVelocity = true)
        {
            if (BoneLib.Player.PhysicsRig != null)
            {
                Transform currentpos = BoneLib.Player.PhysicsRig.transform;
                BoneLib.Player.RigManager.Teleport(pos, zeroVelocity);
                return true;
            }
            return false;
        }

    }
}
