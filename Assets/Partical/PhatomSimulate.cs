using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct PARTICLE
{
    public Vector3 pos; //size = 4*3
    public Vector3 vel;
    public Vector3 acc;

    public const int dataLen = 36;
}
public class PhatomSimulate : MonoBehaviour
{
    public const int MAX_PARTICLE = 1000000;

    public PARTICLE[] particles = new PARTICLE[MAX_PARTICLE];
    public int particleCount = 0;

    public ComputeBuffer pBuffer;
    public Material mat;
    public ComputeShader comps;

    public void Draw() {
        mat.SetBuffer("_Buffer", pBuffer);
        mat.SetPass(0);
        Graphics.DrawProcedural(MeshTopology.Quads, particleCount * 24, 1);
    }
    private void OnPostRender()
    {
        Draw();
    }
    private void Start()
    {
        pBuffer = new ComputeBuffer(MAX_PARTICLE, sizeof(float)*3*3, ComputeBufferType.Default);
    }
    private void Update()
    {
        if (Input.GetKey(KeyCode.F))
        {
            PARTICLE p = new PARTICLE();
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            p.pos = ray.GetPoint(2);
            p.vel = ray.direction * 200;
            p.acc = Vector3.zero;
            AddParticle(p);
        }
        if (Input.GetKey(KeyCode.Space))
        {
            if (particleCount>0)
            {
                comps.SetBuffer(comps.FindKernel("UpdatePoss"), "_Buffer", pBuffer);
                comps.SetBuffer(comps.FindKernel("UpdateVel"), "_Buffer", pBuffer);
                comps.SetBuffer(comps.FindKernel("ClearAcc"), "_Buffer", pBuffer);
                comps.SetBuffer(comps.FindKernel("AddGravity"), "_Buffer", pBuffer);

                comps.Dispatch(comps.FindKernel("UpdatePoss"), (particleCount + 31) / 32, 1, 1);
                comps.Dispatch(comps.FindKernel("UpdateVel"), (particleCount + 31) / 32, 1, 1);
                comps.Dispatch(comps.FindKernel("ClearAcc"), (particleCount + 31) / 32, 1, 1);
                comps.Dispatch(comps.FindKernel("AddGravity"), (particleCount + 31) / 32, 1, 1);
            }
        }
    }
    private void OnDestroy()
    {
        if (pBuffer!=null)
        {
            pBuffer.Release();
            pBuffer = null;
        }
    }
    void AddParticle(PARTICLE p) {
        if (particleCount==MAX_PARTICLE)
        {
            return;
        }
        pBuffer.GetData(particles, 0, 0, particleCount);
        particles[particleCount++] = p;
        pBuffer.SetData(particles);
    }

}
