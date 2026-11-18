@products
Feature: Best Buy API Playground - Products CRUD & Querying

  Background:
    * url baseUrl
    * def productSchema =
      """
      {
        id: '#number',
        name: '#string',
        type: '#string',
        price: '#number',
        upc: '#string',
        shipping: '#number',
        description: '#string',
        manufacturer: '#string',
        model: '#string',
        url: '#string',
        image: '#string',
        createdAt: '#string',
        updatedAt: '#string',
        categories: '#[]'
      }
      """

  @smoke
  Scenario: GET /products with pagination limit and skip
    Given path 'products'
    And param $limit = 5
    And param $skip = 0
    When method get
    Then status 200
    And match response.limit == 5
    And match response.skip == 0
    And match response.total == '#number? _ > 0'
    And match response.data == '#[5]'
    And match each response.data == productSchema

  Scenario: GET /products with field projection and descending price sort
    Given path 'products'
    And param $limit = 3
    And param $select[] = ['name', 'price']
    And param $sort[price] = -1
    When method get
    Then status 200
    And match response.data == '#[3]'
    And match each response.data == { name: '#string', price: '#number' }
    * assert response.data[0].price >= response.data[1].price
    * assert response.data[1].price >= response.data[2].price

  @smoke
  Scenario: Full lifecycle CRUD (POST -> GET -> PATCH -> PUT -> DELETE) on /products
    * def newProduct = read('product-payload.json')
    * def uniqueTag = '' + Date.now()
    * set newProduct.name = 'Karate Wireless Mouse ' + uniqueTag
    * set newProduct.model = 'KL-' + uniqueTag.substring(uniqueTag.length() - 8)

    # Create
    Given path 'products'
    And request newProduct
    When method post
    Then status 201
    * def createdId = response.id
    And match response contains { name: '#(newProduct.name)', price: 29.99, manufacturer: 'KarateLabs' }

    # Read
    Given path 'products', createdId
    When method get
    Then status 200
    And match response.id == createdId
    And match response.model == newProduct.model

    # Partial update (PATCH)
    Given path 'products', createdId
    And request { price: 34.50 }
    When method patch
    Then status 200
    And match response.price == 34.50
    And match response.name == newProduct.name

    # Full update (PUT)
    * set newProduct.price = 39.99
    * set newProduct.description = 'Updated ergonomic wireless mouse via PUT'
    Given path 'products', createdId
    And request newProduct
    When method put
    Then status 200
    And match response.price == 39.99
    And match response.description == 'Updated ergonomic wireless mouse via PUT'

    # Delete
    Given path 'products', createdId
    When method delete
    Then status 200
    And match response.id == createdId

    # Verify deletion returns 404
    Given path 'products', createdId
    When method get
    Then status 404

  Scenario: POST /products rejects payload missing required fields with 400
    Given path 'products'
    And request { name: 'Incomplete Product' }
    When method post
    Then status 400
    And match response.code == 400
