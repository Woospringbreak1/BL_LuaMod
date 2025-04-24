using Il2CppSLZ.Marrow;
using Il2CppSystem.Runtime.Serialization;
using LuaMod.LuaAPI;
using MelonLoader;
using Microsoft.VisualBasic.FileIO;
using MoonSharp.Interpreter;
using MoonSharp.Interpreter.Loaders;
using System.Diagnostics;
using UnityEngine;

namespace LuaMod
{
    public class LuaModScript
    {
        private Script _LuaScript;
        private string LuaFileName;
        private TextAsset LuaAsset;
        public delegate bool del_postreload();
        public del_postreload PostReloadScript;
        private readonly Dictionary<string, DynValue> _loadedModules = new Dictionary<string, DynValue>();

        protected const int MaxScriptExecutionTime = 500;//100; //ms
        protected const float ScriptMemoryBudget = 15.0f; //mB

        private const int MaxStrikes = 3;
        private static readonly Dictionary<string, ScriptStrikeRecord> StrikeRecords = new();
        public enum StrikeReason {ExecutionTime,MemoryUse };
        public class ScriptStrikeRecord
        {
            
            public int Strikes;
            public StrikeReason Reason;
        }

        private string GetScriptIdentifier()
        {
            return !string.IsNullOrEmpty(LuaFileName) ? LuaFileName : LuaAsset?.name ?? "UnknownScript";
        }

        private void AddStrike(StrikeReason reason)
        {
            string path = GetScriptIdentifier();

            if (!StrikeRecords.TryGetValue(path, out var record))
            {
                record = new ScriptStrikeRecord();
                StrikeRecords[path] = record;
            }

            record.Strikes++;
            record.Reason = reason;

            if (record.Strikes >= MaxStrikes)
            {
                MelonLogger.Error($"Script '{path}' blocked due to {record.Strikes} strikes ({reason}).");
                DestroyScript(); // Kill the running script
            }

            MelonLogger.Warning($"Script '{path}' received a strike ({record.Strikes}): {reason}");
        }
        private static bool CheckBan(string path)
        {
            if (StrikeRecords.TryGetValue(path, out var record) && record.Strikes >= MaxStrikes)
            {
                return true;
            }
            return false;
        }

        /*
        public bool ReloadScript()
        {


            if (LuaAsset != null && LoadScript(LuaAsset, true))
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
        */

        public void SetGlobal(string name, object val)
        {
            if (_LuaScript != null)
            {
                _LuaScript.Globals.Set(name, DynValue.FromObject(_LuaScript, val));
            }
        }

        public DynValue GetGlobal(string name)
        {
            if (_LuaScript != null)
            {
                return(_LuaScript.Globals.Get(name));
            }
            return null;
        }

        public bool ScriptIsValid()
        { 
            return _LuaScript != null;
        }




        public bool LoadScript(string filename, bool reloading,LuaBehaviour host)
        {
            filename = API_Utils.RemoveDoubleSlashes(filename);

            if (!Security.IsSafePath(filename))
            {
                throw new ScriptRuntimeException($"attempted to access an unsafe path: {filename}");
            }
               

            if (!File.Exists(filename))
            {
                return false;
            }
               

            if (CheckBan(filename))
            {
                throw new ScriptRuntimeException($"Script '{filename}' not allowed -- too many strikes");
            }
            MelonLogger.Msg($"LuaBehaviour loading script: {filename}");

            _LuaScript = new Script(CoreModules.Preset_HardSandbox);
            _LuaScript.Options.ScriptLoader = new FileSystemScriptLoader();
            _LuaScript.Options.DebugPrint = s => MelonLogger.Msg($"[Lua: {filename}] {s}");
            _LuaScript.Options.CheckThreadAccess = true;

            LuaFileName = filename;

            _LuaScript.Globals.Set("BL_Host", UserData.Create(host.gameObject));
            _LuaScript.Globals.Set("BL_This", UserData.Create(host));

            try
            {
                DynValue entry = _LuaScript.LoadFile(filename);
                LoadFunctionPointers();
                CallScriptFunction(entry);
            }
            catch (ScriptRuntimeException ex)
            {
                MelonLogger.Error($"Lua error while loading {filename}: {ex.DecoratedMessage}");
                return false;
            }

            if (!reloading)
            {
                ScriptManager.RegisterScript(this);
            }

            return true;
        }



        public bool LoadScript(TextAsset scriptAsset, bool reloading,LuaBehaviour host)
        {
            if (scriptAsset == null)
            {   
                return false;
            }
                

            string virtualPath = scriptAsset.name;
            if (CheckBan(virtualPath))
            {
                throw new UnauthorizedAccessException($"Script '{virtualPath}' not allowed -- too many strikes");
            }

            MelonLogger.Msg($"LuaBehaviour loading asset script: {virtualPath}.txt");

            _LuaScript = new Script(CoreModules.Preset_HardSandbox);
            _LuaScript.Options.ScriptLoader = new UnityAssetsScriptLoader("LuaScripts");
            _LuaScript.Options.DebugPrint = s => MelonLogger.Msg($"[Lua: {virtualPath}] {s}");
            _LuaScript.Options.CheckThreadAccess = true;

            LuaFileName = string.Empty;
            LuaAsset = scriptAsset;

            _LuaScript.Globals.Set("BL_Host", UserData.Create(host.gameObject));
            _LuaScript.Globals.Set("BL_This", UserData.Create(host));

            try
            {
                DynValue entry = _LuaScript.LoadString(scriptAsset.text);
                LoadFunctionPointers();
                CallScriptFunction(entry);
            }
            catch (ScriptRuntimeException ex)
            {
                MelonLogger.Error($"Lua error in asset script {virtualPath}: {ex.DecoratedMessage}");
                return false;
            }

            if (!reloading)
            {
                ScriptManager.RegisterScript(this);
            }
               

            return true;
        }



        public DynValue CallScriptFunction(DynValue luaFunc, params object[] Args)
        {
            if (luaFunc.Type != DataType.Function && luaFunc.Type != DataType.ClrFunction)
            {
                throw new ArgumentException("DynValue must be a Lua function or callback");
            }

            if (CheckBan(GetScriptIdentifier()))
            {
                DestroyScript();
                throw new UnauthorizedAccessException($"Script '{GetScriptIdentifier()}' not allowed -- too many strikes");
            }

            var coro = _LuaScript.CreateCoroutine(luaFunc).Coroutine;
            coro.AutoYieldCounter = 1000;
            DynValue[] dynArgs = Array.ConvertAll(Args, arg => DynValue.FromObject(_LuaScript, arg));

            Stopwatch stopwatch = Stopwatch.StartNew();
            DynValue result;

            try
            {
                result = coro.Resume(dynArgs);

                while (result.Type == DataType.YieldRequest)
                {
                    if (stopwatch.ElapsedMilliseconds > MaxScriptExecutionTime)
                    {
                        AddStrike(StrikeReason.ExecutionTime);
                        throw new ScriptRuntimeException($"Lua function execution exceeded {MaxScriptExecutionTime}ms and was aborted");
                    }

                    if (LuaMemoryProfiler.EstimateMemoryMB(_LuaScript, _loadedModules) > ScriptMemoryBudget)
                    {
                        AddStrike(StrikeReason.MemoryUse);
                        throw new ScriptRuntimeException($"Lua script exceeded memory budget of {ScriptMemoryBudget}MB and was aborted");
                    }

                    result = coro.Resume();
                }
            }
            catch (ScriptRuntimeException e)
            {
                MelonLogger.Error($"Lua Error: {e.DecoratedMessage}");
                throw;
            }
            finally
            {
                stopwatch.Stop();
            }

            return result;
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
            _LuaScript = null;
            ScriptManager.DeregisterScript(this);
        }

        // File-based
        private DynValue LoadModule(string module)
        {
            return LoadModuleInternal(module, null);
        }

        // Asset-based
        private DynValue LoadModule(TextAsset moduleAsset)
        {
            if (moduleAsset == null)
                throw new ScriptRuntimeException("Provided TextAsset is null");

            string moduleName = moduleAsset.name;
            return LoadModuleInternal(moduleName, moduleAsset.text);
        }

        // Shared logic
        private DynValue LoadModuleInternal(string moduleName, string codeOverride = null)
        {
            return LuaSafeCall.Run(() =>
            {
                string code;
                if (codeOverride != null)
                {
                    code = codeOverride;
                }
                else
                {
                    string path = Security.GetRelativeScriptPath(moduleName);

                    if (!Security.IsSafePath(path))
                    {
                        throw new ScriptRuntimeException($"attempted to access an unsafe path: {moduleName}");
                    }

                    if (!File.Exists(path))
                    {
                        throw new ScriptRuntimeException($"Module '{moduleName}' not found at path: {path}");
                    }
                        

                    code = File.ReadAllText(path);
                }

                DynValue func = _LuaScript.LoadString(code, null, $"module:{moduleName}");
                DynValue result = CallScriptFunction(func);

                if (result.Type == DataType.Table || result.Type == DataType.UserData || result.Type == DataType.Function)
                {
                    _LuaScript.Globals.Set(moduleName, result);
                    _loadedModules[moduleName] = result;
                    return result;
                }

                _LuaScript.Globals.Set(moduleName, DynValue.True);
                _loadedModules[moduleName] = DynValue.True;
                return DynValue.True;

            }, $"loadmodule('{moduleName}')");
        }




        // File-based require
        private DynValue Require(string module)
        {
            return RequireInternal(module, null);
        }

        // Asset-based require
        private DynValue Require(TextAsset moduleAsset)
        {
            if (moduleAsset == null)
                throw new ScriptRuntimeException("Provided TextAsset is null");

            string moduleName = moduleAsset.name;
            return RequireInternal(moduleName, moduleAsset.text);
        }

