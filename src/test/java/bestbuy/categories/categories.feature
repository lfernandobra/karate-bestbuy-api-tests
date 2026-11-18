@categories
Feature: Best Buy API Playground - Categories Queries & CRUD

  Background:
    * url baseUrl

  @smoke
  Scenario: GET /categories returns hierarchy metadata
    Given path 'categories'
    And param $limit = 3
    When method get
    Then status 200
    And match response.data == '#[3]'
    And match each response.data contains
      """
      {
        id: '#string',
        name: '#string',
        subCategories: '#[]',
        categoryPath: '#[]'
      }
      """

  Scenario: Full lifecycle CRUD (POST -> GET -> PATCH -> DELETE) on /categories
    * def catId = 'karatecat' + Date.now()
    * def catName = 'Karate Test Category ' + Date.now()

    Given path 'categories'
    And request { id: '#(catId)', name: '#(catName)' }
    When method post
    Then status 201
    And match response contains { id: '#(catId)', name: '#(catName)' }

    Given path 'categories', catId
    When method get
    Then status 200
    And match response.id == catId

    Given path 'categories', catId
    And request { name: 'Karate Updated Category' }
    When method patch
    Then status 200
    And match response.name == 'Karate Updated Category'

    Given path 'categories', catId
    When method delete
    Then status 200

    Given path 'categories', catId
    When method get
    Then status 404
