using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class DrawP : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    private void Update()
    {
        Debug.Log(Time.deltaTime);
    }

    public Color color = Color.red;

    public float thickness = 0.02f;

    private List<Vector3> points = new List<Vector3>();
    private List<Vector3> normals = new List<Vector3>();

    private List<int> splits = new List<int>();//分割索引

    static Material lineMaterial;
    static void CreateLineMaterial()
    {
        if (!lineMaterial)
        {
            // Unity has a built-in shader that is useful for drawing
            // simple colored things.
            var shader = Shader.Find("Hidden/Internal-Colored");
            lineMaterial = new Material(shader);
            lineMaterial.hideFlags = HideFlags.HideAndDontSave;
            // Turn on alpha blending
            lineMaterial.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
            lineMaterial.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
            // Turn backface culling off
            lineMaterial.SetInt("_Cull", (int)UnityEngine.Rendering.CullMode.Off);
            // Turn off depth writes
            lineMaterial.SetInt("_ZWrite", 0);
        }
    }

    public void OnRenderObject()
    {
        CreateLineMaterial();

        lineMaterial.SetPass(0);

        GL.PushMatrix();
        GL.MultMatrix(transform.localToWorldMatrix);

        GL.Begin(GL.LINES);

        int index = 0;
        for(int i=1; i<points.Count; i++)
        {
            if (index < splits.Count && i == splits[index])
            {
                index++;
                continue;
            }

            GL.Color(color);

            var from = points[i-1] + normals[i-1] * thickness;

            GL.Vertex3(from.x, from.y, from.z);

            var worldNormal = transform.TransformDirection(normals[i]);
            var to = points[i] + worldNormal * thickness;
            GL.Vertex3(to.x, to.y, to.z);
        }

        GL.End();
        GL.PopMatrix();
    }

    public void OnBeginDrag(PointerEventData eventData)
    {

    }

    public void OnDrag(PointerEventData eventData)
    {
        if (!eventData.pointerCurrentRaycast.isValid)
        {
            SplitPoints();
            return;
        }

        var localPosition = transform.InverseTransformPoint(eventData.pointerCurrentRaycast.worldPosition);
        points.Add(localPosition);
        var localNormal = transform.InverseTransformDirection(eventData.pointerCurrentRaycast.worldNormal);
        normals.Add(localNormal);
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        SplitPoints();
    }

    void SplitPoints()
    {
        if (splits.Count == 0 && points.Count != 0 || splits[splits.Count - 1] != points.Count)
            splits.Add(points.Count);
    }
}