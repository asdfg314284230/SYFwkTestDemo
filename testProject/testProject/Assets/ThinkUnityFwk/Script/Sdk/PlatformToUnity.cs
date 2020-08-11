using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Security.Cryptography;
using System.Text;

namespace Flz.SDK
{
    public class PlatformToUnity : MonoBehaviour
    {

        public Action<string> func;
        public void platform_msg(string json_str)
        {
            Debug.Log(json_str);
            if (func != null)
            {
                func(json_str);
            }
        }


        // 计算MD5值(有安全散列算法和MD5算法)
        public string getCheckSum(string appSecret, string nonce, string curTime)
        {
            byte[] data = Encoding.Default.GetBytes(appSecret + nonce + curTime);
            byte[] result;

            SHA1 sha = new SHA1CryptoServiceProvider();
            result = sha.ComputeHash(data);

            return getFormattedText(result);
        }

        // 格式转换
        private static string getFormattedText(byte[] bytes)
        {
            char[] HEX_DIGITS = { '0', '1', '2', '3', '4', '5',
            '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

            int len = bytes.Length;

            StringBuilder buf = new StringBuilder(len * 2);

            for (int i = 0; i < len; i++)
            {
                buf.Append(HEX_DIGITS[(bytes[i] >> 4) & 0x0f]);
                buf.Append(HEX_DIGITS[bytes[i] & 0x0f]);
            }

            return buf.ToString();
        }

    }
}