public with sharing class CovidService {
    
    /**
     * Método principal invocado desde el LWC.
     * Lee el archivo JSON almacenado como Static Resource,
     * evita insertar registros duplicados y guarda los nuevos
     * registros en el objeto covid_tracking__c.
     */

     @AuraEnabled
    public static String loadCovidData() {

        //Acceder al static resource covidData
        StaticResource sr = [
            SELECT Body
            FROM StaticResource
            WHERE Name = 'covidData'
            LIMIT 1
        ];

        // Convierte el archivo en un String JSON
        String responseBody = sr.Body.toString();

        // Deserializa el JSON a una lista de objetos Apex
        List<CovidWrapper> data =
            (List<CovidWrapper>)
            JSON.deserialize(
                responseBody,
                List<CovidWrapper>.class
            );
        
        // Limita la cantidad de registros procesados
        Integer limitRecords = 20;

        // Almacena los hashes recibidos en el archivo
        Set<String> incomingHashes = new Set<String>();

         for(Integer i = 0;
            i < Math.min(limitRecords, data.size());
            i++) {

            if(data[i].hash != null) {
                incomingHashes.add(data[i].hash);
            }
        }
        
        // Consulta los hashes que ya existen en Salesforce
        Set<String> existingHashes = new Set<String>();

        for(covid_tracking__c existing : [
            SELECT Hash__c
            FROM covid_tracking__c
            WHERE Hash__c IN :incomingHashes
        ]) {
            existingHashes.add(existing.Hash__c);
        }

        // Lista que contendrá únicamente registros nuevos
        List<covid_tracking__c> recordsToInsert =
            new List<covid_tracking__c>();

        Integer duplicateCount = 0;

        // Construcción de registros Salesforce
        for(Integer i=0;
            i < Math.min(limitRecords,data.size());
            i++){

            CovidWrapper item = data[i];

            // Evita insertar registros duplicados
            if(existingHashes.contains(item.hash)) {
                duplicateCount++;
                continue;
            }

            // Mapeo de campos JSON → Salesforce
            covid_tracking__c covid =
                new covid_tracking__c();

            covid.TrackingDate__c =
                parseDate(item.TrackingDate);

            covid.States__c =
                item.states;

            covid.Positive__c =
                item.positive;

            covid.Negative__c =
                item.negative;

            covid.Hospitalized_Currently__c =
                item.hospitalizedCurrently;

            covid.Death__c =
                item.death;

            covid.PositiveIncrease__c =
                item.positiveIncrease;

            covid.NegativeIncrease__c =
                item.negativeIncrease;

            covid.DeathIncrease__c =
                item.deathIncrease;

            covid.Hash__c =
                item.hash;

            recordsToInsert.add(covid);
        }

        Integer insertedCount = 0;

        // Inserción parcial para evitar que un error
        // bloquee toda la transacción
        if(!recordsToInsert.isEmpty()) {

            Database.SaveResult[] results =
                Database.insert(
                    recordsToInsert,
                    false
                );

            for(Database.SaveResult srResult : results) {

                if(srResult.isSuccess()) {
                    insertedCount++;
                }
            }
        }

        // Retorna estadísticas para mostrarlas en el LWC
        return
            'Insertados: ' + insertedCount +
            ' | Duplicados: ' + duplicateCount;
    }

     /**
     * Convierte una fecha en formato YYYYMMDD
     * recibida desde el JSON a un objeto Date de Salesforce.
     *
     * Ejemplo:
     * 20210307 -> 2021-03-07
     */
    private static Date parseDate(
        Integer value
    ){

        if(value == null){
            return null;
        }

        String d =
            String.valueOf(value);

        Integer year =
            Integer.valueOf(
                d.substring(0,4)
            );

        Integer month =
            Integer.valueOf(
                d.substring(4,6)
            );

        Integer day =
            Integer.valueOf(
                d.substring(6,8)
            );

        return Date.newInstance(
            year,
            month,
            day
        );
    }
}