public with sharing class CovidService {
     @AuraEnabled
    public static String loadCovidData() {

        StaticResource sr = [
            SELECT Body
            FROM StaticResource
            WHERE Name = 'covidData'
            LIMIT 1
        ];

        String responseBody = sr.Body.toString();

        List<CovidWrapper> data =
            (List<CovidWrapper>)
            JSON.deserialize(
                responseBody,
                List<CovidWrapper>.class
            );

        List<covid_tracking__c> records =
            new List<covid_tracking__c>();

        Integer limitRecords = 20;

        for(Integer i=0;
            i < Math.min(limitRecords,data.size());
            i++){

            CovidWrapper item = data[i];

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

            records.add(covid);
        }

        insert records;

        return records.size() +
            ' registros insertados';
    }

    private static Date parseDate(
        Integer value
    ){

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