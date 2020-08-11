using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using UnityEditor;
using UnityEngine;


namespace SYFwk.Tool
{
    public class Post_Tools
    {


        /// <summary>
        /// 指定Post地址使用Get 方式获取全部字符串
        /// </summary>
        /// <param name="url">请求后台地址</param>
        /// <param name="content">Post提交数据内容(utf-8编码的)</param>
        /// <returns></returns>
        public static string Post(string url, string content)
        {
            string result = "";
            HttpWebRequest req = (HttpWebRequest)WebRequest.Create(url);
            req.Method = "POST";
            req.ContentType = "application/json";

            #region 添加Post 参数
            byte[] data = Encoding.UTF8.GetBytes(content);
            req.ContentLength = data.Length;
            using (Stream reqStream = req.GetRequestStream())
            {
                reqStream.Write(data, 0, data.Length);
                reqStream.Close();
            }
            #endregion

            HttpWebResponse resp = (HttpWebResponse)req.GetResponse();
            Stream stream = resp.GetResponseStream();
            //获取响应内容
            using (StreamReader reader = new StreamReader(stream, Encoding.UTF8))
            {
                result = reader.ReadToEnd();
            }
            return result;
        }

        [MenuItem("Post_Tools/PostJson")]
        public static void PostJson()
        {
            string str = "{\"type\":\"android\", \"bundle_id\":\"5d514c3223389f724c16f268\", \"api_token\":\"cd5d4fc7ce6c1703e525faaa6a59d044\"}";

            string str_Json = Post("http://api.fir.im/apps",str);


            //把str文件转成Json类型
            //List<JsonModel> json = getObjectByJson(str_Json);


            Debug.Log(str_Json);
        }



        /// <summary>  
        /// 将json数据转换成实体类     
        /// </summary>  
        /// <returns></returns>  
        //private static List<JsonModel> getObjectByJson(string jsonString)
        //{
        //    // 实例化DataContractJsonSerializer对象，需要待序列化的对象类型  
        //    DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(List<JsonModel>));
        //    //把Json传入内存流中保存  
        //    jsonString = "[" + jsonString + "]";
        //    MemoryStream stream = new MemoryStream(Encoding.UTF8.GetBytes(jsonString));
        //    // 使用ReadObject方法反序列化成对象  
        //    object ob = serializer.ReadObject(stream);
        //    List<JsonModel> ls = (List<JsonModel>)ob;
        //    return ls;
        //}

    }

}
