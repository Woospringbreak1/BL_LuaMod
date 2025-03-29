using Il2CppSLZ.Marrow;
using Il2CppSLZ.Marrow.Pool;
using Il2CppSLZ.Marrow.Warehouse;
using MoonSharp.Interpreter;
using UnityEngine;

namespace LuaMod.LuaAPI
{
    internal class API_Player
    {

        public static readonly API_Player Instance = new API_Player();

        public enum AmmoType
        {
            Light,Medium,Heavy
        }
        public static float BL_GetFixedDeltaTime()
        {
            return(Time.fixedDeltaTime);
        }

        public static void SetPlayerAmmo(AmmoType AT,int newAmmo)
        {
           
        }

        public static void ModifyPlayerAmmo(AmmoType AT, int ammoMod)
        {

        }

        public static int GetPlayerAmmo(AmmoType AT)
        {
            return 0;
        }

        public static string BL_GetAvatarName()
        {
            try
            {
                return BoneLib.Player.Avatar.name;
            }
            catch (Exception e)
            {
                return "";
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
        public static DynValue BL_GetAvatarPosition()
        {
            if(BoneLib.Player.Avatar != null)
            {   
                return UserData.Create(BoneLib.Player.PhysicsRig.transform.position);
            }    
            return null;
           
        }

        public static DynValue BL_GetAvatarCenter()
        {
            if (BoneLib.Player.Avatar != null)
            {
                return UserData.Create(BoneLib.Player.PhysicsRig.m_chest.transform.position);
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
            if (BoneLib.Player.PhysicsRig != null)
            {
                return (BoneLib.Player.ControllerRig);

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

        public static void BL_SetAvatarPosition(Vector3 pos)
        {
     
            BoneLib.Player.PhysicsRig.Teleport(new Il2CppSLZ.Marrow.Utilities.SimpleTransform(pos, Quaternion.identity), true);
        }

    }
}
