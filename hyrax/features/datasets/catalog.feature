Feature: Datasets catalog index

  Background:
    Given an initialised system with a default admin set, permission template and workflow
    And there is 1 open dataset
    And there are 2 authenticated datasets
    And there is 1 restricted dataset
    # NB: "restricted" means "private" in the user interface

  Scenario: Unauthenticated user can only view open datasets
    When I navigate to the dataset catalog page
    Then I should see the open datasets
    # And I should see only the public metadata of the open datasets
    And I should see both the public and restricted metadata of the open datasets
    But I should not see the authenticated datasets
    And I should not see the restricted datasets

  Scenario: Email user can only view open datasets
    Given I am logged in as an email user
    When I navigate to the dataset catalog page
    Then I should see the open datasets
    And I should not see the restricted datasets
    # And I should see only the public metadata of the open datasets
    And I should see both the public and restricted metadata of the open datasets
    But I should not see the authenticated datasets
    And I should not see the restricted datasets

  Scenario: Non-researcher user can view open and authenticated datasets
    Given I am logged in as a nims_other user
    When I navigate to the dataset catalog page
    Then I should see the open datasets
    And I should see the authenticated datasets
    And I should see both the public and restricted metadata of the open datasets
    And I should see both the public and restricted metadata of the authenticated datasets
    But I should not see the restricted dataset

  Scenario: Researcher user can view open and authenticated datasets
    Given I am logged in as a nims_researcher user
    When I navigate to the dataset catalog page
    Then I should see the open datasets
    And I should see the authenticated datasets
    And I should see both the public and restricted metadata of the open datasets
    And I should see both the public and restricted metadata of the authenticated datasets
    But I should not see the restricted datasets

  Scenario: Admin user can view open, authenticated and restricted datasets
    Given I am logged in as an admin user
    When I navigate to the dataset catalog page
    Then I should see the open datasets
    And I should see the authenticated datasets
    And I should see the restricted dataset
    And I should see both the public and restricted metadata of the open datasets
    And I should see both the public and restricted metadata of the authenticated datasets
    And I should see both the public and restricted metadata of the restricted datasets

#Feature: データセット一覧を参照する
#  現在登録されているユーザを確認するため
#
#  Scenario: 非ログインユーザがデータセット一覧を表示する
#    Given ログインしない
#    Given データが5件登録されている
#    When データセット一覧画面を開く
#    Then データが5件とも表示されない
#
#  Scenario: 一般ユーザがデータセット一覧を表示する
#    Given 一般ユーザでログインする
#    Given データが5件登録されている
#    When データセット一覧画面を開く
#    Then データが5件表示される
#
#  Scenario: 管理者ユーザがデータセット一覧を表示する
#    Given 管理者でログインする
#    Given データが5件登録されている
#    When データセット一覧画面を開く
#    Then データが5件表示される
