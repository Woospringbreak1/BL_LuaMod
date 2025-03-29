using Il2CppSLZ.Marrow;
using UnityEngine;

namespace LuaMod.LuaAPI
{
    internal class API_Input
    {

        public static readonly API_Input Instance = new API_Input();


        public static bool BL_IsAButtonDown()
        {
            if (BoneLib.Player.RightController != null)
            {
                return BoneLib.Player.RightController.GetAButton();
            }
            return false;
        }

        public static bool BL_IsAButtonDownOnce()
        {
            if (BoneLib.Player.RightController != null)
            {
                return BoneLib.Player.RightController.GetAButtonDown();
            }
            return false;
        }

        public static bool BL_IsAButtonUpOnce()
        {
            if (BoneLib.Player.RightController != null)
            {
                return BoneLib.Player.RightController.GetAButtonUp();
            }
            return false;
        }



        public static bool BL_IsBButtonDown()
        {
            if (BoneLib.Player.RightController != null)
            {
                return BoneLib.Player.RightController.GetBButton();
            }
            return false;
        }


        public static bool BL_IsXButtonDown()
        {
            if (BoneLib.Player.LeftController != null)
            {
                return BoneLib.Player.LeftController.GetAButton();
            }
            return false;
        }

        public static bool BL_IsYButtonDown()
        {
            if (BoneLib.Player.LeftController != null)
            {
                return BoneLib.Player.LeftController.GetBButton();
            }
            return false;
        }




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

        public static bool BL_RightHandEmpty()
        {
            if (BoneLib.Player.RightHand != null)
            {
                return BoneLib.Player.GetComponentInHand<Component>(BoneLib.Player.RightHand) == null;
            }
            return true;
        }

        public static bool BL_LeftHandEmpty()
        {
            if (BoneLib.Player.LeftHand != null)
            {
                return BoneLib.Player.GetComponentInHand<Component>(BoneLib.Player.LeftHand) == null;
            }
            return true;
        }


        public static bool BL_LeftController_IsGrabbed()
        {
            if (BoneLib.Player.LeftController != null)
            {
                return BoneLib.Player.LeftController.GetGrabbedState();
            }
            return false;
        }

        public static bool BL_RightController_IsGrabbed()
        {
            if (BoneLib.Player.RightController != null)
            {
                return BoneLib.Player.RightController.GetGrabbedState();
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
