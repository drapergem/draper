## Heads Up!

This gem is not yet production ready. The API is sure to change quickly and there could be side-effects I haven't discovered yet.

Please only use it if you're playing around and helping me experiment! Thanks :)

# Draper

This gem makes it easy to apply the decorator pattern to the models in a Rails application.

## Why use decorators?

Helpers, as they're commonly used, are a bit odd. In both Ruby and Rails we approach everything from an Object-Oriented perspective, then with helpers we get procedural.

The job of a helper is to take in data or a data object and output presentation-ready results. We can do that job in an OO fashion with a decorator.

In general, a decorator wraps an object with presentation-related accessor methods. For instance, if you had an `Article` object, then a decorator might add instance methods like `.formatted_published_at` or `.formatted_title` that output actual HTML.

## How is it implemented?

To implement the pattern in Rails we can:

1. Write a wrapper class with the decoration methods
2. Wrap the data object
3. Utilize those methods within our view layer

## How do you utilize this gem in your application?

Here are the steps to utilizing this gem:

Add the dependency to your `Gemfile`:

```
gem "draper"
```

Run bundle:

```
bundle
```

Create a decorator for your model (ex: `Article`)

```
rails generate draper:model Article
```

Open the decorator model (ex: `app/decorators/article_decorator.rb`)

Add your new formatting methods as normal instance or class methods. You have access to the Rails helpers from the following classes:

```
ActionView::Helpers::TagHelper
ActionView::Helpers::UrlHelper
ActionView::Helpers::TextHelper
```

Use the new methods in your views like any other model method (ex: `@article.formatted_published_at`)

## An Interface with Allows/Denies

A proper interface defines a contract between two objects. One purpose of the decorator pattern is to define an interface between your data model and the view template.

You are provided class methods `allows` and `denies` to control exactly which of the subject's methods are available. By default, *all* of the subject's methods can be accessed.

For example, say you want to prevent access to the `:title` method. You'd use `denies` like this:

```ruby
  class ArticleDecorator < Draper::Base
    denies :title
  end
```

`denies` uses a blacklist approach. Note that, as of the current version, denying `:title` does not affect related methods like `:title=`, `:title?`, etc.

A better idea is a whitelist approach using `allows`:

```ruby
  class ArticleDecorator < Draper::Base
    allows :title, :body, :author
  end
```

Now only those methods and any defined in the decorator class itself can be accessed directly.

## Possible Decoration Methods

Here are some ideas of what you might do in decorator methods:

* Implement output formatting for `to_csv`, `to_json`, or `to_xml`
* Format dates and times using `strftime`
* Implement a commonly used representation of the data object like a `.name` method that combines `first_name` and `last_name` attributes

## Example Using a Decorator

Say I have a publishing system with `Article` resources. My designer decides that whenever we print the `published_at` timestamp, it should be constructed like this:

```html
<span class='published_at'>
  <span class='date'>Monday, May 6</span>
  <span class='time'>8:52AM</span>
</span>
```

Could we build that using a partial? Yes. A helper? Uh-huh. But the point of the decorator is to encapsulate logic just like we would a method in our models. Here's how to implement it.

First, follow the steps above to add the dependency, update your bundle, then run the `rails generate decorator:setup` to prepare your app.

Since we're talking about the `Article` model we'll create an `ArticleDecorator` class. You could do it by hand, but use the provided generator:

```
rails generate draper:model Article
```

Now open up the created `app/decorators/article_decorator.rb` and you'll find an `ArticleDecorator` class. Add this method:

```ruby
def formatted_published_at
  date = content_tag(:span, published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date')
  time = content_tag(:span, published_at.strftime("%l:%M%p").delete(" "), :class => 'time')
  content_tag :span, date + time, :class => 'published_at'
end
```

*ASIDE*: Unfortunately, due to the current implementation of `content_tag`, you can't use the style of sending the content is as a block or you'll get an error about `undefined method 'output_buffer='`. Passing in the content as the second argument, as above, works fine.

Then you need to perform the wrapping in your controller. Here's the simplest method:

```ruby
class ArticlesController < ApplicationController
  def show
    @article = ArticleDecorator.new( Article.find params[:id] )
  end
end
```

Then within your views you can utilize both the normal data methods and your new presentation methods:

```ruby
<%= @article.formatted_published_at %>
```

Ta-da! Object-oriented data formatting for your view layer. Below is the complete decorator with extra comments removed:

```ruby
class ArticleDecorator < Draper::Base
  def formatted_published_at
    date = content_tag(:span, published_at.strftime("%A, %B %e").squeeze(" "), :class => 'date')
    time = content_tag(:span, published_at.strftime("%l:%M%p"), :class => 'time').delete(" ")
    content_tag :span, date + time, :class => 'created_at'
  end
end
```

## Issues / Pending

* Test coverage for generators
* Ability to decorate multiple objects at once, ex: `ArticleDecorator.decorate(Article.all)`
* Revise readme to better explain interface pattern
* Build sample Rails application
* Consider: `ArticleDecorator.new(1)` does the equivalent of `ArticleDecorator.new(Article.find(1))`

## License

(The MIT License)

Copyright © 2011 Jeff Casimir

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.