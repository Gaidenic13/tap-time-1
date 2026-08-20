const targets = document.querySelectorAll(
  '.steps article, .hardware-copy, .pilot-card, .compare article, .chaos-calm, .use-grid article, .offer-grid > div, .stat, .faq-list details, .team-gets article, .accordion details, .media-card'
);
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => entry.target.classList.toggle('visible', entry.isIntersecting));
}, { threshold: 0.15 });
targets.forEach((el) => {
  el.classList.add('reveal');
  observer.observe(el);
});
