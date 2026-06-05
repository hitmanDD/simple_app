// Пишем чистый, изолированный код счетчика
function initCharCounter() {
  console.log("Скрипт счетчика запущен!"); // Проверка: заглянем в консоль браузера

  // Ищем форму по нашему маркеру
  const form = document.querySelector('[data-behavior="char-counter-form"]');
  if (!form) {
    console.log("Форма счетчика на этой странице не найдена.");
    return;
  }

  // Находим элементы внутри формы
  const textarea = form.querySelector('[data-target="counter-input"]');
  const counter = form.querySelector('[data-target="counter-display"]');
  const submitBtn = form.querySelector('[data-target="counter-submit"]');
  
  if (!textarea || !counter) {
    console.log("Ошибка: Текстовое поле или элемент счетчика не найдены внутри формы.");
    return;
  }

  console.log("Все элементы формы успешно найдены! Начинаем следить за вводом...");
  const MAX_CHARS = 500;

  function updateCounter() {
    const currentLength = textarea.value.length;
    
    // Меняем текст счетчика
    counter.textContent = `${currentLength} / ${MAX_CHARS}`;

    // Если символов больше 500 — красим в красный и блокируем
    if (currentLength > MAX_CHARS) {
      counter.style.color = 'red';
      textarea.style.borderColor = 'red';
      if (submitBtn) submitBtn.disabled = true;
    } else {
      counter.style.color = '#777';
      textarea.style.borderColor = '#ddd';
      if (submitBtn) submitBtn.disabled = false;
    }
  }

  // Очищаем старые привязки событий, чтобы они не дублировались
  textarea.removeEventListener('input', updateCounter);
  // Вешаем событие: срабатывает мгновенно при каждом нажатии клавиши или вставке текста
  textarea.addEventListener('input', updateCounter);
  
  // Запускаем проверку один раз сразу (чтобы подхватить текст, если он уже был в поле)
  updateCounter();
}

// НАДЕЖНЫЙ ЗАПУСК: слушаем абсолютно все возможные события загрузки в Rails
document.addEventListener('DOMContentLoaded', initCharCounter); // Для обычной загрузки без Turbo
document.addEventListener('turbo:load', initCharCounter);       // Для переходов по ссылкам с Turbo
document.addEventListener('turbo:render', initCharCounter);     // На случай частичного рендеринга страницы