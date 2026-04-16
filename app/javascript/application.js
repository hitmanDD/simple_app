import "@hotwired/turbo-rails"
import "@popperjs/core" // Исправленное имя
import * as bootstrap from "bootstrap" // Импортируем всё как объект bootstrap

document.addEventListener("turbo:load", () => {
  const dropdownElementList = document.querySelectorAll('.dropdown-toggle')
  dropdownElementList.forEach(dropdownToggleEl => {
    new bootstrap.Dropdown(dropdownToggleEl)
  })
})