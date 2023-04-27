using UnityEngine;

[CreateAssetMenu(menuName = "Image Effects Ultra/Fisheye", order = 1)]
public class FisheyeEffect : BaseEffect
{
    [SerializeField] private float pow;

    public override void OnCreate()
    {
        baseMaterial = new Material(Resources.Load<Shader>("Unlit/Fisheye"));
        baseMaterial.SetFloat("_BarrelPower", pow);
    }

    public override void Render(RenderTexture src, RenderTexture dst) =>
        Graphics.Blit(src, dst, baseMaterial);
}
