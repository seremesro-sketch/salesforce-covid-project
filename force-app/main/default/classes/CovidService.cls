public with sharing class CovidService {
    
    /**
     * Método principal invocado desde el LWC.
     */

     @AuraEnabled
    public static String loadCovidData() {
        try {

                List<CovidWrapper> covidData =
                    getCovidData();

                return saveCovidData(covidData);

            }
            catch(Exception e){

                throw new AuraHandledException(
                    e.getMessage()
                );
            }
    }


/**
 * Obtiene y deserializa los datos del Static Resource.
 */
private static List<CovidWrapper> getCovidData() {

    StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'covidData'
        LIMIT 1
    ];

    String responseBody =
        sr.Body.toString();

    responseBody =
        responseBody.replace(
            '"date":',
            '"TrackingDate":'
        );

    return (List<CovidWrapper>)
        JSON.deserialize(
            responseBody,
            List<CovidWrapper>.class
        );
}


/**
 * Guarda los registros evitando duplicados.
 */
private static String saveCovidData(
    List<CovidWrapper> data
) {

    Integer limitRecords = 20;

    Set<String> incomingHashes =
        new Set<String>();

    for(Integer i = 0;
        i < Math.min(limitRecords,data.size());
        i++) {

        if(data[i].hash != null) {
            incomingHashes.add(
                data[i].hash
            );
        }
    }

    Set<String> existingHashes =
        new Set<String>();

    for(covid_tracking__c existing : [

        SELECT Hash__c
        FROM covid_tracking__c
        WHERE Hash__c IN :incomingHashes

    ]) {

        existingHashes.add(
            existing.Hash__c
        );
    }

    List<covid_tracking__c> recordsToInsert =
        new List<covid_tracking__c>();

    Integer duplicateCount = 0;

    for(Integer i = 0;
        i < Math.min(limitRecords,data.size());
        i++) {

        CovidWrapper item =
            data[i];

        if(existingHashes.contains(
            item.hash
        )) {

            duplicateCount++;
            continue;
        }

        recordsToInsert.add(
            mapToCovidTracking(item)
        );
    }

    Integer insertedCount = 0;

    if(!recordsToInsert.isEmpty()) {

        Database.SaveResult[] results =
            Database.insert(
                recordsToInsert,
                false
            );

        for(Database.SaveResult sr :
            results) {

            if(sr.isSuccess()) {
                insertedCount++;
            }
        }
    }

    return
        'Insertados: ' +
        insertedCount +
        ' | Duplicados: ' +
        duplicateCount;
}


/**
 * Convierte un Wrapper en un registro Salesforce.
 */
private static covid_tracking__c
mapToCovidTracking(
    CovidWrapper item
) {

    covid_tracking__c covid =
        new covid_tracking__c();

    covid.TrackingDate__c =
        parseDate(
            item.TrackingDate
        );

    covid.dateChecked__c =
        parseDateTime(
            item.dateChecked
        );

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

    return covid;
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

    /**
 * Convierte la fecha ISO recibida desde el JSON
 * a un Datetime de Salesforce.
 */
private static Datetime parseDateTime(
    String value
    ){

        if(String.isBlank(value)){
            return null;
        }

        value = value.replace(
            'T24:00:00Z',
            'T00:00:00Z'
        );

        value = value.replace(
            'T',
            ' '
        ).replace(
            'Z',
            ''
        );

        return Datetime.valueOfGmt(
            value
        );
    }

}