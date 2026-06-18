/**
 * Wrapper utilizado para deserializar la respuesta JSON
 * proveniente del archivo covidData.json.
 *
 * Cada atributo corresponde a un campo recibido desde la
 * fuente de datos COVID Tracking.
 */
public with sharing class CovidWrapper {
    
        public Integer TrackingDate;
        public Integer states;
        public String dateChecked;
        public Integer positive;
        public Integer negative;
        public Integer hospitalizedCurrently;
        public Integer death;
        public Integer positiveIncrease;
        public Integer negativeIncrease;
        public Integer deathIncrease;
        public String hash;
        public String lastModified;
    
        public CovidWrapper() {
        TrackingDate = 0;
        states = 0;
        dateChecked = '';
        positive = 0;
        negative = 0;
        hospitalizedCurrently = 0;
        death = 0;
        positiveIncrease = 0;
        negativeIncrease = 0;
        deathIncrease = 0;
        hash = '';
        lastModified = '';
    }
}