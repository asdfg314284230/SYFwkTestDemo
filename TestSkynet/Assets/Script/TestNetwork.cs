using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System;
using System.Threading;

public class TestNetwork : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField]
    Text info;
    [SerializeField]
    Text msgInfo;
    [SerializeField]
    Button msg_btn;
    [SerializeField]
    Button connect_btn;

    Socket server;
    Thread threadReceive;

    void Start()
    {
        msg_btn.onClick.AddListener(BtnMsg);

        connect_btn.onClick.AddListener(() => {
            // 开启Sokcet
            server = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

            // 设置ip地址
            IPAddress ip = IPAddress.Parse("106.55.152.65");

            //// 设置端口
            //IPEndPoint ipPoint = new IPEndPoint(ip, 8001);

            //// 绑定了端口
            //server.Bind(ipPoint);

            // 连接服务器
            server.Connect(ip, 8001);

            Debug.Log("连接服务器成功");


            //开启一个新的线程不停的接收服务器发送消息的线程
            threadReceive = new Thread(new ThreadStart(Receive));
            //设置为后台线程
            threadReceive.IsBackground = true;
            threadReceive.Start();

        });


    }

    // Update is called once per frame
    void Update()
    {
        
    }


    // 发送消息
    void BtnMsg()
    {

    }


    /// <summary>
    /// 接口服务器发送的消息
    /// </summary>
    private void Receive()
    {
        try
        {
            while (true)
            {
                byte[] buffer = new byte[2048];
                //实际接收到的字节数
                int r = server.Receive(buffer);
                if (r == 0)
                {
                    break;
                }
                else
                {
                    //判断发送的数据的类型
                    if (buffer[0] == 0)//表示发送的是文字消息
                    {
                        string str = Encoding.Default.GetString(buffer, 1, r - 1);
                        //this.txt_Log.Invoke(receiveCallBack, "接收远程服务器:" + socketSend.RemoteEndPoint + "发送的消息:" + str);
                    }
                    ////表示发送的是文件
                    //if (buffer[0] == 1)
                    //{
                    //    SaveFileDialog sfd = new SaveFileDialog();
                    //    sfd.InitialDirectory = @"";
                    //    sfd.Title = "请选择要保存的文件";
                    //    sfd.Filter = "所有文件|*.*";
                    //    sfd.ShowDialog(this);

                    //    string strPath = sfd.FileName;
                    //    using (FileStream fsWrite = new FileStream(strPath, FileMode.OpenOrCreate, FileAccess.Write))
                    //    {
                    //        fsWrite.Write(buffer, 1, r - 1);
                    //    }

                    //    MessageBox.Show("保存文件成功");
                    //}
                }


            }
        }
        catch (Exception ex)
        {
            //MessageBox.Show("接收服务端发送的消息出错:" + ex.ToString());
        }
    }


}
