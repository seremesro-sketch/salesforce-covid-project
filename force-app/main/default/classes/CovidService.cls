public with sharing class CovidService {
     @AuraEnabled
    public static String loadCovidData() {

        HttpRequest req = new HttpRequest();

        req.setEndpoint(
            'callout:CovidTracking/v1/us/daily.json'
        );

        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('User-Agent', 'Mozilla/5.0');
        
        Http http = new Http();

        
        HttpResponse res = http.send(req);

        System.debug('STATUS CODE: ' + res.getStatusCode());
        System.debug('STATUS: ' + res.getStatus());
        System.debug('BODY: ' + res.getBody());
        

        if(res.getStatusCode() != 200){

            throw new AuraHandledException(
                'HTTP ERROR: ' +
                res.getStatusCode() +
                ' BODY: ' +
                res.getBody()
                
            );

        }

        List<CovidWrapper> data =
            (List<CovidWrapper>)
            JSON.deserialize(
                res.getBody(),
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