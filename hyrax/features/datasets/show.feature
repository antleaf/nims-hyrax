Feature: Access a dataset

  Background:
    Given an initialised system with a default admin set, permission template and workflow
    And there is 1 open dataset
    And there is 1 authenticated dataset
    And there is 1 restricted dataset

  Scenario: Access a open dataset
    Given I am logged in as an email user
    And I have permission to deposit
    When I navigate to the open dataset page
    Then I should access the open dataset

  Scenario: Access a authenticated dataset
    Given I am logged in as an email user
    And I have permission to deposit
    When I navigate to the authenticated dataset page
    Then I should not access the authenticated dataset

  Scenario: Access a restricted dataset
    Given I am logged in as an email user
    And I have permission to deposit
    When I navigate to the restricted dataset page
    Then I should not access the restricted dataset
