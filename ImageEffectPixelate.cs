using UnityEngine;

namespace Assets.Shaders.ShadersRepo
{
    public class ImageEffectPixelate : ImageEffect
    {
        [SerializeField] private int _pixelSize = 2;

        protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            int width = source.width / _pixelSize;    
            int height = source.height / _pixelSize;

            RenderTexture temp = RenderTexture.GetTemporary(width, height, 0, source.format);
            temp.filterMode = FilterMode.Point;

            Graphics.Blit(source, temp);
            Graphics.Blit(temp, destination, material);
        }
    }
}