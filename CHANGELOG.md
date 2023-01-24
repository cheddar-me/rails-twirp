### 0.13.0
* loosen twirp dependency

### 0.13.0
* Adding #controller_name methods to Metal/Base controller (used for instrumentation)
* Include `ActionController::Caching` with Base controller/helpers


### 0.12.0

* Allow a custom exception handling proc to be assigned using `RailsTwirp.unhandled_exception_handler`

### 0.11.0

* Update configuration and tests for Rails 7 compatibility

### 0.10.0

* Handle exceptions more like the Rails controllers do it, do not capture all of them as if they were Twirp exceptions
