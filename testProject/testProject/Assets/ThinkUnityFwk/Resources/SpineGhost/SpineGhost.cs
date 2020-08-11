using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Flz.UI
{
    public class SpineGhost : MonoBehaviour
    {

        //残影的生存时间  
        float start_time = 0;
        [HideInInspector]
        public float durationTime = 1;
        [HideInInspector]
        public Texture texture;
        [HideInInspector]
        public Color color;

        // Update is called once per frame
        void Update()
        {
            start_time += Time.deltaTime;
            Material material = GetComponent<MeshRenderer>().material;
            if (material.HasProperty("_Color"))
            {
                float a = (durationTime - start_time) / durationTime;
                color.a = a;
                material.SetColor("_Color", color);
                //material.SetColor("_Color",  new Color(71/255f,52/255f,156/255f, a));
            }

            material.SetTexture("_MainTex", texture);

            if (start_time >= durationTime)
            {
                Destroy(gameObject);
            }

        }
    }
}