@smoke @utilities
Feature: Best Buy API Playground - Utilities & Healthcheck

  Background:
    * url baseUrl

  Scenario: GET /version returns API semantic version
    Given path 'version'
    When method get
    Then status 200
    And match response == { version: '#string' }

  Scenario: GET /healthcheck confirms database and writable mode
    Given path 'healthcheck'
    When method get
    Then status 200
    And match response ==
      """
      {
        uptime: '#number',
        readonly: false,
        documents: {
          products: '#number? _ > 0',
          stores: '#number? _ > 0',
          categories: '#number? _ > 0'
        }
      }
      """
