using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class SaveTank : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}

	public Texture2D r1;
	public Texture2D r2;
	public RenderTexture rt;
	public Shader sb;
	private void Update()
	{
		if (Input.GetKey(KeyCode.K))
		{
			DumpRenderTexture(rt,Application.dataPath+"Tank.png");
			Debug.Log("OK");
		}
	}
	
	public static void DumpRenderTexture(RenderTexture rt, string pngOutPath)
	{
		var oldRT = RenderTexture.active;
 
		var tex = new Texture2D(rt.width, rt.height);
		RenderTexture.active = rt;
		tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
		tex.Apply();
		File.WriteAllBytes(pngOutPath, tex.EncodeToPNG());
		RenderTexture.active = oldRT;
	}

}
