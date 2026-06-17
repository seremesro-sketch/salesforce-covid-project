import { LightningElement } from 'lwc';

import loadCovidData
from '@salesforce/apex/CovidService.loadCovidData';

export default class CovidTrackingLoader
extends LightningElement {

    message;

    loadData() {

        loadCovidData()

        .then(result => {

            this.message = result;

        })

        .catch(error => {

            this.message =
                error.body.message;

        });

    }
}