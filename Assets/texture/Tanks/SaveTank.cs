using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class SaveTank : MonoBehaviour {
	public Texture2D r1;
	public Texture2D r2;
	public RenderTexture rt;
	public Shader sb;
	public Material mt;

	private void Update()
	{
		if (Input.GetKeyDown(KeyCode.P))
		{
			Shader.DisableKeyword("_HAVECOLOR_ON");
			Shader.DisableKeyword("_HAVECOLOR_OFF");
			Shader.DisableKeyword("_CLIPPING_NULL");
			Shader.DisableKeyword("_CLIPPING_OFF");
			Shader.EnableKeyword("_CLIPPING_ON");
			Shader.EnableKeyword("_HAVECOLOR_NULL");
		}
		if (Input.GetKeyDown(KeyCode.O))
		{
			Shader.DisableKeyword("_CLIPPING_OFF");
			Shader.DisableKeyword("_CLIPPING_ON");
			Shader.DisableKeyword("_HAVECOLOR_OFF");
			Shader.DisableKeyword("_HAVECOLOR_NULL");
			Shader.EnableKeyword("_CLIPPING_NULL");
			Shader.EnableKeyword("_HAVECOLOR_ON");
		}
		if (Input.GetKeyDown(KeyCode.I))
		{
			Shader.DisableKeyword("_CLIPPING_OFF");
			Shader.DisableKeyword("_CLIPPING_ON");
			Shader.EnableKeyword("_HAVECOLOR_OFF");
			Shader.DisableKeyword("_HAVECOLOR_NULL");
			Shader.EnableKeyword("_CLIPPING_NULL");
			Shader.DisableKeyword("_HAVECOLOR_ON");
		}
		if (Input.GetKeyDown(KeyCode.U))
		{
			Shader.EnableKeyword("_CLIPPING_OFF");
			Shader.DisableKeyword("_CLIPPING_ON");
			Shader.DisableKeyword("_HAVECOLOR_OFF");
			Shader.DisableKeyword("_HAVECOLOR_NULL");
			Shader.DisableKeyword("_CLIPPING_NULL");
			Shader.DisableKeyword("_HAVECOLOR_ON");
		}
		if (Input.GetKey(KeyCode.K))
		{
			DumpRenderTexture(rt,Application.dataPath+"Tank.png");
			Debug.Log("OK");
		}

		if (Input.GetKey(KeyCode.G))
		{
			//Debug.Log(GetFilePath());
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
	private List<Texture> cars = new List<Texture>();
//	private string[] GetFilePath()
//	{
//		string[] path = { null };
//		string[] strs = StandaloneFileBrowser.OpenFilePanel("打开用户数据文件", "%HOMEDRIVE/Desktop%", "", false);
//		if (Application.platform == RuntimePlatform.WindowsPlayer || Application.platform == RuntimePlatform.WindowsEditor)
//		{
//			if (strs.Length > 0)
//			{
//				path = strs;
//			}
//			else
//			{
//				Debug.Log("用户取消选择");
//			}
//		}
//		else if (Application.platform == RuntimePlatform.OSXPlayer || Application.platform == RuntimePlatform.OSXEditor)
//		{
//			if (strs.Length > 0)
//			{
//				path = strs;
//			}
//			else
//			{
//				Debug.Log("用户取消选择");
//			}
//		}
//		return path;
//	}


}