        // Shared internal require logic
        private DynValue RequireInternal(string moduleName, string codeOverride = null)
        {
            return LuaSafeCall.Run(() =>
            {
                if (_loadedModules.TryGetValue(moduleName, out var cached))
                {
                    return cached;
                }

                string code;

                if (codeOverride != null)
                {
                    code = codeOverride;
                }
                else
                {
                    string path = Security.GetRelativeScriptPath(moduleName);

                    if (!Security.IsSafePath(path))
                    {
                        throw new ScriptRuntimeException($"attempted to access an unsafe path: {moduleName}");
                    }
                        

                    if (!File.Exists(path))
                    {
                        throw new ScriptRuntimeException($"Module '{moduleName}' not found at path: {path}");
                    }
                        

                    code = File.ReadAllText(path);
                }

                DynValue func = _LuaScript.LoadString(code, null, $"require:{moduleName}");
                DynValue result = CallScriptFunction(func);

                if (result.Type == DataType.Table || result.Type == DataType.UserData || result.Type == DataType.Function)
                {
                    _LuaScript.Globals.Set(moduleName, result);
                    _loadedModules[moduleName] = result;
                    return result;
                }

                _LuaScript.Globals.Set(moduleName, DynValue.True);
                _loadedModules[moduleName] = DynValue.True;
                return DynValue.True;

            }, $"require('{moduleName}')");
        }


        // Exposed to Lua: require(string | TextAsset)
        private DynValue Lua_Require(object module)
        {
            return LuaSafeCall.Run(() =>
            {
                if (module is string s)
                    return Require(s);
                else if (module is TextAsset ta)
                    return Require(ta);
                else
                    throw new ScriptRuntimeException("require() must be called with a string or TextAsset");
            }, "Lua_Require");
        }

        // Exposed to Lua: loadmodule(string | TextAsset)
        private DynValue Lua_LoadModule(object module)
        {
            return LuaSafeCall.Run(() =>
            {
                if (module is string s)
                    return LoadModule(s);
                else if (module is TextAsset ta)
                    return LoadModule(ta);
                else
                    throw new ScriptRuntimeException("loadmodule() must be called with a string or TextAsset");
            }, "Lua_LoadModule");
        }


