# Модуль "Наши работы" (Portfolio)

## Установка

### 1. Загрузка файлов на сервер

Загрузите следующие файлы на сервер в соответствующие директории:

**Админ-панель:**
```
admin/controller/extension/module/prostore_portfolio.php
admin/controller/extension/module/prostore/prostore_portfolio.php
admin/model/extension/theme/prostoreportfolio.php
admin/language/ru-ru/extension/module/prostore_portfolio.php
admin/language/ru-ru/extension/module/prostore/prostore_portfolio.php
admin/language/en-gb/extension/module/prostore_portfolio.php
admin/language/en-gb/extension/module/prostore/prostore_portfolio.php
admin/view/template/extension/module/prostore_portfolio.twig
admin/view/template/extension/module/prostorecatalog/prostore_portfolio_form.twig
admin/view/template/extension/module/prostorecatalog/prostore_portfolio_list.twig
```

**Каталог (фронтенд):**
```
catalog/controller/extension/module/prostore_portfolio.php
catalog/model/extension/module/prostoreportfolio.php
catalog/language/ru-ru/extension/module/prostore_portfolio.php
catalog/language/en-gb/extension/module/prostore_portfolio.php
catalog/view/theme/prostore/template/extension/module/prostore_portfolio.twig
catalog/view/theme/prostore/template/extension/module/prostore_portfolio_list.twig
catalog/view/theme/prostore/stylesheet/portfolio.css
```

### 2. Установка модуля

1. Зайдите в **Админ-панель** → **Расширения** → **Модули**
2. Найдите **Наши работы (Portfolio)** в списке модулей
3. Нажмите кнопку **Установить** (зелёная кнопка с плюсом)
4. После установки нажмите **Редактировать** (синяя кнопка с карандашом)

### 3. Настройка модуля

**Настройки модуля:**
- **Название модуля**: "Наши работы" (или любое другое)
- **Лимит**: количество работ для отображения (по умолчанию 8)
- **Ширина**: ширина превью изображения (по умолчанию 400px)
- **Высота**: высота превью изображения (по умолчанию 400px)
- **Статус**: Включено

Нажмите **Сохранить**

### 4. Добавление модуля на страницу

1. Перейдите в **Дизайн** → **Макеты**
2. Выберите макет **Главная** (или любой другой)
3. Найдите модуль **Наши работы** в списке модулей
4. Нажмите **+** чтобы добавить модуль
5. Перетащите модуль в нужную позицию (например, **Содержание сверху** или **Содержание снизу**)
6. Нажмите **Сохранить**

### 5. Добавление работ

1. Перейдите по ссылке: `ваш-сайт/admin/index.php?route=extension/module/prostore/prostore_portfolio`
   Или через меню: **Каталог** → **Наши работы** (если пункт добавлен в меню)
2. Нажмите **Добавить работу**
3. Заполните форму:
   - **Общее**: название работы, описание (для каждого языка)
   - **Данные**: изображение работы, порядок сортировки, статус
   - **SEO**: мета-теги для поисковых систем
   - **Дизайн**: выбор магазинов и SEO URL
4. Нажмите **Сохранить**

## Страница со всеми работами

Просмотр всех работ доступен по адресу:
```
https://ваш-сайт/index.php?route=extension/module/prostore_portfolio/getPortfoliolist
```

Вы можете добавить эту ссылку в главное меню через **Дизайн** → **Меню**.

## Использование

### На главной странице
Работы отображаются в виде сетки с превью изображениями. При клике на изображение открывается модальное окно с фото в полном размере.

### На отдельной странице
Страница со всеми работами содержит:
- Список работ с превью и описаниями
- Пагинацию
- Модальное окно при клике

## Размеры изображений

- **Превью**: 400x400px (настраивается в модуле)
- **Полный размер**: 800x800px (для модального окна)

Рекомендуется загружать квадратные изображения размером не менее 800x800px для лучшего качества.

## Управление порядком сортировки

Порядок отображения работ управляется полем **Порядок сортировки**. Меньшее число = выше в списке.

## Структура БД

Модуль создаёт 4 таблицы:
- `oc_portfolio` - основная информация о работах
- `oc_portfolio_description` - описания на разных языках
- `oc_portfolio_to_store` - привязка к магазинам
- `oc_portfolio_to_layout` - привязка к макетам

## Удаление модуля

Для полного удаления модуля:
1. Деинсталлируйте модуль через **Расширения** → **Модули**
2. Удалите файлы модуля с сервера
3. Таблицы БД будут удалены автоматически при деинсталляции
