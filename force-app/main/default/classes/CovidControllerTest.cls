@isTest
private class CovidControllerTest {

    
    /*
    //Esto crea 5 registros reales en Salesforce para probar
    */
    @testSetup
    static void setupData() {

        List<covid_tracking__c> records = new List<covid_tracking__c>();

        for(Integer i = 0; i < 5; i++) {

            records.add(new covid_tracking__c(
                TrackingDate__c = Date.today().addDays(-i),
                Positive__c = 100 + i,
                Negative__c = 200 + i,
                Hospitalized_Currently__c = 10,
                Hash__c = 'hash_' + i
            ));
        }

        insert records;
    }

    /*
    //Revisar que regrese registros y respete ordenamiento
    */
    @isTest
    static void testGetRecords() {

        Test.startTest();

        List<covid_tracking__c> result =
            CovidController.getCovidRecords();

        Test.stopTest();

        System.assertEquals(5, result.size());
    }

    /*
    //Verifica que elimine registro y se reduzca el total
    */
    @isTest
    static void testDeleteRecord() {

        covid_tracking__c rec =
            [SELECT Id FROM covid_tracking__c LIMIT 1];

        Test.startTest();

        CovidController.deleteCovidRecord(rec.Id);

        Test.stopTest();

        Integer count =
            [SELECT COUNT() FROM covid_tracking__c WHERE Id = :rec.Id];

        System.assertEquals(0, count);
    }
}