using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Flz.UI
{
    public class SpineGhostGenerate : MonoBehaviour
    {
        //残影预制
        public GameObject ghost;
        //材质
        public Material material;
        //是否产生残影
        public bool isGenerate = false;
        //残影的生存时间  
        public float durationTime = 0.5f;
        //生成残影的间隔时间  
        public float intervalTime = 0.1f;
        //残影颜色
        public Color color;
        //父节点
        public Transform parent;
        //比例
        public Vector3 scale;


        private float generateCD = 0;


        // Update is called once per frame
        void Update()
        {
            if (isGenerate)
            {
                generateCD -= Time.deltaTime;
                if (generateCD <= 0)
                {
                    if (parent == null)
                    {
                        parent = transform.parent;
                    }

                    if (scale == null)
                    {
                        scale = new Vector3(1, 1, 1);
                    }

                    generateCD = intervalTime;
                    GameObject obj = Instantiate(ghost, parent, true);
                    obj.transform.localScale = scale;
                    obj.transform.position = transform.position;


                    MeshRenderer meshRenderer = obj.GetComponent<MeshRenderer>();
                    meshRenderer.sortingLayerName = GetComponent<MeshRenderer>().sortingLayerName;
                    meshRenderer.sortingOrder = GetComponent<MeshRenderer>().sortingOrder - 1;

                    MeshFilter meshFilter = obj.GetComponent<MeshFilter>();
                    meshFilter.mesh = GetComponent<MeshFilter>().mesh;

                    SpineGhost spineGhost = obj.GetComponent<SpineGhost>();
                    spineGhost.durationTime = durationTime;
                    spineGhost.color = color;

                    Texture texture = GetComponent<MeshRenderer>().material.GetTexture("_MainTex");
                    spineGhost.texture = texture;

                }
            }
        }
    }
}