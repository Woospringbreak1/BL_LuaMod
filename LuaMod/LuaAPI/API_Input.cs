using UnityEngine;

namespace LuaMod.LuaAPI
{
    internal class API_Input
    {

        public static readonly API_Input Instance = new API_Input();

        public static GameObject BL_LeftHand()
        {
            if(BoneLib.Player.LeftHand != null)
            {
                return BoneLib.Player.LeftHand.gameObject;
            }
            return null;
            
        }

        public static GameObject BL_RightHand()
        {
            if (BoneLib.Player.RightHand != null)
            {
                return BoneLib.Player.RightHand.gameObject;
            }
            return null;
        }



        public static bool BL_LeftController_IsGrabbed()
        {
            if (BoneLib.Player.LeftController != null)
            {
                return BoneLib.Player.LeftController.IsGrabbed();
            }
            return false;
        }

        public static bool BL_RightController_IsGrabbed()
        {
            if (BoneLib.Player.RightController != null)
            {
                return BoneLib.Player.RightController.IsGrabbed();
            }
            return false;
        }


        public static bool BL_RightController_GetAButtonDown()
        {
            if (BoneLib.Player.RightController != null)
            {
                return BoneLib.Player.RightController.GetAButtonDown();
            }
            return false;
        }

        public static bool BL_RightController_GetAButtonUp()
        {
            if (BoneLib.Player.RightController != null)
            {
                return BoneLib.Player.RightController.GetAButtonUp();
            }
            return false;   
        }


        public static bool BL_IsKeyDown(int keyCodeArg)
        {
            return Input.GetKey((KeyCode)keyCodeArg);
        }




    }
}
