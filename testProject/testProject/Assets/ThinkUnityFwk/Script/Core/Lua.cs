using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using XLua;
using LuaAPI = XLua.LuaDLL.Lua;
namespace SYFwk.Core
{
    /**
     *  框架对Lua脚本的导出
     * 
     **/
    [XLua.LuaCallCSharp]
    class Lua
    {
        // 添加组件
        static public Component AddComponent(GameObject gameobject, string name)
        {
            // TODO 是否有方法通过名称获取Type？？需要考虑跨平台以及裁剪问题
            Type type = null; // Type.GetType(name);
            switch (name)
            {
                case "SYFwk.Core.LuaUIBehaveour":
                    type = typeof(LuaUIBehaveour);
                    break;
                case "SYFwk.Core.DestroyEvent":
                    type = typeof(DestroyEvent);
                    break;
                default:
                    break;
            }
            
            if (type != null)
            {
                Component comp = gameobject.GetComponent(type);
                if (comp == null)
                {
                    comp = gameobject.AddComponent(type);
                }
                return comp;
            }
            return null;
        }
    }
}
