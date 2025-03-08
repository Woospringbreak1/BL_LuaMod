using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace LuaMod.LuaAPI
{
    internal  class API_Input
    {

        public static readonly API_Input Instance = new API_Input();

        public static GameObject BL_LeftHand()
        {
            return BoneLib.Player.LeftHand.gameObject;
        }

        public static GameObject BL_RightHand()
        {
            return BoneLib.Player.RightHand.gameObject;
        }


   
        public static bool BL_LeftController_IsGrabbed()
        {
            return BoneLib.Player.LeftController.IsGrabbed();
        }

        public static bool BL_RightController_IsGrabbed()
        {
            return BoneLib.Player.RightController.IsGrabbed();
        }


        public static bool BL_RightController_GetAButtonDown()
        {
            return BoneLib.Player.RightController.GetAButtonDown();
        }

        public static bool BL_RightController_GetAButtonUp()
        {
            return BoneLib.Player.RightController.GetAButtonUp();
        }


        public static bool BL_IsKeyDown(int keyCodeArg)
        {
            return Input.GetKey((KeyCode)keyCodeArg);
        }




    }
}
