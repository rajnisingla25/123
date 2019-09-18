/* Class :- ComarketingDetailsCtrl
Purpose : LCM-149 To add amend and cancel in CO Marketing relationship
Created Date :- 12 October 2018
Created By : Mridula
*/
public class ComarketingDetailsCtrl {

    public PageReference goBack() {
        PageReference returnPage = new PageReference('/apex/comarketingAccount?email='+sourceAccount.primary_email__c+'&partyId='+sourceAccount.Party_ID__c+'&id='+sourceAccount.Id+'&name='+sourceAccount.Name+'&accountType='+sourceAccount.type);  
        return returnPage;
    }

    public Id arId = null;
    public String partyId { get; set; }
    public String comarketerSpend {get;set;}
    public String relationshipCAP {get;set;}
    public Decimal agentSpend {get;set;}
    public Decimal assetPrice {get;set;} 
    public Decimal selectedAssetsPrice {get;set;}
    public Decimal comarketingSpendPercent {get;set;}
    public Decimal comarketingCurrentPercent {get;set;}
    public List<relationWrapper> records {get;set;}
    public Integer totalAssets {get;set;}
    public boolean hideActivate {get;set;}
    public boolean hidePartyId {get;set;}
    public static boolean error = false;
    private Account sourceAccount; 
    private static boolean sendToZuora = false;
    
    public comarketingDetailsCtrl(){
        getRelations();
        hideActivate = true;
        if(ApexPages.currentPage().getParameters().containsKey('totalAssets') && ApexPages.currentPage().getParameters().get('totalAssets') != null && ApexPages.currentPage().getParameters().get('totalAssets') != ''  && ApexPages.currentPage().getParameters().get('totalAssets') != 'null'){
           totalAssets = Integer.valueOf(ApexPages.currentPage().getParameters().get('totalAssets'));
        } 
        //LCM-226
        if(ApexPages.currentPage().getParameters().get('zuoraStatus') != null && ApexPages.currentPage().getParameters().get('zuoraStatus') == 'false' && ApexPages.currentPage().getParameters().get('status') != null && ApexPages.currentPage().getParameters().get('status') == 'Pending Activation'){
            hideActivate = false;
        }
    }
    public String getPartyIdLabel (){ 
        if(ApexPages.currentPage().getParameters().get('accounttype') == 'Lender Individual'){
            return 'Agent Party Id'; 
        }else{
            return 'Lender Comarketer Party Id';
        }
    }
   
