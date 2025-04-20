using BoneLib.BoneMenu;
using LuaMod.BoneMenu;
using MelonLoader;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;


namespace LuaMod.LuaAPI
{
    /// <summary>
    /// Lua-exposed API for creating and binding BoneMenu menus
    /// </summary>
    public class API_BoneMenu
    {
        
        public static readonly API_BoneMenu Instance = new API_BoneMenu();

 
        public static Page BL_Page = Page.Root;

        public static LuaFunctionElement BL_CreateFunction(Page page,string name,UnityEngine.Color color,LuaBehaviour owner,string function)
        {
            LuaFunctionElement newElement = new LuaFunctionElement(name, color, owner, function);
            page.Add(newElement);
            return newElement;
        }

        public static bool BL_DeletePage(Page page)
        {
            Menu.DestroyPage(page);
            return true;
        }

        /*
        public static FloatElement BL_CreateFloatElement(Page page, string name, UnityEngine.Color color, float start, float increment, float min, float max, LuaBehaviour owner, string function)
        {

            FloatElement newElement = new FloatElement(name, color, start, increment, min, max);
       
            page.Add(newElement);
            return newElement;
        }
        */
        public static void InvokeFloatAction()
        {

        }
    }
}
