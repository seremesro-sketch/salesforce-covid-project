import { LightningElement } from 'lwc';

import getCovidRecords
from '@salesforce/apex/CovidController.getCovidRecords';

import deleteCovidRecord
from '@salesforce/apex/CovidController.deleteCovidRecord';

import loadCovidData
from '@salesforce/apex/CovidService.loadCovidData';

export default class CovidDashboard
extends LightningElement {

    data = [];

    columns = [

        {
            label: 'Date Checked',
            fieldName: 'TrackingDate__c',
            type: 'date'
        },

        {
            label: 'Positive',
            fieldName: 'Positive__c',
            type: 'number'
        },

        {
            label: 'Negative',
            fieldName: 'Negative__c',
            type: 'number'
        },

        {
            label: 'Hospitalized Currently',
            fieldName:
                'Hospitalized_Currently__c',
            type: 'number'
        },

        {
            type: 'button',

            typeAttributes: {

                label: 'Delete',

                name: 'delete',

                variant: 'destructive'

            }
        }
    ];

    /**
    /*Metodo para recargar dataTable
    */

    loadTable() {

        this.refreshData();

    }

    /**
    /*Metodo para refrescar dataTable
    */
    refreshData() {

        getCovidRecords()

        .then(result => {
            console.log('Refrescando tabla...');
            this.data = result;

        })

        .catch(error => {

            console.error(error);

        });
    }

    loadCovidData() {

        loadCovidData()

        .then(() => {

            this.refreshData();

        })

        .catch(error => {

            console.error(error);

        });
    }

    handleRowAction(event) {

        const actionName =
            event.detail.action.name;

        const row =
            event.detail.row;

        if(actionName === 'delete') {

            deleteCovidRecord({

                recordId: row.Id

            })

            .then(() => {

                console.log('Registro eliminado');
                this.refreshData();

            })

            .catch(error => {

                console.error(error);

            });
        }
    }
}