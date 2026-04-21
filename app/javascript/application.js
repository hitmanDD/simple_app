import "@hotwired/turbo-rails"
import "./controllers"

// Импортируем поппер и бутстрап так, чтобы не было ворнингов
import * as bootstrap from "bootstrap"
window.bootstrap = bootstrap // Это полезно для отладки в консоли браузера

document.addEventListener("turbo:load", () => {
  const dropdownElementList = document.querySelectorAll('.dropdown-toggle')
  dropdownElementList.forEach(dropdownToggleEl => {
    new bootstrap.Dropdown(dropdownToggleEl)
  })
})