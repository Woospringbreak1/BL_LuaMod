using Il2CppSLZ.Marrow.VoidLogic;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI;

namespace LuaMod.LuaAPI
{
    internal class API_SLZ_VoidLogic
    {
        public static readonly API_SLZ_VoidLogic Instance = new API_SLZ_VoidLogic();

        public static VoidLogicManager GetVoidLogicManager()
        {
            GameObject VLM_GO = GameObject.Find("MARROW - VoidLogic Manager");
            if (VLM_GO != null) 
            {
                VoidLogicManager VLM = VLM_GO.GetComponent<VoidLogicManager>();

                if (VLM != null)
                {
                    return VLM;
                    //Il2CppSystem.Collections.Generic.List<Il2CppSLZ.Marrow.VoidLogic.VoidLogicSubgraph> Graphs = VLM.nod
                    //MelonLoader.MelonLogger.Msg("graph length: " + Graphs.Count);
                }
                else
                {
                    MelonLoader.MelonLogger.Msg("no VoidLogicManager component");
                }

            }
            else
            {
                MelonLoader.MelonLogger.Msg("no MARROW - VoidLogic Manager object");
            }

            

            return null;
        }
    }
}
