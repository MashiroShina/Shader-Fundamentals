using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))][ExecuteInEditMode]
public class CreatePlane : MonoBehaviour {
	public int xSize, zSize;
	private Vector3[] vertices;
	private Mesh mesh;
	// Use this for initialization
	private void Awake()
	{
		Generate();
	}
	private void Generate () {
		
		GetComponent<MeshFilter>().mesh = mesh = new Mesh();
		mesh.name = "Procedural Grid";
		vertices = new Vector3[(xSize + 1) * (zSize + 1)];
		Vector2[] uv = new Vector2[vertices.Length];
		for (int i = 0, z = 0; z <= zSize; z++) {
			for (int x = 0; x <= xSize; x++, i++) {
				vertices[i] = new Vector3(x/5f, 0,z/5f);
				uv[i] = new Vector2((float)x / xSize, (float)z / zSize);
			}
		}
		mesh.vertices = vertices;
		int[] triangles = new int[xSize * zSize * 6];
		for (int ti = 0, vi = 0, y = 0; y < zSize; y++, vi++) {
			for (int x = 0; x < xSize; x++, ti += 6, vi++) {
				triangles[ti] = vi;
				triangles[ti + 3] = triangles[ti + 2] = vi + 1;
				triangles[ti + 4] = triangles[ti + 1] = vi + xSize + 1;
				triangles[ti + 5] = vi + xSize + 2;
			}
		}
		mesh.triangles = triangles;
		mesh.RecalculateNormals();
		mesh.uv = uv;
	}
	private void OnDrawGizmos () {
		if (vertices==null)
		{
			return;
		}
		Gizmos.color = Color.black;
		for (int i = 0; i < vertices.Length; i++) {
			Gizmos.DrawSphere(vertices[i], 0.1f);
		}
	}
}
