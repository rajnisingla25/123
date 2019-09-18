/*
Apex class :InvoiceWrapper
Purpose :- InvoiceWrapper class is used to develop account statment
CRM - OTC-208
Author :- Sonu Sharma, Move Inc
*/
Public Class InvoiceWrapper {
    Public Zuora__ZInvoice__c zinv {
        get;
        set;
    }
    Public List < Invoice_Item__c > InvlineList1 {
        get;
        set;
    }
    Public List < Invoice_Item__c > InvlineList2 {
        get;
        set;
    }
    Public List < Invoice_Item__c > InvlineList3 {
        get;
        set;
    }
    Public List < Invoice_Item__c > InvlineList4 {
        get;
        set;
    }
    Public List < Invoice_Item__c > InvlineList5 {
        get;
        set;
    }
    Public List < Zuora__PaymentInvoice__c > zinvpayment {
        get;
        set;
    }
    Public List < Zuora__RefundInvoicePayment__c > zinvrefund {
        get;
        set;
    }
    Public List < CreditBalanceAdjustment__c > zinvCredit {
        get;
        set;
    }
    Public Boolean DisplayInvoice {
        get;
        set;
    }
    Public Boolean DisplayPayment {
        get;
        set;
    }
    Public Boolean DisplayRefund {
        get;
        set;
    }
    Public Boolean DisplayCredit {
        get;
        set;
    }
    Public Decimal subtotal {
        get;
        set;
    }
    Public Decimal creditapplied {
        get;
        set;
    }
    Public Decimal total {
        get;
        set;
    }
    Public Decimal paid {
        get;
        set;
    }
    Public Decimal Applied {
        get;
        set;
    }
    Public Decimal Refund {
        get;
        set;
    }
    Public Decimal Adjustment {
        get;
        set;
    }
    Public Decimal Balance {
        get;
        set;
    }
    Public String DueDate {
        get;
        set;
    }
    Public String paymentStatus {
        get;
        set;
    }

}