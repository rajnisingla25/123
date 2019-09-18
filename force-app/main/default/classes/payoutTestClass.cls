@isTest
public class payoutTestClass {

    static testMethod void payoutSubmitForApprovalTest()
    {
        period__c period = new period__c(name='October',Agent_Asset_Owner__c=20,Agent_Sigh_In_AE__c=10,Asset_Owner__c=10,Sigh_In_AE__c=5,Period_Type__c='Month',
                                         Start_Date__c=system.today()-20,End_Date__c=system.today()+10);
        insert period;
        payout__c P = new payout__c(name='payout',Commissionable__c=3,Commissionable_Requested_Value__c=5,High_Amount__c=10000,  High_Level__c=5,
                                    Is_Kicker_Qualified__c='No',Low_Amount__c=8000,Low_Level__c=5,Payout_Change_Status__c='open',Period__c=period.id,
                                  Sale_Type__c='new');
        insert p;
        
        Test.startTest();
        p.Commissionable_Requested_Value__c=5;
        p.Advantage_Leads_and_Branding_Req_Value__c = 1.0000;
        p.Broker_Highlight_Requested_Value__c  = 1.0000;
        p.Connection_SM_for_Co_Brokerage_ReqValue__c = 1.0000;
        p.Connections_SM_for_Sellers_Req_Value__c = 1.0000;
        p.Digital_Ad_Package_Requested_Value__c = 1.0000;
        p.Digital_Advertising_Campaign_Req_Value__c = 1.0000;
        p.Domain_Name_Requested_Value__c  = 1.0000;
        p.Featured_CMA_SM_Requested_Value__c = 1.0000;
        p.FiveStreet_Requested_Value__c = 1.0000;
        p.ListHub_Pro_Requested_Value__c = 1.0000;
        p.LocalExpert_Requested_Value__c = 1.0000;
        p.Market_Builder_Requested_Value__c = 1.0000;
        p.Market_Snapshot_Requested_Value__c  = 1.0000;
        p.Showcase_SM_Listing_Enhancements_ReqVal__c = 1.0000;
        p.Sign_Rider_Requested_Value__c  = 1.0000;
        p.Standard_Listing_Enhancements_Req_Value__c  = 1.0000;
        p.Top_Producer_CRM_Requested_Value__c = 1.0000;
        p.Top_Producer_IDX_Requested_Value__c = 1.0000;
        p.Top_Producer_Website_Requested_Value__c = 1.0000;
        p.Top_Producer_Website_Setup_Fee_Req_Value__c  = 1.0000;
        p.Trackable_Phone_Number_Requested_Value__c = 1.0000;
        p.Local_Expert_City_Requested_Value__c  = 1.0000;
        p.Payout_Change_Status__c = 'Open';
        update p;       
        Test.stopTest();
        
    }
    
    static testMethod void payoutApprovalRejectionTest()
    {
        period__c period = new period__c(name='October',Agent_Asset_Owner__c=20,Agent_Sigh_In_AE__c=10,Asset_Owner__c=10,Sigh_In_AE__c=5,Period_Type__c='Month',
                                         Start_Date__c=system.today()-20,End_Date__c=system.today()+10);
        insert period;
        payout__c P = new payout__c(name='payout',Commissionable__c=3,Commissionable_Requested_Value__c=5,High_Amount__c=10000,  High_Level__c=5,
                                    Is_Kicker_Qualified__c='No',Low_Amount__c=8000,Low_Level__c=5,Payout_Change_Status__c='open',Period__c=period.id,
                                  Sale_Type__c='new');
        insert p;
        
        Test.startTest();
        p.Commissionable_Requested_Value__c=5;
        p.Advantage_Leads_and_Branding_Req_Value__c = 1.0000;
        p.Broker_Highlight_Requested_Value__c  = 1.0000;
        p.Connection_SM_for_Co_Brokerage_ReqValue__c = 1.0000;
        p.Connections_SM_for_Sellers_Req_Value__c = 1.0000;
        p.Digital_Ad_Package_Requested_Value__c = 1.0000;
        p.Digital_Advertising_Campaign_Req_Value__c = 1.0000;
        p.Domain_Name_Requested_Value__c  = 1.0000;
        p.Featured_CMA_SM_Requested_Value__c = 1.0000;
        p.FiveStreet_Requested_Value__c = 1.0000;
        p.ListHub_Pro_Requested_Value__c = 1.0000;
        p.LocalExpert_Requested_Value__c = 1.0000;
        p.Market_Builder_Requested_Value__c = 1.0000;
        p.Market_Snapshot_Requested_Value__c  = 1.0000;
        p.Showcase_SM_Listing_Enhancements_ReqVal__c = 1.0000;
        p.Sign_Rider_Requested_Value__c  = 1.0000;
        p.Standard_Listing_Enhancements_Req_Value__c  = 1.0000;
        p.Top_Producer_CRM_Requested_Value__c = 1.0000;
        p.Top_Producer_IDX_Requested_Value__c = 1.0000;
        p.Top_Producer_Website_Requested_Value__c = 1.0000;
        p.Top_Producer_Website_Setup_Fee_Req_Value__c  = 1.0000;
        p.Trackable_Phone_Number_Requested_Value__c = 1.0000;
        p.Local_Expert_City_Requested_Value__c  = 1.0000;
        p.Payout_Change_Status__c = 'Approved';
        update p;
        
        Test.stopTest();
    }
    
    static testMethod void payoutRejectionTest()
    {
        period__c period = new period__c(name='October',Agent_Asset_Owner__c=20,Agent_Sigh_In_AE__c=10,Asset_Owner__c=10,Sigh_In_AE__c=5,Period_Type__c='Month',
                                         Start_Date__c=system.today()-20,End_Date__c=system.today()+10);
        insert period;
        payout__c P = new payout__c(name='payout',Commissionable__c=3,Commissionable_Requested_Value__c=5,High_Amount__c=10000,  High_Level__c=5,
                                    Is_Kicker_Qualified__c='No',Low_Amount__c=8000,Low_Level__c=5,Payout_Change_Status__c='open',Period__c=period.id,
                                  Sale_Type__c='new');
        insert p;
        
        Test.startTest();
        p.Payout_Change_Status__c = 'Rejected';
        p.Top_Producer_Website_Setup_Fee_Req_Value__c  = 1.0000;
        p.Trackable_Phone_Number_Requested_Value__c = 1.0000;
        p.Local_Expert_City_Requested_Value__c  = 1.0000;        
        update p;
        Test.stopTest();
    }
}