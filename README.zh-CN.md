# Drapper: View Models for Rails

Drapper 使用『面向对象』的方式，给 Rails 添加了独立的视图层。

在不使用Drapper的情况下，类似功能只能通过添加一个 helper 或者给 model 添加一堆逻辑来实现，而使用 Drapper 之后，通过对视图逻辑进行封装，使代码组织更清晰，也更易于测试。

## 为什么使用装饰器？

比如你的应用中有一个 `Article` 模型，使用 Drapper 之后，可以创建一个对应的 `ArticleDecorator`，这个 decorator 封装了 model 对象，并且只封装了视图相关的逻辑。在 controller 中，在传递给 view 层之前，我们可以先装饰一下 article 模型：

```
# app/controllers/articles_controller.rb
def show
  @article = Article.find(params[:id]).decorate
end
```

这样在 view 层使用装饰过的 model 和直接使用 model 基本上没有任何区别。但是，任何时候，如果你开始在 view 中写一堆逻辑、或者你想写一个 helper 方法的时候，就可以通过在 decorator 中实现一个方法来代替。

下面的例子演示了如何把一个helper 方法转成 decorator 方法。假如目前有一个 helper 方法长这样：

```
# app/helpers/articles_helper.rb
def publication_status(article)
  if article.published?
    "Published at #{article.published_at.strftime('%A, %B %e')}"
  else
    "Unpublished"
  end
end
```

这样写完就会觉得很别扭，publication_status 的命名空间是全局的，它在所有的 controllers 和 views 中均可以调用。然后，过了一段时间，当你想实现一个 `Book` 对象的 publication status 的时候，并且要求 book 的日期格式跟 article 不一样。怎么整？

两个办法。要么通过传入参数的类型来判断对象的类型（Ruby 并不是静态类型的语言，所以需要在函数体来判断），然后实现不同的逻辑；要么把这个方法拆成两个方法，`book_publication_status` 和 `article_publication_status`。随着项目不断变大，需要持续添加方法到全局的命名空间，调用的时候也必须记住所有的函数名。额，ugly……

这时候，需要使用面向对象的思维。假如你不知道 rails 有个东西叫 helper，你可能想着能这样调用就好了:

```ruby
<%= @article.publication_status %>
```

假如没有 decorator，那么就得在 `Article` 模型中实现这个 `publication_status` 这个方法，但是这个方法呢，本身又属于视图逻辑，并不属于模型层的逻辑。

所以，更好的方法呢，是实现一个 decorator ：

```
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
    object.published_at.strftime("%A, %B %e")
  end
end
```

在 `publication_status` 方法内，我们使用了 `published?` 方法，这个方法从哪来的？其实它是在 `Article` 中定义的。得益于 `delegate_all` 调用，Article 中的方法可以无缝的在这个 decorator 中使用。

decorator 有一些别名，比如 "presenter"，"exhibit"，"view model"，也有直接叫 "view" （这样的命名约定下，Rails 中的 views 应该叫 templates ）的。不管叫什么，使用面向对象编程来代替 helper 这种面向过程编程，都是非常棒的方法！

综合来说，遇到下面这些情况时，Decorators 尤为合适：

* 格式化复杂的数据显示给用户；
* 实现模型对象中常用的展示逻辑时，比如由 first_name 和 last_name 合并生成 name 这种情况；
* 封装一些对象的属性，比如把 url 属性变成一个超链接。

## 安装 （Installation）

添加 Drapper 到 Gemfile:

```
gem 'draper', '~> 1.3'
```

然后在应用的根目录下执行 `bundle install` 即可。

