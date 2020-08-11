using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace SYFwk.Tool
{
    public class AutoAssetBundle
    {
        private static string GetZIPOutPath(BuildTarget target)
        {
            string basePath = Path.GetFullPath(Path.Combine(Application.dataPath, "../../data/zip_out/"));

            string path = null;
            switch (target)
            {
                case BuildTarget.Android:
                    path = basePath + "android/zip_ab/";
                    break;
                case BuildTarget.StandaloneWindows64:
                    path = basePath + "win/zip_ab/";
                    break;
                case BuildTarget.iOS:
                    path = basePath + "ios/zip_ab/";
                    break;
                default:
                    break;
            }
            if (path != null && !Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            return path;
        }

        [MenuItem("xxtea/encode")]
        public static void test_xxtea()
        {

            string base_path = UnityEngine.Application.dataPath + "/../../lua_zip/";
            List<string[]> d = new List<string[]>();
            string[] s1 = { "config", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/config/"), "config" };
            string[] s2 = { "game", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/game/"), "game" };
            //string[] s3 = { "fwk", Path.Combine(UnityEngine.Application.dataPath, "../../fwk_src/lua/fwk/"), "fwk" };
            d.Add(s1);
            d.Add(s2);
            //d.Add(s3);

            string outPath = Path.Combine(UnityEngine.Application.dataPath, "../../../my_tool/encrypt/");
            if (Directory.Exists(outPath))
            {
                Directory.Delete(outPath, true);
            }
            Directory.CreateDirectory(outPath);

            foreach (var s in d)
            {
                //SYFwk.Core.Extension.xxteaDirectory(s[1], "J:/SYFwk/ASFwk/lua_zip/test_xxtea/" + s[2]);
                SYFwk.Core.Extension.xxteaDirectory(s[1], outPath + "/" + s[2]);
            }
        }


        [MenuItem("ABTool/zip_lua")]
        public static void zip_lua()
        {
            string base_path = UnityEngine.Application.dataPath + "/../../lua_zip/";
            Dictionary<string, string> d = new Dictionary<string, string>();
            d.Add("config", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/config/"));
            d.Add("game", Path.Combine(UnityEngine.Application.dataPath, "../../src/client/game/"));
            d.Add("fwk", Path.Combine(UnityEngine.Application.dataPath, "../../fwk_src/lua/fwk"));
            foreach (var k in d.Keys)
            {
                string ver = File.ReadAllText(base_path + "lua_ver/" + k + "_ver.txt");
                string path = base_path + "lua_zip_src/" + k;
                if (Directory.Exists(path))
                {
                    Directory.Delete(path, true);
                }
                Directory.CreateDirectory(path);
                SYFwk.Core.Extension.CopyDirectory(d[k], path);
                string[] dir = { path };

                if (!Directory.Exists(base_path + "zip/"))
                {
                    Directory.CreateDirectory(base_path + "zip/");
                }
                string fullName = base_path + "zip/" + k + "_" + ver + ".zip";
                ZipUtility.Zip(dir, fullName);
                //string md5 = SYFwk.Core.Extension.EncodeMd5File(fullName, true);
            }

            Debug.Log("zip_lua finish");
        }

        [MenuItem("ABTool/unzip_lua")]
        public static void unzip_lua()
        {
            string base_path = UnityEngine.Application.dataPath + "/../../lua_zip/";
            string src = UnityEngine.Application.dataPath + "../../../lua_zip/zip/";
            DirectoryInfo dir = new DirectoryInfo(src);
            FileSystemInfo[] fileinfo = dir.GetFileSystemInfos();  //获取目录下（不包含子目录）的文件和子目录
            string[] zip_type = { "fwk", "game", "config" };
            foreach (var t in zip_type)
            {
                string ver = File.ReadAllText(base_path + "lua_ver/" + t + "_ver.txt");
                ZipUtility.UnzipFile(
                    base_path + "zip/" + t + "_" + ver + ".zip",
                    base_path + "lua_unzip/");

            }
        }

        [MenuItem("ABTool/zip_ios_ab")]
        public static void zip_ios_ab()
        {
            zip_ab(BuildTarget.iOS);
        }

        [MenuItem("ABTool/zip_android_ab")]
        public static void zip_android_ab()
        {
            zip_ab(BuildTarget.Android);
        }


        public static void zip_ab(BuildTarget target)
        {
            string src = GetOutPath(target);
            string dst = GetZIPOutPath(target);


            List<string> list1 = new List<string>();
            List<string> list2 = new List<string>();
            List<string> list3 = new List<string>();

            AssetBundle.UnloadAllAssetBundles(true);

            if (Directory.Exists(dst))
            {
                DirectoryInfo di = new DirectoryInfo(dst);
                di.Delete(true);
                Directory.CreateDirectory(dst);
            }

            DirectoryInfo dir_info = new DirectoryInfo(src);
            FileSystemInfo[] fileinfo = dir_info.GetFileSystemInfos();  //获取目录下（不包含子目录）的文件和子目录
            int index = 0;
            foreach (FileSystemInfo i in fileinfo)
            {
                string aLastName = i.Name.Substring(i.Name.LastIndexOf(".") + 1, (i.Name.Length - i.Name.LastIndexOf(".") - 1)); //扩展名
                string[] split = i.Name.Split('_');
                if (aLastName != "manifest" && split[0].CompareTo("updata") != 0)
                {
                    list1.Add(i.FullName);
                    list2.Add(i.Name);


                }
            }

            List<List<string>> zip_list = new List<List<string>>();

            while (list1.Count > 0)
            {
                List<string> l = new List<string>();
                for (int i = 0; i < 2; i++)
                {
                    if (list1.Count > 0)
                    {
                        int list_index = UnityEngine.Random.Range(0, list1.Count - 1);
                        l.Add(list1[list_index]);
                        list1.RemoveAt(list_index);
                    }
                }
                zip_list.Add(l);
            }

            for (int i = 0; i < zip_list.Count; i++)
            {
                DateTime dt = DateTime.Now;
                list3.Add(dt.Ticks + "_" + (++index));
                string[] s = zip_list[i].ToArray<string>();
                ZipUtility.Zip(s, dst + list3[i] + ".zip");
            }

            //for (int i = 0; i < list1.Count; i++)
            //{
            //    string[] s = { list1[i] };
            //    Debug.Log(list1[i] + "    " + list2[i]);
            //    ZipUtility.Zip(s, dst + list3[i] + ".zip");
            //}

            if (target == BuildTarget.Android)
            {
                string ss = "{";

                for (int i = 0; i < list3.Count; i++)
                {
                    ss = ss + "\"" + list3[i] + "\"" + ":" + "\"" + list3[i] + "\"" + ",";
                }

                ss = ss.Substring(0, ss.Length - 1);
                ss = ss + "}";

                if (File.Exists(src + "../../../zip_out/android/zip_list.json"))
                {
                    File.Delete(src + "../../../zip_out/android/zip_list.json");
                }
                SYFwk.Core.Extension.WriteFile(src + "../../../zip_out/android", "zip_list.json", ss);
            }

            Debug.Log("zip_ab finish");
        }

        [MenuItem("ABTool/GenVerIOS")]
        public static void GenVerIOS()
        {
            BuildIOS();
            GenVer(BuildTarget.iOS);
        }

        [MenuItem("ABTool/GenVerWin")]
        public static void GenVerWin()
        {
            BuildWin();
            GenVer(BuildTarget.StandaloneWindows64);
        }

        [MenuItem("ABTool/GenVerAndroid")]
        public static void GenVerAndroid()
        {
            BuildAndroid();
            GenVer(BuildTarget.Android);
        }

        private static void GenVer(BuildTarget target)
        {
            string src = GetOutPath(target);
            string path = File.ReadAllText(src + "../pack_ver.txt");

            int pack_ver = int.Parse(File.ReadAllText(path));
            pack_ver++;
            string ver = src + "../ver_" + pack_ver + "/";
            string ver_ab = src + "../ver_" + pack_ver + "/ab/";
            string ver_ab_updata = src + "../ver_" + pack_ver + "/ab_updata/";
            if (Directory.Exists(ver))
            {
                Directory.Delete(ver, true);
            }
            Directory.CreateDirectory(ver);

            if (Directory.Exists(ver_ab))
            {
                Directory.Delete(ver_ab, true);
            }
            Directory.CreateDirectory(ver_ab);

            if (Directory.Exists(ver_ab_updata))
            {
                Directory.Delete(ver_ab_updata, true);
            }
            Directory.CreateDirectory(ver_ab_updata);

            //Flz.Core.Extension.CopyDirectory(src, ver_ab);
            AssetBundle.UnloadAllAssetBundles(true);
            AssetBundle ab = AssetBundle.LoadFromFile(src + "ab");
            AssetBundleManifest abmm = (AssetBundleManifest)ab.LoadAsset("AssetBundleManifest");
            string[] abs = abmm.GetAllAssetBundles();

            File.Copy(src + "ab", ver_ab + "ab");
            foreach (var f in abs)
            {
                //Debug.Log(f);
                string[] split = f.Split('_');
                if (split[0].CompareTo("updata") == 0)
                {
                    File.Copy(src + f, ver_ab_updata + f);
                }
                else
                {
                    File.Copy(src + f, ver_ab + f);
                }

            }

            string[] p = { ver_ab, ver_ab_updata };
            Dictionary<string, string> dic = new Dictionary<string, string>();
            dic.Add(ver_ab, "res_list");
            dic.Add(ver_ab_updata, "updata_res_list");

            string ss = "{";
            foreach (var key in dic.Keys)
            {
                string s = "{";
                bool flag = false;
                DirectoryInfo dir = new DirectoryInfo(key);
                FileSystemInfo[] fileinfo = dir.GetFileSystemInfos();  //获取目录下（不包含子目录）的文件和子目录
                foreach (FileSystemInfo i in fileinfo)
                {
                    string md5 = SYFwk.Core.Extension.EncodeMd5File(i.FullName, true);
                    s = s + "\"" + i.Name + "\"" + ":" + "\"" + md5 + "\"" + ",";
                    flag = true;
                }

                if (flag)
                {
                    s = s.Substring(0, s.Length - 1);
                }
                s = s + "}";


                ss = ss + "\"" + dic[key] + "\"" + ":" + s + ",";

            }

            ss = ss.Substring(0, ss.Length - 1);
            ss = ss + "}";

            SYFwk.Core.Extension.WriteFile(src + "../ver_" + pack_ver, "res_list.json", ss);


            if (File.Exists(path))
            {
                File.Delete(path);
            }
            File.WriteAllText(path, pack_ver.ToString());


        }

        private static string GetOutPath(BuildTarget target)
        {
            string basePath = Path.GetFullPath(Path.Combine(Application.dataPath, "../../data/ab/"));

            string path = null;
            switch (target)
            {
                case BuildTarget.Android:
                    path = basePath + "android/ab/";
                    break;
                case BuildTarget.StandaloneWindows64:
                    path = basePath + "win/ab/";
                    break;
                case BuildTarget.iOS:
                    path = basePath + "ios/ab/";
                    break;
                default:
                    break;
            }
            if (path != null && !Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            return path;
        }

        [MenuItem("ABTool/BuildIOS")]
        public static void BuildIOS()
        {
            Build(BuildTarget.iOS);
            //Deploy(BuildTarget.iOS);
        }

        [MenuItem("ABTool/BuildWin")]
        public static void BuildWin()
        {
            Build(BuildTarget.StandaloneWindows64);
            //Deploy(BuildTarget.StandaloneWindows64);
        }

        [MenuItem("ABTool/BuildAndroid")]
        public static void BuildAndroid()
        {
            Build(BuildTarget.Android);
            //Deploy(BuildTarget.Android);
        }

        private static string[] GetFileListByType(string type, string[] paths = null)
        {
            string[] shaders = AssetDatabase.FindAssets("t:" + type, paths);

            Dictionary<string, string> pathDic = new Dictionary<string, string>();
            foreach (var n in shaders)
            {
                string t = null;
                if (!pathDic.TryGetValue(n, out t))
                {
                    pathDic.Add(n, AssetDatabase.GUIDToAssetPath(n));
                }
                //Debug.LogFormat("{0} {1}", n, AssetDatabase.GUIDToAssetPath(n));

            }
            return pathDic.Values.ToArray();
        }

        private static void Build(BuildTarget target)
        {
            string outDir = GetOutPath(target);
            if (outDir == null)
            {
                Debug.LogErrorFormat("Unsupport target {0}", target);
                return;
            }
            List<AssetBundleBuild> abbList = new List<AssetBundleBuild>();

            string basePath = Path.GetFullPath(Path.Combine(Application.dataPath, "../"));

            // Shader
            string[] shaders = GetFileListByType("Shader");
            //string[] fonts = GetFileListByType("Font");
            string[] prefabs = GetFileListByType("Prefab", new string[1] { "Assets/res/prefab" });
            string[] audio_clips = GetFileListByType("AudioClip", new string[1] { "Assets/res/sound" });

            //AssetBundleBuild abbFont = new AssetBundleBuild();
            //abbFont.assetBundleName = "font.ab";
            //abbFont.assetNames = fonts;
            //abbList.Add(abbFont);

            AssetBundleBuild abbShader = new AssetBundleBuild();
            abbShader.assetBundleName = "shader.ab";
            abbShader.assetNames = shaders;
            abbList.Add(abbShader);

            List<AssetBundleBuild> prefabs_list = get_Prefabs_list();
            abbList.AddRange(prefabs_list);

            List<AssetBundleBuild> sprite_list = get_Sprite_list();
            abbList.AddRange(sprite_list);

            List<AssetBundleBuild> audioClip_list = get_AudioClip_list();
            abbList.AddRange(audioClip_list);

            //    None ： 没有任何特殊要求。 
            //　　UncompressedAssetBundle ： 不压缩。 
            //　　DisableWriteTypeTree ： Assetbundle中不包含Type信息。TypeTree将在后面提到。 
            //　　DeterministicAssetBundle ： 使用资源的Hash ID来导出AssetBundle。使用ID可避免资源改名、移动位置等导致重新导出。 
            //　　ForceRebuildAssetBundle ： 强制重新导出。对已有的AssetBundle，在资源没有变化时，Unity不会重新导出。 
            //　　IgnoreTypeTreeChanges ： 增量打包时忽略Type信息变化。 
            //　　AppendHashToAssetBundleName ： 在AssetBundle名称后添加”_”加上Hash值。 
            //　　ChunkBasedCompression ： 使用块压缩，即LZ4压缩。

            BuildAssetBundleOptions op
                = BuildAssetBundleOptions.DeterministicAssetBundle
                | BuildAssetBundleOptions.ChunkBasedCompression;
            AssetBundleManifest abm = BuildPipeline.BuildAssetBundles(outDir, abbList.ToArray(), op, target);

            AssetBundle.UnloadAllAssetBundles(true);
        }

        private static List<AssetBundleBuild> get_Prefabs_list()
        {
            List<AssetBundleBuild> abbList = new List<AssetBundleBuild>();
            Dictionary<string, string> dic = new Dictionary<string, string>();
            dic.Add("Assets/res/prefab", "");
            dic.Add("Assets/res_updata/prefab", "updata_");
            foreach (string dir_key in dic.Keys)
            {
                string[] prefabs = GetFileListByType("Prefab", new string[1] { dir_key });
                foreach (var pp in prefabs)
                {

                    if (dic[dir_key] == "updata_")
                    {
                        Debug.Log(pp.Replace(dir_key + "/", ""));
                    }

                    string name = pp.Replace(dir_key + "/", "");
                    name = name.Remove(name.LastIndexOf('.'));
                    name = name.Replace('/', '.');
                    name = name.Replace('\\', '.');
                    name = name + ".ab";



                    AssetBundleBuild abb = new AssetBundleBuild();
                    abb.assetBundleName = dic[dir_key] + name;
                    abb.assetNames = new string[1] { pp };
                    abbList.Add(abb);
                }
            }

            //string[] prefabs = GetFileListByType("Prefab", new string[1] { "Assets/res/prefab" });
            //foreach (var pp in prefabs)
            //{
            //    string name = pp.Replace("Assets/res/prefab/", "");

            //    name = name.Remove(name.LastIndexOf('.'));
            //    name = name.Replace('/', '.');
            //    name = name.Replace('\\', '.');
            //    name = name + ".ab";

            //    AssetBundleBuild abb = new AssetBundleBuild();
            //    abb.assetBundleName = name;
            //    abb.assetNames = new string[1] { pp };
            //    abbList.Add(abb);
            //}


            return abbList;
        }
        private static List<AssetBundleBuild> get_Sprite_list()
        {
            string[] sprites = GetFileListByType("Sprite", new string[1] { "Assets/res" });
            List<AssetBundleBuild> abbList = new List<AssetBundleBuild>();
            // 找到指定为load的图片
            Dictionary<string, List<string>> spriteDic = new Dictionary<string, List<string>>();
            //spriteDic.Add("load", new List<string>());
            

            Dictionary<string, bool> dic = EditLoadCheck.GetSpriteDic();
            foreach (var k in dic.Keys)
            {
                spriteDic.Add(k, new List<string>());
            }

            foreach (var sf in sprites)
            {
                AssetImporter ai = AssetImporter.GetAtPath(sf);
                if (spriteDic.ContainsKey(ai.assetBundleName))
                {
                    spriteDic[ai.assetBundleName].Add(sf);
                }
            }

            string[] updata_sprites = GetFileListByType("Sprite", new string[1] { "Assets/res_updata" });
            foreach (var sf in updata_sprites)
            {
                AssetImporter ai = AssetImporter.GetAtPath(sf);
                string assetBundleName = "updata_" + ai.assetBundleName;
                if (spriteDic.ContainsKey(assetBundleName))
                {

                    spriteDic[assetBundleName].Add(sf);
                }
                else
                {
                    if (spriteDic.ContainsKey(ai.assetBundleName))
                    {
                        spriteDic.Add(assetBundleName, new List<string>());
                        spriteDic[assetBundleName].Add(sf);
                    }
                }

            }

            foreach (var item in spriteDic)
            {
                Console.WriteLine(item.Key + item.Value);
                Debug.LogFormat("{0} need dynamic load Count {1}", item.Key, item.Value.Count);
                if (item.Value.Count > 0)
                {
                    AssetBundleBuild abbLoadSprite = new AssetBundleBuild();
                    if (item.Key == "load")
                    {
                        abbLoadSprite.assetBundleName = "sprite_load.ab";
                    }
                    else
                    {
                        abbLoadSprite.assetBundleName = item.Key + ".ab";
                    }
                    abbLoadSprite.assetNames = item.Value.ToArray();
                    abbList.Add(abbLoadSprite);
                }
            }

            return abbList;
        }
        private static List<AssetBundleBuild> get_AudioClip_list()
        {
            List<AssetBundleBuild> abbList = new List<AssetBundleBuild>();
            Dictionary<string, string> dic = new Dictionary<string, string>();
            dic.Add("Assets/res/sound", "sound");
            dic.Add("Assets/res_updata/sound", "updata_sound");
            foreach (string dir_key in dic.Keys)
            {
                string[] audio_clips = GetFileListByType("AudioClip", new string[1] { dir_key });
                Dictionary<string, List<string>> soundDic = new Dictionary<string, List<string>>();
                foreach (var pp in audio_clips)
                {
                    string name = pp.Replace(dir_key + "/", "");
                    name = name.Remove(name.LastIndexOf('.'));
                    name = name.Replace('/', '.');
                    name = name.Replace('\\', '.');
                    string[] s = name.Split('.');
                    if (s.Length > 1)
                    {
                        string key_name = name.Remove(name.LastIndexOf('.')) + ".ab";
                        if (!soundDic.ContainsKey(key_name))
                        {
                            soundDic.Add(key_name, new List<string>());
                        }
                        soundDic[key_name].Add(pp);
                    }
                    else
                    {
                        if (!soundDic.ContainsKey(name + ".ab"))
                        {
                            soundDic.Add(name + ".ab", new List<string>());
                        }
                        soundDic[name + ".ab"].Add(pp);
                    }


                }

                foreach (var key in soundDic.Keys)
                {
                    AssetBundleBuild abb = new AssetBundleBuild();
                    abb.assetBundleName = dic[dir_key] + "_" + key;
                    abb.assetNames = soundDic[key].ToArray();
                    abbList.Add(abb);
                }

            }
            return abbList;
        }
    }
}
