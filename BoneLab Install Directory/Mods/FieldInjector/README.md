This mod is a utility for other mods to utilise MonoBehaviour field serialisation injection. Original mod for Boneworks now ported to Bonelab.

## Instructions for players

 - To install the mod, just extract `FieldInjector.dll` into your `Mods` folder in the game install location.

## Instructions for programmers

If you want to utilise custom MonoBehaviours with properly serialised fields from asset bundles, reference this mod as a dependency.
**Note**: instead of using this mod directly, I might recommend using [Maranara's "Cauldron"](/package/Maranara/Marrow_Cauldron/) system for a more unified end-to-end experience and integration with the Unity editor, that uses this mod under the hood. The instructions below apply only if you want to roll your own systems and just use this to apply serialisation.

### Writing a custom MonoBehaviour

This is fairly simple, and there is very little difference between a normal unity MonoBehaviour and this. There is only a small amount of boilerplate code to add:
```cs
using UnityEngine;

class MyScript : MonoBehaviour
{
    // all of your normal MonoBehaviour code can go here

#if !UNITY_EDITOR
    public TestMB(IntPtr ptr) : base(ptr) { }
#endif
}
```
the `#if` instruction means that this code should compile in both the Unity Editor and in a MelonLoader mod, so that you can keep your code unified and test in the editor with ease.

This tech is still not totally mature, so I recommend testing out whatever you're doing first before relying on it working. Here's what the mod should support.
 
 - primitive types like float, int, string, bool
 - structs that are defined by Unity or the game (ie, Vector3, Quaternion)
 - references to objects defined by the game or unity, e.g. GameObject or Transform
 - you might have success with references to mod classes, *as long as those classes are injected before the class with the reference to them is injected*. If this throws up issues remember you can always just have a serialised reference to the GameObject and then use GetComponent in Start.

Also supported as of 2.0 (*should work*):

 - custom structs (structs defined in mods)
 - classes with cyclic field references
 - injected enums

### Injecting a custom MonoBehaviour
This is what this mod is used for, and it is very simple:
```cs
FieldInjector.SerialisationHandler.Inject<MyScript>();
```
in the `OnApplicationStart` method is all that is needed. Do not register the class in Il2Cpp with MelonLoader or UnhollowerBaseLib - this mod does that itself and it won't be able to inject the class with fields if it's already injected without fields. Makers of frameworks that load code should consider registering fields for loaded behaviours automatically.

### Changelog

- **v1.0**: Release
- **v1.1**: Added support for enum fields, cleaned code/memory allocation and added `FieldInjector.SerializeField` attribute to force serialisation of a non-public field.
- **v2.0**: Rewrite of serialisation handling to allow struct/enum injection.
- **v2.0.2**: Fix bugs with injected enums as fields and arrays of non-blittable structs.
- **v2.0.3**: Prevented non-serialized fields from being considered when mapping injection dependencies.
- **v2.0.301**: Update thunderstore readme, no code change
- **v2.0.400** (aka 2.1.0 (?)): Update for Unity 2021.3.16 (Bonelab Patch 4/5)
- **v2.1.1**: Fix bug causing crashes when certain injected classes were referenced in fields and no structs were injected.
