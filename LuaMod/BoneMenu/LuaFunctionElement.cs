using BoneLib;
using BoneLib.BoneMenu;
using MoonSharp.Interpreter;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace LuaMod.BoneMenu
{
    public class LuaFunctionElement : FunctionElement
    {

        private Texture2D _logo;
        private string _Luacallback;
        private LuaBehaviour _owner;
        private Action<LuaFunctionElement> _callback;

        public LuaFunctionElement(string name, Color color, LuaBehaviour own,string luafunc) : base(name, color,null)
        {
            _elementName = name;
            _elementColor = color;
            _Luacallback = luafunc;
            _owner = own;
            _callback = null;
        }

        public Texture2D Logo
        {
            get
            {
                return _logo;
            }
            set
            {
                _logo = value;
                OnElementChanged.InvokeActionSafe();
            }
        }
        public override void OnElementSelected()
        {
            _owner.CallFunction(_Luacallback);
        }
    }
}
