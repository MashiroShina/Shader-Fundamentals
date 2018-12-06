using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Postprocessing : MonoBehaviour
{
	[SerializeField]
	private Material postprocessMaterial;
	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		
		Graphics.Blit(source,destination,postprocessMaterial);
	}
}
