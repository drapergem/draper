Given /^a post exists$/ do
  @post = Post.create
  @decorator = PostDecorator.decorate(@post)
end

Then /^a _path helper with the underlying model works$/ do
  @decorator.path_helper_with_model.should == {:post_path => "/posts/#{@post.id}"}
end

Then /^a _path helper with the underlying model's id works$/ do
  @decorator.path_helper_with_model_id.should == {:post_path => "/posts/#{@post.id}"}
end

Then /^a _url helper with the underlying model works$/ do
  @decorator.url_helper_with_model.should == {:post_url => "http://www.example.com/posts/#{@post.id}"}
end

Then /^a _url helper with the underlying model's id works$/ do
  @decorator.url_helper_with_model_id.should == {:post_url => "http://www.example.com/posts/#{@post.id}"}
end
