using Il2CppCysharp.Threading.Tasks;
using Il2CppSLZ.Marrow.Data;
using Il2CppSLZ.Marrow.Pool;
using Il2CppSLZ.Marrow.Warehouse;
using MelonLoader;
using MoonSharp.Interpreter;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

namespace LuaMod.LuaAPI
{
    internal class API_Utils
    {
        public static readonly API_Utils Instance = new API_Utils();



        public static bool BL_LoadAddressableResource(LuaBehaviour LB, string VariableName, string address)
        {
            // Load the addressable asset asynchronously
            AsyncOperationHandle<UnityEngine.Object> handle = Addressables.LoadAssetAsync<UnityEngine.Object>(address);

            // Use Il2Cpp-style event assignment
            handle.add_Completed(new Action<AsyncOperationHandle<UnityEngine.Object>>((completedHandle) =>
            {
                if (completedHandle.Status == AsyncOperationStatus.Succeeded)
                {
                  
                    // Bind to Lua
                    LB.SetScriptVariable(VariableName, UserData.Create(completedHandle.Result));
                }
                else
                {
                    MelonLogger.Error($"Failed to load addressable with key: {address}");
                }
            }));

            // Always returns false here, since it’s async
            return false;
        }

       
        public static Table BL_ToLuaTable(IEnumerable collection, Script script)
        {

            if (collection == null || script == null)
                throw new ArgumentNullException("Collection and Script cannot be null.");

            var luaTable = new Table(script);

            // Check if collection is a dictionary
            var type = collection.GetType();
            if (type.IsGenericType &&
                type.GetGenericTypeDefinition().IsAssignableFrom(typeof(Dictionary<,>)))
            {
                foreach (var item in collection)
                {
                    var keyProp = item.GetType().GetProperty("Key");
                    var valueProp = item.GetType().GetProperty("Value");

                    if (keyProp != null && valueProp != null)
                    {
                        var key = keyProp.GetValue(item, null);
                        var value = valueProp.GetValue(item, null);

                        luaTable[DynValue.FromObject(script, key)] = DynValue.FromObject(script, value);
                    }
                }
            }
            else
            {
                int index = 1; // Lua is 1-indexed
                foreach (var item in collection)
                {
                    luaTable[index] = DynValue.FromObject(script, item);
                    index++;
                }
            }

            return luaTable;
        }
    }

}

