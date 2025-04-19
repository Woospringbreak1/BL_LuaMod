using Il2CppCysharp.Threading.Tasks;
using Il2CppSLZ.Marrow.Circuits;
using Il2CppSLZ.Marrow.Data;
using Il2CppSLZ.Marrow.Pool;
using Il2CppSLZ.Marrow.Warehouse;
using MelonLoader;
using MoonSharp.Interpreter;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.SceneManagement;

namespace LuaMod.LuaAPI
{
    public class API_Utils
    {
        public static readonly API_Utils Instance = new API_Utils();


        public static int BL_CollectionLength(ICollection collection)
        {
            if (collection == null)
            {
                return 0;
            }
            else
            {
                return collection.Count;
            }
        }

        public static string BL_GetSceneName()
        {
            return SceneManager.GetAllScenes()[0].name;
        }
        public static string BL_GetBarcode(GameObject gameObject)
        {
            return LuaSafeCall.Run(() =>
            {
                if(gameObject == null)
                {
                    throw new ScriptRuntimeException("GameObject is null");
                }

                Poolee poolee = gameObject.GetComponent<Poolee>();
                if (poolee != null)
                {
                    return (poolee.SpawnableCrate.Barcode.ID);
                }
                return null;
            }, $"BL_GetBarcode(index: {gameObject})");

        }


        public static DynValue BL_ConvertObjectToType(UnityEngine.Object obj, string CompType)
        {

            ///casts the stored UnityEngine.Object to CompType, and may god have mercy on my soul
#if !(UNITY_EDITOR || UNITY_STANDALONE)
            return LuaSafeCall.Run(() =>
            {

                if (obj == null)
                {
                    throw new ScriptRuntimeException("Object for conversion is null");
                }

                Type targetType = LuaMod.LoadedTypes.Find(t => t.Name == CompType);
                if (targetType == null)
                {
                    throw new ScriptRuntimeException($"Component type '{CompType}' not found");
                }


                // Find Resources.ConvertObjects<T>(UnityEngine.Object[])
                MethodInfo convertMethod = typeof(Resources)
                    .GetMethods(BindingFlags.Public | BindingFlags.Static)
                    .First(m => m.Name == "ConvertObjects" && m.IsGenericMethod && m.GetParameters().Length == 1);

                MethodInfo genericConvert = convertMethod.MakeGenericMethod(targetType);

                // Create Il2CppReferenceArray<UnityEngine.Object> with one element
                Type il2cppArrayType = typeof(Il2CppInterop.Runtime.InteropTypes.Arrays.Il2CppReferenceArray<>)
                    .MakeGenericType(typeof(UnityEngine.Object));
                dynamic il2cppArray = Activator.CreateInstance(il2cppArrayType, 1);
                il2cppArray[0] = obj;

                // Invoke ConvertObjects<T>
                dynamic resultArray = genericConvert.Invoke(null, new object[] { il2cppArray });

                if (resultArray == null || resultArray.Length == 0 || resultArray[0] == null)
                {
                    MelonLogger.Warning($"Failed to cast object '{obj.name}' to '{CompType}'");
                    return null;
                }


                object casted = resultArray[0];
                return UserData.Create(casted);
            }, $"BL_ConvertObjectToType('{obj.name}', '{CompType}')");
#endif
            return null;
        }

        public static string RemoveDoubleSlashes(string input)
        {
            while (input.Contains("//"))
            {
                input = input.Replace("//", "/");
            }
            return input;
        }

