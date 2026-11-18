package bestbuy;

import com.intuit.karate.junit5.Karate;

class BestBuyTest {

    @Karate.Test
    Karate testUtilities() {
        return Karate.run("utilities/utilities").relativeTo(getClass());
    }

    @Karate.Test
    Karate testProducts() {
        return Karate.run("products/products").relativeTo(getClass());
    }

    @Karate.Test
    Karate testStores() {
        return Karate.run("stores/stores").relativeTo(getClass());
    }

    @Karate.Test
    Karate testCategories() {
        return Karate.run("categories/categories").relativeTo(getClass());
    }

    @Karate.Test
    Karate testServices() {
        return Karate.run("services/services").relativeTo(getClass());
    }
}
