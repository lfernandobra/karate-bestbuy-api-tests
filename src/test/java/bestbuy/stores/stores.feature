@stores
Feature: Best Buy API Playground - Stores Queries & CRUD

  Background:
    * url baseUrl

  @smoke
  Scenario: GET /stores filtered by state
    Given path 'stores'
    And param state = 'MN'
    And param $limit = 3
    When method get
    Then status 200
    And match response.data == '#[3]'
    And match each response.data contains { state: 'MN', services: '#[]' }

  Scenario: GET /stores filtered by service name
    Given path 'stores'
    And param service.name = 'Geek Squad Services'
    And param $limit = 2
    When method get
    Then status 200
    And match response.data == '#[2]'
    * def hasGeekSquad = function(store){ return karate.filter(store.services, function(s){ return s.name == 'Geek Squad Services'; }).length > 0; }
    And match each response.data == '#? hasGeekSquad(_)'

  Scenario: Full lifecycle CRUD (POST -> GET -> PATCH -> DELETE) on /stores
    * def storeName = 'Karate Flagship Store ' + Date.now()

    Given path 'stores'
    And request
      """
      {
        "name": "#(storeName)",
        "type": "BigBox",
        "address": "100 Karate Way",
        "address2": "Suite 200",
        "city": "Austin",
        "state": "TX",
        "zip": "78701",
        "lat": 30.2672,
        "lng": -97.7431,
        "hours": "Mon-Sun: 9-9"
      }
      """
    When method post
    Then status 201
    * def storeId = response.id
    And match response contains { name: '#(storeName)', city: 'Austin', state: 'TX' }

    Given path 'stores', storeId
    When method get
    Then status 200
    And match response.id == storeId

    Given path 'stores', storeId
    And request { hours: 'Mon-Sun: 10-8' }
    When method patch
    Then status 200
    And match response.hours == 'Mon-Sun: 10-8'

    Given path 'stores', storeId
    When method delete
    Then status 200

    Given path 'stores', storeId
    When method get
    Then status 404
