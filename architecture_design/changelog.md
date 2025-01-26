# Enki Finance Changelog

## [Unreleased]

### Added
- Transaction synchronization with Supabase
- Real-time transaction updates using Supabase streams
- Transaction validation using database functions:
  - Credit card limit validation
  - Jar requirement validation
  - Balance validation
- Enhanced error handling and validation feedback
- Transaction filtering capabilities
- Transaction form with validation
- Transaction list with real-time updates
- Transaction details page with related data
- Local storage support for offline transactions
- Pending changes management for sync conflicts
- Implemented `AccountService` in domain layer for business logic
- Added `AccountException` for domain-specific error handling
- Added `hasTransactions` method to check for account dependencies
- Improved error handling with domain-specific exceptions
- Implemented `JarService` in domain layer for jar management
- Added `JarException` hierarchy for domain-specific errors
- Added `JarDistribution` entity for analyzing jar distributions
- Added jar validation and transfer logic in domain layer

### Changed
- Updated transaction repository to use filters
- Enhanced transaction form with proper null safety
- Improved transaction list performance with caching
- Modified transaction details to show related data
- Simplified Supabase stream mapping for better reliability
- Migrated account and auth business logic from database to domain layer
- Updated account providers to use new `AccountService`
- Improved error handling with domain-specific exceptions
- Enhanced validation logic with proper domain rules
- Migrated jar business logic from database to domain layer
- Enhanced jar validation with proper domain rules
- Improved jar transfer handling with better error messages

### Fixed
- Null safety issues in transaction form
- Linter errors in transaction sync service
- Type mismatches in transaction stream provider
- Method signature mismatch in `TransactionRepository` implementation
- Error handling with proper failure messages
- Type casting issues in query filters
- Filter builder chain in repository
- RPC function name for transaction summary

### Pending Improvements
#### Analytics [TODO-ANALYTICS]
- [ ] Implement `analyze_transactions_by_category` function
- [ ] Add transaction summary views using `get_period_summary`
- [ ] Create charts and visualizations for spending patterns

#### Search and Filtering [TODO-SEARCH]
- [ ] Implement `search_transactions_by_notes`
- [ ] Implement `search_transactions_by_tags`
- [ ] Add tag management for transactions
- [ ] Enhance filtering with saved filters

#### Export Functionality [TODO-EXPORT]
- [ ] Implement `export_transactions_to_excel`
- [ ] Add PDF export for transaction statements
- [ ] Support multiple export formats

#### Credit Card Integration [TODO-CREDIT]
- [ ] Add credit card statement generation
- [ ] Implement installment purchase tracking
- [ ] Add credit card summary views

#### Performance [TODO-PERF]
- [ ] Implement local caching for offline support
- [ ] Add pagination for large transaction lists
- [ ] Optimize database queries

#### User Experience [TODO-UX]
- [ ] Add transaction templates
- [ ] Implement batch transaction operations
- [ ] Add transaction categorization suggestions

### Pending Fixes
#### Repository [FIX-REPO]
- [ ] Fix method signature mismatch in `TransactionRepository` implementation
- [ ] Add proper error handling with failure messages
- [ ] Fix type casting issues in query filters

#### Sync Service [FIX-SYNC]
- [ ] Fix Supabase stream mapping in `TransactionSyncService`
- [ ] Implement local storage for offline support
- [ ] Add proper error handling for sync conflicts

#### Form Validation [FIX-FORM]
- [ ] Improve form validation error messages
- [ ] Add client-side validation before server calls
- [ ] Handle edge cases in amount validation

#### Performance Issues [FIX-PERF]
- [ ] Optimize transaction list rendering
- [ ] Reduce unnecessary API calls
- [ ] Improve state management efficiency

### Removed
- Database functions for account validation:
  - `validate_account_transfer`
  - `validate_account_status`
  - `check_account_exists`
- Auth-related database functions:
  - `handle_auth_user_created`
  - `handle_auth_user_deleted`
  - `handle_user_deletion`
- Database triggers:
  - `validate_account_status_trigger`
  - `handle_auth_user_created_trigger`
  - `handle_auth_user_deleted_trigger`
- Temporary tables:
  - `temp_account_validation`
  - `temp_auth_user_mapping`
- Database functions for jar management:
  - `analyze_jar_distribution`
  - `export_jar_status_to_excel`
  - `execute_jar_transfer`
  - `validate_jar_transfer`
  - `check_jar_requirement`
- Database triggers for jar validation:
  - `check_jar_requirement_trigger`
  - `validate_jar_transfer_trigger`
- Custom types:
  - `jar_distribution_summary`
  - `transfer_validation_result`
- Temporary tables:
  - `temp_jar_distribution`
  - `temp_jar_transfers`

## [1.0.0] - 2024-01-23
### Initial Release
- Basic transaction management
- Category and subcategory support
- Account and jar management
- Transaction filtering
- Real-time updates 

## Pending Tasks

### Testing
- Fix Supabase mock implementations in transaction repository tests:
  - Resolve type mismatches between `MockPostgrestFilterBuilder` and `SupabaseQueryBuilder`
  - Implement missing methods `eq` and `order` in `SupabaseQueryBuilder` mock
  - Update test setup to use correct mock hierarchy for Supabase client
  - Ensure proper type safety in mock implementations 