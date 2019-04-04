using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GodRayVolumeHelper : MonoBehaviour {

	public Transform lightTransform;
	private Material godRayVolumeMateril;

	private void Awake()
	{
		var renderer = GetComponentInChildren<Renderer>();
		foreach (var mat in renderer.sharedMaterials)
		{
			if (mat.shader.name.Contains("VolumeShadow"))
				godRayVolumeMateril = mat;

		}
	}

	private void Update()
	{
		if (lightTransform == null || godRayVolumeMateril == null)
		{
			return;
		}
		float distance = Vector3.Distance(lightTransform.position, transform.position);
		godRayVolumeMateril.SetVector("_WorldLightPos", 
			new Vector4(lightTransform.position.x, lightTransform.position.y, lightTransform.position.z, distance));
	}
}
