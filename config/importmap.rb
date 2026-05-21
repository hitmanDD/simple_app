# Сначала идут системные штуки от Hotwire (без них Turbo не работает)
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# Контроллеры (JS-логика)
pin_all_from "app/javascript/controllers", under: "controllers"

# Bootstrap и Popper (я почистил дубликаты)
pin "popper", to: "popper.js", preload: true
# Мой коммент: Лучше использовать bundle, там внутри уже есть popper
pin "bootstrap", to: "bootstrap.bundle.min.js", preload: true

# Основной файл приложения
pin "application", preload: true