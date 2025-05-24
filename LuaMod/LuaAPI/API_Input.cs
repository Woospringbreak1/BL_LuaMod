using Il2CppSLZ.Marrow;
using MelonLoader;
using MoonSharp.Interpreter;
using UnityEngine;

namespace LuaMod.LuaAPI
{

    public class API_Input
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


        public static bool BL_IsBButtonDownOnce()
        {
            if (BoneLib.Player.RightController != null)
            {
                return BoneLib.Player.RightController.GetBButtonDown();
            }
            return false;
        }

        public static bool BL_IsBButtonUpOnce()
        {
            if (BoneLib.Player.RightController != null)
            {
                return BoneLib.Player.RightController.GetBButtonUp();
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

        public static bool BL_IsXButtonDownOnce()
        {
            if (BoneLib.Player.LeftController != null)
            {
                return BoneLib.Player.LeftController.GetAButtonDown();
               
            }
            return false;
        }

        public static BaseController BL_GetLeftController()
        {
            if (BoneLib.Player.LeftController != null)
            {
                return BoneLib.Player.LeftController;
            }
            return null;
        }

        public static BaseController BL_GetRightController()
        {
            if (BoneLib.Player.RightController != null)
            {
                return BoneLib.Player.RightController;
            }
            return null;
        }

        public static bool BL_IsXButtonUpOnce()
        {
            if (BoneLib.Player.LeftController != null)
            {
                return BoneLib.Player.LeftController.GetAButtonUp();
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

        public static bool BL_IsYButtonDownOnce()
        {
            if (BoneLib.Player.LeftController != null)
            {
                return BoneLib.Player.LeftController.GetBButtonDown();
            }
            return false;
        }

        public static bool BL_IsYButtonUpOnce()
        {
            if (BoneLib.Player.LeftController != null)
            {
                return BoneLib.Player.LeftController.GetBButtonUp();
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
                //(BoneLib.Player.RightHand.Controller.Haptic()
                return BoneLib.Player.RightHand.gameObject;
            }
            return null;
        }

        public static DynValue BL_RightHandContents()
        {
            return LuaSafeCall.Run(() =>
            {
                if (BoneLib.Player.RightHand != null)
                {
                    GameObject handContents = (BoneLib.Player.GetObjectInHand(BoneLib.Player.RightHand));
                    if (handContents != null)
                    {
                        return UserData.Create(handContents);
                    }
                    return DynValue.Nil;
                }
                return null;
            }, $"BL_RightHandContents()"); ;
        }

        public static DynValue BL_LeftHandContents()
        {
            return LuaSafeCall.Run(() =>
            {
                if (BoneLib.Player.RightHand != null)
                {
                    GameObject handContents = (BoneLib.Player.GetObjectInHand(BoneLib.Player.LeftHand));
                    if (handContents != null)
                    {
                        return UserData.Create(handContents);
                    }
                    return DynValue.Nil;
                }
                return null;
            }, $"BL_LeftHandContents()"); ;
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

        public static bool BL_IsKeyDown(int keyCodeArg)
        {
            return Input.GetKey((KeyCode)keyCodeArg);
        }




    }
}