        public static DynValue BL_GetArrayElement(object target, string fieldName, int index)
        {
            /// Bypasses issues related to getting values of c# arrays from lua
            /// And may god have mercy on my soul
            return LuaSafeCall.Run(() =>
            {



                if (target == null)
                {
                    throw new ScriptRuntimeException("collection object is null");
                }

                if (!LuaMod.RegisteredTypes.Contains(target.GetType()))
                {
                    throw new ScriptRuntimeException("Attempt to manipulate array with unregistered type " + target.GetType().FullName);
                }

                if (target is UserData tUdata)
                    target = tUdata.Object;

                var type = target?.GetType();
                var field = type?.GetField(fieldName, BindingFlags.Public | BindingFlags.Instance);
                var prop = type?.GetProperty(fieldName, BindingFlags.Public | BindingFlags.Instance);

                object collection = field != null
                    ? field.GetValue(target)
                    : prop?.GetValue(target);

                if (collection == null)
                    throw new ScriptRuntimeException($"Field '{fieldName}' not found or is null");

                if (collection is Array array)
                {
                    if (index >= 0 && index < array.Length)
                        return UserData.Create(array.GetValue(index));
                    return DynValue.Nil;
                }

                if (collection is IList list)
                {
                    if (index >= 0 && index < list.Count)
                        return UserData.Create(list[index]);
                    return DynValue.Nil;
                }

                if (collection is IEnumerable enumerable &&
                    collection.GetType().IsGenericType &&
                    collection.GetType().GetGenericTypeDefinition().Name.StartsWith("Il2CppReferenceArray"))
                {
                    var listEnu = enumerable.Cast<object>().ToList();
                    if (index >= 0 && index < listEnu.Count)
                        return UserData.Create(listEnu[index]);
                    return DynValue.Nil;
                }

                throw new ScriptRuntimeException($"Unsupported collection type: {collection.GetType().Name}");
            }, $"BL_GetArrayElement({fieldName}[{index}])");
        }


        public static void BL_AppendToArray(object target, string fieldName, object value)
        {
            /// Bypasses issues related to appending values to c# arrays from lua
            /// And may god have mercy on my soul
            LuaSafeCall.Run(() =>
            {


                if (target == null)
                {
                    throw new ScriptRuntimeException("Collection object is null");
                }

                if (value != null && !LuaMod.RegisteredTypes.Contains(value.GetType()))
                {
                    throw new ScriptRuntimeException("Attempt to manipulate array with unregistered type " + value.GetType().FullName);
                }

                if (!LuaMod.RegisteredTypes.Contains(target.GetType()))
                {
                    throw new ScriptRuntimeException("Attempt to manipulate array with unregistered type " + target.GetType().FullName);
                }

                if (target is UserData tUdata)
                    target = tUdata.Object;

                var type = target?.GetType();
                var field = type?.GetField(fieldName, BindingFlags.Public | BindingFlags.Instance);
                var prop = type?.GetProperty(fieldName, BindingFlags.Public | BindingFlags.Instance);

                object collection = field != null
                    ? field.GetValue(target)
                    : prop?.GetValue(target);

                if (collection == null)
                    throw new ScriptRuntimeException($"Field '{fieldName}' not found or is null");

                if (collection is Array array)
                {
                    var elementType = array.GetType().GetElementType();
                    int slot = Array.FindIndex(array.Cast<object>().ToArray(), item => item == null);

                    if (slot == -1)
                    {
                        var resized = Array.CreateInstance(elementType, array.Length + 1);
                        Array.Copy(array, resized, array.Length);
                        slot = array.Length;
                        resized.SetValue(value, slot);
                        array = resized;
                    }
                    else
                    {
                        array.SetValue(value, slot);
                    }

                    if (field != null)
                        field.SetValue(target, array);
                    else if (prop?.CanWrite == true)
                        prop.SetValue(target, array);
                    return;
                }

                if (collection is IList list)
                {
                    int slot = list.IndexOf(null);
                    if (slot == -1)
                        list.Add(value);
                    else
                        list[slot] = value;
                    return;
                }

                if (collection is IEnumerable enumerable &&
                    collection.GetType().IsGenericType &&
                    collection.GetType().GetGenericTypeDefinition().Name.StartsWith("Il2CppReferenceArray"))
                {
                    var elementType = collection.GetType().GetGenericArguments()[0];
                    var listEnu = enumerable.Cast<object>().ToList();

                    int slot = listEnu.FindIndex(item => item == null);
                    if (slot == -1)
                    {
                        slot = listEnu.Count;
                        listEnu.Add(value);
                    }
                    else
                    {
                        listEnu[slot] = value;
                    }

                    var newArray = Array.CreateInstance(elementType, listEnu.Count);
                    for (int i = 0; i < listEnu.Count; i++)
                        newArray.SetValue(listEnu[i], i);

                    var opImplicit = collection.GetType().GetMethod("op_Implicit", BindingFlags.Public | BindingFlags.Static);
                    if (opImplicit == null)
                        throw new ScriptRuntimeException("Cannot convert array to Il2CppReferenceArray — missing op_Implicit");

                    var converted = opImplicit.Invoke(null, new object[] { newArray });

                    if (field != null)
                        field.SetValue(target, converted);
                    else if (prop?.CanWrite == true)
                        prop.SetValue(target, converted);

                    return;
                }

                throw new ScriptRuntimeException($"Unsupported collection type: {collection.GetType().Name}");
            }, $"BL_AppendToArray({fieldName})");
        }


