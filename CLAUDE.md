# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an **ocStore 3.0.3.7** e-commerce website (a fork of OpenCart) for prokraski.com. The site uses the custom **ProStore** theme (themes899) and includes a blog module.

## Architecture

### Entry Points

- **`index.php`** - Catalog (storefront) entry point
- **`admin/index.php`** - Admin panel entry point

Both load `system/startup.php` which initializes the framework and calls `start()` with the appropriate config (`catalog` or `admin`).

### Directory Structure

```
/                      # Root
├── catalog/           # Storefront (customer-facing)
│   ├── controller/    # Controllers (MVC)
│   ├── model/         # Models (data access)
│   ├── language/      # Language files
│   └── view/theme/    # Themes (default, prostore)
├── admin/             # Admin panel
│   ├── controller/
│   ├── model/
│   ├── language/
│   └── view/template/ # Admin templates (not theme-based)
├── system/            # Core framework
│   ├── engine/        # Core classes (Action, Controller, Router, Loader, Model, Registry, Event)
│   ├── library/       # Libraries (cart, db, cache, session, etc.)
│   ├── helper/        # Helper functions (general, utf8, HTMLPurifier)
│   ├── config/        # Configuration files
│   └── startup.php    # Bootstrap
├── image/             # User images
└── system/storage/    # Writable storage (cache, logs, sessions, uploads)
```

### MVC Pattern

Routes follow `directory/filename/method` pattern:
- `common/home` → `catalog/controller/common/home.php`
- `product/product` → `catalog/controller/product/product.php`

Controllers extend `Controller` abstract class and access registry properties via magic methods:
- `$this->config`, `$this->db`, `$this->load`, `$this->request`, `$this->response`, etc.

### Configuration Files

- **`config.php`** (root) - Main config (HTTP/HTTPS URLs, directory paths, DB credentials)
- **`admin/config.php`** - Admin-specific overrides
- **`system/config/default.php`** - Default framework settings
- **`system/config/catalog.php`** - Catalog frontend settings
- **`system/config/admin.php`** - Admin panel settings

### Pre-Actions (Startup Controllers)

Catalog (`system/config/catalog.php`):
- `startup/session` - Session initialization
- `startup/startup` - Core initialization
- `startup/error` - Error handling
- `startup/event` - Event system
- `startup/maintenance` - Maintenance mode
- `startup/seo_url` - SEO URL routing

Admin (`system/config/admin.php`):
- `startup/startup`, `startup/error`, `startup/event`
- `startup/sass`, `startup/login`, `startup/permission`

### Event System

Events are registered in config files and triggered at specific points:
- `controller/*/before` - Before controller execution
- `controller/*/after` - After controller execution
- `view/*/before` - Before template rendering
- `language/*/after` - After language loading

### Theme System

- Default theme: `catalog/view/theme/default/`
- Custom theme: `catalog/view/theme/prostore/`
- Template engine: Twig
- Theme selection via `extension/theme/prostore` in admin

### Custom Extensions

**ProStore Theme Module** (`catalog/controller/extension/module/prostore/`):
- Custom helper class: `system/library/themes899/helper.php`
- Modules: `prostore_blog`, `prostore_category`, `prostore_set`, `prostore_news`, etc.
- Provides Russian language helpers, cart helpers, wishlist/compare helpers

**Blog Module** (`catalog/controller/blog/`, `catalog/model/blog/`):
- Articles, categories, latest posts
- Integrated with ProStore theme

### Database

- Driver: mysqli
- Prefix: `oc_`
- Tables include: `oc_product`, `oc_category`, `oc_customer`, `oc_order`, etc.
- Access via `$this->db->query()`

### Modification System

OpenCart's modification system (VQMod successor) allows core file modifications without editing originals:
- Definition: `system/modification.xml`
- Storage: `system/storage/modification/`
- Function: `modification()` in `system/startup.php` checks for modified files first

### Storage Locations

Writable directories (configured in `config.php`):
- `DIR_STORAGE` - Base storage path (`system/storage/`)
- `DIR_CACHE` - Cache files
- `DIR_LOGS` - Error logs (`error.log`)
- `DIR_SESSION` - Session files
- `DIR_UPLOAD` - User uploads
- `DIR_MODIFICATION` - Modified files
- `DIR_DOWNLOAD` - Downloadable products

## Development Notes

### Loading Models, Languages, Libraries

```php
// Model
$this->load->model('catalog/product');
$product_info = $this->model_catalog_product->getProduct($product_id);

// Language
$this->load->language('product/product');
$text_heading = $this->language->get('heading_title');

// Library
$this->load->library('cart');

// Config
$this->config->load('default');
$value = $this->config->get('key');
```

### Controller Methods

- `index()` - Default method called for routes
- Return a string (output) or nothing (uses `$this->response->setOutput()`)
- Controllers can chain by returning new `Action` objects

### URL Routing

- SEO URLs handled by `startup/seo_url` controller
- Standard URLs: `route=common/home`
- SEO URLs rewritten in `.htaccess` to `index.php?route=...`

### Session

- Engine: Database (`system/library/session/db.php`)
- Session name: `OCSESSID`
- Access via `$this->session->data['key']`

### Cache

- Engine: File-based (default) or APC/memcached
- Expire: 3600 seconds (default)
- Access via `$this->cache->set()` / `$this->cache->get()`
