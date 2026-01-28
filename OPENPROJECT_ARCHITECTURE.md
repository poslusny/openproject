# OpenProject Architecture Overview

This document provides a comprehensive high-level overview of the OpenProject codebase, its architecture, and modular system.

---

## Table of Contents

1. [What is OpenProject?](#what-is-openproject)
2. [Tech Stack](#tech-stack)
3. [Directory Structure](#directory-structure)
4. [Core Domain Concepts](#core-domain-concepts)
5. [Architecture Patterns](#architecture-patterns)
6. [How It Runs](#how-it-runs)
7. [The Modular System](#the-modular-system)
8. [Extension Mechanisms](#extension-mechanisms)
9. [Key Files Reference](#key-files-reference)

---

## What is OpenProject?

OpenProject is an **open-source, web-based project management platform** distributed under GPLv3. It's a fork of ChiliProject/Redmine, designed for team collaboration on projects, tasks, and goals.

### Key Features

- Project planning and scheduling
- Gantt charts and timeline views
- Kanban boards
- Agile and Scrum support (backlogs, sprints)
- Time tracking and cost reporting
- Bug tracking
- Wikis and forums
- Meeting agendas and minutes
- BIM (Building Information Modeling) capabilities
- Integrations with GitHub, GitLab, and cloud storage (NextCloud/SharePoint)

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Backend** | Ruby on Rails 8.0.1 (Ruby 3.4.5) |
| **Frontend** | Angular 20.1.2 |
| **Database** | PostgreSQL 17 |
| **Job Queue** | GoodJob |
| **API** | RESTful API (V3) with Grape |
| **Authentication** | Warden, OmniAuth, SAML, OIDC, LDAP, 2FA |
| **Caching** | Memcached |
| **Container** | Docker support |

---

## Directory Structure

### Root Level

| Directory | Purpose |
|-----------|---------|
| `/app` | Core Rails application (models, controllers, views, services, components) |
| `/frontend` | Angular SPA application |
| `/modules` | **30+ optional feature modules** (backlogs, boards, calendar, gantt, BIM, etc.) |
| `/lib` | Core libraries and plugin system |
| `/lib_static` | OpenProject configuration and static extensions |
| `/config` | Rails configuration, routes, locales |
| `/spec` | RSpec test suite |
| `/db` | Database migrations and seeds |
| `/doc` | Documentation |
| `/docker` | Docker configurations |

### Application Structure (`/app`)

| Directory | Purpose |
|-----------|---------|
| `models/` | ActiveRecord models (Project, WorkPackage, User, etc.) |
| `controllers/` | Rails controllers and API endpoints |
| `views/` | ERB templates and view logic |
| `components/` | ViewComponent-based reusable UI components |
| `services/` | Business logic services (CreateService, UpdateService patterns) |
| `contracts/` | Data validation contracts (for CRUD operations) |
| `forms/` | Form classes for data input |
| `workers/` | Background job workers (GoodJob compatible) |
| `mailers/` | Email notification logic |
| `policies/` | Authorization policies (Pundit) |

### Frontend Structure (`/frontend`)

| Directory | Purpose |
|-----------|---------|
| `src/app/` | Angular app components and modules |
| `src/global_styles/` | Global SCSS/CSS |
| `src/assets/` | Frontend assets |
| `src/environments/` | Environment configurations |

---

## Core Domain Concepts

### Main Entities

| Entity | Description |
|--------|-------------|
| **Project** | Container for work packages and team collaboration. Supports hierarchy (parent/child). |
| **WorkPackage** | The main unit of work (tasks, bugs, features). Supports nesting, relations, and custom fields. |
| **User** | Team member with roles and permissions |
| **Role** | Permission container (global and project-level) |
| **Type** | Configuration for work package attributes and workflows |
| **Status** | Work package states |
| **Workflow** | State transition rules |

### Access Control

| Entity | Description |
|--------|-------------|
| **Permission** | Fine-grained capabilities (e.g., `create_work_packages`) |
| **Role** | Bundles permissions |
| **Member** | User + Role + Project relationship |
| **Policy** | Authorization rules (Pundit-based) |

### Content & Communication

| Entity | Description |
|--------|-------------|
| **Journal** | Audit trail of changes |
| **Attachment** | File uploads |
| **Wiki** | Project documentation |
| **Forum/Message** | Discussion areas |
| **News** | Project announcements |

### Time & Cost

| Entity | Description |
|--------|-------------|
| **TimeEntry** | Time tracking entries |
| **Cost** | Labor and material costs |
| **Budget** | Project budgets |

---

## Architecture Patterns

### Service Objects

Business logic is encapsulated in `*Service` classes:

```ruby
WorkPackages::CreateService  # Business logic for creating work packages
WorkPackages::UpdateService  # Update logic with validation
```

Base classes: `BaseServices::BaseCallable`, `BaseServices::BaseImporter`

### Contracts

Validation layer separate from models, used in services before persistence:

```ruby
WorkPackages::CreateContract
WorkPackages::UpdateContract
```

### ViewComponents

Reusable UI components in Ruby, located in `/app/components/`. They render HTML, styles, and JavaScript.

### Hooks System

Plugin extension points that allow modules to hook into core application events. Used for notifications, UI customization, and data transformations.

### Pluggable Modules

Optional features implemented as Rails engines. Each module is self-contained and can be enabled/disabled per installation.

---

## How It Runs

### Development Mode (`Procfile.dev`)

```bash
web:      bundle exec rails server              # Rails server on port 3000
angular:  npm run serve                         # Angular dev server on port 4200
worker:   bundle exec good_job start            # Background job processor
```

### Production Mode (`Procfile`)

```bash
web:      ./packaging/scripts/web               # Production Rails server
worker:   ./packaging/scripts/worker            # Production job worker
backup:   ./packaging/scripts/backup            # Backup service
check:    ./packaging/scripts/check             # Health checks
```

### Docker Compose Services

- `backend` - Rails application
- `worker` - GoodJob background worker
- `frontend` - Angular dev server
- `db` - PostgreSQL 17
- `cache` - Memcached

### Entry Points

- **HTTP:** Port 3000 (backend), 4200 (frontend dev)
- **Root Route:** `GET /` → HomeScreen controller
- **API:** `/api/v3/` → Grape-based REST API

---

## The Modular System

OpenProject has **30+ modules** in `/modules/` that extend the core application. Each module is a **Rails Engine**.

### Module Structure

```
modules/{module_name}/
├── app/
│   ├── models/          # Domain models
│   ├── controllers/     # Request handlers
│   ├── views/           # Templates
│   ├── services/        # Business logic
│   ├── contracts/       # Validation
│   └── components/      # ViewComponents
├── lib/open_project/{module}/
│   ├── engine.rb        # 🔑 Rails engine definition
│   ├── patches/         # Core class extensions
│   └── hooks/           # View hooks
├── config/
│   ├── routes.rb        # Module routes
│   └── locales/         # Translations
├── db/migrate/          # Database migrations
├── spec/                # Tests
└── {module}.gemspec     # Gem specification
```

### How Modules Load

1. **Gemfile.modules** registers each module as a gem:
   ```ruby
   gem 'openproject-boards', path: 'modules/boards'
   ```

2. **Bundler** loads them via the `:opf_plugins` group

3. **engine.rb** registers the module with permissions and menus:
   ```ruby
   register "openproject-boards", bundled: true do
     project_module :board_view do
       permission :show_board_views, { "boards/boards": [:index, :show] }
       permission :manage_board_views, ...
     end
     menu :project_menu, :boards, { controller: "/boards/boards" }
   end
   ```

### Available Modules

| Category | Modules |
|----------|---------|
| **Views** | boards, gantt, calendar, team_planner, dashboards |
| **Planning** | backlogs, budgets, overviews |
| **Collaboration** | meeting, documents |
| **Integration** | github_integration, gitlab_integration, storages |
| **Authentication** | auth_saml, openid_connect, two_factor_authentication |
| **Advanced** | bim, costs, reporting, webhooks |

### Per-Project Enable/Disable

Modules are **enabled per-project** via the `EnabledModule` model:

```ruby
# Check if module is enabled
project.module_enabled?(:meetings)

# Enable modules
project.enabled_module_names = [:work_package_tracking, :meetings, :boards]
```

When a module is disabled for a project:
- Its permissions disappear
- Its menus are hidden
- Its features are inaccessible

---

## Extension Mechanisms

### Patching Core Classes

Modules extend core models without modifying them:

```ruby
# backlogs/lib/open_project/backlogs/patches/project_patch.rb
module OpenProject::Backlogs::Patches::ProjectPatch
  def self.included(base)
    base.class_eval do
      has_and_belongs_to_many :done_statuses,
                              join_table: :done_statuses_for_project
    end
  end
end

Project.include OpenProject::Backlogs::Patches::ProjectPatch
```

Registration in engine.rb:
```ruby
patches %i[PermittedParams WorkPackage Status Type Project User]
```

### View Hooks

Modules intercept rendering at specific points:

```ruby
class LayoutHook < OpenProject::Hook::ViewListener
  def view_my_settings(context = {})
    # Add UI to user settings
  end
end
```

### API Extensions

Modules can extend API responses:

```ruby
# In engine.rb
add_api_attribute on: :work_package, ar_name: :story_points

extend_api_response(:v3, :work_packages, :work_package,
                    &::OpenProject::Backlogs::Patches::API::WorkPackageRepresenter.extension)
```

### Adding Routes

```ruby
# boards/config/routes.rb
Rails.application.routes.draw do
  resources :boards, controller: "boards/boards", only: %i[index new create destroy]
  scope "projects/:project_id", as: "project" do
    resources :boards, controller: "boards/boards", only: %i[index show]
  end
end
```

### Extension Summary Table

| Mechanism | Purpose | Example |
|-----------|---------|---------|
| **Patches** | Extend core classes | Add `story_points` to WorkPackage |
| **Hooks** | Inject UI at specific points | Add content to settings page |
| **API Extensions** | Add attributes to API responses | `extend_api_response` |
| **Routes** | Add new endpoints | `/projects/:id/boards` |
| **Permissions** | Define access control | `permission :view_meetings` |
| **Menus** | Add navigation items | `menu :project_menu, :boards` |

---

## Key Files Reference

### Core System Files

| File | Purpose |
|------|---------|
| `config/application.rb` | Rails configuration |
| `config/routes.rb` | URL routing |
| `Gemfile.modules` | Module gem definitions |
| `Procfile.dev` | Development process definitions |

### Plugin System Files

| File | Purpose |
|------|---------|
| `lib/open_project/plugins/acts_as_op_engine.rb` | Mixin all modules include |
| `lib/redmine/plugin.rb` | Base registration system |
| `app/models/enabled_module.rb` | Tracks enabled modules per project |
| `lib/open_project/access_control.rb` | Permission & module mapping |

### Module Engine Files

| File | Purpose |
|------|---------|
| `modules/{name}/lib/open_project/{name}/engine.rb` | Module definition |
| `modules/{name}/config/routes.rb` | Module routes |
| `modules/{name}/db/migrate/` | Module migrations |

---

## Example Module Deep Dives

### Boards Module

```
Purpose: Create custom board views with drag-and-drop organization
Models: Boards::Grid (extends ::Grids::Grid)
Controllers: Boards::BoardsController, Boards::MenusController
Routes: /projects/{id}/boards
Permissions: show_board_views, manage_board_views
```

### Gantt Module

```
Purpose: Timeline/Gantt chart view of work packages
Models: Uses core WorkPackage model
Controllers: Gantt::GanttController
Routes: /projects/{id}/gantt
Permissions: view_work_packages
```

### Backlogs Module

```
Purpose: Scrum backlog management with sprints and story points
Models: Story, Task, Impediment (via WorkPackage patches)
Controllers: RbMasterBacklogsController, RbTaskboardsController
Routes: /backlogs, /taskboards
Permissions: view_master_backlog, view_taskboards, update_sprints
Database additions:
  - work_packages.position (story ordering)
  - work_packages.story_points (estimation)
  - work_packages.remaining_hours
```

### Meeting Module

```
Purpose: Meeting management with agenda, minutes, participants
Models: Meeting, MeetingAgendaItem, MeetingParticipant, MeetingOutcome
Controllers: MeetingsController, MeetingAgendaItemsController
Routes: /projects/{id}/meetings, /meetings (global)
Permissions: view_meetings, create_meetings, edit_meetings, delete_meetings
Features: iCalendar feed, PDF export, email notifications
```

---

## Summary

OpenProject is a well-architected Rails + Angular application with:

1. **Clear separation** between backend (Rails API) and frontend (Angular SPA)
2. **Modular design** allowing features to be enabled/disabled per project
3. **Extensible architecture** through patches, hooks, and plugin system
4. **Strong domain model** centered around Projects and WorkPackages
5. **Comprehensive access control** with fine-grained permissions

The modular system allows OpenProject to be both a monolithic application and a flexible, extensible platform suitable for various project management workflows.
