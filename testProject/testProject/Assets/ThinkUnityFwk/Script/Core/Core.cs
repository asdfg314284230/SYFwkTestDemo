using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
//using UnityEditor;
using UnityEngine;
using XLua;

namespace SYFwk.Core
{
    // 导出到lua的核心类
    [LuaCallCSharp]
    class Core
    {
        // 为了模拟Resources.Load不输入扩展名，折腾下
        public static void Load(string name, Type type, Action<UnityEngine.Object> cb = null)
        {
#if UNITY_EDITOR

            Dictionary<string, bool> spriteDic = EditLoadCheck.GetSpriteDic();


            // 拆分路径名和文件名
            string file = Path.GetFileNameWithoutExtension(name);
            string path = Path.GetDirectoryName(name);
            // 添加资源路径
            string updata_path = "Assets/res_updata/" + path;
            path = "Assets/res/" + path;

            // 去掉路径最后的路径分隔符
            path = path.TrimEnd(new char[2] { '/', '\\' });
            updata_path = updata_path.TrimEnd(new char[2] { '/', '\\' });
            UnityEngine.Object obj = null;
            
            string[] assets = UnityEditor.AssetDatabase.FindAssets(file);
            
            for (int i = 0; i < assets.Length; ++i)
            {
                string assetPath = UnityEditor.AssetDatabase.GUIDToAssetPath(assets[i]);

                path = path.Replace('/', '\\');
                updata_path = updata_path.Replace('/', '\\');

                if (Path.GetFileNameWithoutExtension(assetPath) != file || (path != Path.GetDirectoryName(assetPath) && updata_path != Path.GetDirectoryName(assetPath)))
                {
                    continue;
                }

                obj = UnityEditor.AssetDatabase.LoadAssetAtPath(assetPath, type);
                if (obj != null)
                {
                    UnityEditor.AssetImporter ai = UnityEditor.AssetImporter.GetAtPath(assetPath);
                    if (ai != null && !spriteDic.ContainsKey(ai.assetBundleName) && obj.GetType() == typeof(Sprite))
                    {
                        Debug.LogErrorFormat("Fond Sprite[{0}] but not set ab name[{1}]", assetPath, ai.assetBundleName);
                        obj = null;
                        break;
                    }
                    break;
                }
            }
            cb(obj);
            if (obj == null)
            {
                Debug.LogError("No " + name);
            }
#else
            Debug.LogWarning("Flz.Core.Core.Load only in Editor mode");
            return;
#endif

        }

        public static int GetPlatformId()
        {
            return (int)Application.platform;
        }
    }
}
