/*
Apex class :OpportunityDialWrapper
Purpose :- OpportunityDialWrapper class is used to develop dialList
CRM - OTC-208
Author :- Sonu Sharma, Move Inc
*/
Public Class OpportunityDialWrapper {

    Public Decimal totalAmount {
        get;
        set;
    }
    
    Public String AccountId {
        get;
        set;
    }
    Public String OwnerId {
        get;
        set;
    }
    Public String NVMUniqueString {
        get;
        set;
    }
    Public String InflightStatus {
        get;
        set;
    }
    Public Date ExpiryDate {
        get;
        set;
    }
    Public Date ExpiryCBCDate {
        get;
        set;
    }
    Public Date ExpiryDAPDate {
        get;
        set;
    }
    Public Date ExpiryAdvantageDate {
        get;
        set;
    }
    Public Boolean Havecbc {
        get;
        set;
    }
    Public Boolean HasAssetDonotrenew {
        get;
        set;
    }
    Public Boolean Haveadvantage {
        get;
        set;
    }
    Public Boolean HaveDap {
        get;
        set;
    }
    Public String phonenumber{
        get;
        set;
    }
    Public String Mobilenumber{
        get;
        set;
    }
    Public String Preferrednumber{
        get;
        set;
    }
    Public String HomePhonenumber{
        get;
        set;
    }
    Public String Officenumber{
        get;
        set;
    }
}