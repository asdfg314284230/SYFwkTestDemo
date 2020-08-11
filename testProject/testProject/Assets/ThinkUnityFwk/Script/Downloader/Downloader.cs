using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Fwk.Util
{
    public static class Downloader
    {
        static Dictionary<string, DownloadTask> downLoader_dic = new Dictionary<string, DownloadTask>();

        //[XLua.LuaCallCSharp]
        static public string BaseUrl = "";
        /**--------------------------------------------------------------------------------------------------
         *  异步加载文件 
         *  @param url          源地址
         *  @param dir          保存文件夹
         *  @param filename     保存文件名
         *  @param process_func 
         *  @param error_func
         *  @param finish_func  
         */
        [XLua.LuaCallCSharp]
        static public void AsyncLoadFile(string url, string dir, string filename, Action<float> process_func, Action<string> error_func, Action<string, string> finish_func)
        {
            if (downLoader_dic.ContainsKey(dir + filename))
            {
                //downLoader_dic[url].Abort();
                //downLoader_dic.Remove(url);
                if (error_func != null)
                {
                    error_func("downing");
                }
                return;
            }
            DownloadTask downLoader = new DownloadTask();
            downLoader.URL = url;
            downLoader.dir = dir;
            downLoader.filename = filename;
            downLoader.process_func = process_func;
            downLoader.error_func = (status) =>
            {
                downLoader_dic.Remove(dir + filename);
                if (error_func != null)
                {
                    error_func(status);
                }
            };
            downLoader.finish_func = (status, path) =>
            {
                downLoader_dic.Remove(dir + filename);
                if (finish_func != null)
                {
                    finish_func(status, path);
                }
            };
            downLoader.StreamLargeFile();
            downLoader_dic.Add(dir + filename, downLoader);
        }

        static public void AsyncLoadFileByType(string type, string filename, Action<float> process_func, Action<string> error_func, Action<string, string> finish_func)
        {
            TypeInfo info;
            if (!sTypeInfo.TryGetValue(type, out info))
            {
                if (error_func!= null)
                {
                    error_func("unknown type" + type);
                }
                return;
            }
            AsyncLoadFile(BaseUrl + info.url + "/" + filename, info.dir, filename, process_func, error_func, finish_func);
        }


        struct TypeInfo
        {
            public string dir;
            public string localDir;
            public string url;
        }
        static private Dictionary<string, TypeInfo> sTypeInfo = new Dictionary<string, TypeInfo>();
        
        /**--------------------------------------------------------------------------------------------------
         * @desc 注册一个类型
         */
        [XLua.LuaCallCSharp]
        static public void RegisterType(string typeName, string dir, string localDir, string url)
        {
            TypeInfo info = new TypeInfo();
            info.dir = dir;
            info.localDir = localDir;
            info.url = url;
            sTypeInfo[typeName] = info;
        }
        /**--------------------------------------------------------------------------------------------------
         * @desc 通过类型名和文件名，获取全路径
         * @param name 文件名
         * @param type 文件类型
         * @param local 
         */
        static public string GetFullPath(string name, string type, bool local)
        {
            TypeInfo info;
            if (sTypeInfo.TryGetValue(type, out info))
            {
                if (local)
                {
                    return info.localDir + "/" + name;
                }
                else
                {
                    return info.dir + "/" + name;
                }                
            }
            return null;
        }

        static public string GetUrl(string name, string type)
        {
            return "";
        }
    }
}