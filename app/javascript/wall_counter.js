// Функция инициализации счетчика символов
function initCharCounter() {
  // Находим форму по кастомному дата-атрибуту (Middle-стиль: не привязываемся к жестким ID)
  const form = document.querySelector('[data-behavior="char-counter-form"]');
  if (!form) return; // Защита: если на странице нет этой формы, скрипт тихо завершает работу

  // Находим элементы внутри нашей формы
  const textarea = form.querySelector('[data-target="counter-input"]');
  const counter = form.querySelector('[data-target="counter-display"]');
  const submitBtn = form.querySelector('[data-target="counter-submit"]');
  
  if (!textarea || !counter) return;

  const MAX_CHARS = 500; // Лимит символов

  // Функция обновления состояния счетчика
  function updateCounter() {
    const currentLength = textarea.value.length;
    
    // Обновляем текст счетчика (например: "45 / 500")
    counter.textContent = `${currentLength} / ${MAX_CHARS}`;

    if (currentLength > MAX_CHARS) {
      // Если превысили лимит: красим в красный и блокируем кнопку отправки
      counter.classList.add('counter-danger');
      textarea.classList.add('input-danger');
      if (submitBtn) submitBtn.disabled = true;
    } else {
      // Если всё в порядке: возвращаем стандартные стили и разблокируем кнопку
      counter.classList.remove('counter-danger');
      textarea.classList.remove('input-danger');
      if (submitBtn) submitBtn.disabled = false;
    }
  }

  // Слушаем событие ввода текста (работает и при вставке через Ctrl+V)
  textarea.addEventListener('input', updateCounter);
  
  // Запускаем проверку один раз при загрузке (на случай, если в поле уже есть текст)
  updateCounter();
}

// Профессиональный подход для Turbo: слушаем правильное событие загрузки страницы
document.addEventListener('turbo:load', initCharCounter);