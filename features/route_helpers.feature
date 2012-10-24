Feature: Route helpers should work in decorators

  Background:
    Given a post exists

  Scenario:
    Then a _path helper with the underlying model works
    
  Scenario:
    Then a _path helper with the underlying model's id works

  Scenario:
    Then a _url helper with the underlying model works
    
  Scenario:
    Then a _url helper with the underlying model's id works

