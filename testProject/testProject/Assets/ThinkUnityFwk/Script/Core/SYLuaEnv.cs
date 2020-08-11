using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using XLua;

namespace SYFwk.Core
{
    public class SYLuaEnv
    {
        internal static LuaEnv sEnv { get; private set; }
        public static string DEV_LUA_PATH = Path.GetFullPath(UnityEngine.Application.dataPath + "/../../src/client/");
        public static string RUN_LUA_PATH = Path.GetFullPath(UnityEngine.Application.persistentDataPath + "/lua/");
        [CSharpCallLua]
        public interface IFwk
        {
            LuaTable _z__env(string name);
            void _z__init(string name, LuaTable cfg);
            void _z__event(string mod, string en, LuaTable param);
            void _z__res_event(string mod, string en, string id);
            void _z__late_update(float dt);
            void _z__start();
        }
        static private IFwk sFwk = null;
        static internal LuaLoader.LoadMode sMode = LuaLoader.LoadMode.LM_RUN;

        // 初始化内部数据
        static public void Init()
        {
            if (sEnv == null)
            {
                sEnv = new LuaEnv();
                LuaLoader.Init(sMode);
            }
        }

        static public void Start()
        {
            sEnv.DoString(@"require 'fwk.syfwk'");
            sFwk = sEnv.Global.Get<IFwk>("_z__fwk");

            Debug.Log(RUN_LUA_PATH);

            LuaTable tab = sEnv.NewTable();

            if (sMode == LuaLoader.LoadMode.LM_RUN)
            {
                tab.Set("root", RUN_LUA_PATH);
            }
            else
            {
                tab.Set("root", DEV_LUA_PATH);
            }

            tab.Set("mode", (int)sMode);
#if UNITY_EDITOR
            tab.Set("editor", true);
#endif
            sFwk._z__init("unity", tab);

            sFwk._z__start();
        }

        // 调用flz Event函数
        static public void FlzEvent(string mod, string en, LuaTable param)
        {
            sFwk._z__event(mod, en, param);
        }

        // 调用flz Event函数
        static public void ResEvent(string mod, string en, string id)
        {
            sFwk._z__res_event(mod, en, id);

        }

        static public void LateUpdate(float dt)
        {
            if (sFwk != null)
            {
                sFwk._z__late_update(dt);
            }
        }
    }
}
