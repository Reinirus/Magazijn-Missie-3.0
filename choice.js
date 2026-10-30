(function () {
  const choice = document.getElementById('missionChoice');
  const modal = document.getElementById('modal');
  const back = document.getElementById('backWarehouse');
  window.MagazijnMode = null;

  function start(mode) {
    window.MagazijnMode = mode;
    document.body.classList.remove('mode-warehouse', 'mode-retail', 'mode-both');
    document.body.classList.add('mode-' + mode);
    choice.hidden = true;

    if (mode === 'retail') {
      back.textContent = '← Andere keuze';
      back.onclick = () => window.location.reload();
      if (modal.open) modal.close();
      setTimeout(() => window.dispatchEvent(new CustomEvent('open-retail')), 0);
    } else {
      back.textContent = '← Terug naar magazijn';
    }
  }

  choice.querySelectorAll('[data-mode]').forEach(button => {
    button.addEventListener('click', () => start(button.dataset.mode));
  });

  window.addEventListener('mission-completed', event => {
    if (window.MagazijnMode !== 'warehouse' || event.detail.completed !== 5) return;
    const tip = document.querySelector('#modalContent .lesson-tip');
    const next = document.getElementById('resultNext');
    if (tip) tip.textContent = 'Alle magazijnopdrachten zijn afgerond. Je totaalscore blijft zichtbaar.';
    if (next) {
      next.textContent = 'Terug naar de startkeuze →';
      next.onclick = () => window.location.reload();
    }
  });
})();
