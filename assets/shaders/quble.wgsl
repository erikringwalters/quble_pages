#import bevy_pbr::{
    mesh_functions,
    view_transformations::position_world_to_clip,
    pbr_fragment::pbr_input_from_standard_material,
    pbr_functions::alpha_discard,
    forward_io::{VertexOutput, FragmentOutput},
    pbr_functions::{apply_pbr_lighting, main_pass_post_lighting_processing},
}

#define VERTEX_OUTPUT_INSTANCE_INDEX

struct QubleExtension{
    roughness: f32,
    // 16-byte alignment for webgl2
    _padding_8b: f32,
    _padding_12b: f32,
    _padding_16b: f32,
}

@group(#{MATERIAL_BIND_GROUP}) @binding(100)
var<uniform> quble_extension: QubleExtension;

struct Vertex {
    @builtin(instance_index) instance_index: u32,
    @location(0) position: vec3<f32>,
};

@fragment
fn fragment(
    in: VertexOutput,
    @builtin(front_facing) is_front: bool,
) -> FragmentOutput {
    let tag: u32 = mesh_functions::get_tag(in.instance_index);

    // RED
    // X_XXX_RRX_XXX
    var r: u32 = (tag % 1000000) / 10000;
    var rf: f32;
    switch r {
    case 99: {
         rf = 1.0;
     }
    default: {
         rf = f32(r) / 100.;
     }
    }

    // GREEN
    // X_XXX_XXG_GXX
    let g: u32 = (tag % 10000) / 100;
    var gf: f32;
    switch g {
    case 99: {
        gf = 1.0;
    }
    default: {
        gf = f32(g) / 100.;
    }
    }

    // BLUE
    // X_XXX_XXX_XBB
    let b: u32 = tag % 100;
    var bf: f32;
    switch b {
    case 99: {
        bf = 1.0;
    }
    default: {
        bf = f32(b) / 100.;
    }
    }

    // Regular StandardMaterial stuff
    var out: FragmentOutput;
    var pbr_input = pbr_input_from_standard_material(in, is_front);
    pbr_input.material.base_color = vec4<f32>(rf, gf, bf, 1.);
    pbr_input.material.base_color = alpha_discard(pbr_input.material, pbr_input.material.base_color);
    pbr_input.material.perceptual_roughness = quble_extension.roughness;
    out.color = apply_pbr_lighting(pbr_input);
    out.color = main_pass_post_lighting_processing(pbr_input, out.color);

    return out;
}

