using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using UnityEngine;
using XLua;

namespace SYFwk.Core
{
    public class LuaLoader : MonoBehaviour
    {

        private static LoadMode sLoadMode;

#if UNITY_IOS && !UNITY_EDITOR
        const string LUADLL = "__Internal";
#else
        internal const string LUADLL = "xlua";
#endif

        // must match whit lua
        public enum LoadMode
        {
            LM_FWK = 1,         // 框架开发模式，该模式下，所有代码从lua文件中加载
            LM_DEV = 2,         // 用户开发模式，该模式下，fwk加密，其他从文件加载
            LM_EDIT = 3,        // 编辑器开发模式，该模式下，fwk, game加密，其他从文件加载
            LM_RUN = 4,         // 运行模式，该模式下，所有代码从pkg中加载
        }

        static private ArrayList sLuaSearchList = null;
        static public void Init(LoadMode mode = LoadMode.LM_RUN)
        {
            sLoadMode = mode;
            SYLuaEnv.sEnv.AddBuildin("json", LoadRapidJson);
            SYLuaEnv.sEnv.AddBuildin("pb", LoadPb);
            
            sLuaSearchList = new ArrayList();
            //string[] fwk = { "fwk", Path.Combine(UnityEngine.Application.dataPath, "../../src_encrypt/"), "1" };
            //string[] game = { "game", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/"), "0" };
            //string[] config = { "config", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/"), "0" };
            if (sLoadMode == LoadMode.LM_FWK)
            {
                string[] fwk = { "fwk", Path.Combine(UnityEngine.Application.dataPath, "../../ThinkLuaFwk/"), "0" };
                string[] network = { "network", Path.Combine(UnityEngine.Application.dataPath, "../../ThinkServer/server/script/src"), "0" };
                string[] game = { "game", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/"), "0" };
                string[] config = { "config", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/"), "0" };
                string[] share = { "share", Path.Combine(UnityEngine.Application.dataPath, "../../ThinkServer/server/script/src"), "0" };
                sLuaSearchList.Add(fwk);
                sLuaSearchList.Add(network);
                sLuaSearchList.Add(game);
                sLuaSearchList.Add(config);
                sLuaSearchList.Add(share);
            }
            else if(sLoadMode == LoadMode.LM_DEV)
            {
                string[] fwk = { "fwk", Path.Combine(UnityEngine.Application.dataPath, "../../src_encrypt/"), "0" };
                string[] network = { "network", Path.Combine(UnityEngine.Application.dataPath, "../../src/server/script/src"), "0" };
                string[] game = { "game", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/"), "0" };
                string[] config = { "config", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/"), "0" };
                string[] share = { "share", Path.Combine(UnityEngine.Application.dataPath, "../../src/server/script/src"), "0" };
                sLuaSearchList.Add(fwk);
                sLuaSearchList.Add(network);
                sLuaSearchList.Add(game);
                sLuaSearchList.Add(config);
                sLuaSearchList.Add(share);
            }
            else if (sLoadMode == LoadMode.LM_EDIT)
            {
                string[] fwk = { "fwk", Path.Combine(UnityEngine.Application.dataPath, "../../src_encrypt/"), "1" };
                string[] network = { "network", Path.Combine(UnityEngine.Application.dataPath, "../../src/server/script/src"), "0" };
                string[] game = { "game", Path.Combine(UnityEngine.Application.dataPath, "../../src_encrypt/"), "1" };
                string[] config = { "config", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/"), "0" };
                string[] share = { "share", Path.Combine(UnityEngine.Application.dataPath, "../../src_encrypt/game/"), "1" };
                sLuaSearchList.Add(fwk);
                sLuaSearchList.Add(network);
                sLuaSearchList.Add(game);
                sLuaSearchList.Add(config);
                sLuaSearchList.Add(share);
            }
            else if(sLoadMode == LoadMode.LM_RUN)
            {
                //string[] fwk = { "fwk", Path.Combine(UnityEngine.Application.streamingAssetsPath, "/"), "0" };
                ////string[] network = { "network", Path.Combine(UnityEngine.Application.streamingAssetsPath, "lua/game"), "1" };
                //string[] game = { "game", Path.Combine(UnityEngine.Application.streamingAssetsPath, "/"), "0" };
                //string[] config = { "config", Path.Combine(UnityEngine.Application.streamingAssetsPath, "/"), "0" };
                ////string[] share = { "share", Path.Combine(UnityEngine.Application.streamingAssetsPath, "lua/game"), "1" };
                

                // 目前固定路径就是放在streamingAssets下，所有相关的配置跟代码都放在这下面,完了后本地存储的数据跟资料放在默认的存储位置上
                // 0 代表着不加密状态, 1代表着加密状态，如果是正式发布版本需要走正式状态
                string[] fwk = { "fwk", UnityEngine.Application.streamingAssetsPath + "/", "0" };
                string[] game = { "game", UnityEngine.Application.streamingAssetsPath + "/", "0" };
                string[] config = { "config", UnityEngine.Application.streamingAssetsPath + "/", "0" };

                sLuaSearchList.Add(fwk);
                //sLuaSearchList.Add(network);
                sLuaSearchList.Add(game);
                sLuaSearchList.Add(config);
                //sLuaSearchList.Add(share);
            }
            SYLuaEnv.sEnv.AddLoader((ref string name) =>
            {
                string[] tab = name.Split('.');
                foreach (string[] param in sLuaSearchList)
                {
                    if (tab[0] != param[0])
                    {
                        continue;
                    }
                    var filepath = Path.Combine(param[1], name.Replace('.', '/') + ".lua");
                    if (tab[0] == "network")
                    {
                        Debug.Log(filepath);
                    }
                    if (File.Exists(filepath))
                    {
                        Stream stream = File.Open(filepath, FileMode.Open, FileAccess.Read);
                        StreamReader reader = new StreamReader(stream);
                        string text = reader.ReadToEnd();

                        stream.Close();
                        if (param[2].Equals("0"))
                        {
                            return System.Text.Encoding.UTF8.GetBytes(text);
                        }
                        else
                        {
                            // 加密的这块东西暂时还没有研究，暂时用不到加密
                            string decrypt_data = Xxtea.XXTEA.DecryptBase64StringToString(text, "xProject");
                            return System.Text.Encoding.UTF8.GetBytes(decrypt_data);
                        }
                    }
                }
                return null;
            });

        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_rapidjson(System.IntPtr L);

        [MonoPInvokeCallback(typeof(XLua.LuaDLL.lua_CSFunction))]
        public static int LoadRapidJson(System.IntPtr L)
        {
            return luaopen_rapidjson(L);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_pb(System.IntPtr L);
        [MonoPInvokeCallback(typeof(XLua.LuaDLL.lua_CSFunction))]
        public static int LoadPb(System.IntPtr L)
        {
            return luaopen_pb(L);
        }

        

        private static void InitFwkLoader()
        {
            sLuaSearchList = new ArrayList();
            //游戏逻辑lua
            sLuaSearchList.Add(Path.Combine(UnityEngine.Application.dataPath, "../../src/client/"));
            //游戏框架lua
            sLuaSearchList.Add(Path.Combine(UnityEngine.Application.dataPath, "../../fwk_src/lua/"));

            SYLuaEnv.sEnv.AddLoader((ref string name) =>
            {
                foreach (string path in sLuaSearchList)
                {
                    var filepath = Path.Combine(path, name.Replace('.', '/') + ".lua");
                    if (File.Exists(filepath))
                    {
                        Stream stream = File.Open(filepath, FileMode.Open, FileAccess.Read);
                        StreamReader reader = new StreamReader(stream);
                        string text = reader.ReadToEnd();
                        stream.Close();
                        return System.Text.Encoding.UTF8.GetBytes(text);
                    }
                }
                return null;
            });

        }

//        // 创建开发程序使用的Loader
//        private static void InitLogicLoader()
//        {
//#if UNITY_EDITOR
//            sLuaSearchList = new ArrayList();
//            string[] fwk = { "fwk", Path.Combine(UnityEngine.Application.dataPath, "../../src_encrypt/"), "1" };
//            string[] game = { "game", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/"), "0" };
//            string[] config = { "config", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/"), "0" };

//            sLuaSearchList.Add(fwk);
//            sLuaSearchList.Add(game);
//            sLuaSearchList.Add(config);

//            SYLuaEnv.sEnv.AddLoader((ref string name) =>
//            {
//                foreach (string[] param in sLuaSearchList)
//                {
//                    var filepath = Path.Combine(param[1], name.Replace('.', '/') + ".lua");
//                    if (File.Exists(filepath))
//                    {
//                        Stream stream = File.Open(filepath, FileMode.Open, FileAccess.Read);
//                        StreamReader reader = new StreamReader(stream);
//                        string text = reader.ReadToEnd();

//                        stream.Close();
//                        if (param[2].Equals("0"))
//                        {
//                            return System.Text.Encoding.UTF8.GetBytes(text);
//                        }
//                        else
//                        {
//                            string decrypt_data = Xxtea.XXTEA.DecryptBase64StringToString(text, "xProject");
//                            return System.Text.Encoding.UTF8.GetBytes(decrypt_data);
//                        }
//                    }
//                }
//                return null;
//            });
//#endif
//        }

//        private static void InitEditorLoader()
//        {
//            sLuaSearchList = new ArrayList();
//            string[] fwk = { "fwk", Path.Combine(UnityEngine.Application.dataPath, "../../src_encrypt/"), "1" };
//            string[] game = { "game", Path.Combine(UnityEngine.Application.dataPath, "../../src_encrypt/"), "1" };
//            string[] config = { "config", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/"), "0" };

//            sLuaSearchList.Add(fwk);
//            sLuaSearchList.Add(game);
//            sLuaSearchList.Add(config);

//            SYLuaEnv.sEnv.AddLoader((ref string name) =>
//            {
//                string[] tab = name.Split('.');
//                foreach (string[] param in sLuaSearchList)
//                {
//                    if (tab[0] != param[0])
//                    {
//                        continue;
//                    }
//                    var filepath = Path.Combine(param[1], name.Replace('.', '/') + ".lua");
//                    if (File.Exists(filepath))
//                    {
//                        Stream stream = File.Open(filepath, FileMode.Open, FileAccess.Read);
//                        StreamReader reader = new StreamReader(stream);
//                        string text = reader.ReadToEnd();

//                        stream.Close();
//                        if (param[2].Equals("0"))
//                        {
//                            return System.Text.Encoding.UTF8.GetBytes(text);
//                        }
//                        else
//                        {
//                            string decrypt_data = Xxtea.XXTEA.DecryptBase64StringToString(text, "xProject");
//                            return System.Text.Encoding.UTF8.GetBytes(decrypt_data);
//                        }
//                    }
//                }
//                return null;
//            });
//        }

//        // 创建正式运行时使用的Loader
//        private static void InitRunLoader()
//        {

//            sLuaSearchList = new ArrayList();
//            ////游戏框架lua
//            //sLuaSearchList.Add(Path.Combine(UnityEngine.Application.persistentDataPath, "lua/"));
//            ////游戏逻辑lua
//            //sLuaSearchList.Add(Path.Combine(UnityEngine.Application.persistentDataPath, "lua/"));
//            ////游戏配置lua
//            //sLuaSearchList.Add(Path.Combine(UnityEngine.Application.persistentDataPath, "lua/"));

//            //游戏框架lua
//            sLuaSearchList.Add(Path.Combine(UnityEngine.Application.streamingAssetsPath));
//            //游戏逻辑lua
//            sLuaSearchList.Add(Path.Combine(UnityEngine.Application.streamingAssetsPath));
//            //游戏配置lua
//            sLuaSearchList.Add(Path.Combine(UnityEngine.Application.streamingAssetsPath));

//            SYLuaEnv.sEnv.AddLoader((ref string name) =>
//            {
//                foreach (string path in sLuaSearchList)
//                {
//                    var filepath = Path.Combine(path, name.Replace('.', '/') + ".lua");

//                    if (File.Exists(filepath))
//                    {
//                        Stream stream = File.Open(filepath, FileMode.Open, FileAccess.Read);
//                        StreamReader reader = new StreamReader(stream);
//                        string text = reader.ReadToEnd();

//                        stream.Close();

//                        // 这里放弃了加密
//                        //string decrypt_data = Xxtea.XXTEA.DecryptBase64StringToString(text, "xProject");
//                        //return System.Text.Encoding.UTF8.GetBytes(decrypt_data);
                        
//                        // 默认加载
//                        return System.Text.Encoding.UTF8.GetBytes(text);
//                    }
//                }
//                return null;
//            });
//        }

        public static LuaFunction loadstring(string name, LuaTable env = null)
        {
            string[] tab = name.Split('/');

            
            foreach (string[] param in sLuaSearchList)
            {
                
                if (tab[0] != param[0])
                {
                    continue;
                }

                var filepath = Path.Combine(param[1], name);


                if (File.Exists(filepath))
                {
                    Stream stream = File.Open(filepath, FileMode.Open, FileAccess.Read);
                    StreamReader reader = new StreamReader(stream);
                    string text = reader.ReadToEnd();

                    stream.Close();


                    //if (param[2].Equals("0"))
                    //{
                    //    return SYLuaEnv.sEnv.LoadString(text, name, env);
                    //}
                    //else
                    //{
                    //    string decrypt_data = Xxtea.XXTEA.DecryptBase64StringToString(text, "xProject");
                    //    return SYLuaEnv.sEnv.LoadString(decrypt_data, name, env);
                    //}

                    return SYLuaEnv.sEnv.LoadString(text, name, env);
                }
            }

            Debug.Log("===================");
            return null;
        }
    }
}
