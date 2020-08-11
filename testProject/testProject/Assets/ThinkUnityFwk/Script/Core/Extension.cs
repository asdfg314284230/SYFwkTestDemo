using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
using XLua;

namespace SYFwk.Core
{
    [LuaCallCSharp]
    public static class Extension
    {
        //public static bool IsNull(this UnityEngine.Object o)
        //{
        //    return o == null || o.Equals(null);
        //}

        public static string EncodeMd5(string source)
        {
            System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
            byte[] bytes = System.Text.Encoding.Default.GetBytes(source);
            byte[] hash = md5.ComputeHash(bytes);

            string ret = "";
            foreach (byte a in hash)
            {
                if (a < 16)
                    ret += "0" + a.ToString("x");
                else
                    ret += a.ToString("x");
            }
            return ret;
        }

        public static byte[] EncodeMd5_byte(string source)
        {
            System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
            byte[] bytes = System.Text.Encoding.Default.GetBytes(source);
            byte[] hash = md5.ComputeHash(bytes);

            string ret = "";
            foreach (byte a in hash)
            {
                if (a < 16)
                    ret += "0" + a.ToString("x");
                else
                    ret += a.ToString("x");
            }
            return Encoding.UTF8.GetBytes(ret);
        }

        public static int bytelen(byte[] bytes)
        {
            return bytes.Length;
        }

        public static int opcode(byte[] buff)
        {
            int opcode = BitConverter.ToInt32(buff, 2);
            return opcode;
        }

        public static int cpp_code(int opcode)
        {
            int c_dode = opcode & 0xffff;
            return c_dode;
        }

        public static int lua_code(int opcode)
        {
            int l_code = opcode >> 16;
            return l_code;
        }

        public static String bytes2string(byte[] bytes, int index, int count)
        {
            return Encoding.UTF8.GetString(bytes, index, count);
        }
        

        public static byte[] bytes2string1(byte[] bytes, int index, int count)
        {
            int len = count;
            byte[]b = new byte[len];
            for (int i = 0; i < len; i++)
            {
                b[i] = bytes[index + i];
            }
            return b;
        }


        public static string EncodeMd5File(string path, bool is_hex)
        {
            try
            {
                FileStream file = new FileStream(path, FileMode.Open);
                System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
                byte[] retVal = md5.ComputeHash(file);
                file.Close();

                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < retVal.Length; i++)
                {
                    sb.Append(retVal[i].ToString("x2"));
                }
                return sb.ToString();
            }
            catch (Exception ex)
            {
                throw new Exception("GetMD5HashFromFile() fail, error:" + ex.Message);
            }
        }

        public static string EncodeMd5File_base64(string path, bool is_hex)
        {
            try
            {
                FileStream file = new FileStream(path, FileMode.Open);
                System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
                byte[] retVal = md5.ComputeHash(file);
                file.Close();


                return Convert.ToBase64String(retVal);
            }
            catch (Exception ex)
            {
                throw new Exception("GetMD5HashFromFile() fail, error:" + ex.Message);
            }
        }


        public static bool WriteFile(string path, string name, string content, bool f = false)
        {
            try
            {
                if (!Directory.Exists(path))
                {
                    Directory.CreateDirectory(path);
                }
                string fname = path + "/" + name;
                if (!File.Exists(fname))
                {
                    FileStream fs = File.Create(fname);
                    fs.Close();
                }
                if (f)
                {
                    System.IO.File.AppendAllText(fname, content);
                }
                else
                {
                    System.IO.File.AppendAllText(fname, content + "\n");
                }

                return true;
            }
            catch
            {
                return false;
            }
        }

        public static void CopyDirectory(string srcPath, string destPath)
        {
            try
            {
                DirectoryInfo dir = new DirectoryInfo(srcPath);
                FileSystemInfo[] fileinfo = dir.GetFileSystemInfos();  //获取目录下（不包含子目录）的文件和子目录
                foreach (FileSystemInfo i in fileinfo)
                {
                    if (i is DirectoryInfo)     //判断是否文件夹
                    {
                        if (!Directory.Exists(destPath + "\\" + i.Name))
                        {
                            Directory.CreateDirectory(destPath + "\\" + i.Name);   //目标目录下不存在此文件夹即创建子文件夹
                        }
                        CopyDirectory(i.FullName, destPath + "\\" + i.Name);    //递归调用复制子文件夹
                    }
                    else
                    {
                        File.Copy(i.FullName, destPath + "\\" + i.Name, true);      //不是文件夹即复制文件，true表示可以覆盖同名文件
                    }
                }
            }
            catch (Exception e)
            {
                throw;
            }
        }


