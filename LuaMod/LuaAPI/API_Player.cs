using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace LuaMod.LuaAPI
{
    internal class API_Player
    {

        public static readonly API_Player Instance = new API_Player();

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
        public static Vector3 BL_GetAvatarPosition()
        {
            return BoneLib.Player.PhysicsRig.transform.position;
        }
        public static void BL_SetAvatarPosition(Vector3 pos)
        {
            BoneLib.Player.PhysicsRig.Teleport(new Il2CppSLZ.Marrow.Utilities.SimpleTransform(pos, Quaternion.identity), true);
        }

    }
}