        private void LoadFunctionPointers()
        {
            _LuaScript.Globals["API_GameObject"] = (API_GameObject.Instance);
            _LuaScript.Globals["API_Input"] = (API_Input.Instance);
            _LuaScript.Globals["API_Player"] = (API_Player.Instance);
            _LuaScript.Globals["API_Vector"] = (API_Vector.Instance);
            _LuaScript.Globals["API_Events"] = (API_Events.Instance);
            _LuaScript.Globals["API_SLZ_Combat"] = (API_SLZ_Combat.Instance);
            _LuaScript.Globals["API_SLZ_NPC"] = (API_SLZ_NPC.Instance);
            _LuaScript.Globals["API_SLZ_VoidLogic"] = (API_SLZ_VoidLogic.Instance);
            _LuaScript.Globals["API_Physics"] = (API_Physics.Instance);
            _LuaScript.Globals["API_Utils"] = (API_Utils.Instance);
            _LuaScript.Globals["API_BoneMenu"] = (API_BoneMenu.Instance);
            _LuaScript.Globals["API_Audio"] = (API_Audio.Instance);
            _LuaScript.Globals["API_Particles"] = (API_Particles.Instance);
            _LuaScript.Globals["API_FileAccess"] = (API_FileAccess.Instance);
            _LuaScript.Globals["API_Random"] = (API_Random.Instance);
            _LuaScript.Globals["API_Renderer"] = (API_Renderer.Instance);
            
            _LuaScript.Globals["GameObject"] = UserData.CreateStatic<GameObject>();
            _LuaScript.Globals["Quaternion"] = UserData.CreateStatic<Quaternion>();
            _LuaScript.Globals["Vector3"] = UserData.CreateStatic<Vector3>();
            _LuaScript.Globals["Time"] = UserData.CreateStatic<Time>();
            _LuaScript.Globals["Color"] = UserData.CreateStatic<UnityEngine.Color>();
            _LuaScript.Globals["Physics"] = UserData.CreateStatic<UnityEngine.Physics>();
            _LuaScript.Globals["Transform"] = UserData.CreateStatic<Transform>();
            _LuaScript.Globals["Time"] = UserData.CreateStatic<Time>();
            _LuaScript.Globals["Camera"] = UserData.CreateStatic<Camera>();
            _LuaScript.Globals["ConfigurableJointMotion"] = UserData.CreateStatic<ConfigurableJointMotion>();
            _LuaScript.Globals["ForceMode"] = UserData.CreateStatic<ForceMode>();
            _LuaScript.Globals["Mathf"] = UserData.CreateStatic<UnityEngine.Mathf>();
            _LuaScript.Globals["VisibleLightFlags"] = UserData.CreateStatic<UnityEngine.Rendering.VisibleLightFlags>();
         

            _LuaScript.Globals["IsValid"] = (Func<GameObject, bool>)API_GameObject.BL_IsValid;
            _LuaScript.Globals["require"] = (Func<object, DynValue>)Lua_Require;
            _LuaScript.Globals["loadmodule"] = (Func<object, DynValue>)Lua_LoadModule;

            //SLZ
            _LuaScript.Globals["HammerStates"] = UserData.CreateStatic<Gun.HammerStates>();

            //short hand for an often-used function
           
            // Enums from assembly: UnityEngine.CoreModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["LightmapType"] = UserData.CreateStatic<UnityEngineInternal.LightmapType>();
            _LuaScript.Globals["TypeInferenceRules"] = UserData.CreateStatic<UnityEngineInternal.TypeInferenceRules>();
            _LuaScript.Globals["PrimitiveType"] = UserData.CreateStatic<UnityEngine.PrimitiveType>();
            _LuaScript.Globals["Space"] = UserData.CreateStatic<UnityEngine.Space>();
            _LuaScript.Globals["RuntimePlatform"] = UserData.CreateStatic<UnityEngine.RuntimePlatform>();
            _LuaScript.Globals["SystemLanguage"] = UserData.CreateStatic<UnityEngine.SystemLanguage>();
            _LuaScript.Globals["LogType"] = UserData.CreateStatic<UnityEngine.LogType>();
            _LuaScript.Globals["WrapMode"] = UserData.CreateStatic<UnityEngine.WrapMode>();
            _LuaScript.Globals["StackTraceLogType"] = UserData.CreateStatic<UnityEngine.StackTraceLogType>();
            _LuaScript.Globals["FullScreenMode"] = UserData.CreateStatic<UnityEngine.FullScreenMode>();
            _LuaScript.Globals["ComputeBufferMode"] = UserData.CreateStatic<UnityEngine.ComputeBufferMode>();
            _LuaScript.Globals["LightmapsModeLegacy"] = UserData.CreateStatic<UnityEngine.LightmapsModeLegacy>();
            _LuaScript.Globals["LightShadowCasterMode"] = UserData.CreateStatic<UnityEngine.LightShadowCasterMode>();
            _LuaScript.Globals["RenderingPath"] = UserData.CreateStatic<UnityEngine.RenderingPath>();
            _LuaScript.Globals["TransparencySortMode"] = UserData.CreateStatic<UnityEngine.TransparencySortMode>();
            _LuaScript.Globals["StereoTargetEyeMask"] = UserData.CreateStatic<UnityEngine.StereoTargetEyeMask>();
            _LuaScript.Globals["CameraType"] = UserData.CreateStatic<UnityEngine.CameraType>();
            _LuaScript.Globals["ComputeBufferType"] = UserData.CreateStatic<UnityEngine.ComputeBufferType>();
            _LuaScript.Globals["LightType"] = UserData.CreateStatic<UnityEngine.LightType>();
            _LuaScript.Globals["LightShape"] = UserData.CreateStatic<UnityEngine.LightShape>();
            _LuaScript.Globals["LightRenderMode"] = UserData.CreateStatic<UnityEngine.LightRenderMode>();
            _LuaScript.Globals["LightShadows"] = UserData.CreateStatic<UnityEngine.LightShadows>();
            _LuaScript.Globals["FogMode"] = UserData.CreateStatic<UnityEngine.FogMode>();
            _LuaScript.Globals["LightmapBakeType"] = UserData.CreateStatic<UnityEngine.LightmapBakeType>();
            _LuaScript.Globals["MixedLightingMode"] = UserData.CreateStatic<UnityEngine.MixedLightingMode>();
            _LuaScript.Globals["ShadowmaskMode"] = UserData.CreateStatic<UnityEngine.ShadowmaskMode>();
            _LuaScript.Globals["ShadowObjectsFilter"] = UserData.CreateStatic<UnityEngine.ShadowObjectsFilter>();
            _LuaScript.Globals["CameraClearFlags"] = UserData.CreateStatic<UnityEngine.CameraClearFlags>();
            _LuaScript.Globals["DepthTextureMode"] = UserData.CreateStatic<UnityEngine.DepthTextureMode>();
            _LuaScript.Globals["AnisotropicFiltering"] = UserData.CreateStatic<UnityEngine.AnisotropicFiltering>();
            _LuaScript.Globals["MeshTopology"] = UserData.CreateStatic<UnityEngine.MeshTopology>();
            _LuaScript.Globals["SkinQuality"] = UserData.CreateStatic<UnityEngine.SkinQuality>();
            _LuaScript.Globals["ColorSpace"] = UserData.CreateStatic<UnityEngine.ColorSpace>();
            _LuaScript.Globals["FilterMode"] = UserData.CreateStatic<UnityEngine.FilterMode>();
            _LuaScript.Globals["TextureWrapMode"] = UserData.CreateStatic<UnityEngine.TextureWrapMode>();
            _LuaScript.Globals["TextureFormat"] = UserData.CreateStatic<UnityEngine.TextureFormat>();
            _LuaScript.Globals["CubemapFace"] = UserData.CreateStatic<UnityEngine.CubemapFace>();
            _LuaScript.Globals["RenderTextureFormat"] = UserData.CreateStatic<UnityEngine.RenderTextureFormat>();
            _LuaScript.Globals["VRTextureUsage"] = UserData.CreateStatic<UnityEngine.VRTextureUsage>();
            _LuaScript.Globals["RenderTextureReadWrite"] = UserData.CreateStatic<UnityEngine.RenderTextureReadWrite>();
            _LuaScript.Globals["RenderTextureMemoryless"] = UserData.CreateStatic<UnityEngine.RenderTextureMemoryless>();
            _LuaScript.Globals["LightmapsMode"] = UserData.CreateStatic<UnityEngine.LightmapsMode>();
            _LuaScript.Globals["LineAlignment"] = UserData.CreateStatic<UnityEngine.LineAlignment>();
            _LuaScript.Globals["LODFadeMode"] = UserData.CreateStatic<UnityEngine.LODFadeMode>();
            _LuaScript.Globals["CursorMode"] = UserData.CreateStatic<UnityEngine.CursorMode>();
            _LuaScript.Globals["CursorLockMode"] = UserData.CreateStatic<UnityEngine.CursorLockMode>();
            _LuaScript.Globals["KeyCode"] = UserData.CreateStatic<UnityEngine.KeyCode>();
            _LuaScript.Globals["HideFlags"] = UserData.CreateStatic<UnityEngine.HideFlags>();
            _LuaScript.Globals["DisableBatchingType"] = UserData.CreateStatic<UnityEngine.DisableBatchingType>();
            _LuaScript.Globals["OperatingSystemFamily"] = UserData.CreateStatic<UnityEngine.OperatingSystemFamily>();
            _LuaScript.Globals["DrivenTransformProperties"] = UserData.CreateStatic<UnityEngine.DrivenTransformProperties>();
            _LuaScript.Globals["SpriteDrawMode"] = UserData.CreateStatic<UnityEngine.SpriteDrawMode>();
            _LuaScript.Globals["SpriteTileMode"] = UserData.CreateStatic<UnityEngine.SpriteTileMode>();
            _LuaScript.Globals["SpriteMeshType"] = UserData.CreateStatic<UnityEngine.SpriteMeshType>();
            _LuaScript.Globals["SpritePackingMode"] = UserData.CreateStatic<UnityEngine.SpritePackingMode>();
            _LuaScript.Globals["SpriteSortPoint"] = UserData.CreateStatic<UnityEngine.SpriteSortPoint>();
            _LuaScript.Globals["PersistentListenerMode"] = UserData.CreateStatic<UnityEngine.Events.PersistentListenerMode>();
            _LuaScript.Globals["UnityEventCallState"] = UserData.CreateStatic<UnityEngine.Events.UnityEventCallState>();
            _LuaScript.Globals["LoadSceneMode"] = UserData.CreateStatic<UnityEngine.SceneManagement.LoadSceneMode>();
            _LuaScript.Globals["IndexFormat"] = UserData.CreateStatic<UnityEngine.Rendering.IndexFormat>();
            _LuaScript.Globals["MeshUpdateFlags"] = UserData.CreateStatic<UnityEngine.Rendering.MeshUpdateFlags>();
            _LuaScript.Globals["VertexAttributeFormat"] = UserData.CreateStatic<UnityEngine.Rendering.VertexAttributeFormat>();
            _LuaScript.Globals["VertexAttribute"] = UserData.CreateStatic<UnityEngine.Rendering.VertexAttribute>();
            _LuaScript.Globals["OpaqueSortMode"] = UserData.CreateStatic<UnityEngine.Rendering.OpaqueSortMode>();
            _LuaScript.Globals["FastMemoryFlags"] = UserData.CreateStatic<UnityEngine.Rendering.FastMemoryFlags>();
            _LuaScript.Globals["BlendMode"] = UserData.CreateStatic<UnityEngine.Rendering.BlendMode>();
            _LuaScript.Globals["BlendOp"] = UserData.CreateStatic<UnityEngine.Rendering.BlendOp>();
            _LuaScript.Globals["CullMode"] = UserData.CreateStatic<UnityEngine.Rendering.CullMode>();
            _LuaScript.Globals["ColorWriteMask"] = UserData.CreateStatic<UnityEngine.Rendering.ColorWriteMask>();
            _LuaScript.Globals["StencilOp"] = UserData.CreateStatic<UnityEngine.Rendering.StencilOp>();
            _LuaScript.Globals["AmbientMode"] = UserData.CreateStatic<UnityEngine.Rendering.AmbientMode>();
            _LuaScript.Globals["CameraEvent"] = UserData.CreateStatic<UnityEngine.Rendering.CameraEvent>();
            _LuaScript.Globals["LightEvent"] = UserData.CreateStatic<UnityEngine.Rendering.LightEvent>();
            _LuaScript.Globals["ShadowMapPass"] = UserData.CreateStatic<UnityEngine.Rendering.ShadowMapPass>();
            _LuaScript.Globals["BuiltinRenderTextureType"] = UserData.CreateStatic<UnityEngine.Rendering.BuiltinRenderTextureType>();
            _LuaScript.Globals["ShadowCastingMode"] = UserData.CreateStatic<UnityEngine.Rendering.ShadowCastingMode>();
            _LuaScript.Globals["FormatSwizzle"] = UserData.CreateStatic<UnityEngine.Rendering.FormatSwizzle>();
            _LuaScript.Globals["RenderTargetFlags"] = UserData.CreateStatic<UnityEngine.Rendering.RenderTargetFlags>();
            _LuaScript.Globals["ShadowSamplingMode"] = UserData.CreateStatic<UnityEngine.Rendering.ShadowSamplingMode>();
            _LuaScript.Globals["LightProbeUsage"] = UserData.CreateStatic<UnityEngine.Rendering.LightProbeUsage>();
            _LuaScript.Globals["BuiltinShaderDefine"] = UserData.CreateStatic<UnityEngine.Rendering.BuiltinShaderDefine>();
            _LuaScript.Globals["ComputeQueueType"] = UserData.CreateStatic<UnityEngine.Rendering.ComputeQueueType>();
            _LuaScript.Globals["SinglePassStereoMode"] = UserData.CreateStatic<UnityEngine.Rendering.SinglePassStereoMode>();
            _LuaScript.Globals["RTClearFlags"] = UserData.CreateStatic<UnityEngine.Rendering.RTClearFlags>();
            _LuaScript.Globals["RenderTextureSubElement"] = UserData.CreateStatic<UnityEngine.Rendering.RenderTextureSubElement>();
            _LuaScript.Globals["CameraLateLatchMatrixType"] = UserData.CreateStatic<UnityEngine.Rendering.CameraLateLatchMatrixType>();
            _LuaScript.Globals["GraphicsFenceType"] = UserData.CreateStatic<UnityEngine.Rendering.GraphicsFenceType>();
            _LuaScript.Globals["DrawRendererFlags"] = UserData.CreateStatic<UnityEngine.Rendering.DrawRendererFlags>();
            _LuaScript.Globals["GizmoSubset"] = UserData.CreateStatic<UnityEngine.Rendering.GizmoSubset>();
            _LuaScript.Globals["PerObjectData"] = UserData.CreateStatic<UnityEngine.Rendering.PerObjectData>();
            _LuaScript.Globals["RenderStateMask"] = UserData.CreateStatic<UnityEngine.Rendering.RenderStateMask>();
            _LuaScript.Globals["SortingCriteria"] = UserData.CreateStatic<UnityEngine.Rendering.SortingCriteria>();
            _LuaScript.Globals["DistanceMetric"] = UserData.CreateStatic<UnityEngine.Rendering.DistanceMetric>();
            _LuaScript.Globals["VisibleLightFlags"] = UserData.CreateStatic<UnityEngine.Rendering.VisibleLightFlags>();
            _LuaScript.Globals["ShaderPropertyType"] = UserData.CreateStatic<UnityEngine.Rendering.ShaderPropertyType>();
            _LuaScript.Globals["ShaderPropertyFlags"] = UserData.CreateStatic<UnityEngine.Rendering.ShaderPropertyFlags>();
            _LuaScript.Globals["RendererListStatus"] = UserData.CreateStatic<UnityEngine.Rendering.RendererUtils.RendererListStatus>();
            _LuaScript.Globals["DirectorWrapMode"] = UserData.CreateStatic<UnityEngine.Playables.DirectorWrapMode>();
            _LuaScript.Globals["PlayableTraversalMode"] = UserData.CreateStatic<UnityEngine.Playables.PlayableTraversalMode>();
            _LuaScript.Globals["DirectorUpdateMode"] = UserData.CreateStatic<UnityEngine.Playables.DirectorUpdateMode>();
            _LuaScript.Globals["PlayState"] = UserData.CreateStatic<UnityEngine.Playables.PlayState>();
            _LuaScript.Globals["FormatUsage"] = UserData.CreateStatic<UnityEngine.Experimental.Rendering.FormatUsage>();
            _LuaScript.Globals["DefaultFormat"] = UserData.CreateStatic<UnityEngine.Experimental.Rendering.DefaultFormat>();
            _LuaScript.Globals["GraphicsFormat"] = UserData.CreateStatic<UnityEngine.Experimental.Rendering.GraphicsFormat>();
            _LuaScript.Globals["MemorylessMode"] = UserData.CreateStatic<UnityEngineInternal.MemorylessMode>();
            _LuaScript.Globals["GITextureType"] = UserData.CreateStatic<UnityEngineInternal.GITextureType>();
            _LuaScript.Globals["DOTSInstancingPropertyType"] = UserData.CreateStatic<Unity.Rendering.HybridV2.DOTSInstancingPropertyType>();
            _LuaScript.Globals["WeightedMode"] = UserData.CreateStatic<UnityEngine.WeightedMode>();
            _LuaScript.Globals["ReceiveGI"] = UserData.CreateStatic<UnityEngine.ReceiveGI>();
            _LuaScript.Globals["ShadowQuality"] = UserData.CreateStatic<UnityEngine.ShadowQuality>();
            _LuaScript.Globals["TexGenMode"] = UserData.CreateStatic<UnityEngine.TexGenMode>();
            //_LuaScript.Globals["BlendWeights"] = UserData.CreateStatic<UnityEngine.BlendWeights>();
            _LuaScript.Globals["SkinWeights"] = UserData.CreateStatic<UnityEngine.SkinWeights>();
            _LuaScript.Globals["ColorGamut"] = UserData.CreateStatic<UnityEngine.ColorGamut>();
            _LuaScript.Globals["NPOTSupport"] = UserData.CreateStatic<UnityEngine.NPOTSupport>();
            _LuaScript.Globals["HDRDisplaySupportFlags"] = UserData.CreateStatic<UnityEngine.HDRDisplaySupportFlags>();
            _LuaScript.Globals["CustomRenderTextureUpdateMode"] = UserData.CreateStatic<UnityEngine.CustomRenderTextureUpdateMode>();
            _LuaScript.Globals["CustomRenderTextureUpdateZoneSpace"] = UserData.CreateStatic<UnityEngine.CustomRenderTextureUpdateZoneSpace>();
            _LuaScript.Globals["D3DHDRDisplayBitDepth"] = UserData.CreateStatic<UnityEngine.D3DHDRDisplayBitDepth>();
            _LuaScript.Globals["SnapAxis"] = UserData.CreateStatic<UnityEngine.SnapAxis>();
            _LuaScript.Globals["FullScreenMovieControlMode"] = UserData.CreateStatic<UnityEngine.FullScreenMovieControlMode>();
            _LuaScript.Globals["FullScreenMovieScalingMode"] = UserData.CreateStatic<UnityEngine.FullScreenMovieScalingMode>();
            _LuaScript.Globals["AndroidActivityIndicatorStyle"] = UserData.CreateStatic<UnityEngine.AndroidActivityIndicatorStyle>();
            _LuaScript.Globals["GradientMode"] = UserData.CreateStatic<UnityEngine.GradientMode>();
            _LuaScript.Globals["SpriteAlignment"] = UserData.CreateStatic<UnityEngine.SpriteAlignment>();
            _LuaScript.Globals["Light2DType"] = UserData.CreateStatic<UnityEngine.U2D.Light2DType>();
            _LuaScript.Globals["CaptureFlags"] = UserData.CreateStatic<UnityEngine.Profiling.Memory.Experimental.CaptureFlags>();
            _LuaScript.Globals["SearchViewFlags"] = UserData.CreateStatic<UnityEngine.Search.SearchViewFlags>();
            _LuaScript.Globals["ShaderParamType"] = UserData.CreateStatic<UnityEngine.Rendering.ShaderParamType>();
            _LuaScript.Globals["ShaderConstantType"] = UserData.CreateStatic<UnityEngine.Rendering.ShaderConstantType>();
            _LuaScript.Globals["RenderQueue"] = UserData.CreateStatic<UnityEngine.Rendering.RenderQueue>();
            _LuaScript.Globals["PassType"] = UserData.CreateStatic<UnityEngine.Rendering.PassType>();
            _LuaScript.Globals["BuiltinShaderType"] = UserData.CreateStatic<UnityEngine.Rendering.BuiltinShaderType>();
            _LuaScript.Globals["BuiltinShaderMode"] = UserData.CreateStatic<UnityEngine.Rendering.BuiltinShaderMode>();
            _LuaScript.Globals["VideoShadersIncludeMode"] = UserData.CreateStatic<UnityEngine.Rendering.VideoShadersIncludeMode>();
            _LuaScript.Globals["CameraHDRMode"] = UserData.CreateStatic<UnityEngine.Rendering.CameraHDRMode>();
            _LuaScript.Globals["RealtimeGICPUUsage"] = UserData.CreateStatic<UnityEngine.Rendering.RealtimeGICPUUsage>();
            _LuaScript.Globals["ShaderKeywordType"] = UserData.CreateStatic<UnityEngine.Rendering.ShaderKeywordType>();
            _LuaScript.Globals["RayTracingSubMeshFlags"] = UserData.CreateStatic<UnityEngine.Experimental.Rendering.RayTracingSubMeshFlags>();
            _LuaScript.Globals["RayTracingMode"] = UserData.CreateStatic<UnityEngine.Experimental.Rendering.RayTracingMode>();
            _LuaScript.Globals["WaitForPresentSyncPoint"] = UserData.CreateStatic<UnityEngine.Experimental.Rendering.WaitForPresentSyncPoint>();
            _LuaScript.Globals["GraphicsJobsSyncPoint"] = UserData.CreateStatic<UnityEngine.Experimental.Rendering.GraphicsJobsSyncPoint>();
            _LuaScript.Globals["DataStreamType"] = UserData.CreateStatic<UnityEngine.Playables.DataStreamType>();
            _LuaScript.Globals["Camera.GateFitMode"] = UserData.CreateStatic<UnityEngine.Camera.GateFitMode>();
            _LuaScript.Globals["Camera.StereoscopicEye"] = UserData.CreateStatic<UnityEngine.Camera.StereoscopicEye>();
            _LuaScript.Globals["Camera.MonoOrStereoscopicEye"] = UserData.CreateStatic<UnityEngine.Camera.MonoOrStereoscopicEye>();
            _LuaScript.Globals["Camera.SceneViewFilterMode"] = UserData.CreateStatic<UnityEngine.Camera.SceneViewFilterMode>();
            _LuaScript.Globals["Camera.RenderRequestMode"] = UserData.CreateStatic<UnityEngine.Camera.RenderRequestMode>();
            _LuaScript.Globals["Camera.RenderRequestOutputSpace"] = UserData.CreateStatic<UnityEngine.Camera.RenderRequestOutputSpace>();
            _LuaScript.Globals["Camera.FieldOfViewAxis"] = UserData.CreateStatic<UnityEngine.Camera.FieldOfViewAxis>();
            _LuaScript.Globals["GraphicsBuffer.Target"] = UserData.CreateStatic<UnityEngine.GraphicsBuffer.Target>();
            _LuaScript.Globals["LightProbeProxyVolume.BoundingBoxMode"] = UserData.CreateStatic<UnityEngine.LightProbeProxyVolume.BoundingBoxMode>();
            _LuaScript.Globals["LightProbeProxyVolume.RefreshMode"] = UserData.CreateStatic<UnityEngine.LightProbeProxyVolume.RefreshMode>();
            _LuaScript.Globals["LightProbeProxyVolume.QualityMode"] = UserData.CreateStatic<UnityEngine.LightProbeProxyVolume.QualityMode>();
            _LuaScript.Globals["LightProbeProxyVolume.DataFormat"] = UserData.CreateStatic<UnityEngine.LightProbeProxyVolume.DataFormat>();
            _LuaScript.Globals["Texture2D.EXRFlags"] = UserData.CreateStatic<UnityEngine.Texture2D.EXRFlags>();
            _LuaScript.Globals["TouchScreenKeyboard.Status"] = UserData.CreateStatic<UnityEngine.TouchScreenKeyboard.Status>();
            _LuaScript.Globals["RectTransform.Edge"] = UserData.CreateStatic<UnityEngine.RectTransform.Edge>();
            _LuaScript.Globals["RectTransform.Axis"] = UserData.CreateStatic<UnityEngine.RectTransform.Axis>();
            _LuaScript.Globals["Scene.LoadingState"] = UserData.CreateStatic<UnityEngine.SceneManagement.Scene.LoadingState>();
            _LuaScript.Globals["SupportedRenderingFeatures.LightmapMixedBakeModes"] = UserData.CreateStatic<UnityEngine.Rendering.SupportedRenderingFeatures.LightmapMixedBakeModes>();
            _LuaScript.Globals["FrameData.Flags"] = UserData.CreateStatic<UnityEngine.Playables.FrameData.Flags>();

            // Enums from assembly: UnityEngine.PhysicsModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["RigidbodyConstraints"] = UserData.CreateStatic<UnityEngine.RigidbodyConstraints>();
            _LuaScript.Globals["ForceMode"] = UserData.CreateStatic<UnityEngine.ForceMode>();
            _LuaScript.Globals["PhysicMaterialCombine"] = UserData.CreateStatic<UnityEngine.PhysicMaterialCombine>();
            _LuaScript.Globals["JointDriveMode"] = UserData.CreateStatic<UnityEngine.JointDriveMode>();
            _LuaScript.Globals["ModifiableContactPatch.Flags"] = UserData.CreateStatic<UnityEngine.ModifiableContactPatch.Flags>();

            // Enums from assembly: UnityEngine.UIModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["RenderMode"] = UserData.CreateStatic<UnityEngine.RenderMode>();

            // Enums from assembly: UnityEngine.AIModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["NavMesh"] = UserData.CreateStatic(typeof(UnityEngine.AI.NavMesh));
            _LuaScript.Globals["NavMeshPathStatus"] = UserData.CreateStatic<UnityEngine.AI.NavMeshPathStatus>();
            _LuaScript.Globals["ObstacleAvoidanceType"] = UserData.CreateStatic<UnityEngine.AI.ObstacleAvoidanceType>();
            _LuaScript.Globals["NavMeshObstacleShape"] = UserData.CreateStatic<UnityEngine.AI.NavMeshObstacleShape>();
            _LuaScript.Globals["OffMeshLinkType"] = UserData.CreateStatic<UnityEngine.AI.OffMeshLinkType>();
            _LuaScript.Globals["NavMeshBuildSourceShape"] = UserData.CreateStatic<UnityEngine.AI.NavMeshBuildSourceShape>();
            _LuaScript.Globals["NavMeshCollectGeometry"] = UserData.CreateStatic<UnityEngine.AI.NavMeshCollectGeometry>();
            _LuaScript.Globals["PathQueryStatus"] = UserData.CreateStatic<UnityEngine.Experimental.AI.PathQueryStatus>();
            _LuaScript.Globals["NavMeshPolyTypes"] = UserData.CreateStatic<UnityEngine.Experimental.AI.NavMeshPolyTypes>();
            _LuaScript.Globals["NavMeshBuildDebugFlags"] = UserData.CreateStatic<UnityEngine.AI.NavMeshBuildDebugFlags>();

            // Enums from assembly: UnityEngine.AnimationModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["PlayMode"] = UserData.CreateStatic<UnityEngine.PlayMode>();
            _LuaScript.Globals["QueueMode"] = UserData.CreateStatic<UnityEngine.QueueMode>();
            _LuaScript.Globals["AvatarTarget"] = UserData.CreateStatic<UnityEngine.AvatarTarget>();
            _LuaScript.Globals["AvatarIKGoal"] = UserData.CreateStatic<UnityEngine.AvatarIKGoal>();
            _LuaScript.Globals["AvatarIKHint"] = UserData.CreateStatic<UnityEngine.AvatarIKHint>();
            _LuaScript.Globals["AnimatorControllerParameterType"] = UserData.CreateStatic<UnityEngine.AnimatorControllerParameterType>();
            _LuaScript.Globals["StateInfoIndex"] = UserData.CreateStatic<UnityEngine.StateInfoIndex>();
            _LuaScript.Globals["AnimatorRecorderMode"] = UserData.CreateStatic<UnityEngine.AnimatorRecorderMode>();
            _LuaScript.Globals["AnimatorCullingMode"] = UserData.CreateStatic<UnityEngine.AnimatorCullingMode>();
            _LuaScript.Globals["AnimatorUpdateMode"] = UserData.CreateStatic<UnityEngine.AnimatorUpdateMode>();
            _LuaScript.Globals["HumanBodyBones"] = UserData.CreateStatic<UnityEngine.HumanBodyBones>();
            _LuaScript.Globals["AvatarMaskBodyPart"] = UserData.CreateStatic<UnityEngine.AvatarMaskBodyPart>();
            _LuaScript.Globals["BodyDof"] = UserData.CreateStatic<UnityEngine.BodyDof>();
            _LuaScript.Globals["HeadDof"] = UserData.CreateStatic<UnityEngine.HeadDof>();
            _LuaScript.Globals["LegDof"] = UserData.CreateStatic<UnityEngine.LegDof>();
            _LuaScript.Globals["ArmDof"] = UserData.CreateStatic<UnityEngine.ArmDof>();
            _LuaScript.Globals["FingerDof"] = UserData.CreateStatic<UnityEngine.FingerDof>();
            _LuaScript.Globals["HumanPartDof"] = UserData.CreateStatic<UnityEngine.HumanPartDof>();
            _LuaScript.Globals["Dof"] = UserData.CreateStatic<UnityEngine.Dof>();
            _LuaScript.Globals["HumanParameter"] = UserData.CreateStatic<UnityEngine.HumanParameter>();

            // Enums from assembly: UnityEngine.TextRenderingModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["FontStyle"] = UserData.CreateStatic<UnityEngine.FontStyle>();
            _LuaScript.Globals["TextAlignment"] = UserData.CreateStatic<UnityEngine.TextAlignment>();
            _LuaScript.Globals["TextAnchor"] = UserData.CreateStatic<UnityEngine.TextAnchor>();
            _LuaScript.Globals["HorizontalWrapMode"] = UserData.CreateStatic<UnityEngine.HorizontalWrapMode>();
            _LuaScript.Globals["VerticalWrapMode"] = UserData.CreateStatic<UnityEngine.VerticalWrapMode>();

            // Enums from assembly: UnityEngine.ParticleSystemModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["ParticleSystemRenderMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemRenderMode>();
            _LuaScript.Globals["ParticleSystemSortMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemSortMode>();
            _LuaScript.Globals["ParticleSystemRenderSpace"] = UserData.CreateStatic<UnityEngine.ParticleSystemRenderSpace>();
            _LuaScript.Globals["ParticleSystemCurveMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemCurveMode>();
            _LuaScript.Globals["ParticleSystemGradientMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemGradientMode>();
            _LuaScript.Globals["ParticleSystemShapeType"] = UserData.CreateStatic<UnityEngine.ParticleSystemShapeType>();
            _LuaScript.Globals["ParticleSystemMeshShapeType"] = UserData.CreateStatic<UnityEngine.ParticleSystemMeshShapeType>();
            _LuaScript.Globals["ParticleSystemScalingMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemScalingMode>();
            _LuaScript.Globals["ParticleSystemEmitterVelocityMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemEmitterVelocityMode>();
            _LuaScript.Globals["ParticleSystemInheritVelocityMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemInheritVelocityMode>();
            _LuaScript.Globals["ParticleSystemVertexStream"] = UserData.CreateStatic<UnityEngine.ParticleSystemVertexStream>();
            _LuaScript.Globals["ParticleSystemCustomData"] = UserData.CreateStatic<UnityEngine.ParticleSystemCustomData>();
            _LuaScript.Globals["ParticleSystemNoiseQuality"] = UserData.CreateStatic<UnityEngine.ParticleSystemNoiseQuality>();
            _LuaScript.Globals["ParticleSystemGameObjectFilter"] = UserData.CreateStatic<UnityEngine.ParticleSystemGameObjectFilter>();
            _LuaScript.Globals["ParticleSystemForceFieldShape"] = UserData.CreateStatic<UnityEngine.ParticleSystemForceFieldShape>();
            _LuaScript.Globals["ParticleSystemVertexStreams"] = UserData.CreateStatic<UnityEngine.ParticleSystemVertexStreams>();
            _LuaScript.Globals["ParticleSystemShapeTextureChannel"] = UserData.CreateStatic<UnityEngine.ParticleSystemShapeTextureChannel>();
            _LuaScript.Globals["ParticleSystemColliderQueryMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemColliderQueryMode>();
            _LuaScript.Globals["ParticleSystemCullingMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemCullingMode>();
            _LuaScript.Globals["ParticleSystemTriggerEventType"] = UserData.CreateStatic<UnityEngine.ParticleSystemTriggerEventType>();
            _LuaScript.Globals["ParticleSystemCustomDataMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemCustomDataMode>();
            _LuaScript.Globals["ParticleSystemSubEmitterType"] = UserData.CreateStatic<UnityEngine.ParticleSystemSubEmitterType>();
            _LuaScript.Globals["ParticleSystemSubEmitterProperties"] = UserData.CreateStatic<UnityEngine.ParticleSystemSubEmitterProperties>();
            _LuaScript.Globals["ParticleSystemTrailMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemTrailMode>();
            _LuaScript.Globals["ParticleSystemTrailTextureMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemTrailTextureMode>();
            _LuaScript.Globals["ParticleSystemShapeMultiModeValue"] = UserData.CreateStatic<UnityEngine.ParticleSystemShapeMultiModeValue>();
            _LuaScript.Globals["ParticleSystemRingBufferMode"] = UserData.CreateStatic<UnityEngine.ParticleSystemRingBufferMode>();
            _LuaScript.Globals["UVChannelFlags"] = UserData.CreateStatic<UnityEngine.Rendering.UVChannelFlags>();
            _LuaScript.Globals["Particle.Flags"] = UserData.CreateStatic<UnityEngine.ParticleSystem.Particle.Flags>();

            // Enums from assembly: UnityEngine.TerrainModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["TerrainRenderFlags"] = UserData.CreateStatic<UnityEngine.TerrainRenderFlags>();
            _LuaScript.Globals["TerrainHeightmapSyncControl"] = UserData.CreateStatic<UnityEngine.TerrainHeightmapSyncControl>();
            _LuaScript.Globals["TerrainMapStatusCode"] = UserData.CreateStatic<UnityEngine.TerrainUtils.TerrainMapStatusCode>();
            _LuaScript.Globals["DetailRenderMode"] = UserData.CreateStatic<UnityEngine.DetailRenderMode>();
            _LuaScript.Globals["TerrainChangedFlags"] = UserData.CreateStatic<UnityEngine.TerrainChangedFlags>();
            _LuaScript.Globals["TerrainBuiltinPaintMaterialPasses"] = UserData.CreateStatic<UnityEngine.TerrainTools.TerrainBuiltinPaintMaterialPasses>();
            _LuaScript.Globals["Terrain.MaterialType"] = UserData.CreateStatic<UnityEngine.Terrain.MaterialType>();
            _LuaScript.Globals["TerrainData.BoundaryValueType"] = UserData.CreateStatic<UnityEngine.TerrainData.BoundaryValueType>();

            // Enums from assembly: UnityEngine.VideoModule, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["VideoRenderMode"] = UserData.CreateStatic<UnityEngine.Video.VideoRenderMode>();
            _LuaScript.Globals["Video3DLayout"] = UserData.CreateStatic<UnityEngine.Video.Video3DLayout>();
            _LuaScript.Globals["VideoTimeSource"] = UserData.CreateStatic<UnityEngine.Video.VideoTimeSource>();
            _LuaScript.Globals["VideoTimeReference"] = UserData.CreateStatic<UnityEngine.Video.VideoTimeReference>();
            _LuaScript.Globals["VideoSource"] = UserData.CreateStatic<UnityEngine.Video.VideoSource>();
            _LuaScript.Globals["VideoError"] = UserData.CreateStatic<UnityEngineInternal.Video.VideoError>();
            _LuaScript.Globals["VideoPixelFormat"] = UserData.CreateStatic<UnityEngineInternal.Video.VideoPixelFormat>();
            _LuaScript.Globals["VideoAlphaLayout"] = UserData.CreateStatic<UnityEngineInternal.Video.VideoAlphaLayout>();

            _LuaScript.Globals["TextContainerAnchors"] = UserData.CreateStatic<Il2CppTMPro.TextContainerAnchors>();
            _LuaScript.Globals["Compute_DistanceTransform_EventTypes"] = UserData.CreateStatic<Il2CppTMPro.Compute_DistanceTransform_EventTypes>();
            _LuaScript.Globals["TMP_VertexDataUpdateFlags"] = UserData.CreateStatic<Il2CppTMPro.TMP_VertexDataUpdateFlags>();
            _LuaScript.Globals["ColorMode"] = UserData.CreateStatic<Il2CppTMPro.ColorMode>();
            _LuaScript.Globals["FontFeatureLookupFlags"] = UserData.CreateStatic<Il2CppTMPro.FontFeatureLookupFlags>();
            _LuaScript.Globals["VertexSortingOrder"] = UserData.CreateStatic<Il2CppTMPro.VertexSortingOrder>();
            _LuaScript.Globals["MarkupTag"] = UserData.CreateStatic<Il2CppTMPro.MarkupTag>();
            _LuaScript.Globals["TagValueType"] = UserData.CreateStatic<Il2CppTMPro.TagValueType>();
            _LuaScript.Globals["TagUnitType"] = UserData.CreateStatic<Il2CppTMPro.TagUnitType>();
            _LuaScript.Globals["TextRenderFlags"] = UserData.CreateStatic<Il2CppTMPro.TextRenderFlags>();
            _LuaScript.Globals["TMP_TextElementType"] = UserData.CreateStatic<Il2CppTMPro.TMP_TextElementType>();
            _LuaScript.Globals["MaskingTypes"] = UserData.CreateStatic<Il2CppTMPro.MaskingTypes>();
            _LuaScript.Globals["TextOverflowModes"] = UserData.CreateStatic<Il2CppTMPro.TextOverflowModes>();
            _LuaScript.Globals["MaskingOffsetMode"] = UserData.CreateStatic<Il2CppTMPro.MaskingOffsetMode>();
            _LuaScript.Globals["FontStyles"] = UserData.CreateStatic<Il2CppTMPro.FontStyles>();
            _LuaScript.Globals["FontWeight"] = UserData.CreateStatic<Il2CppTMPro.FontWeight>();
            _LuaScript.Globals["TextElementType"] = UserData.CreateStatic<Il2CppTMPro.TextElementType>();
            _LuaScript.Globals["SpriteAssetImportFormats"] = UserData.CreateStatic<Il2CppTMPro.SpriteAssetUtilities.SpriteAssetImportFormats>();
            _LuaScript.Globals["ColorTween.ColorTweenMode"] = UserData.CreateStatic<Il2CppTMPro.ColorTween.ColorTweenMode>();
            _LuaScript.Globals["TMP_InputField.ContentType"] = UserData.CreateStatic<Il2CppTMPro.TMP_InputField.ContentType>();
            _LuaScript.Globals["TMP_InputField.InputType"] = UserData.CreateStatic<Il2CppTMPro.TMP_InputField.InputType>();
            _LuaScript.Globals["TMP_InputField.EditState"] = UserData.CreateStatic<Il2CppTMPro.TMP_InputField.EditState>();
            _LuaScript.Globals["TMP_Text.TextInputSources"] = UserData.CreateStatic<Il2CppTMPro.TMP_Text.TextInputSources>();

         

            // Enums from assembly: Il2CppSLZ.Marrow, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["SaveFeatures"] = UserData.CreateStatic<Il2CppSLZ.Marrow.SaveFeatures>();
            _LuaScript.Globals["GripFlags"] = UserData.CreateStatic<Il2CppSLZ.Marrow.GripFlags>();
            _LuaScript.Globals["SlotType"] = UserData.CreateStatic<Il2CppSLZ.Marrow.SlotType>();
            _LuaScript.Globals["InactiveStates"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Zones.InactiveStates>();
            _LuaScript.Globals["ZoneGunMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Zones.ZoneGunMode>();
            _LuaScript.Globals["EdgeType"] = UserData.CreateStatic<Il2CppSLZ.Marrow.VoidLogic.EdgeType>();
            _LuaScript.Globals["ValueType"] = UserData.CreateStatic<Il2CppSLZ.Marrow.VoidLogic.ValueType>();
            _LuaScript.Globals["StreamStatus"] = UserData.CreateStatic<Il2CppSLZ.Marrow.SceneStreaming.StreamStatus>();
            _LuaScript.Globals["MuscleRemoveMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.PuppetMasta.MuscleRemoveMode>();
            _LuaScript.Globals["FullBodyBone"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Input.FullBodyBone>();
            _LuaScript.Globals["XRControllerType"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Input.XRControllerType>();
            _LuaScript.Globals["HandBone"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Input.HandBone>();
            _LuaScript.Globals["GraphicsQuality"] = UserData.CreateStatic<Il2CppSLZ.Marrow.SaveData.GraphicsQuality>();
            _LuaScript.Globals["SpectatorCameraMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.SaveData.SpectatorCameraMode>();
            _LuaScript.Globals["EyeTarget"] = UserData.CreateStatic<Il2CppSLZ.Marrow.SaveData.EyeTarget>();
            _LuaScript.Globals["SettingLevel"] = UserData.CreateStatic<Il2CppSLZ.Marrow.SaveData.SettingLevel>();
            _LuaScript.Globals["FoveatedRenderingMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.SaveData.FoveatedRenderingMode>();
            _LuaScript.Globals["FoveatedPresets"] = UserData.CreateStatic<Il2CppSLZ.Marrow.SaveData.FoveatedPresets>();
            _LuaScript.Globals["SaveFlags"] = UserData.CreateStatic<Il2CppSLZ.Marrow.SaveData.SaveFlags>();
            _LuaScript.Globals["AttackType"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Data.AttackType>();
            _LuaScript.Globals["Weight"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Data.Weight>();
            _LuaScript.Globals["VRPlatform"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Data.VRPlatform>();
            _LuaScript.Globals["AvatarGrip.BodyRb"] = UserData.CreateStatic<Il2CppSLZ.Marrow.AvatarGrip.BodyRb>();
            _LuaScript.Globals["BarrelGrip.Caps"] = UserData.CreateStatic<Il2CppSLZ.Marrow.BarrelGrip.Caps>();
            _LuaScript.Globals["BoxGrip.Faces"] = UserData.CreateStatic<Il2CppSLZ.Marrow.BoxGrip.Faces>();
            _LuaScript.Globals["BoxGrip.Edges"] = UserData.CreateStatic<Il2CppSLZ.Marrow.BoxGrip.Edges>();
            _LuaScript.Globals["BoxGrip.Corners"] = UserData.CreateStatic<Il2CppSLZ.Marrow.BoxGrip.Corners>();
            _LuaScript.Globals["ForcePullGrip.GripState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.ForcePullGrip.GripState>();
            _LuaScript.Globals["LadderInfo.Source"] = UserData.CreateStatic<Il2CppSLZ.Marrow.LadderInfo.Source>();
            _LuaScript.Globals["Constrainer.ConstraintMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Constrainer.ConstraintMode>();
            _LuaScript.Globals["Gun.FireMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Gun.FireMode>();
            _LuaScript.Globals["Gun.SlideStates"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Gun.SlideStates>();
            _LuaScript.Globals["Gun.HammerStates"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Gun.HammerStates>();
            _LuaScript.Globals["Gun.CartridgeStates"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Gun.CartridgeStates>();
            _LuaScript.Globals["ImpactProperties.DecalType"] = UserData.CreateStatic<Il2CppSLZ.Marrow.ImpactProperties.DecalType>();
            _LuaScript.Globals["Haptor.HapStack"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Haptor.HapStack>();
            _LuaScript.Globals["Health.HealthMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Health.HealthMode>();
            _LuaScript.Globals["PlayerDamageReceiver.BodyPart"] = UserData.CreateStatic<Il2CppSLZ.Marrow.PlayerDamageReceiver.BodyPart>();
            _LuaScript.Globals["BaseController.GesturePose"] = UserData.CreateStatic<Il2CppSLZ.Marrow.BaseController.GesturePose>();
            _LuaScript.Globals["OpenControllerRig.TrackedState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.OpenControllerRig.TrackedState>();
            _LuaScript.Globals["OpenControllerRig.CurveMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.OpenControllerRig.CurveMode>();
            _LuaScript.Globals["OpenControllerRig.VrVertState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.OpenControllerRig.VrVertState>();
            _LuaScript.Globals["PhysicsRig.BodyMassState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.PhysicsRig.BodyMassState>();
            _LuaScript.Globals["PhysicsRig.StepState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.PhysicsRig.StepState>();
            _LuaScript.Globals["RemapRig.TraversalState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.RemapRig.TraversalState>();
            _LuaScript.Globals["RemapRig.VertState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.RemapRig.VertState>();
            _LuaScript.Globals["RigManager.BodyState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.RigManager.BodyState>();
            _LuaScript.Globals["RigManager.LeashType"] = UserData.CreateStatic<Il2CppSLZ.Marrow.RigManager.LeashType>();
            _LuaScript.Globals["Seat.SeatState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Seat.SeatState>();
            _LuaScript.Globals["Seat.AxisAssignment"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Seat.AxisAssignment>();
            _LuaScript.Globals["ParticleSpread.Alignment"] = UserData.CreateStatic<Il2CppSLZ.Marrow.ParticleSpread.Alignment>();
            _LuaScript.Globals["PhysHand.HandPhysState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.PhysHand.HandPhysState>();
            _LuaScript.Globals["Zone3dSound.SoundMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Zones.Zone3dSound.SoundMode>();
            _LuaScript.Globals["ZoneLinkItem.EventTypes"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Zones.ZoneLinkItem.EventTypes>();
            _LuaScript.Globals["MarrowQuery.LogicOperator"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Warehouse.MarrowQuery.LogicOperator>();
            _LuaScript.Globals["BaseEnemyConfig.LocoState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.PuppetMasta.BaseEnemyConfig.LocoState>();
            _LuaScript.Globals["Muscle.Group"] = UserData.CreateStatic<Il2CppSLZ.Marrow.PuppetMasta.Muscle.Group>();
            _LuaScript.Globals["PuppetMaster.Mode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.PuppetMasta.PuppetMaster.Mode>();
            _LuaScript.Globals["PuppetMaster.State"] = UserData.CreateStatic<Il2CppSLZ.Marrow.PuppetMasta.PuppetMaster.State>();
            _LuaScript.Globals["Weight.Mode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.PuppetMasta.Weight.Mode>();
            _LuaScript.Globals["DisplaySubsystemManager.ColorSpace"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Input.DisplaySubsystemManager.ColorSpace>();
            _LuaScript.Globals["SpawnPolicyData.PolicyRule"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Data.SpawnPolicyData.PolicyRule>();
            _LuaScript.Globals["BaseConsoleCommand.CommandStatus"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Console.BaseConsoleCommand.CommandStatus>();
            _LuaScript.Globals["AngularXSensor.Output"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Circuits.AngularXSensor.Output>();
            _LuaScript.Globals["AngularYSensor.Output"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Circuits.AngularYSensor.Output>();
            _LuaScript.Globals["AngularZSensor.Output"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Circuits.AngularZSensor.Output>();
            _LuaScript.Globals["ButtonController.ButtonMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Circuits.ButtonController.ButtonMode>();
            _LuaScript.Globals["LinearXSensor.Output"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Circuits.LinearXSensor.Output>();
            _LuaScript.Globals["Encounter.SpawnOrder"] = UserData.CreateStatic<Il2CppSLZ.Marrow.AI.Encounter.SpawnOrder>();
            _LuaScript.Globals["NPC_Display_Data.NPC_State"] = UserData.CreateStatic<Il2CppSLZ.Marrow.AI.NPC_Display_Data.NPC_State>();
            _LuaScript.Globals["SpawnAgro.MentalMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.AI.SpawnAgro.MentalMode>();
            _LuaScript.Globals["SpawnGroup.MentalMode"] = UserData.CreateStatic<Il2CppSLZ.Marrow.AI.SpawnGroup.MentalMode>();
            _LuaScript.Globals["TriggerRefProxy.TriggerType"] = UserData.CreateStatic<Il2CppSLZ.Marrow.AI.TriggerRefProxy.TriggerType>();
            _LuaScript.Globals["TriggerRefProxy.NpcType"] = UserData.CreateStatic<Il2CppSLZ.Marrow.AI.TriggerRefProxy.NpcType>();
            _LuaScript.Globals["Footstep.StepState"] = UserData.CreateStatic<Il2CppSLZ.Marrow.SLZ_Body.Footstep.StepState>();

            // Enums from assembly: Il2CppSLZ.Marrow.VoidLogic.Core, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["SupportFlags"] = UserData.CreateStatic<Il2CppSLZ.Marrow.VoidLogic.SupportFlags>();

            // Enums from assembly: Il2CppSLZ.Marrow.VoidLogic.Engine, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null


            // Enums from assembly: Assembly-CSharp, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null

            _LuaScript.Globals["GradType"] = UserData.CreateStatic<Il2Cpp.GradType>();
            _LuaScript.Globals["LeanTweenType"] = UserData.CreateStatic<Il2Cpp.LeanTweenType>();
            _LuaScript.Globals["LeanProp"] = UserData.CreateStatic<Il2Cpp.LeanProp>();
            _LuaScript.Globals["ListChangeType"] = UserData.CreateStatic<Il2CppSplineMesh.ListChangeType>();
            _LuaScript.Globals["Workflow"] = UserData.CreateStatic<Il2CppMK.Glow.Workflow>();
            _LuaScript.Globals["AntiFlickerMode"] = UserData.CreateStatic<Il2CppMK.Glow.AntiFlickerMode>();
            _LuaScript.Globals["Quality"] = UserData.CreateStatic<Il2CppMK.Glow.Quality>();
            _LuaScript.Globals["DebugView"] = UserData.CreateStatic<Il2CppMK.Glow.DebugView>();
            _LuaScript.Globals["LensFlareStyle"] = UserData.CreateStatic<Il2CppMK.Glow.LensFlareStyle>();
            _LuaScript.Globals["GlareStyle"] = UserData.CreateStatic<Il2CppMK.Glow.GlareStyle>();
            _LuaScript.Globals["RenderPipeline"] = UserData.CreateStatic<Il2CppMK.Glow.RenderPipeline>();
            _LuaScript.Globals["NORMAL_OFFSET"] = UserData.CreateStatic<Il2CppECE.NORMAL_OFFSET>();
            _LuaScript.Globals["CAPSULE_COLLIDER_METHOD"] = UserData.CreateStatic<Il2CppECE.CAPSULE_COLLIDER_METHOD>();
            _LuaScript.Globals["CREATE_COLLIDER_TYPE"] = UserData.CreateStatic<Il2CppECE.CREATE_COLLIDER_TYPE>();
            _LuaScript.Globals["GIZMO_TYPE"] = UserData.CreateStatic<Il2CppECE.GIZMO_TYPE>();
            _LuaScript.Globals["RENDER_POINT_TYPE"] = UserData.CreateStatic<Il2CppECE.RENDER_POINT_TYPE>();
            _LuaScript.Globals["SKINNED_MESH_COLLIDER_TYPE"] = UserData.CreateStatic<Il2CppECE.SKINNED_MESH_COLLIDER_TYPE>();
            _LuaScript.Globals["SPHERE_COLLIDER_METHOD"] = UserData.CreateStatic<Il2CppECE.SPHERE_COLLIDER_METHOD>();
            _LuaScript.Globals["MESH_COLLIDER_METHOD"] = UserData.CreateStatic<Il2CppECE.MESH_COLLIDER_METHOD>();
            _LuaScript.Globals["VERTEX_SNAP_METHOD"] = UserData.CreateStatic<Il2CppECE.VERTEX_SNAP_METHOD>();
            _LuaScript.Globals["VHACD_RESULT_METHOD"] = UserData.CreateStatic<Il2CppECE.VHACD_RESULT_METHOD>();
            _LuaScript.Globals["ECE_WINDOW_TAB"] = UserData.CreateStatic<Il2CppECE.ECE_WINDOW_TAB>();
            _LuaScript.Globals["COLLIDER_HOLDER"] = UserData.CreateStatic<Il2CppECE.COLLIDER_HOLDER>();
            _LuaScript.Globals["CONVEX_HULL_SAVE_METHOD"] = UserData.CreateStatic<Il2CppECE.CONVEX_HULL_SAVE_METHOD>();
            _LuaScript.Globals["CategoryFilters"] = UserData.CreateStatic<Il2CppSLZ.Data.CategoryFilters>();
            _LuaScript.Globals["MuzzleBreakType"] = UserData.CreateStatic<Il2CppSLZ.Combat.MuzzleBreakType>();
            _LuaScript.Globals["ObjetiveModes"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.ObjetiveModes>();
            _LuaScript.Globals["UtilityModes"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.UtilityModes>();
            _LuaScript.Globals["LogicGunMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.VoidLogic.LogicGunMode>();
            _LuaScript.Globals["Difficulty"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.SaveData.Difficulty>();
            _LuaScript.Globals["PlayMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.SaveData.PlayMode>();
            _LuaScript.Globals["RTSize"] = UserData.CreateStatic<Il2CppLuxURPEssentials.RTSize>();
            _LuaScript.Globals["RTFormat"] = UserData.CreateStatic<Il2CppLuxURPEssentials.RTFormat>();
            _LuaScript.Globals["GustMixLayer"] = UserData.CreateStatic<Il2CppLuxURPEssentials.GustMixLayer>();
            _LuaScript.Globals["ProceduralTexture2D.TextureType"] = UserData.CreateStatic<Il2Cpp.ProceduralTexture2D.TextureType>();
            _LuaScript.Globals["LTGUI.Element_Type"] = UserData.CreateStatic<Il2Cpp.LTGUI.Element_Type>();
            _LuaScript.Globals["NPC_Tracker_Data.NPC_State"] = UserData.CreateStatic<Il2Cpp.NPC_Tracker_Data.NPC_State>();
            _LuaScript.Globals["NPC_Tracker_Data.ALIVE_State"] = UserData.CreateStatic<Il2Cpp.NPC_Tracker_Data.ALIVE_State>();
            _LuaScript.Globals["EnemyTool.EToolMode"] = UserData.CreateStatic<Il2Cpp.EnemyTool.EToolMode>();
            _LuaScript.Globals["MeshBender.FillingMode"] = UserData.CreateStatic<Il2CppSplineMesh.MeshBender.FillingMode>();
            _LuaScript.Globals["ControlData.EyeControl"] = UserData.CreateStatic<Il2CppRealisticEyeMovements.ControlData.EyeControl>();
            _LuaScript.Globals["ControlData.EyelidControl"] = UserData.CreateStatic<Il2CppRealisticEyeMovements.ControlData.EyelidControl>();
            _LuaScript.Globals["ControlData.EyelidBoneMode"] = UserData.CreateStatic<Il2CppRealisticEyeMovements.ControlData.EyelidBoneMode>();
            _LuaScript.Globals["EyeAndHeadAnimator.HeadControl"] = UserData.CreateStatic<Il2CppRealisticEyeMovements.EyeAndHeadAnimator.HeadControl>();
            _LuaScript.Globals["EyeAndHeadAnimator.HeadTweenMethod"] = UserData.CreateStatic<Il2CppRealisticEyeMovements.EyeAndHeadAnimator.HeadTweenMethod>();
            _LuaScript.Globals["EyeAndHeadAnimator.BlinkState"] = UserData.CreateStatic<Il2CppRealisticEyeMovements.EyeAndHeadAnimator.BlinkState>();
            _LuaScript.Globals["EyeAndHeadAnimator.HeadSpeed"] = UserData.CreateStatic<Il2CppRealisticEyeMovements.EyeAndHeadAnimator.HeadSpeed>();
            _LuaScript.Globals["EyeAndHeadAnimator.EyeDelay"] = UserData.CreateStatic<Il2CppRealisticEyeMovements.EyeAndHeadAnimator.EyeDelay>();
            _LuaScript.Globals["EyeAndHeadAnimator.LookTarget"] = UserData.CreateStatic<Il2CppRealisticEyeMovements.EyeAndHeadAnimator.LookTarget>();
            _LuaScript.Globals["EyeAndHeadAnimator.FaceLookTarget"] = UserData.CreateStatic<Il2CppRealisticEyeMovements.EyeAndHeadAnimator.FaceLookTarget>();
            _LuaScript.Globals["LookTargetController.State"] = UserData.CreateStatic<Il2CppRealisticEyeMovements.LookTargetController.State>();
            _LuaScript.Globals["Effect.ShaderRenderPass"] = UserData.CreateStatic<Il2CppMK.Glow.Effect.ShaderRenderPass>();
            _LuaScript.Globals["Effect.MaterialKeywords"] = UserData.CreateStatic<Il2CppMK.Glow.Effect.MaterialKeywords>();
            _LuaScript.Globals["EasyColliderRotateDuplicate.ROTATE_AXIS"] = UserData.CreateStatic<Il2CppECE.EasyColliderRotateDuplicate.ROTATE_AXIS>();
            _LuaScript.Globals["AraTrail.TrailAlignment"] = UserData.CreateStatic<Il2CppAra.AraTrail.TrailAlignment>();
            _LuaScript.Globals["AraTrail.TrailSpace"] = UserData.CreateStatic<Il2CppAra.AraTrail.TrailSpace>();
            _LuaScript.Globals["AraTrail.TrailSorting"] = UserData.CreateStatic<Il2CppAra.AraTrail.TrailSorting>();
            _LuaScript.Globals["AraTrail.Timescale"] = UserData.CreateStatic<Il2CppAra.AraTrail.Timescale>();
            _LuaScript.Globals["AraTrail.TextureMode"] = UserData.CreateStatic<Il2CppAra.AraTrail.TextureMode>();
            _LuaScript.Globals["IKSolverLimbSlz.BendModifier"] = UserData.CreateStatic<Il2CppSLZ.VRMK.IKSolverLimbSlz.BendModifier>();
            _LuaScript.Globals["FadeMaterials.Fade"] = UserData.CreateStatic<Il2CppSLZ.VFX.FadeMaterials.Fade>();
            _LuaScript.Globals["GenericFrameTimer.FrameType"] = UserData.CreateStatic<Il2CppSLZ.VFX.GenericFrameTimer.FrameType>();
            _LuaScript.Globals["GenericTimer.TimeType"] = UserData.CreateStatic<Il2CppSLZ.VFX.GenericTimer.TimeType>();
            _LuaScript.Globals["LaserVector.Alignment"] = UserData.CreateStatic<Il2CppSLZ.VFX.LaserVector.Alignment>();
            _LuaScript.Globals["Atv_WheelColliders.WheelType"] = UserData.CreateStatic<Il2CppSLZ.Vehicle.Atv_WheelColliders.WheelType>();
            _LuaScript.Globals["Atv_WheelColliders.SpeedUnit"] = UserData.CreateStatic<Il2CppSLZ.Vehicle.Atv_WheelColliders.SpeedUnit>();
            _LuaScript.Globals["SimpleSFX.mixerGroups"] = UserData.CreateStatic<Il2CppSLZ.SFX.SimpleSFX.mixerGroups>();
            _LuaScript.Globals["BoneLeaderData.ScoreType"] = UserData.CreateStatic<Il2CppSLZ.Data.BoneLeaderData.ScoreType>();
            _LuaScript.Globals["HandPoseViewer.ViewerMode"] = UserData.CreateStatic<Il2CppSLZ.Data.HandPoseViewer.ViewerMode>();
            _LuaScript.Globals["MobileEncounter.SpawnOrder"] = UserData.CreateStatic<Il2CppSLZ.Marrow.Zones.MobileEncounter.SpawnOrder>();
            _LuaScript.Globals["Launch_Gun.LaunchMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.Launch_Gun.LaunchMode>();
            _LuaScript.Globals["NavMeshDoor.DoorType"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.NavMeshDoor.DoorType>();
            _LuaScript.Globals["NPC_Objective.TowerMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.NPC_Objective.TowerMode>();
            _LuaScript.Globals["ZipJointMover.ZipState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.ZipJointMover.ZipState>();
            _LuaScript.Globals["AgentLinkControl.LinkState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.AgentLinkControl.LinkState>();
            _LuaScript.Globals["EnemyTurret.TurretStates"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.EnemyTurret.TurretStates>();
            _LuaScript.Globals["ArenaCraneController.MoveState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.ArenaCraneController.MoveState>();
            _LuaScript.Globals["ArenaCraneController.GrabState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.ArenaCraneController.GrabState>();
            _LuaScript.Globals["Arena_BellInteractable.BellState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.Arena_BellInteractable.BellState>();
            _LuaScript.Globals["Bell_Interactable.MoveState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.Bell_Interactable.MoveState>();
            _LuaScript.Globals["GripJointMover.MoveState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.GripJointMover.MoveState>();
            _LuaScript.Globals["SimpleGripJointMover.MoveState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.SimpleGripJointMover.MoveState>();
            _LuaScript.Globals["ArmFinale.ArmStage"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.ArmFinale.ArmStage>();
            _LuaScript.Globals["BoneLeaderManager.LeaderMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.BoneLeaderManager.LeaderMode>();
            _LuaScript.Globals["Conveyor.Mode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.Conveyor.Mode>();
            _LuaScript.Globals["EnemyCollisonRelay.BodyPart"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.EnemyCollisonRelay.BodyPart>();
            _LuaScript.Globals["EnemyDamageReceiver.BodyPart"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.EnemyDamageReceiver.BodyPart>();
            _LuaScript.Globals["TurretHeadController.FireType"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.TurretHeadController.FireType>();
            _LuaScript.Globals["SpawnableSaver.SpawnerItemType"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.SpawnableSaver.SpawnerItemType>();
            _LuaScript.Globals["Arena_GameController.ArenaStartMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.Arena_GameController.ArenaStartMode>();
            _LuaScript.Globals["Arena_GameController.ArenaDifficulty"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.Arena_GameController.ArenaDifficulty>();
            _LuaScript.Globals["Arena_GameController.ArenaState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.Arena_GameController.ArenaState>();
            _LuaScript.Globals["BaseGameController.GameMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.BaseGameController.GameMode>();
            _LuaScript.Globals["BaseGameController.TimerMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.BaseGameController.TimerMode>();
            _LuaScript.Globals["BaseGameController.EndMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.BaseGameController.EndMode>();
            _LuaScript.Globals["BaseGameController.DebugMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.BaseGameController.DebugMode>();
            _LuaScript.Globals["TimeTrial_GameController.TimeTrialMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.TimeTrial_GameController.TimeTrialMode>();
            _LuaScript.Globals["TimeTrial_GameController.TimeTrialStartMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.TimeTrial_GameController.TimeTrialStartMode>();
            _LuaScript.Globals["TimeTrial_GameController.TTDifficulty"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.TimeTrial_GameController.TTDifficulty>();
            _LuaScript.Globals["GenericKeypressEvent.KeyPressType"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.GenericKeypressEvent.KeyPressType>();
            _LuaScript.Globals["GeoManager.GeoState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.GeoManager.GeoState>();
            _LuaScript.Globals["LinkData.LinkType"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.LinkData.LinkType>();
            _LuaScript.Globals["NarrativeState.HoldState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.NarrativeState.HoldState>();
            _LuaScript.Globals["MineCartControl.RideSpeed"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.MineCartControl.RideSpeed>();
            _LuaScript.Globals["NooseBonelabIntro.NooseStage"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.NooseBonelabIntro.NooseStage>();
            _LuaScript.Globals["PlatformDiscriminator.Platform"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.PlatformDiscriminator.Platform>();
            _LuaScript.Globals["PlatformEvent.Platform"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.PlatformEvent.Platform>();
            _LuaScript.Globals["BodyVitals.MeasurementState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.BodyVitals.MeasurementState>();
            _LuaScript.Globals["Balloon.BalloonColor"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.Balloon.BalloonColor>();
            _LuaScript.Globals["Dice.DieState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.Dice.DieState>();
            _LuaScript.Globals["GlassHandler.GlassType"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.GlassHandler.GlassType>();
            _LuaScript.Globals["ArenaLootItem.LootType"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.ArenaLootItem.LootType>();
            _LuaScript.Globals["SplineEntity.ContactCount"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.SplineEntity.ContactCount>();
            _LuaScript.Globals["SplineJointSpawnableEmitter.Mode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.SplineJointSpawnableEmitter.Mode>();
            _LuaScript.Globals["TextureStreamingDebugTool.Modes"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.TextureStreamingDebugTool.Modes>();
            _LuaScript.Globals["TutorialRig.InputHighlight"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.TutorialRig.InputHighlight>();
            _LuaScript.Globals["TutorialRig.SpecificHand"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.TutorialRig.SpecificHand>();
            _LuaScript.Globals["TutorialShaft.ShaftState"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.TutorialShaft.ShaftState>();
            _LuaScript.Globals["PageItemView.SegmentType"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.PageItemView.SegmentType>();
            _LuaScript.Globals["UI_ModGroup.PageType"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.UI_ModGroup.PageType>();
            _LuaScript.Globals["VRGraphicRaycaster.BlockingObjects"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.VRGraphicRaycaster.BlockingObjects>();
            _LuaScript.Globals["VRStandaloneInputModule.InputMode"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.VRStandaloneInputModule.InputMode>();
            _LuaScript.Globals["WeaponPack.WeaponType"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.WeaponPack.WeaponType>();
            _LuaScript.Globals["WeaponPack.MeleeType"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.WeaponPack.MeleeType>();
            _LuaScript.Globals["GraphicsManager.FoveatedRadii"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.SaveData.GraphicsManager.FoveatedRadii>();
            _LuaScript.Globals["GarageDoorPowerable.MOVINGSTATE"] = UserData.CreateStatic<Il2CppSLZ.Bonelab.Obsolete.GarageDoorPowerable.MOVINGSTATE>();
            _LuaScript.Globals["DebugGrassDisplacementTex.DebugSize"] = UserData.CreateStatic<Il2CppLux_SRP_GrassDisplacement.DebugGrassDisplacementTex.DebugSize>();
            _LuaScript.Globals["GrassDisplacementRenderFeature.RTDisplacementSize"] = UserData.CreateStatic<Il2CppLux_SRP_GrassDisplacement.GrassDisplacementRenderFeature.RTDisplacementSize>();
            _LuaScript.Globals["IvyController.State"] = UserData.CreateStatic<Il2CppDynamite3D.RealIvy.IvyController.State>();


        }
    }
}
