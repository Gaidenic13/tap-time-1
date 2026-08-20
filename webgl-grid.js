import * as THREE from './vendor/three.module.min.js';

// Full-bleed perspective grid field + the TapTime case assembly rendered in-scene.
// Motion mirrors the hero prototype: 10deg/s auto-rotate from a -32deg/58deg orbit,
// slow breathing pulse, pointer-reactive drift. DOM model-viewer remains the fallback.

// Minimal ASCII STL parser — the CAD pipeline emits "solid JSCAD" ASCII files.
const parseSTL = (text) => {
  const positions = [];
  const re = /vertex\s+([\d.eE+-]+)\s+([\d.eE+-]+)\s+([\d.eE+-]+)/g;
  let m;
  while ((m = re.exec(text))) positions.push(+m[1], +m[2], +m[3]);
  const geometry = new THREE.BufferGeometry();
  geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
  geometry.computeVertexNormals();
  return geometry;
};

const initWebGL = () => {
  const container = document.getElementById('webgl-container');
  if (!container) return;

  let renderer;
  try {
    renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
  } catch {
    return; // no WebGL — DOM fallback remains
  }

  const scene = new THREE.Scene();
  scene.fog = new THREE.FogExp2(0xf5f3fb, 0.0015);

  const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 2000);
  camera.position.z = 200;
  camera.position.y = 50;
  camera.lookAt(0, 0, 0);

  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  container.appendChild(renderer.domElement);

  const EXTENT = 1200;
  const STEP = 40;
  const positions = [];
  for (let i = -EXTENT; i <= EXTENT; i += STEP) {
    positions.push(-EXTENT, 0, i, EXTENT, 0, i);
    positions.push(i, 0, -EXTENT, i, 0, EXTENT);
  }
  const gridGeometry = new THREE.BufferGeometry();
  gridGeometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
  const gridMaterial = new THREE.LineBasicMaterial({ color: 0x5b4bdb, transparent: true, opacity: 0.22 });
  const grid = new THREE.LineSegments(gridGeometry, gridMaterial);
  grid.position.y = -40;
  scene.add(grid);

  // ambient + key + rim
  scene.add(new THREE.AmbientLight(0xefeff5, 1.35));
  const key = new THREE.DirectionalLight(0xffffff, 2.4);
  key.position.set(160, 260, 220);
  scene.add(key);
  const rim = new THREE.DirectionalLight(0xcbd5e1, 1.2);
  rim.position.set(-180, 40, -160);
  scene.add(rim);

  // The case assembly — same layout as cad/build-glb.mjs, recolored to the system.
  const anchor = new THREE.Group(); // page-anchored position + scale
  const tilt = new THREE.Group(); // camera-fixed lean, approximating the 58deg polar hero orbit
  const spin = new THREE.Group(); // hero auto-rotate + breathing float
  tilt.rotation.x = 0.32;
  tilt.add(spin);
  anchor.add(tilt);
  scene.add(anchor);
  anchor.visible = false;

  const stage = document.querySelector('.device-stage');

  const buildAssembly = ([frontText, rearText]) => {
    const front = new THREE.Mesh(
      parseSTL(frontText),
      new THREE.MeshStandardMaterial({ color: 0x272258, roughness: 0.48, metalness: 0.04 })
    );
    front.rotation.x = Math.PI;
    front.position.z = 17;

    const rear = new THREE.Mesh(
      parseSTL(rearText),
      new THREE.MeshStandardMaterial({ color: 0xefeff5, roughness: 0.7, metalness: 0 })
    );

    const nfc = new THREE.Mesh(
      new THREE.CylinderGeometry(12.5, 12.5, 0.7, 64),
      new THREE.MeshStandardMaterial({ color: 0x5b4bdb, roughness: 0.55, metalness: 0.08 })
    );
    nfc.rotation.x = Math.PI / 2;
    nfc.position.z = 13.1;

    const assembly = new THREE.Group();
    assembly.add(rear, nfc, front);
    assembly.rotation.x = -Math.PI / 2;
    assembly.position.y = -8.5;

    spin.add(assembly);
    spin.rotation.y = THREE.MathUtils.degToRad(-32);
    anchor.visible = true;
    document.body.classList.add('webgl-product');
  };

  Promise.all([
    fetch('cad/output/taptime-front-case.stl').then((r) => r.text()),
    fetch('cad/output/taptime-rear-case.stl').then((r) => r.text()),
  ])
    .then(buildAssembly)
    .catch(() => {}); // keep model-viewer fallback

  // Keep the assembly glued to the hero's .device-stage element.
  const ray = new THREE.Vector3();
  const placeOnStage = () => {
    if (!stage || !anchor.visible) return;
    const rect = stage.getBoundingClientRect();
    const cx = ((rect.left + rect.width / 2) / window.innerWidth) * 2 - 1;
    const cy = -((rect.top + rect.height / 2) / window.innerHeight) * 2 + 1;
    ray.set(cx, cy, 0.5).unproject(camera).sub(camera.position).normalize();
    const t = -camera.position.z / ray.z; // intersect world plane z=0
    anchor.position.copy(camera.position).addScaledVector(ray, t);
    const worldH = 2 * Math.abs(t) * Math.tan(THREE.MathUtils.degToRad(camera.fov / 2));
    const targetPx = Math.min(rect.width, rect.height) * 0.6;
    anchor.scale.setScalar(((targetPx / window.innerHeight) * worldH) / 56);
  };

  const pointer = { x: 0, y: 0 };
  const drift = { x: 0, y: 0 };
  window.addEventListener('pointermove', (e) => {
    pointer.x = (e.clientX / window.innerWidth) * 2 - 1;
    pointer.y = (e.clientY / window.innerHeight) * 2 - 1;
  });

  window.addEventListener('resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
  });

  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const AUTO_ROTATE = THREE.MathUtils.degToRad(10); // hero: rotation-per-second="10deg"
  const clock = new THREE.Clock();
  let t = 0;
  const render = () => {
    const dt = clock.getDelta();
    if (!reduceMotion) {
      t += dt * 0.24; // slow breathing pulse
      gridMaterial.opacity = 0.22 + Math.sin(t) * 0.07;
      grid.position.z = (t * 8) % STEP;
      spin.rotation.y += AUTO_ROTATE * dt;
      spin.position.y = Math.sin(t * 1.4) * 2.4;
      drift.x += (pointer.x * 14 - drift.x) * 0.03; // subtle pointer drift
      drift.y += (-pointer.y * 8 - drift.y) * 0.03;
      camera.position.x = drift.x;
      camera.position.y = 50 + drift.y;
      camera.lookAt(0, 0, 0);
    }
    placeOnStage();
    renderer.render(scene, camera);
    requestAnimationFrame(render);
  };
  render();
};

initWebGL();
