# Системный план разработки модуля "Наши работы" (Portfolio)

## Обзор
Создание модуля для управления и отображения галереи работ (фото с комментариями) на сайте ocStore 3.0.3.7 с темой ProStore.

## Требования
- Неограниченное количество работ
- Каждая работа содержит: одно фото + комментарий (описание)
- Возможность добавления модуля через Дизайн - Макеты
- На фронтенде: галерея фото с комментариями
- При клике: модальное окно с фото в полный размер + подпись
- Стиль по аналогии с blog-featured

## Технические решения
- **Префикс таблиц**: `oc_portfolio`
- **Фото**: одно фото на работу
- **Размеры изображений**: 800x800 (полный), 400x400 (превью)

---

## ЭТАП 1. БАЗА ДАННЫХ

### 1.1. Создание таблиц

**Таблица `oc_portfolio`**:
```sql
CREATE TABLE `oc_portfolio` (
  `portfolio_id` int(11) NOT NULL AUTO_INCREMENT,
  `image` varchar(255) DEFAULT NULL,
  `sort_order` int(3) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `date_added` datetime NOT NULL,
  PRIMARY KEY (`portfolio_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
```

**Таблица `oc_portfolio_description`**:
```sql
CREATE TABLE `oc_portfolio_description` (
  `portfolio_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `meta_title` varchar(255) NOT NULL,
  `meta_h1` varchar(255) NOT NULL,
  `meta_description` varchar(255) NOT NULL,
  `meta_keyword` varchar(255) NOT NULL,
  PRIMARY KEY (`portfolio_id`, `language_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
```

**Таблица `oc_portfolio_to_store`**:
```sql
CREATE TABLE `oc_portfolio_to_store` (
  `portfolio_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL,
  PRIMARY KEY (`portfolio_id`, `store_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
```

**Таблица `oc_portfolio_to_layout`**:
```sql
CREATE TABLE `oc_portfolio_to_layout` (
  `portfolio_id` int(11) NOT NULL,
  `store_id` int(11) NOT NULL,
  `layout_id` int(11) NOT NULL,
  PRIMARY KEY (`portfolio_id`, `store_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
```

---

## ЭТАП 2. АДМИН-ПАНЕЛЬ (Управление работами)

### 2.1. Контроллер
**Файл**: `admin/controller/extension/module/prostore/prostore_portfolio.php`

Методы:
- `index()` - список работ
- `add()` - форма добавления
- `edit()` - форма редактирования
- `delete()` - удаление
- `validateForm()` - валидация

### 2.2. Модель
**Файл**: `admin/model/extension/theme/prostoreportfolio.php`

Методы:
- `addPortfolio($data)` - добавление работы
- `editPortfolio($portfolio_id, $data)` - редактирование
- `deletePortfolio($portfolio_id)` - удаление
- `getPortfolio($portfolio_id)` - получение одной работы
- `getPortfolios($data = array())` - список работ
- `getTotalPortfolios()` - количество работ
- `getPortfolioDescriptions($portfolio_id)` - описания на языках
- `getPortfolioStores($portfolio_id)` - привязка к магазинам
- `getPortfolioLayouts($portfolio_id)` - привязка к макетам
- `createTable()` - создание таблиц при установке

### 2.3. Шаблоны
**Файл**: `admin/view/template/extension/module/prostorecatalog/prostore_portfolio_list.twig`
- Список работ с пагинацией

**Файл**: `admin/view/template/extension/module/prostorecatalog/prostore_portfolio_form.twig`
- Форма добавления/редактирования
- Вкладки: Общее, Данные, SEO, Дизайн
- Поля: изображение, заголовок, описание, статусы

### 2.4. Языковые файлы
**Файл**: `admin/language/ru-ru/extension/module/prostore/prostore_portfolio.php`

---

## ЭТАП 3. АДМИН-ПАНЕЛЬ (Модуль для макетов)

### 3.1. Контроллер модуля
**Файл**: `admin/controller/extension/module/prostore_portfolio.php`

Методы:
- `index()` - настройки модуля (название, лимит, статус)
- `validate()` - валидация настроек
- `install()` - установка модуля + создание прав
- `uninstall()` - удаление модуля

### 3.2. Шаблон настроек
**Файл**: `admin/view/template/extension/module/prostore_portfolio.twig`
- Поля: название модуля, лимит записей, статус

---

## ЭТАП 4. ФРОНТЕНД (Отображение на сайте)

### 4.1. Контроллер модуля
**Файл**: `catalog/controller/extension/module/prostore_portfolio.php`

Методы:
- `index($settings)` - вывод галереи
  - Получает работы из БД
  - Ресайзит изображения
  - Передаёт данные в шаблон

### 4.2. Модель
**Файл**: `catalog/model/extension/module/prostoreportfolio.php`

Методы:
- `getPortfolios($data)` - получение списка работ
- `getPortfolio($portfolio_id)` - получение одной работы
- `getTotalPortfolios()` - общее количество
- `isModuleSet()` - проверка установлен ли модуль

### 4.3. Шаблон модуля
**Файл**: `catalog/view/theme/prostore/template/extension/module/prostore_portfolio.twig`

Стили по аналогии с blog-featured:
```twig
<div class="portfolio-featured">
  <div class="container-fluid">
    <span class="h2 portfolio-featured__title">{{ heading_title }}</span>
    <div class="portfolio-featured__grid">
      {% for portfolio in portfolios %}
      <div class="portfolio-featured__item">
        <a class="portfolio-featured__link js-portfolio-popup" href="{{ portfolio.popup }}" data-caption="{{ portfolio.title }}">
          <div class="portfolio-featured__item-image">
            <img src="{{ portfolio.thumb }}" alt="{{ portfolio.title }}" loading="lazy">
          </div>
        </a>
        <span class="portfolio-featured__item-caption">{{ portfolio.description }}</span>
      </div>
      {% endfor %}
    </div>
  </div>
</div>
```

### 4.4. JavaScript для модального окна
**Файл**: `catalog/view/theme/prostore/javascript/portfolio.js`

Использовать Fancybox (уже есть на сайте):
```javascript
$('.js-portfolio-popup').fancybox({
  caption : function( instance, item ) {
    return $(this).data('caption');
  }
});
```

### 4.5. Языковые файлы
**Файл**: `catalog/language/ru-ru/extension/module/prostore_portfolio.php`

---

## ЭТАП 5. СТРАНИЦА "Наши работы"

### 5.1. Контроллер страницы
**Файл**: `catalog/controller/extension/module/prostore_portfolio.php`

Добавить методы:
- `getPortfoliolist()` - страница со всеми работами
  - SEO заголовки
  - Пагинация
  - Хлебные крошки

### 5.2. Шаблон страницы
**Файл**: `catalog/view/theme/prostore/template/extension/module/prostore_portfolio_list.twig`

Структура аналогично `prostore_news_list_main.twig`

---

## ЭТАП 6. СТИЛИ (CSS)

**Файл**: `catalog/view/theme/prostore/stylesheet/portfolio.css`

Стили по аналогии с blog-featured:
```css
.portfolio-featured {
  padding: 40px 0;
}

.portfolio-featured__grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
}

.portfolio-featured__item {
  position: relative;
}

.portfolio-featured__link {
  display: block;
  border-radius: 8px;
  overflow: hidden;
}

.portfolio-featured__item-image img {
  width: 100%;
  height: auto;
  transition: transform 0.3s;
}

.portfolio-featured__item:hover .portfolio-featured__item-image img {
  transform: scale(1.05);
}

.portfolio-featured__item-caption {
  display: block;
  margin-top: 10px;
  font-size: 14px;
  color: #666;
}
```

---

## ПОРЯДОК РЕАЛИЗАЦИИ

1. **База данных** - создание таблиц
2. **Админка (управление)** - CRUD для работ
3. **Модуль** - настройка для макетов
4. **Фронтенд** - вывод галереи
5. **Модальное окно** - JavaScript
6. **Страница списка** - все работы
7. **Стили** - CSS
8. **Тестирование** - проверка функционала

---

## ВОПРОСЫ ДЛЯ УТОЧНЕНИЯ

1. Нужна ли сортировка работ вручную (drag & drop)?
2. Нужна ли категоризация работ (по типам услуг)?
3. Нужно ли добавлять ссылку на страницу "Наши работы" в главное меню?
