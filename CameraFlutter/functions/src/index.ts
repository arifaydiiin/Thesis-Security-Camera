import * as functions from 'firebase-functions'

import * as admin from 'firebase-admin'

admin.initializeApp(functions.config().firebase);


exports.createUser = functions.database
    .ref('/camerasecurity-955a4-default-rtdb')
    .onCreate(() => {
       console.log("Yeni veri oluştu...");
    });
