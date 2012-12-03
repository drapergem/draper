# Draper Changelog

## 1.0.0.beta3

* Relaxed Rails version requirement to 3.0. Support for < 3.2 should be
  considered experimental. Please file bug reports.

## 1.0.0.beta2

* `has_finders` is now `decorates_finders`. [https://github.com/haines/draper/commit/33f18aa062e0d3848443dbd81047f20d5665579f](https://github.com/haines/draper/commit/33f18aa062e0d3848443dbd81047f20d5665579f)

* If a finder method is used, and the source class is not set and cannot be inferred, an `UninferrableSourceError` is raised. [https://github.com/haines/draper/commit/8ef5bf2f02f7033e3cd4f1f5de7397b02c984fe3](https://github.com/haines/draper/commit/8ef5bf2f02f7033e3cd4f1f5de7397b02c984fe3)

* Class methods are now properly delegated again. [https://github.com/haines/draper/commit/731995a5feac4cd06cf9328d2892c0eca9992db6](https://github.com/haines/draper/commit/731995a5feac4cd06cf9328d2892c0eca9992db6)

* We no longer `respond_to?` private methods on the source. [https://github.com/haines/draper/commit/18ebac81533a6413aa20a3c26f23e91d0b12b031](https://github.com/haines/draper/commit/18ebac81533a6413aa20a3c26f23e91d0b12b031)

* Rails versioning relaxed to support Rails 4 [https://github.com/drapergem/draper/commit/8bfd393b5baa7aa1488076a5e2cb88648efaa815](https://github.com/drapergem/draper/commit/8bfd393b5baa7aa1488076a5e2cb88648efaa815)

## 1.0.0.beta1

* Renaming `Draper::Base` to `Draper::Decorator`. This is the most significant
  change you'll need to upgrade your application. [https://github.com/drapergem/draper/commit/025742cb3b295d259cf0ecf3669c24817d6f2df1](https://github.com/drapergem/draper/commit/025742cb3b295d259cf0ecf3669c24817d6f2df1)
* Added an internal Rails application for integration tests. This won't affect
  your application, but we're now running a set of Cucumber tests inside of a
  Rails app in both development and production mode to help ensure that we
  don't make changes that break Draper. [https://github.com/drapergem/draper/commit/90a4859085cab158658d23d77cd3108b6037e36f](https://github.com/drapergem/draper/commit/90a4859085cab158658d23d77cd3108b6037e36f)
* Add `#decorated?` method. This gives us a free RSpec matcher,
  `is_decorated?`. [https://github.com/drapergem/draper/commit/834a6fd1f24b5646c333a04a99fe9846a58965d6](https://github.com/drapergem/draper/commit/834a6fd1f24b5646c333a04a99fe9846a58965d6)
* `#decorates` is no longer needed inside your models, and should be removed.
  Decorators automatically infer the class they decorate. [https://github.com/drapergem/draper/commit/e1214d97b62f2cab45227cc650029734160dcdfe](https://github.com/drapergem/draper/commit/e1214d97b62f2cab45227cc650029734160dcdfe)
* Decorators do not automatically come with 'finders' by default. If you'd like
  to use `SomeDecorator.find(1)`, for example, simply add `#has_finders` to
  the decorator to include them. [https://github.com/drapergem/draper/commit/42b6f78fda4f51845dab4d35da68880f1989d178](https://github.com/drapergem/draper/commit/42b6f78fda4f51845dab4d35da68880f1989d178)
* To refer to the object being decorated, `#source` is now the preferred
  method. [https://github.com/drapergem/draper/commit/1e84fcb4a0eab0d12f5feda6886ce1caa239cb16](https://github.com/drapergem/draper/commit/1e84fcb4a0eab0d12f5feda6886ce1caa239cb16)
* `ActiveModel::Serialization` is included in Decorators if you've requred
  `ActiveModel::Serializers`, so that decorators can be serialized. [https://github.com/drapergem/draper/commit/c4b352799067506849abcbf14963ea36abda301c](https://github.com/drapergem/draper/commit/c4b352799067506849abcbf14963ea36abda301c)
* Properly support Test::Unit [https://github.com/drapergem/draper/commit/087e134ed0885ec11325ffabe8ab2bebef77a33a](https://github.com/drapergem/draper/commit/087e134ed0885ec11325ffabe8ab2bebef77a33a)

And many small bug fixes and refactorings.

## 0.18.0

* [Adds the ability to decorate an enumerable proxy](https://github.com/drapergem/draper/commit/67c7125192740a7586a3a635acd735ae01b97837)

* Many bug fixes.

* Last version of Draper in the 0.x series.

## 0.17.0

* [Fix earlier fix of `view_context` priming](https://github.com/jcasimir/draper/commit/5da44336)
* [Add `denies_all`](https://github.com/jcasimir/draper/commit/148e732)
* [Properly proxy associations with regard to `find`](https://github.com/jcasimir/draper/commit/d46d19205e)

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
