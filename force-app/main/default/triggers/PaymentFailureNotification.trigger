trigger PaymentFailureNotification on Zuora__PaymentInvoice__c (After Insert,After Update) {
    PreAuthPaymentFailureNotifyOnInsert notification = New PreAuthPaymentFailureNotifyOnInsert();
    notification.VerifyandSendNotification(trigger.oldmap,trigger.newmap,trigger.isInsert);
}