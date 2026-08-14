const device = document.querySelector('#device');
const stage = document.querySelector('.device-stage');

if (device && stage && matchMedia('(pointer:fine)').matches) {
  stage.addEventListener('pointermove', (event) => {
    const rect = stage.getBoundingClientRect();
    const x = (event.clientX - rect.left) / rect.width - 0.5;
    const y = (event.clientY - rect.top) / rect.height - 0.5;
    device.style.transform = `rotateX(${57 - y * 8}deg) rotateZ(${-32 + x * 8}deg) translateZ(4px)`;
  });
  stage.addEventListener('pointerleave', () => {
    device.style.transform = 'rotateX(57deg) rotateZ(-32deg)';
  });
}

const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => entry.target.classList.toggle('visible', entry.isIntersecting));
}, { threshold: 0.15 });
document.querySelectorAll('.steps article, .hardware-copy, .pilot-card').forEach((el) => observer.observe(el));