如果是从 0.x 的版本中升级而来，主要的变更在 [wiki](https://github.com/drapergem/draper/wiki/Upgrading-to-1.0) 中有详细说明。

## 实现装饰器（Writing Decorators）

Decorators 继承自 `Drapper::Decorator`，一般放入 `app/decorators` 目录，并且命名保持和相应的模型一致：

```ruby
# app/decorators/article_decorator.rb
class ArticleDecorator < Draper::Decorator
# ...
end
```

### 生成器

引入 drapper gem 之后，当使用 rails 生成一个 controller 时:

```
rails generate resource Article
```

也会自动生成一个 decorator，非常方便！！

如果 Article 模型已经存在的话，也可以直接执行：

```
rails generate decorator Article
```

来创建一个 `ArticleDecorator`。

### 调用 Helper 方法

一般的 rails helper 方法还是不可避免的要使用，不管是 rails 内置的 helper，还是 app 内自定义的 helper，通过 `h` 对象即可调用：

```ruby
class ArticleDecorator < Draper::Decorator
  def emphatic
    h.content_tag(:strong, "Awesome")
  end
end
```

嗯，如果觉得总是写一个 `h.` 很麻烦，可以在 Decorator 类中添加:

```ruby
include Draper::LazyHelpers
```

那么会自动 mixin 很多 helper 方法，也就不再需要写 `h.` 了。

（注意：`capture` 方法必须通过 `h` 或者 `helpers` 来调用）

### 调用 model 中的方法

当 decorator 中需要调用 model 中的方法时，除了 [下面](#delegating-methods) 会提到的 delegation 的方式，任何时候都可以通过 `object` 对象（或者 `model` 对象）来调用。

```ruby
class ArticleDecorator < Draper::Decorator
  def published_at
    object.published_at.strftime("%A, %B %e")
  end
end
```

## 使用装饰器（Decorating Objects）

### 单个对象的装饰

好，现在写完一个装饰器了，如何使用呢？最简单的办法是调用 model 的`decorate` 方法：

```ruby
@article = Article.first.decorate
```

这种方式通过命名约定来自动推断应该使用哪个装饰器类。假如需要更灵活的使用，比如 使用 `ProductDecorator` 装饰了一个模型 `Widget`，可以直接调动装饰器类：

```ruby
@widget = ProductDecorator.new(Widget.first)
# or, equivalently
@widget = ProductDecorator.decorate(Widget.first)
```

### 集合的装饰

#### 装饰集合中的所有对象

如果要装饰一个对象的集合，可以一次性装饰所有的对象：

```ruby
@articles = ArticleDecorator.decorate_collection(Article.all)
```

假如集合是一个 ActiveRecord 查询，也可以直接这样使用：

```ruby
@articles = Article.popular.decorate
```

*注意：* 在 Rails 3 中，`.all`方法返回的是一个数据，所以 _不能_ 使用 `Article.all.decorate` 这种方法。但是，Rails 4 中，`.all` 方法返回的是一个 query 对象，所以可以用这种方法。


#### 装饰集合本身

如果想给一个集合本身添加一些方法（比如，用于分页），那么可以继承 `Draper::CollectionDecorator` ：

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

Drapper 使用 `decorate` 方法来装饰每个对象，你也可以通过覆盖集合装饰器的 `decorator_class` 方法来改名，或者传递一个 `:with` 参数给构造器。

#### 使用分页

有些分页的 gem 会添加一些方法到 `ActiveRecord::Relation`，比如 [Kaminari](https://github.com/amatsuda/kaminari) 的 `paginate` 方法需要集合实现 `current_page`, `total_pages`, and
`limit_value` 这些方法。为了导出这些方法给一个集合类的装饰器，可以把这些方法 delegate 到 `object` 对象：

```ruby
class PaginatingDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?
end
```

这里的 `delegate` 是 [Active
Support](http://api.rubyonrails.org/classes/Module.html#method-i-delegate) 中的 delegate 方法是相同的，除了 参数 `:to` 是可选的，不传递时默认 delegate 到 `:object` 对象。

[will_paginate](https://github.com/mislav/will_paginate) 需要下面这些方法被 delegate :

```ruby
delegate :current_page, :per_page, :offset, :total_entries, :total_pages
```

### 装饰相关联的对象

当主模型被装饰时，可以自动装饰相关联的对象。比如，`Article` 模型有一个相关的对象 `Author` 时：

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author
end
```

当 `ArticleDecorator` 装饰一个 `Article` 时，drapper 会自动使用 `AuthorDecorator` 来装饰 `Author` 对象。

### 装饰 Finders

还可以在 decorator 中调用 `decorate_finders` 方法：

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_finders
end
```

这样，当在 decorator 调用 finder 类方法时，可以直接返回一个装饰过的对象：

```ruby
@article = ArticleDecorator.find(params[:id])
```

### 什么时候使用装饰器？

理论上，装饰器是和它所装饰的对象行为上是很接近的，所以，看起来在 controller 的 action 方法一开始就装饰这个对象，然后一直使用这个装饰器对象就行了。

*别这么干！*

因为，装饰器本质上就是为了给 view 层使用的，所以只应该在 view 层使用装饰器。先准备好 model，然后在最后一刻开始装饰它们，然后紧接着在 view 中使用它们。这样的话，就避免了很多尝试修改装饰器对象而导致的诸多隐患。

为了让装饰器对象只读，drapper 也提供了 `decorates_assigned` 方法给 controller。它添加了一个 helper 方法，会自动返回一个装饰过后的对象：

```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  decorates_assigned :article

  def show
    @article = Article.find(params[:id])
  end
end
```

`decorates_assigned :article`这个语句基本上等同于：

```ruby
def article
  @decorated_article ||= @article.decorate
end
helper_method :article
```

也就是说，只需要在 views 中调用 `article` 方法（取代常用的 @article 对象），就可以直接得到一个装饰后的 @article 对象。而在 controller 中，可以继续使用 `@article` 变量来进行各种逻辑操作，比如 `@article.comments.build` 可以创建一个 comment。

## 测试 (Testing)

Drapper 支持 Rspec，MiniTest::Rails 以及 Test::Unit，并且生成 decorator 的时候会自动创建一些测试用例。

### Rspec

spec 测试文件一般放在 `spec/decorators` 中。如果放在另外一个目录，那么需要使用 `type: :decorator`来标记它们。

在 controller 测试中，可能会想判断一个实例变量是否被正确的装饰了。可以使用下面这些 matchers 来判断：

```ruby
assigns(:article).should be_decorated

# 或者，下面这样可以显式的指定装饰器类
assigns(:article).should be_decorated_with ArticleDecorator
```

另外，`model.decorate == model`，所以，添加 decorator 之后，已经写好的 specs 应该仍然可以通过测试。

#### Spork 用户

在 `spec_helper.rb` 文件中的 `Spork.prefork` 段，需要添加下面的代码:

```ruby
require 'draper/test/rspec_integration'
```

### 独立测试装饰器

在测试中，Drapper 会创建一个 view 的上下文环境来存取 helper 方法。默认情况下，Drapper 会创建一个 `ApplicationController`，然后在 view 的上下文中使用它。假如你想通过测试每一个组件来加入测试，那么可以通过添加下面的代码到 spec_helper 或者类似文件中来删除这种依赖：

```ruby
Draper::ViewContext.test_strategy :fast
```

这样的话，装饰器就不再能够存在应用的 helper 方法，如果需要有选择的引入一些 herlper 方法，可以传递一个 block 给这个方法：

```ruby
Draper::ViewContext.test_strategy :fast do
  include ApplicationHelper
end
```

#### Stub 路由相关的 helper

假如需要写一些依赖于routes helper 的装饰器方法，那么可以 stub 这些路由，而无需引入 Rails。

假如你在使用 Rspec，minitest-rails 或者 minitest 中 Test::Unit语法，那么可以直接使用 `helpers` 对象在你的测试中，因为这些测试是继承自 `Drapper::TestCase`。假如你在使用 minitest 的 spec 语法，并且没有使用 minitest-rails，可以显式的引入 Drapper 的 `helpers`：

```ruby
describe YourDecorator do
  include Draper::ViewHelpers
end
```

然后，就可以使用你熟悉的方式来 stub 一些路由的 helper 方法了（下面的例子使用了 Rspec 的 `stub` 方法）：

```ruby
helpers.stub(users_path: '/users')
```

## 高级使用技巧 （Advanced Usage）

### 共享装饰器方法

可能会遇到多个装饰器都有类似方法的情况，因为装饰器就是一个 Ruby 对象，所以完全可以使用常用的 Ruby 的技巧来共享相关功能。

比如，Rails 控制器中，一般的 Controller 都是继承自 `ApplicationController`，可以在装饰器的实现中也使用类似技巧：

```ruby
# app/decorators/application_decorator.rb
class ApplicationDecorator < Draper::Decorator
# ...
end
```

然后，让所有的装饰器都继承自这个 `ApplicationDecorator`，不再直接继承自`Drapper::Decorator`：

```ruby
class ArticleDecorator < ApplicationDecorator
  # decorator methods
end
```

### 只 delegate 指定的方法

当装饰器调用 `delegate_all` 的时候，所有被调用的方法如果没有在装饰器中定义，那么都会委托至原有的 model 对象。这样有点过度了~

所以如果想严格控制哪些方法可以在 view 中被调用，那么可以只 delegate 部分方法到 model 中：

```ruby
class ArticleDecorator < Draper::Decorator
  delegate :title, :body
end
```

我们省略了参数 `:to` ，这样的话，默认委托至 `object` 对象。

也可以选择委托至其他对象：

```ruby
class ArticleDecorator < Draper::Decorator
  delegate :title, :body
  delegate :name, :title, to: :author, prefix: true
end
```

这样，在 view 的模板中，假如 @article 已经被装饰过，那么可以像下面这样使用：

```ruby
@article.title # 返回 the article's `.title`
@article.body  # 返回 the article's `.body`
@article.author_name  # 返回 the article's `author.name`
@article.author_title # 返回 the article's `author.title`
```

### 传递上下文

假如需要传递额外的数据给装饰器，可以在创建装饰器的时候，使用一个 `context` 参数来传递数据。比如：

```ruby
Article.first.decorate(context: {role: :admin})
```

传递给 `:context` 参数的数据，在装饰器中可以通过 context 方法来获取。

假如使用了 `decorates_association`，那么主模型的上下文数据会传递给相关的对象。也可以覆盖这个 `:context` 参数：

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author, context: {foo: "bar"}
end
```

或者，如果希望修改主模型的上线文数据，可以使用 lambda 表达式：

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author,
    context: ->(parent_context){ parent_context.merge(foo: "bar") }
end
```

### 指定装饰器类

当使用 `decorates_association`时，Drapper 使用 `decorate` 方法来装饰每一个关联对象，假如想使用一个不同的类来装饰，可以使用 `with`参数：

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :author, with: FancyPersonDecorator
end
```

如果是一个集合的关联（比如 has_many），可以传递一个 `CollectionDecorator` 的子类，这样的话会装饰整个集合；或者传递一个 `Decorator` 的子类，这样的话会装饰每一个集合内的对象。

### 限定 association 的范围

如果期望被装饰的关联对象被排序、限定个数或者其他限定，可以传递 `:scope` 参数给 `decorates_association`，这样的话，这个方法会在对象装饰 *之前* 被调用：

```ruby
class ArticleDecorator < Draper::Decorator
  decorates_association :comments, scope: :recent
end
```

### 代理类方法

如果想代理类方法给模型类，包括使用 `decorates_finders` 的时候，Drapper 必须要知道具体的模型类是什么。默认情况下，Drapper 默认你的装饰器被命名为 `SomeModelDecorator`，然后会代理所有的未知方法给 `SomeModel`。

如果，命名不符合约定，Drapper 无法推导出相应的模型类，则需要显式的调用 `decorates` 方法：

```ruby
class MySpecialArticleDecorator < Draper::Decorator
  decorates :article
end
```

这仅仅当需要代理类方法的时候才需要。

### 使模型可以被装饰

模型对象通过 mixin `Drapper::Decoratable` 模块来获得 `decorate` 方法，这个行为默认在 `ActiveRecord::Base` 和 `Mongoid::Document` 中被引入。

所以如果你 [使用了其他 ORM](https://github.com/drapergem/draper/wiki/Using-other-ORMs)（包括3.0版本之前的 Mongoid），或者想装饰普通的 Ruby 对象，那么需要显式的 include 这个模块。

## 贡献者

Draper was conceived by Jeff Casimir and heavily refined by Steve Klabnik and a
great community of open source
[contributors](https://github.com/drapergem/draper/contributors).

### 核心开发者

* Jeff Casimir (jeff@jumpstartlab.com)
* Steve Klabnik (steve@jumpstartlab.com)
* Vasiliy Ermolovich
* Andrew Haines 



