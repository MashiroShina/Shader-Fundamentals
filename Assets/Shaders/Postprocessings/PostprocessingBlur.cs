using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostprocessingBlur : MonoBehaviour {

	[SerializeField]
	private Material postprocessMaterial;

	//method which is automatically called by unity after the camera is done rendering
	void OnRenderImage(RenderTexture source, RenderTexture destination){
		//Graphics.Blit(source,destination,postprocessMaterial);
		var temporaryTexture = RenderTexture.GetTemporary(source.width, source.height);
		Graphics.Blit(source,temporaryTexture,postprocessMaterial,0);
		Graphics.Blit(temporaryTexture,destination,postprocessMaterial,1);
		RenderTexture.ReleaseTemporary(temporaryTexture);
		
//		//draws the pixels from the source texture to the destination texture
//		var temporaryTexture = RenderTexture.GetTemporary(source.width, source.height);
//		Graphics.Blit(source, temporaryTexture, postprocessMaterial, 0);
//		Graphics.Blit(temporaryTexture, destination, postprocessMaterial, 1);
//		RenderTexture.ReleaseTemporary(temporaryTexture);
	}
}
