import "@hotwired/turbo-rails"
import "popper"
import "bootstrap"

// Инициализация Bootstrap dropdown
document.addEventListener("turbo:load", () => {
  const dropdownElementList = document.querySelectorAll('.dropdown-toggle')
  dropdownElementList.forEach(dropdownToggleEl => {
    new bootstrap.Dropdown(dropdownToggleEl)
  })
})