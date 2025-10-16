# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Overview

Cohenix ESS (Employee Self-Service) is a Flutter mobile app for warehouse stock-taking and HR operations that integrates with Frappe/ERPNext via the Nex Bridge backend. The app supports offline-first workflows (local SQLite via sqflite) with periodic background sync and uses OAuth (authorization code flow) for authentication.

Key functionality:
- **Stock-taking operations**: Warehouse inventory counting with offline support
- **HR operations**: Employee self-service functions (leaves, claims, attendance) with offline queue processing
- **Dual sync system**: Stock-taking sync (15-minute intervals) + HR outbox queue processing

Key points from README:
- Requires Nex Bridge on the Frappe/ERPNext server for API endpoints used by this app.
- First-run configuration prompts for Base URL and Client ID; values are persisted and can be edited later.
- OAuth redirect URI used by the app: cohenixess://oauth2redirect

## Commands

- Install dependencies
  - flutter pub get

- Run on a connected device or simulator
  - flutter run
  - Specify platform/device (optional):
    - flutter run -d android
    - flutter run -d ios

- Analyze (static checks)
  - flutter analyze

- Format
  - dart format .

- Tests
  - Run all: flutter test
  - Run a single file: flutter test test/path_to_test.dart
  - Filter by test name: flutter test -n "partial or regex of test name"

- Build
  - Android APK (debug): flutter build apk
  - Android APK (release): flutter build apk --release
  - iOS (debug): flutter build ios
  - iOS (release): flutter build ios --release
    - Note: Codesigning and Xcode setup required on macOS to produce an installable IPA.
  - Generate launcher icons: flutter pub run flutter_launcher_icons:main

- Development utilities
  - Clean build cache: flutter clean
  - Update dependencies: flutter pub upgrade
  - Check for outdated packages: flutter pub outdated
  - Generate code (if using build_runner): flutter packages pub run build_runner build

## Architecture

- Entry point and app flow
  - lib/main.dart initializes Hive, schedules periodic HR sync (Timer every 15 minutes, non-web), and bootstraps Provider state via ChangeNotifierProvider(StockTakeNotifier).
  - startPeriodicHRSync() handles HR-focused sync operations including OutboxQueue.processQueue() for offline operations (leaves, claims, attendance).
  - AppConfig.isConfigured (lib/config.dart) controls first-run flow:
    - If not configured, a blocking SetupDialog (lib/screens/setup_dialog.dart) collects Base URL and Client ID and persists them.
    - Otherwise proceeds to LoginScreen (lib/screens/login.dart).

- Configuration and persistence
  - AppConfig (lib/config.dart)
    - Persists Base URL and Client ID via SharedPreferences with cached getters/setters.
    - Defines redirectUri (cohenixess://oauth2redirect) and paths for token and userinfo endpoints.
  - Hive (box: authBox)
    - Stores accessToken, refreshToken, tokenExpiry, userId, userDetails and cached server data (warehouses_by_company, companies, assigned_items).
  - SQLite via sqflite with schema in lib/utilis/db_schema.dart
    - StockCountEntry (id, server_id, company, warehouse, posting_date/time, stock_count_person, synced, last_sync_time)
    - StockCountEntryItem (id, stock_count_entry_id, server_id, item_barcode, warehouse, qty, synced, last_sync_time)

- Authentication and API integration
  - ApiService (lib/utilis/api_service.dart)
    - OAuth authorization code flow using flutter_web_auth_2.
    - Exchanges code for tokens at /api/method/frappe.integrations.oauth2.get_token, stores tokens in Hive.
    - Fetches user info from /api/method/frappe.integrations.oauth2.openid_profile and persists to Hive.
    - After login, triggers initial data fetch via SyncManager and navigates to HomeScreen.
  - Requires Nex Bridge endpoints on server (examples used in code):
    - nex_bridge.api.stock_take.sync_entry (sync to/from server)
    - nex_bridge.api.stock_take.get_warehouses_grouped_by_company
    - nex_bridge.api.stock_take.get_user_assigned_items

- Sync orchestration (offline-first)
  - SyncManager (lib/utilis/sync_manager.dart)
    - getDatabase() opens/creates local DB using DBSchema.
    - Stores/reads cached metadata in Hive (authBox) with helpers to ensure the box is open.
    - syncToServer(): posts unsynced StockCountEntry and related StockCountEntryItem to the Nex Bridge endpoint, then marks local rows as synced and records server_id mappings.
    - syncFromServer(): fetches entries from server and upserts to local DB using server_id as linkage; updates related items accordingly.
    - fetchAndStoreWarehousesAndCompanies(): caches warehouses_by_company and companies in Hive.
    - fetchAndStoreAssignedItems(): caches assigned_items in Hive.
  - OutboxQueue (lib/utilis/outbox_queue.dart)
    - Handles offline HR operations queue processing (leaves, claims, attendance).
    - Processes queued operations when connectivity is restored.
  - Periodic scheduling: main.dart startPeriodicHRSync() sets a Timer.periodic for HR outbox queue processing every 15 minutes.

- State management and UI
  - State management: Provider (lib/utilis/change_notifier.dart) for lightweight app state management.
  - Theming: Multiple theme systems including lib/constants/theme.dart, lib/constants/app_theme.dart, and lib/constants/modern_design_system.dart with Cohenix branding elements.
  - Screens:
    - LoginScreen (lib/screens/login.dart): Triggers OAuth login via ApiService, includes access to SetupDialog for editing config.
    - SetupDialog (lib/screens/setup_dialog.dart): Edits Base URL/Client ID and provides embedded instructions to configure OAuth in Frappe.
    - HomeScreen (lib/screens/home.dart): Orchestrates counting workflow, reads assigned items from Hive, manages SQLite DB instance, start/stop count, and displays a slide-in pane for settings or assigned items.
    - EntryDetailsScreen (lib/screens/entry_detail_screen.dart): Displays details and scanned items for a selected StockCountEntry from SQLite.

## Notes from README (condensed)

- Nex Bridge is required on the Frappe/ERPNext server for this app.
- OAuth client in Frappe should be configured with:
  - App Name: Cohenix ESS
  - Redirect URIs: cohenixess://oauth2redirect
  - Default Redirect URI: cohenixess://oauth2redirect
  - Grant Type: Authorization Code
  - Response Type: Code
- On first launch, the app requests:
  - Base URL (e.g., https://your-frappe-server.com)
  - Client ID (from the OAuth Client you created)

## Tooling/automation rules present

- No repository-specific rules for Claude, Cursor, or Copilot were found.
