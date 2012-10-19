Given /^a blog post exists that was posted today$/ do
  @post = Post.create
end

When /^I visit the page for that post$/ do
  visit post_path(@post)
end

Then /^I should see that it was posted today$/ do
  page.should have_content("Posted: Today")
end
