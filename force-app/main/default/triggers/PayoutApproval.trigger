/********************************************************
Created By     : Srinivas Pendli
Use of Trigger : The usage of trigger is to sand approval for payout change and once the payout record is approved
                 It will re-calculate payout rate for commission records for releted commissions of current payout record 
Company        : NTT Data,Inc. 
Modified By    : Srinivas Pendli
*********************************************************/
trigger PayoutApproval on Payout__c (before update) {
    if(Commissions_TriggerHelperClass.payoutApproval == false){
        if(trigger.isBefore && trigger.isUpdate){
            Commissions_TriggerHelperClass.payoutApproval = True;
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
            Map<Id,Payout__c> MapPay = new Map<Id,Payout__c>();
            for(Payout__c pay : Trigger.New){                
                if(pay.Payout_Change_Status__c == 'Open'){
                    if(Trigger.oldMap.get(pay.Id).Commissionable_Requested_Value__c != Trigger.newMap.get(pay.Id).Commissionable_Requested_Value__c)
                    {
                        system.debug('Enter first loop : ');
                        pay.Commissionable__c = Trigger.newMap.get(pay.Id).Commissionable__c ;
                        pay.Commissionable_Requested_Value__c = Trigger.newMap.get(pay.Id).Commissionable_Requested_Value__c; 
                    }
                    if(Trigger.oldMap.get(pay.Id).Advantage_Leads_and_Branding_Req_Value__c != Trigger.newMap.get(pay.Id).Advantage_Leads_and_Branding_Req_Value__c){
                        pay.Advantage_Leads_and_Branding__c = Trigger.newMap.get(pay.Id).Advantage_Leads_and_Branding__c;
                        pay.Advantage_Leads_and_Branding_Req_Value__c = Trigger.newMap.get(pay.Id).Advantage_Leads_and_Branding_Req_Value__c;
                    }
                    if(Trigger.oldMap.get(pay.Id).Broker_Highlight_Requested_Value__c != Trigger.newMap.get(pay.Id).Broker_Highlight_Requested_Value__c){
                        pay.Broker_Highlight__c = Trigger.newMap.get(pay.Id).Broker_Highlight__c;
                        pay.Broker_Highlight_Requested_Value__c = Trigger.newMap.get(pay.Id).Broker_Highlight_Requested_Value__c;    
                    }
                    if(Trigger.oldMap.get(pay.Id).Connection_SM_for_Co_Brokerage_ReqValue__c != Trigger.newMap.get(pay.Id).Connection_SM_for_Co_Brokerage_ReqValue__c) {
                        pay.Connection_SM_for_Co_Brokerage__c = Trigger.newMap.get(pay.Id).Connection_SM_for_Co_Brokerage__c;
                        pay.Connection_SM_for_Co_Brokerage_ReqValue__c = Trigger.newMap.get(pay.Id).Connection_SM_for_Co_Brokerage_ReqValue__c;
                    }
                    if(Trigger.oldMap.get(pay.Id).Connections_SM_for_Sellers_Req_Value__c != Trigger.newMap.get(pay.Id).Connections_SM_for_Sellers_Req_Value__c){
                        pay.Connections_SM_for_Sellers__c = Trigger.newMap.get(pay.Id).Connections_SM_for_Sellers__c;
                        pay.Connections_SM_for_Sellers_Req_Value__c = Trigger.newMap.get(pay.Id).Connections_SM_for_Sellers_Req_Value__c;
                    }
                    if(Trigger.oldMap.get(pay.Id).Digital_Ad_Package_Requested_Value__c != Trigger.newMap.get(pay.Id).Digital_Ad_Package_Requested_Value__c){
                        pay.Digital_Ad_Package__c = Trigger.newMap.get(pay.Id).Digital_Ad_Package__c; 
                        pay.Digital_Ad_Package_Requested_Value__c = Trigger.newMap.get(pay.Id).Digital_Ad_Package_Requested_Value__c;
                    }
                    if(Trigger.oldMap.get(pay.Id).Digital_Advertising_Campaign_Req_Value__c != Trigger.newMap.get(pay.Id).Digital_Advertising_Campaign_Req_Value__c){
                        pay.Digital_Advertising_Campaign__c = Trigger.newMap.get(pay.Id).Digital_Advertising_Campaign__c;
                        pay.Digital_Advertising_Campaign_Req_Value__c = Trigger.newMap.get(pay.Id).Digital_Advertising_Campaign_Req_Value__c;
                    }
                    if(Trigger.oldMap.get(pay.Id).Domain_Name_Requested_Value__c != Trigger.newMap.get(pay.Id).Domain_Name_Requested_Value__c){
                        pay.Domain_Name__c = Trigger.newMap.get(pay.Id).Domain_Name__c;
                        pay.Domain_Name_Requested_Value__c = Trigger.newMap.get(pay.Id).Domain_Name_Requested_Value__c;
                    }
                    if(Trigger.oldMap.get(pay.Id).Featured_CMA_SM_Requested_Value__c != Trigger.newMap.get(pay.Id).Featured_CMA_SM_Requested_Value__c){
                        pay.Featured_CMA_SM__c = Trigger.newMap.get(pay.Id).Featured_CMA_SM__c;
                        pay.Featured_CMA_SM_Requested_Value__c = Trigger.newMap.get(pay.Id).Featured_CMA_SM_Requested_Value__c;
                    }
                    if(Trigger.oldMap.get(pay.Id).FiveStreet_Requested_Value__c != Trigger.newMap.get(pay.Id).FiveStreet_Requested_Value__c){
                        pay.FiveStreet__c = Trigger.newMap.get(pay.Id).FiveStreet__c;
                        pay.FiveStreet_Requested_Value__c = Trigger.newMap.get(pay.Id).FiveStreet_Requested_Value__c;    
                    }
                    if(Trigger.oldMap.get(pay.Id).ListHub_Pro_Requested_Value__c != Trigger.newMap.get(pay.Id).ListHub_Pro_Requested_Value__c){
                        pay.ListHub_Pro__c = Trigger.newMap.get(pay.Id).ListHub_Pro__c;
                        pay.ListHub_Pro_Requested_Value__c = Trigger.newMap.get(pay.Id).ListHub_Pro_Requested_Value__c;     
                    }
                    if(Trigger.oldMap.get(pay.Id).LocalExpert_Requested_Value__c != Trigger.newMap.get(pay.Id).LocalExpert_Requested_Value__c){
                        pay.LocalExpert__c = Trigger.newMap.get(pay.Id).LocalExpert__c;
                        pay.LocalExpert_Requested_Value__c = Trigger.newMap.get(pay.Id).LocalExpert_Requested_Value__c;     
                    }
                    if(Trigger.oldMap.get(pay.Id).Market_Builder_Requested_Value__c != Trigger.newMap.get(pay.Id).Market_Builder_Requested_Value__c){
                        pay.Market_Builder__c = Trigger.newMap.get(pay.Id).Market_Builder__c;
                        pay.Market_Builder_Requested_Value__c = Trigger.newMap.get(pay.Id).Market_Builder_Requested_Value__c;   
                    }
                    if(Trigger.oldMap.get(pay.Id).Market_Snapshot_Requested_Value__c != Trigger.newMap.get(pay.Id).Market_Snapshot_Requested_Value__c){
                        pay.Market_Snapshot__c = Trigger.newMap.get(pay.Id).Market_Snapshot__c;
                        pay.Market_Snapshot_Requested_Value__c = Trigger.newMap.get(pay.Id).Market_Snapshot_Requested_Value__c;       
                    }
                    if(Trigger.oldMap.get(pay.Id).Showcase_SM_Listing_Enhancements_ReqVal__c != Trigger.newMap.get(pay.Id).Showcase_SM_Listing_Enhancements_ReqVal__c){
                        pay.Showcase_SM_Listing_Enhancements__c = Trigger.newMap.get(pay.Id).Showcase_SM_Listing_Enhancements__c;
                        pay.Showcase_SM_Listing_Enhancements_ReqVal__c = Trigger.newMap.get(pay.Id).Showcase_SM_Listing_Enhancements_ReqVal__c;    
                    }
                    if(Trigger.oldMap.get(pay.Id).Sign_Rider_Requested_Value__c != Trigger.newMap.get(pay.Id).Sign_Rider_Requested_Value__c){
                        pay.Sign_Rider__c = Trigger.newMap.get(pay.Id).Sign_Rider__c;
                        pay.Sign_Rider_Requested_Value__c = Trigger.newMap.get(pay.Id).Sign_Rider_Requested_Value__c;     
                    }
                    if(Trigger.oldMap.get(pay.Id).Standard_Listing_Enhancements_Req_Value__c != Trigger.newMap.get(pay.Id).Standard_Listing_Enhancements_Req_Value__c){
                        pay.Standard_Listing_Enhancements__c = Trigger.newMap.get(pay.Id).Standard_Listing_Enhancements__c;
                        pay.Standard_Listing_Enhancements_Req_Value__c = Trigger.newMap.get(pay.Id).Standard_Listing_Enhancements_Req_Value__c;     
                    }
                    if(Trigger.oldMap.get(pay.Id).Top_Producer_CRM_Requested_Value__c != Trigger.newMap.get(pay.Id).Top_Producer_CRM_Requested_Value__c){
                        pay.Top_Producer_CRM__c = Trigger.newMap.get(pay.Id).Top_Producer_CRM__c;
                        pay.Top_Producer_CRM_Requested_Value__c = Trigger.newMap.get(pay.Id).Top_Producer_CRM_Requested_Value__c;         
                    }
                    if(Trigger.oldMap.get(pay.Id).Top_Producer_IDX_Requested_Value__c != Trigger.newMap.get(pay.Id).Top_Producer_IDX_Requested_Value__c){
                        pay.Top_Producer_IDX__c = Trigger.newMap.get(pay.Id).Top_Producer_IDX__c;
                        pay.Top_Producer_IDX_Requested_Value__c = Trigger.newMap.get(pay.Id).Top_Producer_IDX_Requested_Value__c;      
                    }
                    if(Trigger.oldMap.get(pay.Id).Top_Producer_Website_Requested_Value__c != Trigger.newMap.get(pay.Id).Top_Producer_Website_Requested_Value__c){
                        pay.Top_Producer_Website__c = Trigger.newMap.get(pay.Id).Top_Producer_Website__c;
                        pay.Top_Producer_Website_Requested_Value__c = Trigger.newMap.get(pay.Id).Top_Producer_Website_Requested_Value__c;    
                    }
                    if(Trigger.oldMap.get(pay.Id).Top_Producer_Website_Setup_Fee_Req_Value__c != Trigger.newMap.get(pay.Id).Top_Producer_Website_Setup_Fee_Req_Value__c){
                        pay.Top_Producer_Website_Setup_Fee__c = Trigger.newMap.get(pay.Id).Top_Producer_Website_Setup_Fee__c;
                        pay.Top_Producer_Website_Setup_Fee_Req_Value__c = Trigger.newMap.get(pay.Id).Top_Producer_Website_Setup_Fee_Req_Value__c;        
                    }
                    if(Trigger.oldMap.get(pay.Id).Trackable_Phone_Number_Requested_Value__c != Trigger.newMap.get(pay.Id).Trackable_Phone_Number_Requested_Value__c){
                        pay.Trackable_Phone_Number__c = Trigger.newMap.get(pay.Id).Trackable_Phone_Number__c;
                        pay.Trackable_Phone_Number_Requested_Value__c = Trigger.newMap.get(pay.Id).Trackable_Phone_Number_Requested_Value__c;            
                    }
                    if(Trigger.oldMap.get(pay.Id).Local_Expert_City_Requested_value__c != Trigger.newMap.get(pay.Id).Local_Expert_City_Requested_value__c){
                        pay.Local_Expert_City__c = Trigger.newMap.get(pay.Id).Local_Expert_City__c;
                        pay.Local_Expert_City_Requested_value__c = Trigger.newMap.get(pay.Id).Local_Expert_City_Requested_value__c;            
                    }
                    pay.Payout_Change_Status__c = 'Pending' ;
                    pay.Record_Processed__c = false ;                                   
                    MapPay.put(Pay.Id,Pay);
                    
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Submitted for approval. Please approve.');
                    req.setObjectId(pay.Id);
                    requests.add(req); 
                    
                    Approval.ProcessResult[] processResults = null;
                    try{
                        system.debug('Enter third loop : ');
                        processResults = Approval.process(requests, true);
                    }
                    catch (System.DmlException e) {
                        System.debug('Exception Is ' + e.getMessage());
                    }
                
               }
            }            
            /*for(Payout__c pay1 : MapPay.Values()){
                if(pay1.Name != Null){
                    system.debug('Enter second loop : ');                      
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Submitted for approval. Please approve.');
                    req.setObjectId(pay1.Id);
                    requests.add(req);                       
                }
            }
            Approval.ProcessResult[] processResults = null;
            try{
                system.debug('Enter third loop : ');
                processResults = Approval.process(requests, true);
            }
            catch (System.DmlException e) {
                System.debug('Exception Is ' + e.getMessage());
            }*/
            //Approved            
            for(Payout__c pay : Trigger.New){
                if(pay.Payout_Change_Status__c == 'Approved'){          
                    pay.Commissionable__c = Trigger.oldMap.get(pay.Id).Commissionable_Requested_Value__c != Trigger.newMap.get(pay.Id).Commissionable_Requested_Value__c ? Trigger.newMap.get(pay.Id).Commissionable_Requested_Value__c : Trigger.oldMap.get(pay.Id).Commissionable_Requested_Value__c; 
                    pay.Commissionable_Requested_Value__c =  0.0;
                    // CRM-6044-
                    pay.Advantage_Leads_and_Branding__c = pay.Advantage_Leads_and_Branding_Req_Value__c != 0.0 ? pay.Advantage_Leads_and_Branding_Req_Value__c : pay.Advantage_Leads_and_Branding__c;
                    pay.Advantage_Leads_and_Branding_Req_Value__c = 0.0;
                    pay.Broker_Highlight__c = pay.Broker_Highlight_Requested_Value__c != 0.0 ? pay.Broker_Highlight_Requested_Value__c : pay.Broker_Highlight__c;
                    pay.Broker_Highlight_Requested_Value__c = 0.0;
                    pay.Connection_SM_for_Co_Brokerage__c = pay.Connection_SM_for_Co_Brokerage_ReqValue__c != 0.0 ? pay.Connection_SM_for_Co_Brokerage_ReqValue__c :  pay.Connection_SM_for_Co_Brokerage__c;
                    pay.Connection_SM_for_Co_Brokerage_ReqValue__c = 0.0;
                    pay.Connections_SM_for_Sellers__c = pay.Connections_SM_for_Sellers_Req_Value__c != 0.0 ? pay.Connections_SM_for_Sellers_Req_Value__c : pay.Connections_SM_for_Sellers__c;
                    pay.Connections_SM_for_Sellers_Req_Value__c = 0.0;
                    pay.Digital_Ad_Package__c = pay.Digital_Ad_Package_Requested_Value__c != 0.0 ? pay.Digital_Ad_Package_Requested_Value__c : pay.Digital_Ad_Package__c;
                    pay.Digital_Ad_Package_Requested_Value__c = 0.0;
                    pay.Digital_Advertising_Campaign__c = pay.Digital_Advertising_Campaign_Req_Value__c != 0.0 ? pay.Digital_Advertising_Campaign_Req_Value__c : pay.Digital_Advertising_Campaign__c;
                    pay.Digital_Advertising_Campaign_Req_Value__c = 0.0;
                    pay.Domain_Name__c = pay.Domain_Name_Requested_Value__c != 0.0 ? pay.Domain_Name_Requested_Value__c : pay.Domain_Name__c;
                    pay.Domain_Name_Requested_Value__c = 0.0;
                    pay.Featured_CMA_SM__c = pay.Featured_CMA_SM_Requested_Value__c !=  0.0 ? pay.Featured_CMA_SM_Requested_Value__c : pay.Featured_CMA_SM__c;
                    pay.Featured_CMA_SM_Requested_Value__c = 0.0;
                    pay.FiveStreet__c = pay.FiveStreet_Requested_Value__c != 0.0 ? pay.FiveStreet_Requested_Value__c : pay.FiveStreet__c;
                    pay.FiveStreet_Requested_Value__c = 0.0;
                    pay.ListHub_Pro__c	= pay.ListHub_Pro_Requested_Value__c != 0.0 ? pay.ListHub_Pro_Requested_Value__c : pay.ListHub_Pro__c;
                    pay.ListHub_Pro_Requested_Value__c = 0.0;
                    pay.LocalExpert__c = pay.LocalExpert_Requested_Value__c != 0.0 ? pay.LocalExpert_Requested_Value__c : pay.LocalExpert__c;
                    pay.LocalExpert_Requested_Value__c = 0.0;
                    pay.Market_Builder__c = pay.Market_Builder_Requested_Value__c != 0.0 ? pay.Market_Builder_Requested_Value__c : pay.Market_Builder__c;
                    pay.Market_Builder_Requested_Value__c = 0.0;
                    pay.Market_Snapshot__c = pay.Market_Snapshot_Requested_Value__c != 0.0 ? pay.Market_Snapshot_Requested_Value__c : pay.Market_Snapshot__c;
                    pay.Market_Snapshot_Requested_Value__c = 0.0;
                    pay.Showcase_SM_Listing_Enhancements__c = pay.Showcase_SM_Listing_Enhancements_ReqVal__c != 0.0 ? pay.Showcase_SM_Listing_Enhancements_ReqVal__c : pay.Showcase_SM_Listing_Enhancements__c;
                    pay.Showcase_SM_Listing_Enhancements_ReqVal__c = 0.0;
                    pay.Sign_Rider__c = pay.Sign_Rider_Requested_Value__c != 0.0 ? pay.Sign_Rider_Requested_Value__c : pay.Sign_Rider__c;
                    pay.Sign_Rider_Requested_Value__c = 0.0;
                    pay.Standard_Listing_Enhancements__c = pay.Standard_Listing_Enhancements_Req_Value__c != 0.0 ? pay.Standard_Listing_Enhancements_Req_Value__c : pay.Standard_Listing_Enhancements__c;
                    pay.Standard_Listing_Enhancements_Req_Value__c = 0.0;
                    pay.Top_Producer_CRM__c = pay.Top_Producer_CRM_Requested_Value__c != 0.0 ? pay.Top_Producer_CRM_Requested_Value__c : pay.Top_Producer_CRM__c;
                    pay.Top_Producer_CRM_Requested_Value__c = 0.0;
                    pay.Top_Producer_IDX__c = pay.Top_Producer_IDX_Requested_Value__c != 0.0 ? pay.Top_Producer_IDX_Requested_Value__c : pay.Top_Producer_IDX__c;
                    pay.Top_Producer_IDX_Requested_Value__c = 0.0;
                    pay.Top_Producer_Website__c = pay.Top_Producer_Website_Requested_Value__c != 0.0 ? pay.Top_Producer_Website_Requested_Value__c : pay.Top_Producer_Website__c;
                    pay.Top_Producer_Website_Requested_Value__c = 0.0;
                    pay.Top_Producer_Website_Setup_Fee__c = pay.Top_Producer_Website_Setup_Fee_Req_Value__c != 0.0 ? pay.Top_Producer_Website_Setup_Fee_Req_Value__c : pay.Top_Producer_Website_Setup_Fee__c;
                    pay.Top_Producer_Website_Setup_Fee_Req_Value__c = 0.0;
                    pay.Trackable_Phone_Number__c = pay.Trackable_Phone_Number_Requested_Value__c != 0.0 ? pay.Trackable_Phone_Number_Requested_Value__c : pay.Trackable_Phone_Number__c;
                    pay.Trackable_Phone_Number_Requested_Value__c = 0.0;
                    pay.Local_Expert_City__c = pay.Local_Expert_City_Requested_value__c != 0.0 ? pay.Local_Expert_City_Requested_value__c : pay.Local_Expert_City__c;
                    pay.Local_Expert_City_Requested_value__c = 0.0;
                    pay.Payout_Change_Status__c = 'Open';
                    MapPay.put(Pay.Id,Pay);
                }
            }
            for(Payout__c pay : Trigger.New){
                if(pay.Payout_Change_Status__c == 'Rejected'){
                    pay.Commissionable_Requested_Value__c =  0.0;  
                    // CRM-6044-
                    pay.Advantage_Leads_and_Branding_Req_Value__c = 0.0;                    
                    pay.Broker_Highlight_Requested_Value__c = 0.0;                    
                    pay.Connection_SM_for_Co_Brokerage_ReqValue__c = 0.0;                    
                    pay.Connections_SM_for_Sellers_Req_Value__c = 0.0;                    
                    pay.Digital_Ad_Package_Requested_Value__c = 0.0;                    
                    pay.Digital_Advertising_Campaign_Req_Value__c = 0.0;                    
                    pay.Domain_Name_Requested_Value__c = 0.0;                    
                    pay.Featured_CMA_SM_Requested_Value__c = 0.0;                    
                    pay.FiveStreet_Requested_Value__c = 0.0;                    
                    pay.ListHub_Pro_Requested_Value__c = 0.0;                    
                    pay.LocalExpert_Requested_Value__c = 0.0;                    
                    pay.Market_Builder_Requested_Value__c = 0.0;                    
                    pay.Market_Snapshot_Requested_Value__c = 0.0;                    
                    pay.Showcase_SM_Listing_Enhancements_ReqVal__c = 0.0;                    
                    pay.Sign_Rider_Requested_Value__c = 0.0;                    
                    pay.Standard_Listing_Enhancements_Req_Value__c = 0.0;                    
                    pay.Top_Producer_CRM_Requested_Value__c = 0.0;                    
                    pay.Top_Producer_IDX_Requested_Value__c = 0.0;                    
                    pay.Top_Producer_Website_Requested_Value__c = 0.0;                    
                    pay.Top_Producer_Website_Setup_Fee_Req_Value__c = 0.0;                    
                    pay.Trackable_Phone_Number_Requested_Value__c = 0.0; 
                    pay.Local_Expert_City_Requested_value__c = 0.0;
                    pay.Payout_Change_Status__c = 'Open';
                    MapPay.put(Pay.Id,Pay);
                }
            }            
        }
    }    
}