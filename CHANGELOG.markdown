# Draper Changelog

## 0.16.0

* [Automatically prime `view_context`](https://github.com/jcasimir/draper/commit/057ab4e8)
* [Fixed bug where rspec eq matchers didn't work]((https://github.com/jcasimir/draper/commit/57617b)
* [Sequel ORM support](https://github.com/jcasimir/draper/commit/7d4942)
* Fixed issues with newer minitest
* [Changed the way the `view_context` gets set](https://github.com/jcasimir/draper/commit/0b03d9c)

## 0.15.0

* Proper minitest integration
* [We can properly decorate scoped associations](https://github.com/jcasimir/draper/issues/223)
* [Fixed awkward eager loading](https://github.com/jcasimir/draper/commit/7dc3510b)

## 0.14.0

* [Properly prime the view context in Rails Console](https://github.com/jcasimir/draper/commit/738074f)
* Make more gems development requirements only

## 0.13.0

* Upgraded all dependencies
* Dropped support for Rubies < 1.9.3
* `#to_model` has been renamed to `#wrapped_object`
* Allow proper overriding of special `ActiveModel` methods

## 0.12.3

* [Fix i18n issue](https://github.com/jcasimir/draper/issues/202)

## 0.12.2

* Fix bug with initializing ammeter
* Some gems are now development only in the gemspec
* Fix bug where generated models were still inheriting from `ApplicationDecorator`

## 0.12.0

* Added Changelog
* [Prevented double decoration](https://github.com/jcasimir/draper/issues/173)
* [`ActiveModel::Errors` support](https://github.com/jcasimir/draper/commit/19496f0c)
* [Fixed autoloading issue](https://github.com/jcasimir/draper/issues/188)
* [Re-did generators](https://github.com/jcasimir/draper/commit/9155e58f)
* [Added capybara integration](https://github.com/jcasimir/draper/commit/57c8678e)
* Fixed a few bugs with the `DecoratedEnumerableProxy`

## 0.11.1

* [Fixed regression, we don't want to introduce a hard dependency on Rails](https://github.com/jcasimir/draper/issues/107)