        public static void xxteaDirectory(string srcPath, string destPath, string key = "xProject")
        {
            try
            {
                if (!Directory.Exists(destPath))
                {
                    Directory.CreateDirectory(destPath);   //目标目录下不存在此文件夹即创建子文件夹
                }

                DirectoryInfo dir = new DirectoryInfo(srcPath);
                FileSystemInfo[] fileinfo = dir.GetFileSystemInfos();  //获取目录下（不包含子目录）的文件和子目录
                foreach (FileSystemInfo i in fileinfo)
                {
                    if (i is DirectoryInfo)     //判断是否文件夹
                    {
                        if (!Directory.Exists(destPath + "\\" + i.Name))
                        {
                            Directory.CreateDirectory(destPath + "\\" + i.Name);   //目标目录下不存在此文件夹即创建子文件夹
                        }
                        xxteaDirectory(i.FullName, destPath + "\\" + i.Name);    //递归调用复制子文件夹
                    }
                    else
                    {
                        Stream stream = File.Open(i.FullName, FileMode.Open, FileAccess.Read);
                        StreamReader reader = new StreamReader(stream);
                        string text = reader.ReadToEnd();
                        stream.Close();

                        string encrypt_data = Xxtea.XXTEA.EncryptToBase64String(text, key);
                        File.WriteAllText(destPath + "\\" + i.Name, encrypt_data);
                        //Byte[] encrypt_data = Xxtea.XXTEA.Encrypt(text, key);
                        //String decrypt_data = Xxtea.XXTEA.DecryptToString(encrypt_data, key);
                        //Debug.Assert(text == decrypt_data);
                        //File.WriteAllBytes(destPath + "\\" + i.Name, encrypt_data);
                        //File.Copy(i.FullName, destPath + "\\" + i.Name, true);      //不是文件夹即复制文件，true表示可以覆盖同名文件
                    }
                }
            }
            catch (Exception e)
            {
                throw;
            }
        }

        ///编码
        public static string EncodeBase64(string code, string code_type = "utf-8")
        {
            string encode = "";
            byte[] bytes = Encoding.GetEncoding(code_type).GetBytes(code);
            try
            {
                encode = Convert.ToBase64String(bytes);
            }
            catch
            {
                encode = code;
            }
            return encode;
        }
        ///解码
        public static string DecodeBase64(string code, string code_type = "utf-8")
        {
            string decode = "";
            byte[] bytes = Convert.FromBase64String(code);
            try
            {
                decode = Encoding.GetEncoding(code_type).GetString(bytes);
            }
            catch
            {
                decode = code;
            }
            return decode;
        }

        public static string randomkey()
        {
            char[] tmp = new char[8];
            int i;
            char x = (char)0;
            for (i = 0; i < 8; i++)
            {
                var seed = Guid.NewGuid().GetHashCode();
                System.Random r = new System.Random(seed);
                tmp[i] = (char)(r.Next() & 0xff);
                x ^= tmp[i];
            }
            if (x == 0)
            {
                tmp[0] |= (char)1;    // avoid 0
            }


            string s = new string(tmp);
            return s;
        }

        public static string dhsecret()
        {
            UInt32[] x = new UInt32[2];
            UInt32[] y = new UInt32[2];
            UInt64 xx = (UInt64)x[0] | (UInt64)x[1] << 32;

            return "";
        }

        public static string dhexchange(string s)
        {
            var sz = 0;
            return "";
        }
    }
}
//static int
//ldhexchange(lua_State* L)
//{
//    size_t sz = 0;
//    const uint8_t* x = (const uint8_t*)luaL_checklstring(L, 1, &sz);
//    if (sz != 8)
//    {
//        luaL_error(L, "Invalid dh uint64 key");
//    }
//    uint32_t xx[2];
//    xx[0] = x[0] | x[1] << 8 | x[2] << 16 | x[3] << 24;
//    xx[1] = x[4] | x[5] << 8 | x[6] << 16 | x[7] << 24;

//    uint64_t x64 = (uint64_t)xx[0] | (uint64_t)xx[1] << 32;
//    if (x64 == 0)
//        return luaL_error(L, "Can't be 0");

//    uint64_t r = powmodp(G, x64);
//    push64(L, r);
//    return 1;
//}