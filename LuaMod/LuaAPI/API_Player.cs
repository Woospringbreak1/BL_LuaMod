using Il2Cpp;
using Il2CppSLZ.Marrow;
using Il2CppSLZ.Marrow.Pool;
using Il2CppSLZ.Marrow.Warehouse;
using Il2CppSLZ.VRMK;
using MoonSharp.Interpreter;

using UnityEngine;

namespace LuaMod.LuaAPI
{

    public class API_Player
    {

        public static readonly API_Player Instance = new API_Player();


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
            if (BoneLib.Player.ControllerRig != null)
            {
                return (BoneLib.Player.ControllerRig);

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
