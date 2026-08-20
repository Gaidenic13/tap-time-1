const targets = document.querySelectorAll(
  '.benefits-grid article, .method-card, .modules-grid article, .support-grid article, .record-mock, .recap, .pilot-card, .hardware-copy, .faq-list details, .offer-card'
);
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => entry.target.classList.toggle('visible', entry.isIntersecting));
}, { threshold: 0.15 });
targets.forEach((el) => {
  el.classList.add('reveal');
  observer.observe(el);
});

// Demo form: frontend-only — opens a prefilled email to the pilot team.
const demoForm = document.querySelector('.demo-form');
demoForm?.addEventListener('submit', (e) => {
  e.preventDefault();
  const phone = demoForm.querySelector('input[name="phone"]').value;
  const email = demoForm.querySelector('input[name="email"]').value;
  const body = encodeURIComponent(`Hi TapTime team,\n\nI'd like a demo.\nPhone: ${phone}\nEmail: ${email}\n`);
  window.location.href = `mailto:pilots@taptime.app?subject=${encodeURIComponent('TapTime demo request')}&body=${body}`;
});

// EN / RO language switch. English lives in the markup; Romanian in data-ro
// attributes. The first switch caches the English text so both directions work.
const applyLang = (lang) => {
  document.documentElement.lang = lang;
  document.querySelectorAll('[data-ro]').forEach((el) => {
    if (el.dataset.en === undefined) el.dataset.en = el.innerHTML;
    el.innerHTML = lang === 'ro' ? el.dataset.ro : el.dataset.en;
  });
  document.querySelectorAll('[data-ro-placeholder]').forEach((el) => {
    if (el.dataset.enPlaceholder === undefined) el.dataset.enPlaceholder = el.placeholder;
    el.placeholder = lang === 'ro' ? el.dataset.roPlaceholder : el.dataset.enPlaceholder;
  });
  document.querySelectorAll('.lang-switch button').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.lang === lang);
  });
  try {
    localStorage.setItem('taptime-lang', lang);
  } catch {}
};
document.querySelectorAll('.lang-switch button').forEach((btn) => {
  btn.addEventListener('click', () => applyLang(btn.dataset.lang));
});
let savedLang = 'en';
try {
  savedLang = localStorage.getItem('taptime-lang') || 'en';
} catch {}
if (savedLang === 'ro') applyLang('ro');
