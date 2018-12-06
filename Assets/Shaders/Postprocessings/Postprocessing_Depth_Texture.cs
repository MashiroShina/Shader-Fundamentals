using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Postprocessing_Depth_Texture : MonoBehaviour
{
	[SerializeField]
	private Material postprocessMaterial;
	[SerializeField]
	private float waveSpeed;
	[SerializeField]
	private bool waveActive;
	// Use this for initialization
	void Start ()
	{
		transform.Find("Depth").gameObject.SetActive(true);
		
		Camera cam = GetComponent<Camera>();
		cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.Depth;
	}
	
	private float waveDistance;
	void Update () {
		if(waveActive){
			waveDistance = waveDistance + waveSpeed * Time.deltaTime;
		} else {
			waveDistance = 0;
		}
	}

	private void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		postprocessMaterial.SetFloat("_WaveDistance", waveDistance);
		Graphics.Blit(src,dest,postprocessMaterial);
	}
	
}
