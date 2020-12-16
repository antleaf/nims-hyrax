Feature: Create a dataset

  Background:
    Given an initialised system with a default admin set, permission template and workflow

  Scenario: Cannot create a dataset as an email user
    Given I am logged in as an email user
    And I have permission to deposit
    When I try to navigate to the new dataset page
    # When I try to navigate to the dashboard page
    Then I should be redirected to the top page

  Scenario: Cannot create a dataset as a Non-Researcher user
    Given I am logged in as a nims_other user
    And I have permission to deposit
    When I try to navigate to the new dataset page
    Then I should not be authorized to access the page

  Scenario: Create a dataset as a NIMS Researcher user
    Given I am logged in as a nims_researcher user
    And I have permission to deposit
    When I navigate to the new dataset page
    And I create the dataset with:
      | TITLE           | SUPERVISOR   | DATA_ORIGIN | CREATOR   | KEYWORD  |
      | My Test Dataset | Jones, Janet | experiments | Doe, Jane | big data |
    Then I should see a message that my files are being processed
