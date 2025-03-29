using System.Collections.Generic;
using UnityEngine;

public class LuaResources : MonoBehaviour
{
    public List<string> stringKeys = new List<string>();
    public List<string> stringValues = new List<string>();

    public List<string> floatKeys = new List<string>();
    public List<float> floatValues = new List<float>();

    public List<string> boolKeys = new List<string>();
    public List<bool> boolValues = new List<bool>();

    public List<string> objectKeys = new List<string>();
    public List<UnityEngine.Object> objectValues = new List<UnityEngine.Object>();

    private Dictionary<string, string> _strings;
    private Dictionary<string, float> _floats;
    private Dictionary<string, bool> _bools;
    private Dictionary<string, UnityEngine.Object> _objects;

    public Dictionary<string, string> Strings => _strings ??= Build(stringKeys, stringValues);
    public Dictionary<string, float> Floats => _floats ??= Build(floatKeys, floatValues);
    public Dictionary<string, bool> Bools => _bools ??= Build(boolKeys, boolValues);
    public Dictionary<string, UnityEngine.Object> Objects => _objects ??= Build(objectKeys, objectValues);

    private Dictionary<string, T> Build<T>(List<string> keys, List<T> values)
    {
        var dict = new Dictionary<string, T>();
        for (int i = 0; i < keys.Count && i < values.Count; i++)
        {
            if (!dict.ContainsKey(keys[i]))
                dict[keys[i]] = values[i];
        }
        return dict;
    }

    public string GetString(string key) => Strings.TryGetValue(key, out var val) ? val : null;
    public float GetFloat(string key) => Floats.TryGetValue(key, out var val) ? val : 0f;
    public bool GetBool(string key) => Bools.TryGetValue(key, out var val) && val;
    public UnityEngine.Object GetObject(string key) => Objects.TryGetValue(key, out var val) ? val : null;

    public void SetString(string key, string value) => SetValue(stringKeys, stringValues, ref _strings, key, value);
    public void SetFloat(string key, float value) => SetValue(floatKeys, floatValues, ref _floats, key, value);
    public void SetBool(string key, bool value) => SetValue(boolKeys, boolValues, ref _bools, key, value);
    public void SetObject(string key, UnityEngine.Object value) => SetValue(objectKeys, objectValues, ref _objects, key, value);

    private void SetValue<T>(List<string> keys, List<T> values, ref Dictionary<string, T> dict, string key, T value)
    {
        int index = keys.IndexOf(key);
        if (index >= 0)
        {
            values[index] = value;
        }
        else
        {
            keys.Add(key);
            values.Add(value);
        }

        dict ??= new Dictionary<string, T>();
        dict[key] = value;
    }

    public void RebuildAll()
    {
        _strings = Build(stringKeys, stringValues);
        _floats = Build(floatKeys, floatValues);
        _bools = Build(boolKeys, boolValues);
        _objects = Build(objectKeys, objectValues);
    }

    public HashSet<string> GetAllKeys()
    {
        HashSet<string> all = new HashSet<string>();
        all.UnionWith(stringKeys);
        all.UnionWith(floatKeys);
        all.UnionWith(boolKeys);
        all.UnionWith(objectKeys);
        return all;
    }

    public List<string> GetDuplicateKeys()
    {
        Dictionary<string, int> count = new Dictionary<string, int>();

        void AddKeys(List<string> list)
        {
            foreach (var key in list)
            {
                if (string.IsNullOrEmpty(key)) continue;
                if (!count.ContainsKey(key)) count[key] = 0;
                count[key]++;
            }
        }

        AddKeys(stringKeys);
        AddKeys(floatKeys);
        AddKeys(boolKeys);
        AddKeys(objectKeys);

        List<string> dupes = new List<string>();
        foreach (var kvp in count)
        {
            if (kvp.Value > 1)
                dupes.Add(kvp.Key);
        }

        return dupes;
    }
}
