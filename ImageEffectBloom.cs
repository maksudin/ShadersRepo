using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageEffectBloom : ImageEffect
{
    private const int _thresholdPass = 0;

    protected override void OnRenderImage(RenderTexture src, RenderTexture dst) 
    {
        RenderTexture thresholdTex = 
                RenderTexture.GetTemporary(src.width, src.height, 0, src.format);
        Graphics.Blit(src, thresholdTex, material, _thresholdPass);
        RenderTexture.ReleaseTemporary(thresholdTex);

    }

}
