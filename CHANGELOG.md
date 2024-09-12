### 0.17
* Adding support for rails 7.2. Mostly this was fixing the deprecation of `request.show_exceptions?` and support the various
  values of `Rails.application.config.action_dispatch.show_exceptions`.

### 0.16
* Ensure `decode_rack_response` always calls `#close` on the Rack body in tests, as some middleware might be applying a BodyProxy

### 0.15
* Exclude versions of Rails 7 which were incompatible with the pbbuilder ActionView handler, as pbbuilder cannot work there at all
* Fix decode_rack_response to be compatible with Rack response body wrappers (and conform to the Rack SPEC)

### 0.14
* Adding frozen_string_literal: true to all files.

### 0.13.2
* revert - include `test/` folder in a final gem distribution

### 0.13.1
* Don't include `test/` folder in a final gem distribution
* Format dummy app code with standardrb

### 0.13.0
* Adding #controller_name methods to Metal/Base controller (used for instrumentation)
* Include `ActionController::Caching` with Base controller/helpers


### 0.12

* Allow a custom exception handling proc to be assigned using `RailsTwirp.unhandled_exception_handler`

### 0.11

* Update configuration and tests for Rails 7 compatibility

### 0.10

* Handle exceptions more like the Rails controllers do it, do not capture all of them as if they were Twirp exceptions
