# Draper: View Models for Rails

[![TravisCI Build Status](https://secure.travis-ci.org/drapergem/draper.png?branch=master)](http://travis-ci.org/drapergem/draper)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/drapergem/draper)

Draper adds a nicely-separated object-oriented layer of presentation logic to your Rails apps. Previously, this logic might have been tangled up in procedural helpers, or contributing to your fat models' weight problems. Now, you can wrap your models up in decorators to organise - and test - this layer of your app much more effectively.


## Overview

With Draper, your `Article` model has a corresponding `ArticleDecorator`. The decorator wraps the model, and deals only with presentational concerns. In the controller, you simply decorate your article before handing it off to the view.

```ruby
# app/controllers/articles_controller.rb
def show
  @article = Article.find(params[:id]).decorate
end
```

In the view, you can use the decorator in exactly the same way as you would have used the model. The difference is, any time you find yourself needing to write a helper, you can implement a method on the decorator instead. For example, this helper:

```ruby
# app/helpers/articles_helper.rb
def publication_status(article)
  if article.published?
    "Published at #{article.published_at.strftime('%A, %B %e')}"
  else
    "Unpublished"
  end
end
```

could be better written as:

```ruby
# app/decorators/article_decorator.rb
class ArticleDecorator < Draper::Decorator
  delegate_all

  def publication_status
    if published?
      "Published at #{published_at}"
    else
      "Unpublished"
    end
  end

  def published_at
    source.published_at.strftime("%A, %B %e")
  end
end
```

Notice that the `published?` method can be called even though `ArticleDecorator` doesn't define it - thanks to `delegate_all`, the decorator delegates missing methods to the source model. However, we can override methods like `published_at` to add presentation-specific formatting, in which case we access the underlying model using the `source` method.

You might have heard this sort of decorator called a "presenter", an "exhibit", a "view model", or even just a "view" (in that nomenclature, what Rails calls "views" are actually "templates"). Whatever you call it, it's a great way to replace procedural helpers like the one above with "real" object-oriented programming.

Decorators are the ideal place to:
* format dates and times using `strftime`,
* define commonly-used representations of an object, like a `name` method that combines `first_name` and `last_name` attributes,
* mark up attributes with a little semantic HTML, like turning a `url` field into a hyperlink.


## Installation

Add Draper to your Gemfile:

```ruby
gem 'draper', '~> 1.0.0.beta6'
```

And run `bundle install` within your app's directory.


## Writing decorators

Decorators inherit from `Draper::Decorator`, live in your `app/decorators` directory, and are named for the model that they decorate:

```ruby
# app/decorators/article_decorator.rb
class ArticleDecorator < Draper::Decorator
# ...
end
```

### Generators

When you generate a resource with `rails generate resource Article`, you get a decorator for free! But if the `Article` model already exists, you can run `rails generate decorator Article` to create the `ArticleDecorator`.

### Accessing helpers

Procedural helpers are still useful for generic tasks like generating HTML, and as such you can access all this goodness (both built-in Rails helpers, and your own) through the `helpers` method:

```ruby
class ArticleDecorator < Draper::Decorator
  def emphatic
    helpers.content_tag(:strong, "Awesome")
  end
end
```

To save your typing fingers it's aliased to `h`. If that's still too much effort, just pop `include Draper::LazyHelpers` at the top of your decorator class - you'll mix in a bazillion methods and never have to type `h.` again... [if that's your sort of thing](https://github.com/garybernhardt/base).

### Accessing the model

Decorators will delegate methods to the model where possible, which means in most cases you can replace a model with a decorator and your view won't notice the difference. When you need to get your hands on the underlying model the `source` method is your friend (and its aliases `model` and `to_source`):

```ruby
class ArticleDecorator < Draper::Decorator
  delegate_all

  def published_at
    source.published_at.strftime("%A, %B %e")
  end
end
```


## Decorating

### Single objects

Ok, so you've written a sweet decorator, now you're going to want to put it in action! A simple option is to call the `decorate` method on your model:

```ruby
@article = Article.first.decorate
```

This infers the decorator from the object being decorated. If you want more control - say you want to decorate a `Widget` with a more general `ProductDecorator` - then you can instantiate a decorator directly:

```ruby
@widget = ProductDecorator.new(Widget.first)
# or, equivalently
@widget = ProductDecorator.decorate(Widget.first)
```

### Collections

If you have a whole bunch of objects, you can decorate them all in one fell swoop:

```ruby
@articles = ArticleDecorator.decorate_collection(Article.all)
# or, for scopes (but not `all`)
@articles = Article.popular.decorate
```

If you want to add methods to your decorated collection (for example, for pagination), you can subclass `Draper::CollectionDecorator`:

```ruby
# app/decorators/articles_decorator.rb
class ArticlesDecorator < Draper::CollectionDecorator
  def page_number
    42
  end
end

# elsewhere...
@articles = ArticlesDecorator.new(Article.all)
# or, equivalently
@articles = ArticlesDecorator.decorate(Article.all)
```

Draper guesses the decorator used for each item from the name of the collection decorator (`ArticlesDecorator` becomes `ArticleDecorator`). If that fails, it falls back to using each item's `decorate` method. Alternatively, you can specify a decorator by overriding the collection decorator's `decorator_class` method.

Some pagination gems add methods to `ActiveRecord::Relation`. For example, [Kaminari](https://github.com/amatsuda/kaminari)'s `paginate` helper method requires the collection to implement `current_page`, `total_pages`, and `limit_value`. To expose these on a collection decorator, you can simply delegate to the `source`:

```ruby
class PaginatingDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value
end
```

The `delegate` method used here is the same as that added by [Active Support](http://api.rubyonrails.org/classes/Module.html#method-i-delegate), except that the `:to` option is not required; it defaults to `:source` when omitted.

### Handy shortcuts

You can automatically decorate associated models:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author
end
```

And, if you want, you can add decorated finder methods:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_finders
end
```

so that you can do:

```ruby
@article = ArticleDecorator.find(params[:id])
```


## Testing

Draper supports RSpec, MiniTest::Rails, and Test::Unit, and will add the appropriate tests when you generate a decorator.

### RSpec

Your specs should live in `spec/decorators` (if not, you need to tag them with `type: :decorator`).

In controller specs, you might want to check whether your instance variables are being decorated properly. You can use the handy predicate matchers:

```ruby
assigns(:article).should be_decorated
# or, if you want to be more specific
assigns(:article).should be_decorated_with ArticleDecorator
```

Note that `model.decorate == model`, so your existing specs shouldn't break when you add the decoration.

Spork users should `require 'draper/test/rspec_integration'` in the `Spork.prefork` block.


## Advanced usage

### `ApplicationDecorator`

If you need common methods in your decorators, you can create an `ApplicationDecorator`:

```ruby
# app/decorators/application_decorator.rb
class ApplicationDecorator < Draper::Decorator
# ...
end
```

and inherit from it instead of directly from `Draper::Decorator`.

### Enforcing an interface between controllers and views

The `delegate_all` call at the top of your decorator means that all missing methods will delegated to the source. If you want to strictly control which methods are called in your views, you can choose to only delegate certain methods.

```ruby
class ArticleDecorator < Draper::Decorator
  delegate :title, :author
end
```

As mentioned above for `CollectionDecorator`, the `delegate` method defaults to using `:source` if the `:to` option is omitted.


### Adding context

If you need to pass extra data to your decorators, you can use a `context` hash. Methods that create decorators take it as an option, for example

```ruby
Article.first.decorate(context: {role: :admin})
```

The value passed to the `:context` option is then available in the decorator through the `context` method.

If you use `decorates_association`, the context of the parent decorator is passed to the associated decorators. You can override this with the `:context` option:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author, context: {foo: "bar"}
end
```

or, if you simply want to modify the parent's context, use a lambda that takes a hash and returns a new hash:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author,
    context: ->(parent_context){ parent_context.merge(foo: "bar") }
end
```

### Specifying decorators

When you're using `decorates_association`, Draper uses the `decorate` method on the associated record (or each associated record, in the case of a collection association) to perform the decoration. If you want use a specific decorator, you can use the `:with` option:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author, with: FancyPersonDecorator
end
```

For a collection association, you can specify a `CollectionDecorator` subclass, which is applied to the whole collection, or a singular `Decorator` subclass, which is applied to each item individually.

### Scoping associations

If you want your decorated association to be ordered, limited, or otherwise scoped, you can pass a `:scope` option to `decorates_association`, which will be applied to the collection before decoration:

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :comments, scope: :recent
end
```

### Breaking with convention

If, as well as instance methods, you want to proxy class methods to the model through the decorator (including when using `decorates_finders`), Draper needs to know the model class. By default, it assumes that your decorators are named `SomeModelDecorator`, and then attempts to proxy unknown class methods to `SomeModel`. If your model name can't be inferred from your decorator name in this way, you need to use the `decorates` method:

```ruby
class MySpecialArticleDecorator < Draper::Decorator
  decorates :article
end
```

You don't need to worry about this if you don't want to proxy class methods.

### Making models decoratable

Models get their `decorate` method from the `Draper::Decoratable` module, which is included in `ActiveRecord::Base` and `Mongoid::Document` by default. If you're using another ORM, or want to decorate plain old Ruby objects, you can include this module manually.


## Contributors

Draper was conceived by Jeff Casimir and heavily refined by Steve Klabnik and a great community of open source [contributors](https://github.com/drapergem/draper/contributors).

### Core Team

* Jeff Casimir (jeff@jumpstartlab.com)
* Steve Klabnik (steve@jumpstartlab.com)
* Vasiliy Ermolovich
* Andrew Haines
