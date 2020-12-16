Feature: Users index page

  Background:
    Given there are 3 nims_researcher users

  Scenario: Unauthenticated user cannot view users
    When I navigate to the users list
    Then I should not see the nims_researcher users
    And I should be redirected to the login page

  Scenario: Email user cannot view users
    When I navigate to the users list
    Then I should not see the nims_researcher users
    And I should be redirected to the login page

  Scenario: nims_other user cannot view users
    Given I am logged in as an nims_other user
    When I navigate to the users list
    Then I should not see the nims_researcher users
    And I should be redirected to the home page

  Scenario: nims_researcher user cannot view users
    Given I am logged in as an nims_researcher user
    When I navigate to the users list
    Then I should not see the nims_researcher users
    And I should be redirected to the home page

  Scenario: Admin user can view users
    Given I am logged in as an admin user
    When I navigate to the users list
    Then I should see the nims_researcher users

#Feature: ユーザ一覧を参照する
#現在登録されているユーザを確認するため
#
#  Scenario: 非ログインユーザがユーザ一覧を表示する
#    Given ログインしない
#    Given ユーザが5件登録されている
#    When ユーザ一覧画面を開く
#    Then ユーザが5件とも表示されない
#
#  Scenario: 一般ユーザがユーザ一覧を表示する
#    Given 一般ユーザでログインする
#    Given ユーザが5件登録されている
#    When ユーザ一覧画面を開く
#    Then ユーザが5件表示される
#
#  Scenario: 管理者ユーザがユーザ一覧を表示する
#    Given 管理者でログインする
#    Given ユーザが5件登録されている
#    When ユーザ一覧画面を開く
#    Then ユーザが5件表示される