        public static void BL_SetArrayElement(object target, string fieldName, int index, object value)
        {
            /// Bypasses issues related to setting values of c# arrays from lua
            /// And may god have mercy on my soul
            LuaSafeCall.Run(() =>
            {

                if(target == null)
                {
                    throw new ScriptRuntimeException("Collection object is null");
                }

                if (value != null && !LuaMod.RegisteredTypes.Contains(value.GetType()))
                {
                    throw new ScriptRuntimeException("Attempt to manipulate array with unregistered type " + value.GetType().FullName);
                }

                if (!LuaMod.RegisteredTypes.Contains( target.GetType()) )
                {
                    throw new ScriptRuntimeException("Attempt to manipulate array with unregistered type " + target.GetType().FullName);
                }

                if (target is UserData tUdata)
                    target = tUdata.Object;

                if (string.IsNullOrEmpty(fieldName))
                    throw new ScriptRuntimeException("Field name cannot be null or empty");

                var type = target.GetType();
                var field = type.GetField(fieldName, BindingFlags.Public | BindingFlags.Instance);
                var prop = type.GetProperty(fieldName, BindingFlags.Public | BindingFlags.Instance);

                object collection = field != null
                    ? field.GetValue(target)
                    : prop?.GetValue(target);

                if (collection == null)
                    throw new ScriptRuntimeException($"Field or property '{fieldName}' not found or is null on {type.Name}");

                // Collection is array
                if (collection is Array array)
                {
                    var elementType = array.GetType().GetElementType();
                    if (value != null && !elementType.IsInstanceOfType(value))
                        throw new ScriptRuntimeException($"Value of type {value.GetType().Name} is not assignable to array element type {elementType.Name}");

                    if (index >= array.Length)
                    {
                        var resized = Array.CreateInstance(elementType, index + 1);
                        Array.Copy(array, resized, array.Length);
                        array = resized;
                    }

                    array.SetValue(value, index);

                    if (field != null)
                        field.SetValue(target, array);
                    else if (prop?.CanWrite == true)
                        prop.SetValue(target, array);

                    return;
                }

                // Collection is list
                if (collection is IList list)
                {
                    var listType = collection.GetType();
                    var elementType = listType.IsGenericType ? listType.GetGenericArguments()[0] : typeof(object);

                    if (value != null && !elementType.IsInstanceOfType(value))
                        throw new ScriptRuntimeException($"Value type {value.GetType().Name} is not assignable to list element type {elementType.Name}");

                    while (list.Count <= index)
                        list.Add(null);

                    list[index] = value;
                    return;
                }

                // collection is Il2CppReferenceArray
                var colType = collection.GetType();
                if (collection is IEnumerable && colType.IsGenericType && colType.GetGenericTypeDefinition().Name.StartsWith("Il2CppReferenceArray"))
                {
                    var elementType = colType.GetGenericArguments()[0];

                    var asList = ((IEnumerable)collection).Cast<object>().ToList();
                    var desiredLength = Math.Max(index + 1, asList.Count);
                    var newArray = Array.CreateInstance(elementType, desiredLength);

                    for (int i = 0; i < asList.Count; i++)
                        newArray.SetValue(asList[i], i);

                    newArray.SetValue(value, index);

                    // Convert to Il2CppReferenceArray<T> using implicit operator
                    var il2cppArrayType = colType; // Il2CppReferenceArray<T>
                    var implicitOp = il2cppArrayType.GetMethod("op_Implicit", BindingFlags.Public | BindingFlags.Static);

                    if (implicitOp == null)
                        throw new ScriptRuntimeException($"Could not find implicit op_Implicit method for {il2cppArrayType.Name}");

                    var converted = implicitOp.Invoke(null, new object[] { newArray });

                    if (field != null) field.SetValue(target, converted);
                    else if (prop?.CanWrite == true) prop.SetValue(target, converted);
                    return;
                }

                throw new ScriptRuntimeException($"Field '{fieldName}' is not assignable (type: {collection.GetType().Name})");
            }, $"BL_SetArrayElement({fieldName}[{index}])");
        }



    }
}


