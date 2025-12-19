struct VS_Output {
    float4 position : SV_POSITION;
}

struct Param_Block {
    float2* positions;
};

struct Push_Consts {
    Param_Block* params;
};

[vk::push_constant]
Push_Consts gpc;

[shader("vertex")]
VS_Output main(uint vertex_id: SV_VertexID) {
    VS_Output output;
    output.position = float4(gpc.params.positions[vertex_id], 0., 1.);
    return output;
}