Feature: Blog posts

  Scenario: A post exists with the correct time
    Given a blog post exists that was posted today
    When I visit the page for that post
    Then I should see that it was posted today
