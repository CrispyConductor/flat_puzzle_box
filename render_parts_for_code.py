import json
import argparse
import os
import subprocess

argparser = argparse.ArgumentParser(description='Renders the STLs from a JSON configuration needed for a given code.')
argparser.add_argument('json_config', type=str, help='path to JSON options file')
argparser.add_argument('code', type=str, help='code to generate STLs for')
argparser.add_argument('outdir', type=str, help='directory to output STLs in')
args = argparser.parse_args()

def value_to_scad(val):
    if val == None:
        return 'undef';
    elif isinstance(val, list):
        return '[' + ', '.join([ value_to_scad(v) for v in val ]) + ']'
    else:
        return json.dumps(val)

def make_scad_args(variables, outfile):
    args = [ 'openscad', '-o', outfile ]
    for varname, value in variables.items():
        args.append('-D')
        args.append(varname + '=' + value_to_scad(value))
    args.append('./main.scad')
    return args

with open(args.json_config, 'r') as f:
    params = json.loads(f.read())

primary_scale = params.get('primary_scale', '0123456789')
secondary_scale = params.get('secondary_scale', None)
slider_scales = params.get('slider_scales', [ 0, 0, 0, 0, 0 ])

assert len(args.code) == len(slider_scales), 'Code is wrong length'

def generate_stl(out_filename, part, slider_num = 0, position_num = 0):
    out_filename = os.path.join(args.outdir, out_filename)
    myvars = params.copy()
    myvars.update({
        'part': part,
        'slider_num': slider_num,
        'position_num': position_num
    })
    cmdargs = make_scad_args(myvars, out_filename)
    print(f'=== Making STL for part {part} slider {slider_num} position {position_num} ===')
    r = subprocess.run(cmdargs)
    assert r.returncode == 0, 'OpenSCAD rendering failed'

os.makedirs(args.outdir, exist_ok=True)

generate_stl('inner_box.stl', 'InnerBoxPrint')
generate_stl('outer_box_A.stl', 'OuterBoxPrint1')
generate_stl('outer_box_B.stl', 'OuterBoxPrint2')

generated_stls = set() # contains tuples of (scalenum, positionnum)

for slider_num, slider_scale in enumerate(slider_scales):
    scale = primary_scale if slider_scale == 0 else secondary_scale
    assert(scale)
    for posnum, poschar in enumerate(list(scale)):
        tup = (slider_scale, posnum)
        if tup in generated_stls:
            continue
        if args.code[slider_num] == poschar:
            generated_stls.add(tup)
            generate_stl(f'slider{slider_num}_{poschar}.stl', 'SliderPrint', slider_num, posnum)

