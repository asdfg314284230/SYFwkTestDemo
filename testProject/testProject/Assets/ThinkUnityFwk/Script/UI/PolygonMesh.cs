using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PolygonMesh : MonoBehaviour
{
    public GameObject[] pos;
    public string sortingLayerName;
    public int sortingOrder = 0;
    public Color color;
    /*
    creat a triangle by using Mesh 
     2016/11/21
                 ————Carl    
    */
    void Start()
    {
        creatPolygon();
    }

    public void refresh_polygon()
    {
        creatPolygon();
    }

    public List<GameObject> GetPosList()
    {
        List<GameObject> list = new List<GameObject>();

        for (int i = 0; i < pos.Length; i++)
        {
            list.Add(pos[i]);
        }
        return list;
    }

    private void creatPolygon()
    {
        Vector3[] vertices = new Vector3[pos.Length+1];
        vertices[0] = new Vector3(0, 0, 0);
        for (int i = 1; i < vertices.Length; i++)
        {
            vertices[i] = pos[i-1].transform.localPosition;
        }
      
        int[] indices = new int[pos.Length*3];
        int vertices_index = 0;
        for (int i = 1; i <= pos.Length; i++)
        {
            indices[vertices_index++] = 0;
            indices[vertices_index++] = i;

            if (i+1 < vertices.Length)
            {
                indices[vertices_index++] = i + 1;
            }
            else
            {
                indices[vertices_index++] = 1;
            }
            
        }
        Color[] colors = new Color[vertices.Length];
        for (int i = 0; i < colors.Length; i++)
        {
            colors[i] = color;
        }

        Mesh mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.triangles = indices;
        mesh.colors = colors;
        MeshRenderer meshRenderer = GetComponent<MeshRenderer>();
        if(sortingLayerName != null)
        {
            meshRenderer.sortingLayerName = sortingLayerName;
            meshRenderer.sortingOrder = sortingOrder;
        }
        MeshFilter meshfilter = GetComponent<MeshFilter>();
        meshfilter.mesh = mesh;
    }

}