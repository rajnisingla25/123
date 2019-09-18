public with sharing class OrderConfirmationInvoicedClass {

    public Order relatedTo { get; set; }
    Public OrderConfirmationInvoicedClass(){
        relatedTo = [select id,Name from Order ];
    
    }
}