    public List<relationWrapper> getRelations() {
        sourceAccount = [Select primary_email__c,id,Email_Address__c,party_id__c,type,name from Account where id =: ApexPages.currentPage().getParameters().get('id')];

        records = new List<relationWrapper>();
        if(ApexPages.currentPage().getParameters().get('rId') != null && ApexPages.currentPage().getParameters().get('rId') != ''){
            List<Account_Relationship__c> arList = [Select id, Current_Comarketer_Spend_Percent__c , comarketer_Actual_Spend__c, total_connections_price__c,total_relationship_assets_price__c, relationship_Type__c, relationship_CAP__c, comarketer_spend__c, Initial_comarketer_spend_percent__c, comarketer_spend_percent__c,  child_account__r.party_id__c, parent_account__r.party_id__c  from Account_Relationship__c where id=:ApexPages.currentPage().getParameters().get('rId')];
            List<comarketing_Relationship__c> crList = [Select agent_zuora_comment__c, lender_zuora_comment__c, agent_zuora_status__c, lender_zuora_status__c, status__c,cfcb_asset__r.Asset_Number__c,Lender_Percentage_Contribution__c, lender_asset_monthly_contribution__c, agent_asset_monthly_contribution__c, id,cfcb_asset__r.monthly_price__c, market__c,cfcb_asset__c,action__c from comarketing_relationship__c where relationship__c =: arList[0].id];
            hidePartyId = true;
            if(ApexPages.currentPage().getParameters().get('accounttype')=='Lender Individual'){
                partyId = arList[0].parent_account__r.party_id__c;
                
            }else{
                partyId = arList[0].child_account__r.party_id__c;

            }
            comarketerSpend = String.valueOf(arList[0].comarketer_actual_spend__c);
            relationshipCAP = String.valueOf(arList[0].relationship_CAP__c);
            AssetPrice     = arList[0].total_connections_price__c;
            selectedAssetsPrice     = arList[0].total_relationship_assets_price__c;
            comarketingSpendPercent = arList[0].Initial_comarketer_spend_percent__c;
            comarketingCurrentPercent = arList[0].Current_Comarketer_Spend_Percent__c;
            agentspend = selectedAssetsPrice >0 ? selectedAssetsPrice - Decimal.valueOf(comarketerSpend) : 0.00;
            
            records = new List<relationWrapper>();
            for(comarketing_Relationship__c a: crList){
                relationWrapper rw = new relationWrapper();
                rw.selected = true;
                rw.market = a.market__c;
                rw.assetName = a.cfcb_asset__r.Asset_Number__c;
                rw.purchasePrice = a.cfcb_asset__r.monthly_price__c;
                rw.comarketerSpend = a.lender_asset_monthly_contribution__c;
                rw.agentSpend = a.agent_asset_monthly_contribution__c;
                rw.comarketerPercent = a.Lender_Percentage_Contribution__c;
                rw.assetId = a.cfcb_asset__c;
                rw.status = a.status__c;
                rw.action = a.action__c;//LCM-255
                rw.isZero = a.agent_zuora_comment__c != null && a.agent_zuora_comment__c.contains('zero dollars') ? true : false; //LCM-266
                records.add(rw);
            }
        }else{
            createwrapper(ApexPages.currentPage().getParameters().get('id'));
        }
        return records;
    }

