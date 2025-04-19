using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using UnityEngine;

namespace LuaMod.LuaAPI
{

    public class API_Physics
    {

        public static readonly API_Physics Instance = new API_Physics();

        public static DynValue BL_SphereCast(Vector3 origin, Vector3 direction, float radius, float maxdistance)
        {
            return LuaSafeCall.Run(() =>
            {
                if (Physics.SphereCast(origin, radius, direction, out RaycastHit hit, maxdistance))
                {
                    return UserData.Create(hit);
                }

                return DynValue.Nil;
            }, $"BL_SphereCast(origin: {origin}, direction: {direction}, radius: {radius}, maxdistance: {maxdistance})");
        }

        public static DynValue BL_SphereCast(Vector3 start_pos, Vector3 end_pos, float radius)
        {
            return LuaSafeCall.Run(() =>
            {
                Vector3 direction = (end_pos - start_pos).normalized;
                float length = (end_pos - start_pos).magnitude;

                if (Physics.SphereCast(start_pos, radius, direction, out RaycastHit hit, length))
                {
                    return UserData.Create(hit);
                }

                return DynValue.Nil;
            }, $"BL_SphereCast(start: {start_pos}, end: {end_pos}, radius: {radius})");
        }

        public static DynValue BL_SphereCastAll(Vector3 origin, float radius, Vector3 direction, float maxDistance, int layerMask = Physics.DefaultRaycastLayers)
        {
            return LuaSafeCall.Run(() =>
            {
                RaycastHit[] hits = Physics.SphereCastAll(origin, radius, direction, maxDistance, layerMask);
                if (hits == null || hits.Length == 0)
                    return DynValue.Nil;

                List<DynValue> results = new List<DynValue>();
                foreach (var hit in hits)
                    results.Add(UserData.Create(hit));

                return UserData.Create(results);
            }, $"BL_SphereCastAll(origin: {origin}, dir: {direction}, radius: {radius}, dist: {maxDistance}, mask: {layerMask})");
        }

        public static DynValue BL_SphereCastAll(Vector3 start_pos, Vector3 end_pos, float radius, int layerMask = Physics.DefaultRaycastLayers)
        {
            return LuaSafeCall.Run(() =>
            {
                Vector3 direction = (end_pos - start_pos).normalized;
                float length = (end_pos - start_pos).magnitude;

                RaycastHit[] hits = Physics.SphereCastAll(start_pos, radius, direction, length, layerMask);
                if (hits == null || hits.Length == 0)
                    return DynValue.Nil;

                List<DynValue> results = new List<DynValue>();
                foreach (var hit in hits)
                    results.Add(UserData.Create(hit));

                return UserData.Create(results);
            }, $"BL_SphereCastAll(start: {start_pos}, end: {end_pos}, radius: {radius}, mask: {layerMask})");
        }


        public static DynValue BL_RayCast(Vector3 start_pos, Vector3 end_pos)   
        {
            return LuaSafeCall.Run(() =>
            {
                Vector3 direction = (end_pos - start_pos).normalized;
                float length = (end_pos - start_pos).magnitude;

                if (Physics.Raycast(start_pos, direction, out RaycastHit hit, length))
                {
                    return UserData.Create(hit);
                }

                return DynValue.Nil;
            }, $"BL_RayCast(start: {start_pos}, end: {end_pos})");
        }

        public static DynValue BL_RayCast(Vector3 origin, Vector3 direction, float maxdistance = Mathf.Infinity)
        {
            return LuaSafeCall.Run(() =>
            {
                if (Physics.Raycast(origin, direction, out RaycastHit hit, maxdistance))
                {
                    return UserData.Create(hit);
                }

                return DynValue.Nil;
            }, $"BL_RayCast(origin: {origin}, direction: {direction}, maxdistance: {maxdistance})");
        }

        public static DynValue BL_BoxCast(Vector3 center, Vector3 halfExtents, Vector3 direction, Quaternion orientation, float maxDistance, int layerMask = Physics.DefaultRaycastLayers)
        {
            return LuaSafeCall.Run(() =>
            {
                if (Physics.BoxCast(center, halfExtents, direction, out RaycastHit hit, orientation, maxDistance, layerMask))
                    return UserData.Create(hit);

                return DynValue.Nil;
            }, $"BL_BoxCast(center: {center}, halfExtents: {halfExtents}, dir: {direction}, dist: {maxDistance}, mask: {layerMask})");
        }

        public static DynValue BL_BoxCastAll(Vector3 center, Vector3 halfExtents, Vector3 direction, Quaternion orientation, float maxDistance, int layerMask = Physics.DefaultRaycastLayers)
        {
            return LuaSafeCall.Run(() =>
            {
                RaycastHit[] hits = Physics.BoxCastAll(center, halfExtents, direction, orientation, maxDistance, layerMask);
                if (hits == null || hits.Length == 0)
                    return DynValue.Nil;

                List<DynValue> results = new List<DynValue>();
                foreach (var hit in hits)
                    results.Add(UserData.Create(hit));

                return UserData.Create(results);
            }, $"BL_BoxCastAll(center: {center}, halfExtents: {halfExtents}, dir: {direction}, dist: {maxDistance}, mask: {layerMask})");
        }

        public static DynValue BL_CapsuleCast(Vector3 point1, Vector3 point2, float radius, Vector3 direction, float maxDistance, int layerMask = Physics.DefaultRaycastLayers)
        {
            return LuaSafeCall.Run(() =>
            {
                if (Physics.CapsuleCast(point1, point2, radius, direction, out RaycastHit hit, maxDistance, layerMask))
                    return UserData.Create(hit);

                return DynValue.Nil;
            }, $"BL_CapsuleCast(p1: {point1}, p2: {point2}, radius: {radius}, dir: {direction}, dist: {maxDistance}, mask: {layerMask})");
        }

        public static DynValue BL_CapsuleCastAll(Vector3 point1, Vector3 point2, float radius, Vector3 direction, float maxDistance, int layerMask = Physics.DefaultRaycastLayers)
        {
            return LuaSafeCall.Run(() =>
            {
                RaycastHit[] hits = Physics.CapsuleCastAll(point1, point2, radius, direction, maxDistance, layerMask);
                if (hits == null || hits.Length == 0)
                    return DynValue.Nil;

                List<DynValue> results = new List<DynValue>();
                foreach (var hit in hits)
                    results.Add(UserData.Create(hit));

                return UserData.Create(results);
            }, $"BL_CapsuleCastAll(p1: {point1}, p2: {point2}, radius: {radius}, dir: {direction}, dist: {maxDistance}, mask: {layerMask})");
        }
    }
}
