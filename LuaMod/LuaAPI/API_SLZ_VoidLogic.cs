using Il2CppSLZ.Bonelab;
using Il2CppSLZ.Marrow;
using Il2CppSLZ.Marrow.Circuits;
using Il2CppSLZ.Marrow.VoidLogic;
using Il2CppSLZ.Marrow.Warehouse;
using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI;

namespace LuaMod.LuaAPI
{

    public class API_SLZ_VoidLogic
    {
        public static readonly API_SLZ_VoidLogic Instance = new API_SLZ_VoidLogic();

        /// <summary>
        /// Sets a MarrowEntityPoseDecorator to a pose given by barcode. Required due to bug preventing the registration of DataCardReference<EntityPose>
        /// </summary>
        public static bool BL_SetMarrowEntityPoseDectoratorPose(MarrowEntityPoseDecorator posedec,string barcode)
        {
            LuaSafeCall.Run(() =>
            {
                if (posedec != null)
                {
                    posedec.MarrowEntityPose = new DataCardReference<EntityPose>(barcode);
                    return true;
                }
                else
                {
                    throw new ScriptRuntimeException("MarrowEntityPoseDecorator is null");
                }
            }, $"SetMarrowEntityPoseDectoratorPose('{posedec}', barcode: '{barcode}')");

            return false;
        }
      
    }
}
