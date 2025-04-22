using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using LuaMod;

[CustomEditor(typeof(LuaResources))]
public class LuaResourcesEditor : Editor
{
    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        LuaResources lua = (LuaResources)target;

        // Show warning if any duplicate keys exist across types
        List<string> dupes = lua.GetDuplicateKeys();
        if (dupes.Count > 0)
        {
            EditorGUILayout.HelpBox(
                "Duplicate keys detected across types:\n" + string.Join(", ", dupes),
                MessageType.Error
            );
        }

        // Draw each typed dictionary UI
        DrawKeyValueList("stringKeys", "stringValues", "String");
        DrawKeyValueList("floatKeys", "floatValues", "Float");
        DrawKeyValueList("boolKeys", "boolValues", "Bool");
        DrawKeyValueList("objectKeys", "objectValues", "Object");

        serializedObject.ApplyModifiedProperties();
    }

    void DrawKeyValueList(string keyPropName, string valuePropName, string label)
    {
        SerializedProperty keys = serializedObject.FindProperty(keyPropName);
        SerializedProperty values = serializedObject.FindProperty(valuePropName);

        EditorGUILayout.LabelField(label + "s", EditorStyles.boldLabel);
        int count = Mathf.Min(keys.arraySize, values.arraySize);

        for (int i = 0; i < count; i++)
        {
            SerializedProperty keyProp = keys.GetArrayElementAtIndex(i);
            SerializedProperty valueProp = values.GetArrayElementAtIndex(i);

            EditorGUILayout.BeginHorizontal();

            // Key field
            EditorGUILayout.PropertyField(keyProp, GUIContent.none, GUILayout.MinWidth(100));

            // Value field
            EditorGUILayout.PropertyField(valueProp, GUIContent.none);

            EditorGUILayout.EndHorizontal();
        }

        // Add / Remove buttons
        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("+"))
        {
            keys.arraySize++;
            values.arraySize++;
            serializedObject.ApplyModifiedProperties();
        }

        if (GUILayout.Button("-") && keys.arraySize > 0)
        {
            keys.arraySize--;
            values.arraySize--;
            serializedObject.ApplyModifiedProperties();
        }
        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space(10);
    }
}
