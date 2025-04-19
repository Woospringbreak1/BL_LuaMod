using UnityEngine;

namespace LuaMod.LuaAPI
{
    public class API_Random
    {
        public static readonly API_Random Instance = new API_Random();

        public float RangeFloat(float min, float max)
        {
            return UnityEngine.Random.Range(min, max);
        }

        public int RangeInt(int min, int max)
        {
            return UnityEngine.Random.Range(min, max);
        }

        public float Value()
        {
            return UnityEngine.Random.value;
        }

        public bool Bool()
        {
            return UnityEngine.Random.value > 0.5f;
        }

        public Quaternion Rotation()
        {
            return UnityEngine.Random.rotation;
        }

        public Quaternion RotationUniform()
        {
            return UnityEngine.Random.rotationUniform;
        }

        public Vector3 InsideUnitSphere()
        {
            return UnityEngine.Random.insideUnitSphere;
        }

        public Vector2 InsideUnitCircle()
        {
            return UnityEngine.Random.insideUnitCircle;
        }

        public Vector3 OnUnitSphere()
        {
            return UnityEngine.Random.onUnitSphere;
        }

        public void InitState(int seed)
        {
            UnityEngine.Random.InitState(seed);
        }

        public int Seed
        {
            get => UnityEngine.Random.seed;
            set => UnityEngine.Random.seed = value;
        }
        

        public UnityEngine.Random.State GetState()
        {
            return UnityEngine.Random.state;
        }

        public void SetState(UnityEngine.Random.State state)
        {
            UnityEngine.Random.state = state;
        }
    }

}
