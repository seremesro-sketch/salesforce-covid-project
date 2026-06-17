import { LightningElement } from 'lwc';

import loadCovidData
from '@salesforce/apex/CovidService.loadCovidData';

export default class CovidTrackingLoader
extends LightningElement {

    message;

    loadData() {

         console.log('Botón presionado');

            loadCovidData()

            .then(result => {

                console.log('Resultado Apex:', result);

                this.message = result;

            })

            .catch(error => {

                console.error('Error Apex:', error);

                this.message =
                    JSON.stringify(error);

            });

    }
}