    public void createwrapper(String param){
        records = new List<relationWrapper>();
        List<Asset> assets = [Select id, Asset_Number__c, Market__c, monthly_price__c from Asset where (AccountId =:param OR account.party_Id__c =:param) AND status = 'Active' AND productCode = 'COBROKE' AND Fulfillment_Status__c = 'Fulfilled' and asset_type__c = 'Parent'];
        totalAssets = assets.size();
            assetPrice = 0;
            if(assets.isEmpty() && partyID != null && partyID != ''){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'This Party Id does not have any active, fulfilled, cobroke assets. Please try a different party Id '));
               error = true;
            }
           
            for(Asset a: assets){
                relationWrapper rw = new relationWrapper();
                rw.selected = true;
                rw.market = a.market__c;
                rw.assetName = a.Asset_Number__c;
                rw.purchasePrice = a.monthly_price__c;
                rw.agentSpend = a.monthly_price__c;
                rw.assetId = a.id;
                assetPrice += a.monthly_price__c;
                records.add(rw);
            }
            
    }
    
    private void setARID(string param){
            List<Account_Relationship__c> arList = [Select id, parent_account__r.party_Id__c, child_account__r.party_Id__c,  parent_account__c, child_account__c, comarketing_status__c from Account_Relationship__c where (parent_account__c =: param OR parent_account__r.party_Id__c =: param OR child_account__c =: param OR child_account__r.party_id__c =: param) AND comarketing_status__c = 'Cancelled'];    
            if(!arList.isEmpty()){
               system.debug('Inside the ar list');
               for(account_relationship__c ar: arList){
                    
                    if(partyID != null && partyId != '' &&
                       ar.comarketing_status__c == 'Cancelled' &&
                       (ar.child_account__c == ApexPages.currentPage().getParameters().get('id') ||
                        ar.parent_account__c == ApexPages.currentPage().getParameters().get('id')) &&
                       (ar.parent_account__r.party_Id__c == partyId ||
                       ar.child_account__r.party_Id__c == partyID)){
                       
                          arId = ar.id;
                          
                       }
               
            }
            }
    }
    
    
    public PageReference activate() {
        
        List<Account> accounts= [select id,type from Account where party_id__c =: partyId OR id =: ApexPages.currentPage().getParameters().get('Id')];
        Map<String,Id> accMap = new map<String,Id>();
        for(account a : accounts){
            if(a.type == 'Lender Individual'){
               accMap.put('lender',a.id);
               setARID(a.id);
            }else{
                accMap.put('agent',a.id);  
                setARID(a.id);
            }
        }
        
        if(ApexPages.currentPage().getParameters().get('Status') == 'Pending Activation'){
            sendToZuora = true;
        }
        
        Account_Relationship__c ar = new Account_Relationship__c();
        ar.relationship_Type__c = 'Partner';
        ar.parent_account__c = accMap.get('agent');
        ar.child_account__c = accMap.get('lender');
        ar.total_comarketing_assets__c = records.size();
        ar.relationship_CAP__c = relationshipCAP != null && relationshipCAP != '0' && relationshipCAP != '' ? Decimal.valueOf(relationshipCAP) : null ;
        ar.comarketer_spend__c = Decimal.valueOf(comarketerSpend);
        ar.Initial_comarketer_spend_percent__c = comarketingSpendPercent;
        ar.current_comarketer_spend_percent__c = comarketingCurrentPercent;
        ar.total_connections_price__c = assetPrice;
        ar.total_relationship_assets_price__c = assetPrice;
        
         //LCM-67: Populate lender and agent email fields. These fields be used for sending notifications
        for(Account_Relationship__c rel : [Select id, Contact_To__r.email, parent_account__c, parent_account__r.Email_Address__c, parent_account__r.Type, Contact_To__r.FirstName, Contact_To__r.LastName from Account_Relationship__c 
                                                     where parent_account__c IN :accMap.values() and Contact_Role__c = 'Primary Contact' and Active__c = true and Contact_To__c != null]){
            if(rel.parent_account__r.Type == 'Lender Individual'){
                ar.Child_account_email__c =  rel.parent_account__r.Email_Address__c; //ACP: Use account email
                ar.Child_account_contact_name__c = rel.Contact_To__r.FirstName;
                ar.Child_account_contact_last_name__c = rel.Contact_To__r.LastName;//LCM-269
            } else {
                ar.Parent_account_email__c =  rel.parent_account__r.Email_Address__c;// ACP: Use account email
                ar.Parent_account_contact_name__c = rel.Contact_To__r.FirstName;
                ar.Parent_account_contact_last_name__c = rel.Contact_To__r.LastName;
            }                    
        }// END LCM-67
        
        if((ApexPages.currentPage().getParameters().get('rId') == null || ApexPages.currentPage().getParameters().get('rId') == '') && (arId == null) ){
            ar.comarketing_status__c = 'Pending Activation';
            ar.comarketer_actual_spend__c = Decimal.valueOf(comarketerSpend);
            sendToZuora = true;
            ar.comarketing_action__c = 'Add';
            insert ar;
        }else{
            if(arID == null){
                Account_Relationship__c ar_priceCheck = [Select id, comarketer_actual_spend__c,comarketing_status__c from Account_Relationship__c where id =: ApexPages.currentPage().getParameters().get('rId')];
                if(ar_priceCheck.comarketer_actual_spend__c != null && ar_priceCheck.comarketer_actual_spend__c != Decimal.valueOf(comarketerSpend)){
                    sendToZuora = true;
                }
            
            ar.comarketer_actual_spend__c = Decimal.valueOf(comarketerSpend);
            
            if(ar_priceCheck.comarketing_status__c == 'Active'){
                ar.comarketing_action__c = 'Amend';
                ar.comarketing_status__c = 'Pending Activation';
            }
            ar.active__c = true; 
            }
            ar.id =  (arId != null ? arID : ApexPages.currentPage().getParameters().get('rId'));
            if(arID != null){
                sendToZuora = true;
                ar.Sent_LCM_amend_notification_date__c = null;
                ar.Sent_LCM_cancel_notification_date__c = null;
                ar.Sent_LCM_new_relationship_email__c = false;
                ar.Comarketing_Cancellation_Date__c = null;
                ar.comarketing_cancellation_reason__c = null;
                ar.comarketing_cancellation_description__c = null;
                ar.comarketing_action__c = 'Add';
            }
            update ar;
        }
        List<comarketing_relationship__c> crList = new List<comarketing_relationship__c>();
        for(relationWrapper rw: records){
         if(rw.status != 'Cancelled' && rw.status != 'Pending Cancellation'){ 
            comarketing_relationship__c cr = new comarketing_relationship__c();
            cr.agent_account__c = accMap.get('agent');
            cr.lender_account__c = accmap.get('lender');
            cr.relationship__c = ar.id;
            cr.cfcb_asset__c = rw.assetId;
            cr.Agent_Lender_Asset_Id__c = cr.agent_account__c+'-'+cr.lender_account__c+'-'+cr.cfcb_asset__c;
            cr.lender_asset_monthly_contribution__c = rw.comarketerSpend;
            cr.Lender_Percentage_Contribution__c = rw.comarketerPercent;
            cr.Agent_Asset_Monthly_Contribution__c = rw.agentSpend;

            if(ApexPages.currentPage().getParameters().get('rId') != null && ApexPages.currentPage().getParameters().get('rId') != ''){
                if(ApexPages.currentPage().getParameters().get('status') == 'Active'){ // Update action only if relationship is active
                   if(rw.isZero != null && rw.isZero){
                      cr.action__c = 'Add';
                      cr.status__c = 'Pending Activation'; 
                   }else{
                    cr.action__c = 'Amend';
                    cr.status__c = 'Pending Activation';
                    }
                }
                if(cr.action__c == 'Amend' || rw.action == 'Amend'){ // Override values on every amend LCM-255
                    cr.Amendment_Effective_Date__c = System.Today();
                    cr.Amendment_Description__c = 'Lender Spend Adjustment';
                    cr.Amendment_Reason__c = 'Customer Driven';
                }
            }else{
                 cr.action__c = 'Add';
                 cr.status__c = 'Pending Activation';
            }
           
            if(cr.Action__c == 'Add'){
                cr.Initial_lender_monthly_contribution__c = cr.lender_asset_monthly_contribution__c;
                cr.Initial_Agent_Monthly_Contribution__c = cr.Agent_Asset_Monthly_Contribution__c;
            }
           
            if(arID != null){
                cr.Amendment_Effective_Date__c = null;
                cr.lender_cancellation_Date__c = null;
                cr.agent_cancellation_date__c = null;
                cr.cancellation_reason__c = '';
                cr.Cancel_Description__c = '';
                cr.reactivated__c = true;

            }
            
            
           
                crList.add(cr);
           }
            
        }
        if(!crList.isempty()){
            upsert crList Agent_Lender_Asset_Id__c;
        }
        return new PageReference('/apex/LenderPaymentProfile?id='+accMap.get('lender')+'&rId='+ar.id+'&ActType='+ApexPages.currentPage().getParameters().get('accounttype')+'&sendToZuora='+sendToZuora);
       //return new PageReference('/apex/LenderPaymentProfile?id='+accMap.get('lender')+'&accId='+ApexPages.currentPage().getParameters().get('id'));

      
    }
    private void checkifContactExists(String cPartyId){
        List<Account_Relationship__c> arContacts = [Select id from Account_Relationship__c where parent_account__r.party_id__c =: cPartyId AND active__c = true AND relationship_type__c = 'Contact' AND Billing_Contact__c = true];
        if(arContacts.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The selected lender does not have billing contact. Please add billing contact and proceed'));
            error = true;
        }
    } 
    
    private void checkifRelationshipExists(String agentPartyId){
        List<account_relationship__c> alist = [Select id from account_relationship__c where relationship_type__c = 'Partner' AND (comarketing_status__c = 'Active' OR comarketing_status__c = 'Pending Activation' OR comarketing_status__c = 'Pending Cancellation') AND (parent_account__r.party_id__c =: agentPartyId OR parent_account__c =: agentPartyID) ];
        if(!alist.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Selected customer already has one active/pending lender associated. Cannot associate more than one lender to a customer.')); //LCM-346
            error = true;
        }
    }
    
    private void checkIfAccountIsBroker(String cPartyId){
        List<Account> accts = [Select id, type from Account where party_id__c = :cPartyId and type = 'Broker' limit 1];
        if(!accts.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'The selected account is a Broker. Cannot create comarketing relationship on broker accounts.'));
            error = true;
        }
    }
    private void checkifAccountisLCMEligible(String cPartyId){
        List<Account> accs = [Select id, LCM_eligible__c, past_due__c from Account where party_id__c =: cPartyId];
        if(!accs.isEmpty()){
            if(!accs[0].lcm_eligible__c){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Selected party Id is not LCM Eligible'));
                error = true;
            }
            if(accs[0].past_Due__c){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Selected party Id is Past Due.'));
                error = true;
            }
        }
    }
   
    public void onChangePartyID(){
        if(partyId != null && partyId != ''){
            //checkIfAccountIsBroker(partyId); commented as part of lcm-287
        }
        if(partyId != null && partyId != '' && ApexPages.currentPage().getParameters().get('accounttype') == 'Lender Individual'){
           checkifRelationshipExists(partyId);
           checkifAccountisLCMEligible(partyId);
           createwrapper(partyId);
        }
        if(partyId != null && partyId != '' && ApexPages.currentPage().getParameters().get('accounttype') != 'Lender Individual' && ApexPages.currentPage().getParameters().get('rId') == '' ){
            checkifContactExists(partyId);
            checkifRelationshipExists(ApexPages.currentPage().getParameters().get('id'));
        }
        
        if(assetPrice != null && assetPrice != 0 && assetPrice > 0 && comarketerSpend != null && comarketerSpend != '' && Decimal.valueOf(comarketerSpend)<=0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lender Spend cannot be 0 or less')); //'Comarketing Spend cannot be greater than RDC CAP which is '+Label.RDC_CAP+'% of total relationship assets price ('+((assetPrice*Integer.valueOf(Label.RDC_CAP))/100)+')'));
               error = true;
            }
           
        try{
            if(partyId != null && partyId != '' && ApexPages.currentPage().getParameters().get('accounttype') != 'Lender Individual'){            
                List<Account> acc = [Select Id From Account Where Party_Id__c =:partyId];
                if(acc.size()>0)
                    system.debug('@@@ZCreation1');
                    String ZId=  Z_PaymentMethodCaptureUtil.CreateZuoraAccountWithSfdcAccountId(acc[0].Id);                 
            }else if(ApexPages.currentPage().getParameters().get('accounttype') == 'Lender Individual'){
                system.debug('@@@ZCreation2');
                String ZId=  Z_PaymentMethodCaptureUtil.CreateZuoraAccountWithSfdcAccountId(ApexPages.currentPage().getParameters().get('id'));   
            }
        }catch(exception ex){}
        
        if(comarketerSpend == ''){
            error = true;
        }
        
        if(error){
                hideActivate = true;
        }else{
            hideActivate = false;
        }
    }
    
    public void onChangeLenderSpend(){
        if(partyId != null && partyId != ''){
             //checkIfAccountIsBroker(partyId); lcm-287
             if(ApexPages.currentPage().getParameters().get('rId') == ''){
                checkifRelationshipExists(partyId); 
                 if(ApexPages.currentPage().getParameters().get('accounttype') == 'Lender Individual'){
                    checkifAccountisLCMEligible(partyId);
                 }

             } 
            
             if(relationshipCAP != null && relationshipCAP != '0' && relationshipCAP != '' && comarketerSpend != null && comarketerSpend != '0' && comarketerSpend != '' && Decimal.valueOf(comarketerSpend) > Decimal.valueOf(relationshipCAP)){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Comarketing Spend cannot be greater than relationship CAP'));
               error = true;
            }
            if(assetPrice != null && comarketerSpend != null && comarketerSpend != '0' && comarketerSpend != '' && Decimal.valueOf(comarketerSpend) > ((assetPrice*Integer.valueOf(Label.RDC_CAP))/100)){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lender Contribution % cannot exceed 50%')); //'Comarketing Spend cannot be greater than RDC CAP which is '+Label.RDC_CAP+'% of total relationship assets price ('+((assetPrice*Integer.valueOf(Label.RDC_CAP))/100)+')'));
               error = true;
            }
            if(comarketerSpend == '' || Decimal.valueOf(comarketerSpend) < 0 )
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lender Contribution % cannot be blank or less than 0')); //'Comarketing Spend cannot be greater than RDC CAP which is '+Label.RDC_CAP+'% of total relationship assets price ('+((assetPrice*Integer.valueOf(Label.RDC_CAP))/100)+')'));
               error = true;
            }
            
            if(assetPrice != null && assetPrice != 0 && assetPrice > 0  && comarketerSpend != null && comarketerSpend != '' && Decimal.valueOf(comarketerSpend)<=0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lender Spend cannot be 0 or less')); //'Comarketing Spend cannot be greater than RDC CAP which is '+Label.RDC_CAP+'% of total relationship assets price ('+((assetPrice*Integer.valueOf(Label.RDC_CAP))/100)+')'));
               error = true;
            }
            
            // calculating percentage x = total comarketing Spend times 100 divided by total Assets price
            if(comarketerSpend != null && comarketerSpend != '0' && comarketerSpend != ''){
                sendToZuora = true;
                comarketingSpendPercent = assetPrice > 0 ? ((Decimal.valueOf(comarketerSpend) / assetPrice) *100) : 0 ;
                comarketingCurrentPercent = comarketingSpendPercent;
                agentSpend = assetPrice > 0? (assetPrice - Decimal.valueOf(comarketerSpend)) : 0;
                comarketerSpend = String.valueOf(Decimal.valueOf(comarketerSpend).setScale(2));
                for(relationWrapper r: records){
                    r.comarketerSpend = ((r.purchasePrice != null ? r.purchasePrice : 0.00) * (comarketingSpendPercent!= null ? comarketingSpendPercent : 0.00))/100;
                    r.agentSpend = (r.purchasePrice!= null ? r.purchasePrice : 0.00) - (r.comarketerSpend!= null ? r.comarketerSpend : 0.00);
                    r.comarketerPercent = (comarketingSpendPercent!= null ? comarketingSpendPercent : 0.00);
                    
                }
            }
            if(comarketerSpend != null && comarketerSpend == '0'){
               comarketingSpendPercent = 0;
               comarketingCurrentPercent = 0;
            }
            
        }
        else{
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter party Id before changing lender spend')); //'Comarketing Spend cannot be greater than RDC CAP which is '+Label.RDC_CAP+'% of total relationship assets price ('+((assetPrice*Integer.valueOf(Label.RDC_CAP))/100)+')'));
            error = true; 
        }
       if(error){
                hideActivate = true;
        }else{
            hideActivate = false;
        }
    }
    
    public void onChangeLenderSpendMax(){
        if(partyId != null && partyId != ''){
           // checkIfAccountIsBroker(partyId); lcm-287
             if(ApexPages.currentPage().getParameters().get('rId') == ''){
                checkifRelationshipExists(partyId); 
                if(ApexPages.currentPage().getParameters().get('accounttype') == 'Lender Individual'){
                    checkifAccountisLCMEligible(partyId);
                 }

             } 
            if(relationshipCAP != null && relationshipCAP != '0' && relationshipCAP!= '' && comarketerSpend != null && comarketerSpend != '0' && comarketerSpend != '' && Decimal.valueOf(comarketerSpend) > Decimal.valueOf(relationshipCAP)){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Comarketing Spend cannot be greater than relationship CAP'));
               error = true;
            }
            if(assetPrice != null && comarketerSpend != null && comarketerSpend != '0' && comarketerSpend != '' && Decimal.valueOf(comarketerSpend) > ((assetPrice*Integer.valueOf(Label.RDC_CAP))/100)){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lender Contribution % cannot exceed 50%')); //'Comarketing Spend cannot be greater than RDC CAP which is '+Label.RDC_CAP+'% of total relationship assets price ('+((assetPrice*Integer.valueOf(Label.RDC_CAP))/100)+')'));
               error = true;
            }
            if(comarketerSpend == '' || Decimal.valueOf(comarketerSpend) < 0 )
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lender Contribution % cannot be blank or less than 0')); //'Comarketing Spend cannot be greater than RDC CAP which is '+Label.RDC_CAP+'% of total relationship assets price ('+((assetPrice*Integer.valueOf(Label.RDC_CAP))/100)+')'));
               error = true;
            }
            if(comarketingCurrentPercent != comarketingSpendPercent){
                if(relationshipCAP != null && relationshipCAP != ''){
                    comarketingCurrentPercent = (Decimal.valueOf(relationshipCAP)/assetPrice)*100;
                    if(comarketingCurrentPercent > comarketingSpendPercent){
                        comarketingCurrentPercent = comarketingSpendPercent;   
                    }
                }else{
                    comarketingCurrentPercent = comarketingSpendPercent;
                }
                comarketerSpend = String.valueOf(((comarketingCurrentPercent/100)*assetPrice).setScale(2));
                agentSpend = assetPrice - Decimal.valueOf(comarketerSpend);
                for(relationWrapper r: records){
                    r.comarketerSpend = ((r.purchasePrice != null ? r.purchasePrice : 0.00) * (comarketingCurrentPercent!= null ? comarketingCurrentPercent : 0.00))/100;
                    r.agentSpend = (r.purchasePrice!= null ? r.purchasePrice : 0.00) - (r.comarketerSpend!= null ? r.comarketerSpend : 0.00);
                    r.comarketerPercent = (comarketingCurrentPercent!= null ? comarketingCurrentPercent : 0.00);
                    
                }
            }
            
    
            if(assetPrice != null && assetPrice != 0 && assetPrice >0 && comarketerSpend != null && comarketerSpend != '' && Decimal.valueOf(comarketerSpend)<=0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Lender Spend cannot be 0 or less')); //'Comarketing Spend cannot be greater than RDC CAP which is '+Label.RDC_CAP+'% of total relationship assets price ('+((assetPrice*Integer.valueOf(Label.RDC_CAP))/100)+')'));
               error = true;
            }
          
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter party Id before changing lender spend max')); //'Comarketing Spend cannot be greater than RDC CAP which is '+Label.RDC_CAP+'% of total relationship assets price ('+((assetPrice*Integer.valueOf(Label.RDC_CAP))/100)+')'));
            error = true;
        }
        if(error){
                hideActivate = true;
        }else{
            hideActivate = false;
        }
    }
   
   
   
  
    public class relationWrapper{
        public boolean selected {get;set;}
        public string market {get;set;}
        public String AssetName {get;set;}
        public Decimal purchasePrice {get;set;}
        public Decimal agentSpend {get;set;}
        public Decimal comarketerSpend {get;set;}
        public Decimal comarketerPercent {get;set;}
        public String Status {get;set;}
        public Id assetId {get;set;}
        public Boolean isZero {get;set;}
        public String action {get;set;}
    }

}