﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GodRayPostEffect : PostEffectBase {
//高亮部分提取阈值
    public Color colorThreshold = Color.gray;
    //体积光颜色
    public Color lightColor = Color.white;
    //光强度
    [Range(0.0f, 20.0f)]
    public float lightFactor = 0.5f;
    //径向模糊uv采样偏移值
    [Range(0.0f, 10.0f)]
    public float samplerScale = 1;
    //Blur迭代次数
    [Range(1,3)]
    public int blurIteration = 2;
    //降低分辨率倍率
    [Range(0, 3)]
    public int downSample = 1;
    //光源位置
    public Transform lightTransform;
    //产生体积光的范围
    [Range(0.0f, 5.0f)]
    public float lightRadius = 2.0f;
    //提取高亮结果Pow倍率，适当降低颜色过亮的情况
    [Range(1.0f, 4.0f)]
    public float lightPowFactor = 3.0f; 
 
    private Camera targetCamera = null;
 
    void Awake()
    {
        targetCamera = GetComponent<Camera>();
    }
 
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_Material && targetCamera)
        {
            int rtWidth = source.width >> downSample;
            int rtHeight = source.height >> downSample;
            //RT分辨率按照downSameple降低
            RenderTexture temp1 = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);
 
            //计算光源位置从世界空间转化到视口空间
            Vector3 viewPortLightPos = lightTransform == null ? new Vector3(.5f, .5f, 0) : targetCamera.WorldToViewportPoint(lightTransform.position);
          
            //将shader变量改为PropertyId，以及将float放在Vector中一起传递给Material会更省一些，but，我懒
            _Material.SetVector("_ColorThreshold", colorThreshold);
            _Material.SetVector("_ViewPortLightPos", new Vector4(viewPortLightPos.x, viewPortLightPos.y, viewPortLightPos.z, 0));
            _Material.SetFloat("_LightRadius", lightRadius);
            _Material.SetFloat("_PowFactor", lightPowFactor);
            //根据阈值提取高亮部分,使用pass0进行高亮提取，比Bloom多一步计算光源距离剔除光源范围外的部分
            Graphics.Blit(source, temp1, _Material, 0);
 
            _Material.SetVector("_ViewPortLightPos", new Vector4(viewPortLightPos.x, viewPortLightPos.y, viewPortLightPos.z, 0));
            _Material.SetFloat("_LightRadius", lightRadius);
            //径向模糊的采样uv偏移值
            float samplerOffset = samplerScale / source.width;
            //径向模糊，两次一组，迭代进行
            for (int i = 0; i < blurIteration; i++)
            {
                RenderTexture temp2 = RenderTexture.GetTemporary(rtWidth, rtHeight, 0, source.format);
                float offset = samplerOffset * (i * 2 + 1);
                _Material.SetVector("_offsets", new Vector4(offset, offset, 0, 0));
                Graphics.Blit(temp1, temp2, _Material, 1);
 
                offset = samplerOffset * (i * 2 + 2);
                _Material.SetVector("_offsets", new Vector4(offset, offset, 0, 0));
                Graphics.Blit(temp2, temp1, _Material, 1);
                RenderTexture.ReleaseTemporary(temp2);
            }
           
            _Material.SetTexture("_BlurTex", temp1);
            _Material.SetVector("_LightColor", lightColor);
            _Material.SetFloat("_LightFactor", lightFactor);
            //最终混合，将体积光径向模糊图与原始图片混合，pass2
            Graphics.Blit(source, destination, _Material, 2);
 
            //释放申请的RT
            RenderTexture.ReleaseTemporary(temp1);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }


	
}
