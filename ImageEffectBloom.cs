using UnityEngine;

public class ImageEffectBloom : ImageEffect
{
    private const int thresholdPass = 0;
    private const int horizontalPass = 1;
    private const int verticalPass = 2;
    private const int bloomPass = 3;


	protected override void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
        // Беру яркие объекты
        RenderTexture thresholdTex = 
	        RenderTexture.GetTemporary(src.width, src.height, 0, src.format);

        Graphics.Blit(src, thresholdTex, material, thresholdPass);

        RenderTexture blurredTex =
            RenderTexture.GetTemporary(src.width, src.height, 0, src.format);

        material.SetInt("_kSize", 21);
        material.SetFloat("_Spread", 5.0f);


        RenderTexture temp =
            RenderTexture.GetTemporary(src.width, src.height, 0, src.format);

        Graphics.Blit(thresholdTex, temp, material, horizontalPass);
        Graphics.Blit(temp, blurredTex, material, verticalPass);

        RenderTexture.ReleaseTemporary(thresholdTex);
        RenderTexture.ReleaseTemporary(temp);

        Graphics.Blit(blurredTex, dst, material);

        //material.SetTexture("_SrcTex", src);



        //RenderTexture.ReleaseTemporary(blurredTex);
    }

}
