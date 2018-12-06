using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Postprocessing_via_Outlines : MonoBehaviour {

	[SerializeField]
	private Material postprocessMaterial;

	private Camera cam;
	// Use this for initialization
	void Start () {
		cam = GetComponent<Camera>();
		cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.DepthNormals;
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	private void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		Matrix4x4 viewClipToWorld = cam.cameraToWorldMatrix;

		postprocessMaterial.SetMatrix("_viewToWorld",viewClipToWorld);
		Graphics.Blit(src,dest,postprocessMaterial);
	}
}
