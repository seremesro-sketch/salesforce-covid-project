public with sharing class CovidController {
    /**
     * Obtiene los registros COVID ordenados
     * del más reciente al más antiguo.
     */
    @AuraEnabled(cacheable=false)
    public static List<covid_tracking__c> getCovidRecords() {

        return [

            SELECT
                Id,
                TrackingDate__c,
                Positive__c,
                Negative__c,
                Hospitalized_Currently__c

            FROM covid_tracking__c

            ORDER BY TrackingDate__c DESC

        ];
    }

    /**
     * Elimina un registro por Id.
     */
    @AuraEnabled
    public static void deleteCovidRecord(
        Id recordId
    ) {

        delete [

            SELECT Id

            FROM covid_tracking__c

            WHERE Id = :recordId

            LIMIT 1

        ];
    }
}