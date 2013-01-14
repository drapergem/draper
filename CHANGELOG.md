# Draper Changelog

## 1.0.0

Major changes from 0.18.0 to 1.0.0 are outlined [in the wiki](https://github.com/drapergem/draper/wiki/Upgrading-to-1.0).


* Infer collection decorators. [https://github.com/drapergem/draper/commit/e8253df7dc6c90a542444c0f4ef289909fce4f90](https://github.com/drapergem/draper/commit/e8253df7dc6c90a542444c0f4ef289909fce4f90)

* Prevent calls to `scoped` on decorated associations. [https://github.com/drapergem/draper/commit/5dcc6c31ecf408753158d15fed9fb23fbfdc3734](https://github.com/drapergem/draper/commit/5dcc6c31ecf408753158d15fed9fb23fbfdc3734)

* Add `helper` method to tests. [https://github.com/drapergem/draper/commit/551961e72ee92355bc9c848bedfcc573856d12b0](https://github.com/drapergem/draper/commit/551961e72ee92355bc9c848bedfcc573856d12b0)

* Inherit method security. [https://github.com/drapergem/draper/commit/1865ed3e3b2b34853689a60b59b8ce9145674d1d](https://github.com/drapergem/draper/commit/1865ed3e3b2b34853689a60b59b8ce9145674d1d)

* Test against all versions of Rails 3. [https://github.com/drapergem/draper/commit/1865ed3e3b2b34853689a60b59b8ce9145674d1d](https://github.com/drapergem/draper/commit/1865ed3e3b2b34853689a60b59b8ce9145674d1d)

* Pretend to be `instance_of?(source.class)` [https://github.com/drapergem/draper/commit/30d209f990847e84b221ac798e84b976f5775cc0](https://github.com/drapergem/draper/commit/30d209f990847e84b221ac798e84b976f5775cc0)

* Remove security from `Decorator`. Do manual delegation with `:delegate`. [https://github.com/drapergem/draper/commit/c6f8aaa2b2bd4679738050aede2503aa8e9db130](https://github.com/drapergem/draper/commit/c6f8aaa2b2bd4679738050aede2503aa8e9db130)

* Add generators for MiniTest. [https://github.com/drapergem/draper/commit/1fac02b65b15e32f06e8292cb858c97cb1c1da2c](https://github.com/drapergem/draper/commit/1fac02b65b15e32f06e8292cb858c97cb1c1da2c)

* Test against edge rails. [https://github.com/drapergem/draper/commit/e9b71e3cf55a800b48c083ff257a7c1cbe1b601b](https://github.com/drapergem/draper/commit/e9b71e3cf55a800b48c083ff257a7c1cbe1b601b)

## 1.0.0.beta6

* Fix up README to include changes made. [https://github.com/drapergem/draper/commit/5e6e4d11b1e0c07c12b6b1e87053bc3f50ef2ab6](https://github.com/drapergem/draper/commit/5e6e4d11b1e0c07c12b6b1e87053bc3f50ef2ab6)

* `CollectionDecorator` no longer freezes its collection: direct access is discouraged by making access private [https://github.com/drapergem/draper/commit/c6d60e6577ed396385f3f1151c3f188fe47e9a57](https://github.com/drapergem/draper/commit/c6d60e6577ed396385f3f1151c3f188fe47e9a57)

* A fix for `Decoratable#==` [https://github.com/drapergem/draper/commit/e4fa239d84e8e9d6a490d785abb3953acc28fa65](https://github.com/drapergem/draper/commit/e4fa239d84e8e9d6a490d785abb3953acc28fa65)

* Ensure we coerce to an array in the right place. [https://github.com/drapergem/draper/commit/9eb9fc909c372ea1c2392d05594fa75a5c08b095](https://github.com/drapergem/draper/commit/9eb9fc909c372ea1c2392d05594fa75a5c08b095)

## 1.0.0.beta5

* Change CollectionDecorator to freeze its collection [https://github.com/drapergem/draper/commit/04d779615c43580409083a71661489e1bbf91ad4](https://github.com/drapergem/draper/commit/04d779615c43580409083a71661489e1bbf91ad4)

* Bugfix on `CollectionDecorator#to_s` [https://github.com/drapergem/draper/commit/eefd7d09cac97d531b9235246378c3746d153f08](https://github.com/drapergem/draper/commit/eefd7d09cac97d531b9235246378c3746d153f08)

* Upgrade `request_store` dependency to take advantage of a bugfix [https://github.com/drapergem/draper/commit/9f17212fd1fb656ef1314327d60fe45e0acf60a2](https://github.com/drapergem/draper/commit/9f17212fd1fb656ef1314327d60fe45e0acf60a2)

## 1.0.0.beta4

* Fixed a race condition with capybara integration. [https://github.com/drapergem/draper/commit/e79464931e7b98c85ed5d78ed9ca38d51f43006e](https://github.com/drapergem/draper/commit/e79464931e7b98c85ed5d78ed9ca38d51f43006e)

* `[]` can be decorated again. [https://github.com/drapergem/draper/commit/597fbdf0c80583f5ea6df9f7350fefeaa0cca989](https://github.com/drapergem/draper/commit/597fbdf0c80583f5ea6df9f7350fefeaa0cca989)

* `model == decorator` as well as `decorator == model`. [https://github.com/drapergem/draper/commit/46f8a6823c50c13e5c9ab3c07723f335c4e291bc](https://github.com/drapergem/draper/commit/46f8a6823c50c13e5c9ab3c07723f335c4e291bc)

* Preliminary Mongoid integration. [https://github.com/drapergem/draper/commit/892d1954202c61fd082a07213c8d4a23560687bc](https://github.com/drapergem/draper/commit/892d1954202c61fd082a07213c8d4a23560687bc)

* Add a helper method `sign_in` for devise in decorator specs. [https://github.com/drapergem/draper/commit/66a30093ed4207d02d8fa60bda4df2da091d85a3](https://github.com/drapergem/draper/commit/66a30093ed4207d02d8fa60bda4df2da091d85a3)

* Brought back `context`. [https://github.com/drapergem/draper/commit/9609156b997b3a469386eef3a5f043b24d8a2fba](https://github.com/drapergem/draper/commit/9609156b997b3a469386eef3a5f043b24d8a2fba)

* Fixed issue where classes were incorrectly being looked up. [https://github.com/drapergem/draper/commit/ee2a015514ff87dfd2158926457e988c2fc3fd79](https://github.com/drapergem/draper/commit/ee2a015514ff87dfd2158926457e988c2fc3fd79)

* Integrate RequestStore for per-request storage. [https://github.com/drapergem/draper/commit/fde1cde9adfb856750c1f616d8b62d221ef97fc6](https://github.com/drapergem/draper/commit/fde1cde9adfb856750c1f616d8b62d221ef97fc6)

## 1.0.0.beta3

* Relaxed Rails version requirement to 3.0. Support for < 3.2 should be
  considered experimental. Please file bug reports.

## 1.0.0.beta2

* `has_finders` is now `decorates_finders`. [https://github.com/drapergem/draper/commit/33f18aa062e0d3848443dbd81047f20d5665579f](https://github.com/drapergem/draper/commit/33f18aa062e0d3848443dbd81047f20d5665579f)

* If a finder method is used, and the source class is not set and cannot be inferred, an `UninferrableSourceError` is raised. [https://github.com/drapergem/draper/commit/8ef5bf2f02f7033e3cd4f1f5de7397b02c984fe3](https://github.com/drapergem/draper/commit/8ef5bf2f02f7033e3cd4f1f5de7397b02c984fe3)

* Class methods are now properly delegated again. [https://github.com/drapergem/draper/commit/731995a5feac4cd06cf9328d2892c0eca9992db6](https://github.com/drapergem/draper/commit/731995a5feac4cd06cf9328d2892c0eca9992db6)

* We no longer `respond_to?` private methods on the source. [https://github.com/drapergem/draper/commit/18ebac81533a6413aa20a3c26f23e91d0b12b031](https://github.com/drapergem/draper/commit/18ebac81533a6413aa20a3c26f23e91d0b12b031)

* Rails versioning relaxed to support Rails 4 [https://github.com/drapergem/draper/commit/8bfd393b5baa7aa1488076a5e2cb88648efaa815](https://github.com/drapergem/draper/commit/8bfd393b5baa7aa1488076a5e2cb88648efaa815)

## 1.0.0.beta1

* Renaming `Draper::Base` to `Draper::Decorator`. This is the most significant
  change you'll need to upgrade your application. [https://github.com/drapergem/draper/commit/025742cb3b295d259cf0ecf3669c24817d6f2df1](https://github.com/drapergem/draper/commit/025742cb3b295d259cf0ecf3669c24817d6f2df1)
* Added an internal Rails application for integration tests. This won't affect
  your application, but we're now running a set of Cucumber tests inside of a
  Rails app in both development and production mode to help ensure that we
  don't make changes that break Draper. [https://github.com/drapergem/draper/commit/90a4859085cab158658d23d77cd3108b6037e36f](https://github.com/drapergem/draper/commit/90a4859085cab158658d23d77cd3108b6037e36f)
* Add `#decorated?` method. This gives us a free RSpec matcher,
  `be_decorated`. [https://github.com/drapergem/draper/commit/834a6fd1f24b5646c333a04a99fe9846a58965d6](https://github.com/drapergem/draper/commit/834a6fd1f24b5646c333a04a99fe9846a58965d6)
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

* [Fix earlier fix of `view_context` priming](https://github.com/drapergem/draper/commit/5da44336)
* [Add `denies_all`](https://github.com/drapergem/draper/commit/148e732)
* [Properly proxy associations with regard to `find`](https://github.com/drapergem/draper/commit/d46d19205e)

## 0.16.0

* [Automatically prime `view_context`](https://github.com/drapergem/draper/commit/057ab4e8)
* [Fixed bug where rspec eq matchers didn't work]((https://github.com/drapergem/draper/commit/57617b)
* [Sequel ORM support](https://github.com/drapergem/draper/commit/7d4942)
* Fixed issues with newer minitest
* [Changed the way the `view_context` gets set](https://github.com/drapergem/draper/commit/0b03d9c)

## 0.15.0

* Proper minitest integration
* [We can properly decorate scoped associations](https://github.com/drapergem/draper/issues/223)
* [Fixed awkward eager loading](https://github.com/drapergem/draper/commit/7dc3510b)

## 0.14.0

* [Properly prime the view context in Rails Console](https://github.com/drapergem/draper/commit/738074f)
* Make more gems development requirements only

## 0.13.0

* Upgraded all dependencies
* Dropped support for Rubies < 1.9.3
* `#to_model` has been renamed to `#wrapped_object`
* Allow proper overriding of special `ActiveModel` methods

## 0.12.3

* [Fix i18n issue](https://github.com/drapergem/draper/issues/202)

## 0.12.2

* Fix bug with initializing ammeter
* Some gems are now development only in the gemspec
* Fix bug where generated models were still inheriting from `ApplicationDecorator`

## 0.12.0

* Added Changelog
* [Prevented double decoration](https://github.com/drapergem/draper/issues/173)
* [`ActiveModel::Errors` support](https://github.com/drapergem/draper/commit/19496f0c)
* [Fixed autoloading issue](https://github.com/drapergem/draper/issues/188)
* [Re-did generators](https://github.com/drapergem/draper/commit/9155e58f)
* [Added capybara integration](https://github.com/drapergem/draper/commit/57c8678e)
* Fixed a few bugs with the `DecoratedEnumerableProxy`

## 0.11.1

* [Fixed regression, we don't want to introduce a hard dependency on Rails](https://github.com/drapergem/draper/issues/107)
