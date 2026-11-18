@services
Feature: Best Buy API Playground - Services Queries & CRUD

  Background:
    * url baseUrl

  @smoke
  Scenario: GET /services returns available store services
    Given path 'services'
    And param $limit = 25
    When method get
    Then status 200
    And match response.total == '#number? _ >= 21'
    And match response.data[*].name contains 'Geek Squad Services'

  Scenario: Full lifecycle CRUD (POST -> GET -> PATCH -> DELETE) on /services
    * def serviceName = 'Karate Express Setup ' + Date.now()

    Given path 'services'
    And request { name: '#(serviceName)' }
    When method post
    Then status 201
    * def serviceId = response.id
    And match response.name == serviceName

    Given path 'services', serviceId
    When method get
    Then status 200
    And match response.id == serviceId

    Given path 'services', serviceId
    And request { name: 'Karate Express Setup Pro' }
    When method patch
    Then status 200
    And match response.name == 'Karate Express Setup Pro'

    Given path 'services', serviceId
    When method delete
    Then status 200

    Given path 'services', serviceId
    When method get
    Then status 404
