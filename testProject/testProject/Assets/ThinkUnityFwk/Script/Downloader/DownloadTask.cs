using BestHTTP;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public sealed class DownloadTask //: MonoBehaviour
{
    /// <summary>
    /// The url of the resource to download
    /// </summary>
    public string URL = null;//"F:/P3 Project Art Source/P3项目写真视频/约会5.mp4";//"http://uk3.testmy.net/dl-102400";
    public string dir = null;//"G:/game_girl_3";//"TODO!";
    public string filename = null;//"约会5.mp4";

    public Action<string, string> finish_func;
    public Action<float> process_func;
    public Action<string> error_func;

    #region Private Fields

    /// <summary>
    /// Cached request to be able to abort it
    /// </summary>
    HTTPRequest request;

    /// <summary>
    /// Debug status of the request
    /// </summary>
    string status = string.Empty;

    /// <summary>
    /// Download(processing) progress. Its range is between [0..1]
    /// </summary>
    float progress;

    /// <summary>
    /// The fragment size that we will set to the request
    /// </summary>
    int fragmentSize = 10 * 1024;//HTTPResponse.MinBufferSize; 200 * 1024

    int downloadProgress = 0;
    int downloadLength = 0;

    #endregion

    #region Unity Events


    void OnDestroy()
    {
        // Stop the download if we are leaving this example
        if (request != null && request.State < HTTPRequestStates.Finished)
        {
            request.OnProgress = null;
            request.Callback = null;
            request.Abort();
        }
    }

    #endregion

    #region Private Helper Functions

    // Calling this function again when the "DownloadProgress" key in the PlayerPrefs present will
    //	continue the download
    public void StreamLargeFile()
    {
        if (Directory.Exists(dir) == false)//如果不存在就创建file文件夹
        {
            Directory.CreateDirectory(dir);
        }

        if (File.Exists(dir + "/" + filename + ".temp"))
        {
            File.Delete(dir + "/" + filename + ".temp");
        }
        

        request = new HTTPRequest(new Uri(URL), (req, resp) =>
        {
            switch (req.State)
            {
                // The request is currently processed. With UseStreaming == true, we can get the streamed fragments here
                case HTTPRequestStates.Processing:
                    if (downloadLength == 0 )
                    {
                        string value = resp.GetFirstHeaderValue("content-length");
                        if (!string.IsNullOrEmpty(value))
                        {
                            downloadLength = int.Parse(value);
                        }
                    }
                    
                    // Get the fragments, and save them
                    ProcessFragments(resp.GetStreamedFragments());

                    status = "Processing";
                    break;

                // The request finished without any problem.
                case HTTPRequestStates.Finished:
                    // Set the DownloadLength, so we can display the progress
                    if (downloadLength == 0)
                    {
                        string value = resp.GetFirstHeaderValue("content-length");
                        if (!string.IsNullOrEmpty(value))
                        {
                            downloadLength = int.Parse(value);
                        }
                    }
                    if (resp.IsSuccess)
                    {
                        // Save any remaining fragments
                        ProcessFragments(resp.GetStreamedFragments());

                        // Completely finished
                        if (resp.IsStreamingFinished)
                        {
                            status = "Streaming finished!";
                            request = null;
                            File.Delete(dir + "/" + filename);
                            File.Move(dir + "/" + filename + ".temp", dir + "/" + filename);
                            if (!Launcher_param.ignore_down_verify && resp.Headers.ContainsKey("content-md5")) 
                            {
                                string content_md5 = resp.Headers["content-md5"][0];
                                string md5 = SYFwk.Core.Extension.EncodeMd5File_base64(dir + "/" + filename, true);
                                if (md5 != content_md5)
                                {
                                    if (error_func != null)
                                    {
                                        File.Delete(dir + "/" + filename);
                                        error_func("Error");
                                    }
                                }

                            }
                        }
                        else
                            status = "Processing";
                    }
                    else
                    {
                        status = string.Format("Request finished Successfully, but the server sent an error. Status Code: {0}-{1} Message: {2}",
                                                        resp.StatusCode,
                                                        resp.Message,
                                                        resp.DataAsText);
                        Debug.LogWarning(status);

                        request = null;
                    }
                    Debug.Log("DownLoad Finished");
                    if (finish_func != null)
                    {
                        finish_func(status, dir + "/" + filename);
                    }
                    break;

                // The request finished with an unexpected error. The request's Exception property may contain more info about the error.
                case HTTPRequestStates.Error:
                    status = "Request Finished with Error! " + (req.Exception != null ? (req.Exception.Message + "\n" + req.Exception.StackTrace) : "No Exception");
                    Debug.LogWarning(status);

                    request = null;
                    if (error_func != null)
                    {
                        error_func("Error");
                    }
                    break;

                // The request aborted, initiated by the user.
                case HTTPRequestStates.Aborted:
                    status = "Request Aborted!";
                    Debug.LogWarning(status);

                    request = null;
                    if (error_func != null)
                    {
                        error_func("Aborted");
                    }
                    break;

                // Connecting to the server is timed out.
                case HTTPRequestStates.ConnectionTimedOut:
                    status = "Connection Timed Out!";
                    Debug.LogWarning(status);

                    request = null;
                    if (error_func != null)
                    {
                        error_func("ConnectionTimedOut");
                    }
                    break;

                // The request didn't finished in the given time.
                case HTTPRequestStates.TimedOut:
                    status = "Processing the request Timed Out!";
                    Debug.LogWarning(status);

                    request = null;
                    
                    if (error_func != null)
                    {
                        error_func("TimedOut");
                    }
                    break;
            }
        });


#if !BESTHTTP_DISABLE_CACHING && (!UNITY_WEBGL || UNITY_EDITOR)
        // If we are writing our own file set it true(disable), so don't duplicate it on the file-system
        request.DisableCache = true;
#endif

        // We want to access the downloaded bytes while we are still downloading
        request.UseStreaming = true;

        // Set a reasonable high fragment size. Here it is 5 megabytes.
        request.StreamFragmentSize = fragmentSize;

        // Start Processing the request
        request.Send();
    }

    /// <summary>
    /// In this function we can do whatever we want with the downloaded bytes. In this sample we will do nothing, just set the metadata to display progress.
    /// </summary>
    void ProcessFragments(List<byte[]> fragments)
    {
        if (fragments != null && fragments.Count > 0)
        {
            using (System.IO.FileStream fs = new System.IO.FileStream(System.IO.Path.Combine(dir, filename + ".temp"), System.IO.FileMode.Append))
                for (int i = 0; i < fragments.Count; ++i)
                    fs.Write(fragments[i], 0, fragments[i].Length);

            for (int i = 0; i < fragments.Count; ++i)
            {
                // Save how many bytes we wrote successfully
                int downloaded = downloadProgress + fragments[i].Length;
                downloadProgress = downloaded;
            }

            // Set the progress to the actually processed bytes
            progress = downloadProgress / (float)downloadLength;
            if (process_func != null)
            {
                process_func(progress);
            }
        }
    }

    public void Abort()
    {   
        //if (request != null)
        //{
            request.Abort();
        //}
    }
    #endregion
}
