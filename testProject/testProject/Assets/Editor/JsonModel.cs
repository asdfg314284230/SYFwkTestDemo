using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JsonModel  {

    /// <summary>
    /// 
    /// </summary>
    public string id { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string type { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public string @short { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public Cert cert { get; set; }


    public class Cert
    {
        /// <summary>
        /// 
        /// </summary>
        public Icon icon { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public Binary binary { get; set; }
    }

    public class Icon
    {
        /// <summary>
        /// 
        /// </summary>
        public string key { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string token { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string upload_url { get; set; }
    }

    public class Binary
    {
        /// <summary>
        /// 
        /// </summary>
        public string key { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string token { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string upload_url { get; set; }
    }

}
