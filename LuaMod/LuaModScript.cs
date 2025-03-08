using LuaMod.LuaAPI;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MoonSharp.Interpreter;
using MoonSharp.Interpreter.Loaders;
using MoonSharp.Interpreter.CoreLib;
using MoonSharp.Interpreter.Platforms;
using UnityEngine;
using Il2CppVoxelization;

namespace LuaMod
{
    public class LuaModScript
    {
        public Script LuaScript;
        private string LuaFileName;
        private TextAsset LuaAsset;
        public delegate bool del_postreload();
        public del_postreload PostReloadScript;
        public bool ReloadScript()
        {
            //todo: change luabehaviour to inheret an interface and passa  reference to this function so we can just call postreloadscript()

            if (LuaAsset != null && LoadScript(LuaAsset,true))
            {
                if (PostReloadScript != null)
                {
                    return PostReloadScript.Invoke();
                }
                else
                {
                    return true;
                }
            }
            else if (LuaFileName != null && LuaFileName != "" && LoadScript(LuaFileName, true))
            {
                if (PostReloadScript != null)
                {
                    return PostReloadScript.Invoke();
                }
                else
                {
                    return true;
                }
            }
            return false;
        }

        public bool LoadScript(string filename, bool reloading) //ugly, change
        {
            MelonLoader.MelonLogger.Msg("Lua Behaviour loading script " + filename);
            if (File.Exists(filename))
            {



                LuaScript = new Script();
                LuaScript.Options.ScriptLoader = new FileSystemScriptLoader();
                DynValue res;
                try
                {
                    res = LuaScript.DoFile(filename);
                }
                catch (ScriptRuntimeException ex)
                {
                    MelonLoader.MelonLogger.Error("Doh! An error occured! " + ex.DecoratedMessage);
                 //   throw;
                }

                
                LuaFileName = filename;
                LuaScript.Options.DebugPrint = s => { MelonLoader.MelonLogger.Msg(s); };
                LoadFunctionPointers();

                if (!reloading)
                {
                    //ugly, refactor
                    ScriptManager.RegisterScript(this);
                }

                return true;
            }
            else
            {
                return false;
            }

        }


        public bool LoadScript(TextAsset scriptasset, bool reloading) //ugly, change 
        {
            MelonLoader.MelonLogger.Msg("Lua Behaviour loading asset script " + scriptasset.name + ".txt");
            if (scriptasset != null)
            {
                LuaScript = new Script();
                LuaScript.Options.ScriptLoader = new UnityAssetsScriptLoader("LuaScripts"); // located in Assets\Resources\LuaScripts
                DynValue res;

                try
                {
                    res = LuaScript.DoString(scriptasset.text);
                }
                catch (ScriptRuntimeException ex)
                {
                    MelonLoader.MelonLogger.Error("Doh! An error occured! " + ex.DecoratedMessage);
                  //  throw;
                }

                LuaFileName = "";
                LuaAsset = scriptasset;

                LuaScript.Options.DebugPrint = s => { MelonLoader.MelonLogger.Msg(s); };

                LoadFunctionPointers();

                if (!reloading)
                {
                    //ugly, refactor
                    ScriptManager.RegisterScript(this); 
                }
                

                return true;
            }
            else
            {
                return false;
            }

        }

        public static bool IsScriptPathSafe(string path)
        {
            return true;
        }

        private void LoadBehaviourFunctionReferences()
        {


        }

        public void DestroyScript()
        {
            LuaScript = null;
            ScriptManager.DeregisterScript(this);
        }


        private void LoadFunctionPointers()
        {
            LuaScript.Globals["API_GameObject"] = (API_GameObject.Instance);
            LuaScript.Globals["API_Input"] = (API_Input.Instance);
            LuaScript.Globals["API_Player"] = (API_Player.Instance);
            LuaScript.Globals["API_Vector"] = (API_Vector.Instance);
            LuaScript.Globals["API_Event"] = (API_Event.Instance);
            LuaScript.Globals["API_SLZ_Combat"] = (API_SLZ_Combat.Instance);
            /*
            LuaScript.Globals["BL_testmsg"] = (Func<string, Quaternion,bool>)API_GameObject.BL_testmsg;
            LuaScript.Globals["BL_Vector3"] = (Func<float,float,float, Vector3>)API_Vector.BL_Vector3;
            LuaScript.Globals["BL_GetAvatarName"] = (Func<string>)API_Player.BL_GetAvatarName;
            LuaScript.Globals["BL_IsKeyDown"] = (Func<int, bool>)API_Input.BL_IsKeyDown;
            LuaScript.Globals["BL_GetAvatarGameObject"] = (Func<GameObject>)API_Player.BL_GetAvatarGameObject;
            LuaScript.Globals["BL_SetAvatarPosition"] = (Action<Vector3>)API_Player.BL_SetAvatarPosition;
            LuaScript.Globals["BL_GetAvatarPosition"] = (Func<Vector3>)API_Player.BL_GetAvatarPosition;
            LuaScript.Globals["BL_SpawnByBarcode"] = (Func<string,Vector3,UnityEngine.Quaternion,GameObject>)API_GameObject.BL_SpawnByBarcode;
            LuaScript.Globals["BL_LeftController"] = (Func<GameObject>)API_Input.BL_LeftController;
            LuaScript.Globals["BL_RightController"] = (Func<GameObject>)API_Input.BL_RightController;
            */

        }
    }
}
