Public Class WaitlistItemtriggerHandlerManager {
    public boolean matchfound = false;
    
    // Gives rank for customer accepted items
    public void giverank(list < Waitlist_Item__c > giverank, list < Waitlist_Item__c > wlifulfil) {
        boolean matchfound = false;
        list < aggregateResult > wlirankinfo = [select max(Rank__c) maxrank, Product__c, Market__c, 
                                                Market_Type__c from Waitlist_Item__c 
                                                GROUP BY Product__c, Market__c, 
                                                Market_Type__c,status__C having status__C = 'Active'];
        
        for (Waitlist_Item__c wliloop: giverank) {
            
            If(wliloop.Rank__c==null || wliloop.Rank__C == 9999){
            
            matchfound = false;
            for (aggregateResult agrlp: wlirankinfo) {
                if (agrlp.get('Product__c') == wliloop.Product__c &&
                    agrlp.get('Market__c') == wliloop.Market__c &&
                    agrlp.get('Market_Type__c') == wliloop.Market_Type__c) {
                        if(agrlp.get('maxrank')!=null && agrlp.get('maxrank')!=9999){
                             wliloop.Rank__c = Integer.valueof(agrlp.get('maxrank')) + 1;
                             matchfound = true;
                          }
                       
                    } else {
                        if (!(matchfound)) {
                            wliloop.Rank__c = 0;
                            wliloop.Rank__c = wliloop.Rank__c + 1;
                        }
                    }
            }
            if (wlirankinfo.size() == 0) {
                wliloop.Rank__c = 0;
                wliloop.Rank__c = wliloop.Rank__c + 1;
            }
        }
}        
        for (Waitlist_Item__c wliffloop: wlifulfil) {
            wliffloop.rank__c = 0;
        }
        
        waitlistitemTriggerHandler.skipbeforeupdaterun = true;
    }
    
    public void Rerank(list < Waitlist_Item__c > Rerank, Map < Id, Waitlist_Item__c > olditems) { //CRM-1452
        system.debug('Rerank:'+Rerank);
        list < Waitlist_Item__c > Rerankupdate = new list < Waitlist_Item__c > ();
        list < Waitlist_Item__c > wlirerank = new list < Waitlist_Item__c > ();
        try {
            Set<String> statuses = new Set<String>();
            statuses.add('Active');
            statuses.add('Renewed');
            wlirerank = [SELECT id, Rank__c, Product__c, Market__c, Market_Type__c, status__C FROM Waitlist_Item__c 
                         WHERE status__C IN: statuses and Wailist_Type__c = 'Pre-Auth'order by Rank__c ASC]; //CRM-3439 added renewed
            system.debug('wlirerank:'+wlirerank);
        } catch (queryexception e) {
            for (Waitlist_Item__c wliloop: Rerank) {
                wliloop.Rank__c = 0;
                Rerankupdate.add(wliloop);
            }
        }
        
        for (Waitlist_Item__c wliloop: Rerank) {
            
            //Waitlist_Item__c zerorank = new Waitlist_Item__c();
            //zerorank.id       = wliloop.id; 
            //zerorank.Rank__c  = 0;
            
            for (Waitlist_Item__c wlirrnklp: wlirerank) {
                Waitlist_Item__c toRerank = new Waitlist_Item__c();
                if (wlirrnklp.Product__c == wliloop.Product__c &&
                    wlirrnklp.Market__c == wliloop.Market__c &&
                    wlirrnklp.Market_Type__c == wliloop.Market_Type__c) {
                        if(wlirrnklp.Rank__c > olditems.get(wliloop.id).Rank__c){ //CRM-1452
                           // If(wlirrnklp.Rank__c !=1){
                            
                            wlirrnklp.Rank__c = wlirrnklp.Rank__c - 1;
                            Rerankupdate.add(wlirrnklp);
                            system.debug('wlirrnklp:'+wlirrnklp);
                               // }
                        }
                    }
            }
           // Rerankupdate.add(zerorank);
        }
       update Rerankupdate;
        
        waitlistitemTriggerHandler.skipafterupdaterun = true;

        /*
      
             list < aggregateResult > wlirankinfo = [select max(Rank__c) maxrank, Product__c, Market__c, 
                                                Market_Type__c from Waitlist_Item__c 
                                                GROUP BY Product__c, Market__c, 
                                                Market_Type__c,status__C having status__C = 'Active'];
       
        
        List<Waitlist_Item__c> wlReRankUpdate = new List<Waitlist_Item__c>() ;
        
        for (Waitlist_Item__c wliloop: Rerank) {
        
        
        }
        //update Rerankupdate;
        */
        
        
        
        
    }

    // Insert Opportunity
    public static void InsertOpportunity(list<Waitlist_Item__c> WLItoporcess) {
        set<id> Acctids = new set<id>();
        for (Waitlist_Item__c WLIloop : WLItoporcess){
            Acctids.add(WLIloop.Account__c);
        }
        
        map<id,Account> acctdata = new map<id,Account>([select id,name from account where id in :Acctids]);
        for (Waitlist_Item__c loop1 : WLItoporcess){
            //Insert opportunity
            Opportunity theOpportunity = new Opportunity(
                Name            = acctdata.get(loop1.Account__c).Name.replace(' ','-') + '-' + Datetime.now().format('yyyy-MM-dd'),
                StageName       = 'Prospecting',
                CloseDate       = system.today(),
                AccountId       = loop1.Account__c,
                RecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Inside Sales').RecordTypeId,
                Account_Type__c = 'Short');
            insert theOpportunity;
            loop1.Opportunity__c = theOpportunity.id;
        }
        waitlistitemTriggerHandler.skipbeforeupdaterun = true;
    }
    
    // Create Quote in CPQ
    @Future(callout=true)
    public static void CreateQuote(set<id> WLIids) {
        System.debug(' == > Logic 1 == ');
        string sfdcquoteid = '';
        list<case> insertcase = new list<case>();
        list<InventoryAvailability__C> deleteinvtavlbldata = new list<InventoryAvailability__C>(); 
        WebserviceCallBigMachineQuoteCls createquote = new WebserviceCallBigMachineQuoteCls();
        map<string,CreateWaitlist__c> gridMap = CreateWaitlist__c.getAll();
        map<string,CreateWaitlist__c> prdctmap = new map<string,CreateWaitlist__c>();
        for(CreateWaitlist__c cwlloop : gridMap.values()){
            prdctmap.put(cwlloop.Product_Code__c,cwlloop);
        }
        list<CreateWaitlistQuoteWrapper> quotedata = new list<CreateWaitlistQuoteWrapper>();
        list<Waitlist_Item__c> WLIdata = [select id, Term__c, Account__c,Account__r.ownerid,Account__r.owner.username,product__r.ProductCode,
                                          Opportunity__c,Waitlist__r.Submitted_Date__c ,
                                          Waitlist__r.Pre_Auth_Email__c,(select id,leadType__c,product_Size__c,
                                                                         Market_ID__c,Market_Stripped__c,Market_Key__c,
                                                                         Market_State_ID__c,product_Type__c,Quantity__c,PriceTier__c from InventoryAvailability__r) 
                                          from Waitlist_Item__c where id in :WLIids];
         System.debug(' == > WLIdata 1 == '+WLIdata.size());
        for(Waitlist_Item__c wliloop : WLIdata){
            list<InventoryAvailability__C> invtavlbldata =  wliloop.InventoryAvailability__r;
            //create a case for sales opp to create quote
            if(invtavlbldata.size() > 80){
                case tempcase           = new case();
                tempcase.Status         = 'New';
                tempcase.Origin         = 'Web';
                tempcase.Type           = 'Sales Support';
                tempcase.Area__c         = 'Create Quote';
                tempcase.Subject         = 'Create quote for pre-auth waitlist id:' + wliloop.id ;
                insertcase.add(tempcase);
            }else if(invtavlbldata.size() > 0){
                deleteinvtavlbldata.addAll(invtavlbldata);
                for(InventoryAvailability__C invtavlloop : invtavlbldata){
                    
                    System.debug('invtavlbldata===>>'+invtavlbldata);
                    
                    CreateWaitlistQuoteWrapper tempdata = new CreateWaitlistQuoteWrapper();
                    System.debug('tempdata===>>>>>>'+tempdata);
                    tempdata.uniqueRecordId     = invtavlloop.id;
                    tempdata.LeadType           = invtavlloop.leadType__c;
                    tempdata.ProductCode        = wliloop.product__r.ProductCode;
                    //tempdata.MarketID           = invtavlloop.Market_ID__c;
                    tempdata.MarketID           = invtavlloop.Market_Stripped__c;
                    tempdata.MarketKey          = invtavlloop.Market_Key__c;
                    tempdata.MarketStateID      = invtavlloop.Market_State_ID__c;
                    tempdata.productSize        = invtavlloop.product_Size__c;
                    tempdata.productType        = invtavlloop.product_Size__c;
                    //tempdata.productType        = invtavlloop.product_Type__c;
                    tempdata.Quantity           = invtavlloop.Quantity__c;
                    tempdata.Term              = wliloop.term__c != null ? integer.valueof(wliloop.term__c) : integer.valueof(prdctmap.get(wliloop.product__r.ProductCode).Default_Term__c); //CRM-1342
                    tempdata.Email              = wliloop.Waitlist__r.Pre_Auth_Email__c;
                    tempdata.priceTier          = integer.valueOf(invtavlloop.PriceTier__c);
                    tempdata.priceEffectiveDate = wliloop.Waitlist__r.Submitted_Date__c ;
                    quotedata.add(tempdata);
                }
                if(!Test.isRunningTest()){
                    sfdcquoteid = createquote.CreateWaitlistQuote(null,null,
                                                                  wliloop.Account__c,wliloop.opportunity__c,null,'New','Add',
                                                                  false,true,wliloop.id,
                                                                  wliloop.Account__r.owner.username,wliloop.Account__r.ownerid,quotedata);
                    wliloop.Quote__c = sfdcquoteid;
                    wliloop.Inventory_Available__c = false;
                    quotedata.clear();
                }
                else{
                    sfdcquoteid =  '1234567890';
                }
            }
        }
        System.debug('WLIdata===>>>'+WLIdata);
        update WLIdata;
        delete deleteinvtavlbldata; 
        insert insertcase;
        waitlistitemTriggerHandler.skipafterupdaterun = true;
    }
    //Relate Quote to Waitlist
    public static void RelateQuoteToWaitlist(map<id,id> QuoteWLIMap) {
        // CRM-455 Optimized below code
        /*List<BigMachines__Quote__c > QpLIst = New List<BigMachines__Quote__c >();
        
        FOR(Id Idloop : QuoteWLIMap.keySet()){
            BigMachines__Quote__c  TempQuote = New BigMachines__Quote__c();
            TempQuote.id = QuoteWLIMap.get(Idloop);
            TempQuote.Waitlist_Item__c = Idloop;
            QpLIst.add(TempQuote);
        }
        
        IF(!QpLIst.isEmpty()){
            Update QpLIst;
        }
        */
        
        List<BigMachines__Quote__c > quotesToUpdate  = New List<BigMachines__Quote__c >();
        for (BigMachines__Quote__c quote : [SELECT id, Waitlist_Item__c FROM BigMachines__Quote__c WHERE Id in :QuoteWLIMap.values()]) {
            for (Id waitListItemId : QuoteWLIMap.keySet()) {
                if (quote.Id == QuoteWLIMap.get(waitListItemId) && quote.Waitlist_Item__c != waitListItemId) {
                    quote.Waitlist_Item__c = waitListItemId;
                    quotesToUpdate.add(quote);
                    break;
                }   
            
            }
        }
        if (!quotesToUpdate.isEmpty()){
            update quotesToUpdate;
        }
        
        
    }
}