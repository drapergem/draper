# Draper Changelog

## 2.1.0 - 2015-03-26

* Cleared most issues and merged a few PRs
* Improved behavior when decorating structs
* Improved how equality is handled
* Minor improvements to the README

## 2.0.0 - 2015-03-26

Working to breathe new life into the project by shedding baggage.

* Rails 3.2 support dropped
* Ruby 1.9.3 and 2.0 support dropped
* Add support for Rails 4.2 and Ruby 2.2
* Rewrite tests to get over RSpec deprecations
* Get RSpec up to 3.2
* Try to un-screw the challenges of ActiveModelSerializers

Due to the breakages of dropping legacy support, we've bumped the major version. From here,
development effort will likely focus on a version 3.0 that removes features and simplifies
usage of the library.

## 1.3.0 - 2013-10-26

[30 commits by 11 authors](https://github.com/drapergem/draper/compare/v1.2.1...v1.3.0)

* [Add `decorator_class?` method](https://github.com/drapergem/draper/commit/53e1df5c3ee169144a2778c6d2ee13cc6af99429)

* [Clear ViewContext before specs instead of after](https://github.com/drapergem/draper/pull/547)

* [Add alias method `#{model_name}` to the decorated object ](https://github.com/drapergem/draper/commit/f5f27243c3f0c37bff4872e1e78521e570ff1e4f)

* [Hook into `controller_generator` and `scaffold_controller_generator` instead of resource generator](https://github.com/drapergem/draper/commit/cd4f298987c3b4ad8046563ad4a087055fc7efe2)

* [Delegate `to_s` method to the object](https://github.com/drapergem/draper/commit/58b8181050c2a9a86f54660e7bb6bfefa5fd0b64)

## 1.2.1 - 2013-05-05

[28 commits by 4 authors](https://github.com/drapergem/draper/compare/v1.2.0...v1.2.1)

* [Document stubbing route helpers](https://github.com/drapergem/draper/commit/dbe8a81ca7d4d9ae87b4b62926a0ba6379397fbc)

* [Rename `source` to `object`. `source` still works, but will be deprecated in a future release.](https://github.com/drapergem/draper/commit/4b933ef39d252ecfe93c573a072633be545c49fb)

Various bugfixes, as always.

## 1.2.0 - 2013-04-01

[78 commits by 14 authors](https://github.com/drapergem/draper/compare/v1.1.0...v1.2.0)

* [Added license to the gemspec](https://github.com/drapergem/draper/commit/731fa85f7744a12da1364a3aa94cdf6994efa9e2)

* [Improvements in serialization](https://github.com/drapergem/draper/pull/448)

* [Fix support for Guard in development](https://github.com/drapergem/draper/commit/93c95200277fd3922e30e74c7a7e05563747e896)

* [Improved support for #capture](https://github.com/drapergem/draper/commit/efb934a6f59b9d8afe4a7fe29e9a94aae983b05c)

* [CollectionDecorator now has #decorated?](https://github.com/drapergem/draper/commit/65e3c4e4573173b510440b7e80f95a87109a1d15)

* [Added #respond_to_missing?](https://github.com/drapergem/draper/commit/11bb59bcf89f8e0be4ba2851eb78634caf783ecd)

* [Add proper STI support](https://github.com/drapergem/draper/commit/7802d97446cf6ea130a66c2781f5a7a087d28c0a)

* [Added before_remove_const callback for ActiveSupport](https://github.com/drapergem/draper/commit/9efda27c6a4f8680df4fad8f67ecb58e3f91703f)

* [Accept a lambda for context](https://github.com/drapergem/draper/commit/3ab3b35e875b8b2bd99a57e4add388313e765230)

* [Start testing against Ruby 2.0.0](https://github.com/drapergem/draper/commit/dbd1cbceedb0ddb3f060196cd31eb967db8a370b)

* [Fix our use of #scoped per Rails 4 deprecation](https://github.com/haines/draper/commit/47ee29c3b739eee3fc28a561432ad2363c14813c)

* [Properly swallow NameErrors](https://github.com/haines/draper/commit/09ad84fb712a30dd4302b9daa03d11281ac7d169)

* [Delegate CollectionDecorator#kind_of? to the underlying collection](https://github.com/drapergem/draper/commit/d5975f2c5b810306a96d9485fd39d550896dc2a1)

* [Make CollectionDecorators respond to #decorated_with?](https://github.com/drapergem/draper/commit/dc430b3e82de0d9cae86f7297f816e5b69d9ca58)

* [Avoid using #extend in Decorator#== for performance reasons](https://github.com/drapergem/draper/commit/205a0d43b4141f7b1756fe2b44b877545eb37517)

## 1.1.0 - 2013-01-28

[44 commits by 6 authors](https://github.com/drapergem/draper/compare/v1.0.0...v1.1.0)

* README improvements.
* Rails 4 compatibility.
  [b2401c7](https://github.com/drapergem/draper/commit/b2401c71e092470e3b912b5da475115c22b55734)
* Added support for testing decorators without loading `ApplicationController`.
  See the [README](https://github.com/drapergem/draper/blob/v1.1.0/README.md#isolated-tests) for details.
  [4d0181f](https://github.com/drapergem/draper/commit/4d0181fb9c65dc769b05ed19bfcec2119d6e88f7)
* Improved the `==` method to check for `decorated?` before attempting to
  compare with `source`.
  [6c31617](https://github.com/drapergem/draper/commit/6c316176f5039a5861491fbcaa81f64ac4b36768)
* Changed the way helpers are accessed, so that helper methods may be stubbed
  in tests.
  [7a04619](https://github.com/drapergem/draper/commit/7a04619a06f832801bd4aedaaf5985d6e3e5e1af)
* Made the Devise test helper `sign_in` method independent of mocking
  framework.
  [b0902ab](https://github.com/drapergem/draper/commit/b0902ab0fe01916b7fddb0a3d97aa0c7cca09482)
* Stopped attempting to call `to_a` on decorated objects (a now-redundant lazy
  query workaround).
  [34c6390](https://github.com/drapergem/draper/commit/34c6390583f7fc7704d04e38bc974b65fc92517c)
* Fixed a minor bug where view contexts could be accidentally shared between
  tests.
  [3d07cb3](https://github.com/drapergem/draper/commit/3d07cb387b1cae6f97897dfb85512e30f5e888e9)
* Improved helper method performance.
  [e6f88a5](https://github.com/drapergem/draper/commit/e6f88a5e7dada3f9db480e13e16d1acc964ba098)
* Our specs now use the new RSpec `expect( ).to` syntax.
  [9a3b319](https://github.com/drapergem/draper/commit/9a3b319d6d54cd78fb2654a94bbe893e36359754)

## 1.0.0 - 2013-01-14

[249 commits by 19 authors](https://github.com/drapergem/draper/compare/v0.18.0...v1.0.0)

Major changes are described [in the upgrade guide](https://github.com/drapergem/draper/wiki/Upgrading-to-1.0).

* Infer collection decorators.
  [e8253df](https://github.com/drapergem/draper/commit/e8253df7dc6c90a542444c0f4ef289909fce4f90)
* Prevent calls to `scoped` on decorated associations.
  [5dcc6c3](https://github.com/drapergem/draper/commit/5dcc6c31ecf408753158d15fed9fb23fbfdc3734)
* Add `helper` method to tests.
  [551961e](https://github.com/drapergem/draper/commit/551961e72ee92355bc9c848bedfcc573856d12b0)
* Inherit method security.
  [1865ed3](https://github.com/drapergem/draper/commit/1865ed3e3b2b34853689a60b59b8ce9145674d1d)
* Test against all versions of Rails 3.
  [1865ed3](https://github.com/drapergem/draper/commit/1865ed3e3b2b34853689a60b59b8ce9145674d1d)
* Pretend to be `instance_of?(source.class)`.
  [30d209f](https://github.com/drapergem/draper/commit/30d209f990847e84b221ac798e84b976f5775cc0)
* Remove security from `Decorator`. Do manual delegation with `:delegate`.
  [c6f8aaa](https://github.com/drapergem/draper/commit/c6f8aaa2b2bd4679738050aede2503aa8e9db130)
* Add generators for MiniTest.
  [1fac02b](https://github.com/drapergem/draper/commit/1fac02b65b15e32f06e8292cb858c97cb1c1da2c)
* Test against edge rails.
  [e9b71e3](https://github.com/drapergem/draper/commit/e9b71e3cf55a800b48c083ff257a7c1cbe1b601b)

### 1.0.0.beta6 - 2012-12-31

* Fix up README to include changes made.
  [5e6e4d1](https://github.com/drapergem/draper/commit/5e6e4d11b1e0c07c12b6b1e87053bc3f50ef2ab6)
* `CollectionDecorator` no longer freezes its collection: direct access is
  discouraged by making access private.
  [c6d60e6](https://github.com/drapergem/draper/commit/c6d60e6577ed396385f3f1151c3f188fe47e9a57)
* A fix for `Decoratable#==`.
  [e4fa239](https://github.com/drapergem/draper/commit/e4fa239d84e8e9d6a490d785abb3953acc28fa65)
* Ensure we coerce to an array in the right place.
  [9eb9fc9](https://github.com/drapergem/draper/commit/9eb9fc909c372ea1c2392d05594fa75a5c08b095)

### 1.0.0.beta5 - 2012-12-27

* Change CollectionDecorator to freeze its collection.
  [04d7796](https://github.com/drapergem/draper/commit/04d779615c43580409083a71661489e1bbf91ad4)
* Bugfix on `CollectionDecorator#to_s`.
  [eefd7d0](https://github.com/drapergem/draper/commit/eefd7d09cac97d531b9235246378c3746d153f08)
* Upgrade `request_store` dependency to take advantage of a bugfix.
  [9f17212](https://github.com/drapergem/draper/commit/9f17212fd1fb656ef1314327d60fe45e0acf60a2)

### 1.0.0.beta4 - 2012-12-18

* Fixed a race condition with capybara integration.
  [e794649](https://github.com/drapergem/draper/commit/e79464931e7b98c85ed5d78ed9ca38d51f43006e)
* `[]` can be decorated again.
  [597fbdf](https://github.com/drapergem/draper/commit/597fbdf0c80583f5ea6df9f7350fefeaa0cca989)
* `model == decorator` as well as `decorator == model`.
  [46f8a68](https://github.com/drapergem/draper/commit/46f8a6823c50c13e5c9ab3c07723f335c4e291bc)
* Preliminary Mongoid integration.
  [892d195](https://github.com/drapergem/draper/commit/892d1954202c61fd082a07213c8d4a23560687bc)
* Add a helper method `sign_in` for devise in decorator specs.
  [66a3009](https://github.com/drapergem/draper/commit/66a30093ed4207d02d8fa60bda4df2da091d85a3)
* Brought back `context`.
  [9609156](https://github.com/drapergem/draper/commit/9609156b997b3a469386eef3a5f043b24d8a2fba)
* Fixed issue where classes were incorrectly being looked up.
  [ee2a015](https://github.com/drapergem/draper/commit/ee2a015514ff87dfd2158926457e988c2fc3fd79)
* Integrate RequestStore for per-request storage.
  [fde1cde](https://github.com/drapergem/draper/commit/fde1cde9adfb856750c1f616d8b62d221ef97fc6)

### 1.0.0.beta3 - 2012-12-03

* Relaxed Rails version requirement to 3.0. Support for < 3.2 should be
  considered experimental. Please file bug reports.

### 1.0.0.beta2 - 2012-12-03

* `has_finders` is now `decorates_finders`.
  [33f18aa](https://github.com/drapergem/draper/commit/33f18aa062e0d3848443dbd81047f20d5665579f)
* If a finder method is used, and the source class is not set and cannot be
  inferred, an `UninferrableSourceError` is raised.
  [8ef5bf2](https://github.com/drapergem/draper/commit/8ef5bf2f02f7033e3cd4f1f5de7397b02c984fe3)
* Class methods are now properly delegated again.
  [731995a](https://github.com/drapergem/draper/commit/731995a5feac4cd06cf9328d2892c0eca9992db6)
* We no longer `respond_to?` private methods on the source.
  [18ebac8](https://github.com/drapergem/draper/commit/18ebac81533a6413aa20a3c26f23e91d0b12b031)
* Rails versioning relaxed to support Rails 4.
  [8bfd393](https://github.com/drapergem/draper/commit/8bfd393b5baa7aa1488076a5e2cb88648efaa815)

### 1.0.0.beta1 - 2012-11-30

* Renaming `Draper::Base` to `Draper::Decorator`. This is the most significant
  change you'll need to upgrade your application.
  [025742c](https://github.com/drapergem/draper/commit/025742cb3b295d259cf0ecf3669c24817d6f2df1)
* Added an internal Rails application for integration tests. This won't affect
  your application, but we're now running a set of Cucumber tests inside of a
  Rails app in both development and production mode to help ensure that we
  don't make changes that break Draper.
  [90a4859](https://github.com/drapergem/draper/commit/90a4859085cab158658d23d77cd3108b6037e36f)
* Add `#decorated?` method. This gives us a free RSpec matcher,
  `be_decorated`.
  [834a6fd](https://github.com/drapergem/draper/commit/834a6fd1f24b5646c333a04a99fe9846a58965d6)
* `#decorates` is no longer needed inside your models, and should be removed.
  Decorators automatically infer the class they decorate.
  [e1214d9](https://github.com/drapergem/draper/commit/e1214d97b62f2cab45227cc650029734160dcdfe)
* Decorators do not automatically come with 'finders' by default. If you'd like
  to use `SomeDecorator.find(1)`, for example, simply add `#has_finders` to
  the decorator to include them.
  [42b6f78](https://github.com/drapergem/draper/commit/42b6f78fda4f51845dab4d35da68880f1989d178)
* To refer to the object being decorated, `#source` is now the preferred
  method.
  [1e84fcb](https://github.com/drapergem/draper/commit/1e84fcb4a0eab0d12f5feda6886ce1caa239cb16)
* `ActiveModel::Serialization` is included in Decorators if you've requred
  `ActiveModel::Serializers`, so that decorators can be serialized.
  [c4b3527](https://github.com/drapergem/draper/commit/c4b352799067506849abcbf14963ea36abda301c)
* Properly support Test::Unit.
  [087e134](https://github.com/drapergem/draper/commit/087e134ed0885ec11325ffabe8ab2bebef77a33a)

And many small bug fixes and refactorings.

## 0.x

See changes prior to version 1.0 [here](https://github.com/drapergem/draper/blob/16140fed55f57d18f8b10a0789dd1fa5b3115a8d/CHANGELOG.markdown).
