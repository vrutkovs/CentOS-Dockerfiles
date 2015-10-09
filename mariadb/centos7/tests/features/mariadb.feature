Feature: MariaDB connection

  Background:
    Given mariadb container param "MYSQL_USER" is set to "user"
      And mariadb container param "MYSQL_PASSWORD" is set to "pass"
      And mariadb container param "MYSQL_DATABASE" is set to "db"

  Scenario: User account - smoke test
    When mariadb container is started
    Then mariadb connection can be established

  Scenario: Root account - smoke test
    Given mariadb container param "MYSQL_ROOT_PASSWORD" is set to "root_passw"
     When mariadb container is started
     Then mariadb connection with parameters can be established:
          | param          | value      |
          | MYSQL_USER     | root       |
          | MYSQL_PASSWORD | root_passw |
          | MYSQL_DATABASE | db         |

  Scenario Outline: Incorrect connection data - user account
    When mariadb container is started
    Then mariadb connection with parameters can not be established:
          | param          | value      |
          | MYSQL_USER     | <user>     |
          | MYSQL_PASSWORD | <password> |
          | MYSQL_DATABASE | <db>       |

    Examples:
    | user      | password | db  |
    | userr     | pass     | db  |
    | user      | passs    | db  |
    | user      | pass     | db1 |
    | \$invalid | pass     | db  |
    | user      | '        | db  |
    | user      | pass     | $invalid  |
    | user      | pass     | very_long_database_name_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  |
    | very_long_username | pass     | db  |

  Scenario Outline: Incorrect connection data - root account
    Given mariadb container param "MYSQL_ROOT_PASSWORD" is set to "root_passw"
     When mariadb container is started
    Then mariadb connection with parameters can not be established:
          | param          | value      |
          | MYSQL_USER     | root       |
          | MYSQL_PASSWORD | <password> |
          | MYSQL_DATABASE | <db>       |

    Examples:
    | password    | db  |
    | root_passw1 | db  |
    | root_passw  | db1 |
    | '           | db  |

  Scenario: Incomplete params
    When mariadb container is started
    Then mariadb connection with parameters can not be established:
          | param          | value |
          | MYSQL_USER     | user  |
          | MYSQL_PASSWORD | pass  |
     And mariadb connection with parameters can not be established:
          | param          | value |
          | MYSQL_USER     | user  |
          | MYSQL_DATABASE | pass  |
     And mariadb connection with parameters can not be established:
          | param          | value |
          | MYSQL_PASSWORD | pass  |
          | MYSQL_DATABASE | pass  |