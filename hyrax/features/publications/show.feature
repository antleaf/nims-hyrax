Feature: Access a publication

  Background:
    Given an initialised system with a default admin set, permission template and workflow
    And there is 1 open publication
    And there is 1 authenticated publication
    And there is 1 restricted publication

  Scenario: Access a open publication
    Given I am logged in as an email user
    And I have permission to deposit
    When I navigate to the open publication page
    Then I should access the open publication

  Scenario: Access a authenticated publication
    Given I am logged in as an email user
    And I have permission to deposit
    When I navigate to the authenticated publication page
    Then I should not access the authenticated publication

  Scenario: Access a restricted publication
    Given I am logged in as an email user
    And I have permission to deposit
    When I navigate to the restricted publication page
    Then I should not access the restricted publication
