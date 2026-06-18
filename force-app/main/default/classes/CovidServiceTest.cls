@isTest
private class CovidServiceTest {

    @isTest
    static void testLoadCovidDataFromStaticResource() {

        /*
        Se llama a la logica
        */
        Test.startTest();

        String result = CovidService.loadCovidData();

        Test.stopTest();

        // Verifica respuesta
        System.assert(
            result != null &&
            result.contains('Insertados'),
            'Debe retornar mensaje de inserción'
        );

        // Verifica inserción en objeto
        List<covid_tracking__c> records =
            [SELECT Id, Hash__c FROM covid_tracking__c];

        System.assert(
            records.size() > 0,
            'Debe insertar registros desde Static Resource'
        );
    }
}