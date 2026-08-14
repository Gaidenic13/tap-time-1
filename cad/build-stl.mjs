import fs from 'node:fs/promises';
import path from 'node:path';
import modeling from '@jscad/modeling';
import { serialize } from '@jscad/stl-serializer';

const { primitives, booleans, transforms, extrusions } = modeling;

const { roundedRectangle, cylinder, cuboid } = primitives;
const { subtract, union } = booleans;
const { translate } = transforms;
const { extrudeLinear } = extrusions;
const out = new URL('./output/', import.meta.url);

const move = (xyz, shape) => translate(xyz, shape);
const pegPositions = [[-22,-22],[-22,22],[22,-22],[22,22]];
const roundedPrism = (size, radius, centerZ) => move([0,0,centerZ - size[2] / 2], extrudeLinear({ height:size[2] }, roundedRectangle({ size:[size[0],size[1]], roundRadius:radius, segments:48 })));

const outer = roundedPrism([60,60,8], 8, 4);
const inner = roundedPrism([55.2,55.2,6.2], 5.6, 5.1);
const tagPocket = cylinder({ radius:12.75, height:1.25, segments:72, center:[0,0,1.425] });
const sockets = pegPositions.map(([x,y]) => cylinder({ radius:1.725, height:6.3, segments:36, center:[x,y,4.85] }));
const face = subtract(outer, inner, tagPocket, ...sockets);

const plateBase = roundedPrism([54.6,54.6,4], 5.5, 2);
const pegs = pegPositions.map(([x,y]) => cylinder({ radius:1.5, height:3.1, segments:36, center:[x,y,5.55] }));
let plate = union(plateBase, ...pegs);
const screwHoles = [-16,16].flatMap((y) => [
  cylinder({ radius:2.1, height:4.4, segments:48, center:[0,y,2] }),
  cylinder({ radiusStart:2.1, radiusEnd:4.1, height:2.2, segments:48, center:[0,y,3.1] })
]);
const notch = cuboid({ size:[14,8,5], center:[0,-27,2.5] });
plate = subtract(plate, ...screwHoles, notch);

await fs.mkdir(out, { recursive:true });
for (const [name, solid] of [['taptime-face-shell.stl', face], ['taptime-wall-plate.stl', plate]]) {
  const data = serialize({ binary:false }, solid);
  await fs.writeFile(new URL(name, out), data.join(''));
}
console.log(`Created printable STL files in ${path.resolve('cad/output')}`);
