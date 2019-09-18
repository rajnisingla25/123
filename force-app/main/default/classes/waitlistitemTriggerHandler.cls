public class waitlistitemTriggerHandler {
    Public static boolean skipbeforeupdaterun = false;
    Public static boolean skipafterupdaterun = false;
    
    // Before Update Method of Trigger
    public void onBeforeUpdate(Map < Id, Waitlist_Item__c > newitems, Map < Id, Waitlist_Item__c > olditems) {
        System.debug('==>>waitlistitemTriggerHandler :: Before Update');
        WaitlistItemtriggerHandlerManager Manager = new WaitlistItemtriggerHandlerManager();
        list < Waitlist_Item__c > giverank = new list < Waitlist_Item__c > ();
        list < Waitlist_Item__c > wlifulfil = new list < Waitlist_Item__c > ();
        list < Waitlist_Item__c > Rerank = new list < Waitlist_Item__c > ();
        list < Waitlist_Item__c > WLItoporcess = new list < Waitlist_Item__c > ();
        
        for (Waitlist_Item__c wliloop: newitems.values()) {
            
            if (wliloop.Wailist_Type__c == 'Pre-Auth' && wliloop.Status__c == 'Active' && (olditems.get(wliloop.id).Status__c == 'Pending Pre-Auth Approval' || olditems.get(wliloop.id).Status__c == 'Renewed')) {
                system.debug('Going here ===>>');
                
                giverank.add(wliloop);
            }
        }
        
        for (Waitlist_Item__c wliffloop: newitems.values()) {
            if (wliffloop.Wailist_Type__c == 'Pre-Auth' && wliffloop.Status__c == 'Fulfilled' && olditems.get(wliffloop.id).Status__c == 'Active') {
                system.debug('Going here ===>> 222');
                
                wlifulfil.add(wliffloop);
            }
        }
        Manager.giverank(giverank, wlifulfil);
        
        
        //Insert opportunity when Inventory_Available__c is set to true from Inventory
        for (Waitlist_Item__c wliloop: newitems.values()) {
            if(wliloop.Inventory_Available__c == true && olditems.get(wliloop.id).Inventory_Available__c == false){
                WLItoporcess.add(wliloop);
            }
        }
        //inserts opportunity and uses it for create and syncing quote
        if(WLItoporcess.size() > 0){
            WaitlistItemtriggerHandlerManager.InsertOpportunity(WLItoporcess);
        }
        
    }
    // After Update Method of Trigger
    public void onAfterUpdate(Map < Id, Waitlist_Item__c > newitems, Map < Id, Waitlist_Item__c > olditems) {
        System.debug('==>>waitlistitemTriggerHandler :: After Update');
        WaitlistItemtriggerHandlerManager Manager = new WaitlistItemtriggerHandlerManager();
        list < Waitlist_Item__c > Rerank = new list < Waitlist_Item__c > ();
        map<id,id> QuoteWLIMap = New map<id,id>();
        set <id> WLIids = new set<id>();
        for (Waitlist_Item__c wliloop: newitems.values()) {
           
            //Rerank when waitlist is fulfilled and Cancelled
            if (wliloop.Wailist_Type__c == 'Pre-Auth' && (wliloop.Status__c == 'Fulfilled' || wliloop.Status__c == 'Canceled' || wliloop.Status__c == 'Account Spend Max Reached')
                && olditems.get(wliloop.id).Status__c == 'Active' && olditems.get(wliloop.id).Rank__c != 0) {
                    Rerank.add(wliloop);
                }
            //Rerank when waitlist is Expired
            if (wliloop.Wailist_Type__c == 'Pre-Auth' && wliloop.Status__c == 'Expired' && !wliloop.has_Renewal__c && olditems.get(wliloop.id).Rank__c != 0 && wliloop.Rank__c != 0) { //CRM-1587
                Rerank.add(wliloop);
            }
            //createquote when Inventory_Available__c is set to true from Inventory
            if(wliloop.Inventory_Available__c == true && olditems.get(wliloop.id).Inventory_Available__c == false ){
                WLIids.add(wliloop.id);
            }
            If(wliloop.Quote__c != null){
                QuoteWLIMap.put(wliloop.id,wliloop.Quote__c);
            }
        }
        // CRM-2816 - Added extra if condition on DocuSignStatustriggerHandler.runRerank to avoid rerank on amend
        if(Rerank.size() > 0 && DocuSignStatustriggerHandler.runRerank){
            Manager.Rerank(Rerank, oldItems); //CRM-1452
            System.debug('Rerank======>>>'+Rerank);
        }
        if(WLIids.size() > 0){
            WaitlistItemtriggerHandlerManager.CreateQuote(WLIids);
        }
        IF(!QuoteWLIMap.isEmpty()){
            WaitlistItemtriggerHandlerManager.RelateQuoteToWaitlist(QuoteWLIMap);
        }
        
   
        
    }
    
    
    
    public void onBeforeUpdateOnDocuSignAmend(Waitlist_Item__c wlListSingleRecordNew ,Waitlist_Item__c wlListSingleRecordOld) {
        If(wlListSingleRecordNew.Status__c =='Active'){ //CRM-1547 && wlListSingleRecordNew.Waitlist__r.Pre_Auth_Type__c =='--None--'){ 
            if( (wlListSingleRecordOld.Lead_Routing__c  != wlListSingleRecordNew.Lead_Routing__c  
                 || wlListSingleRecordOld.Product_Size__c   != wlListSingleRecordNew.Product_Size__c    
                 || wlListSingleRecordOld.Original_Max_Spend__c   != wlListSingleRecordNew.Original_Max_Spend__c 
                 || wlListSingleRecordOld.term__c != wlListSingleRecordNew.term__c)){ //CRM-1547
                     wlListSingleRecordNew.Amendment_Status__c='Pending Pre-Auth Approval';
                     //update wlListSingleRecordNew;                       
                 }
        }
    }   
    public void waitListItemStatusToAccMaxSpend(List<Waitlist_Item__c> newitem){
        Set<Id> uniquerAcces = new Set<Id>();
        Set<ID> uniquerMaps = new Set<ID>();
        
        for(Waitlist_Item__c wl : newitem){
            if(wl.Status__c=='Fulfilled'){
                uniquerMaps.add(wl.Waitlist__c);
                uniquerAcces.add(wl.Account__c);
            }    
        }
        for(ID ids : uniquerMaps){
            AggregateResult aggrs = [Select Sum(Current_Utilized_Spend__c) total 
                                     from Waitlist_Item__c
                                     where  Waitlist__c=:ids AND Status__c='Fulfilled'] ; 
            Double total = (Double)aggrs.get('total');
            Waitlist__c wlist = [Select Status__c ,Id ,Total_MAX_Monthly_Pre_Auth_Spend__c from  Waitlist__c where id=:ids] ;
            if(total>=wlist.Total_MAX_Monthly_Pre_Auth_Spend__c){
                wlist.Status__c='Account Spend Max Reached';
                update wlist;
                
                List<Waitlist_Item__c> wlItemsupdate =   [Select Id, Status__c 
                                                          from Waitlist_Item__c 
                                                          where  Waitlist__c=:ids  AND (Status__c='Pending Pre-Auth' OR Status__c='Active' )];
                for(Waitlist_Item__c wl : wlItemsupdate){
                    wl.Status__c='Account Spend Max Reached';
                }
                update wlItemsupdate ;   
            }
            
        }
        List<Account> accForUpdate = new List<Account>();
        
        for(Id iAcc :uniquerAcces ){
            
            AggregateResult aggrs = [Select Sum(Current_Utilized_Spend__c) total  from Waitlist_Item__c   
                                     where Status__c='Fulfilled' AND Account__c=:iAcc AND Wailist_Type__c ='Pre-Auth'];
            Double total = (Double)aggrs.get('total');
            
            Account accToUpdae = [Select Id ,Current_Monthly_Pre_Auth_Spend__c from Account where Id=:iAcc];
            If(accToUpdae.Current_Monthly_Pre_Auth_Spend__c==null){
                accToUpdae.Current_Monthly_Pre_Auth_Spend__c= 0 ;
            }
            accToUpdae.Current_Monthly_Pre_Auth_Spend__c = 0;
            
            accToUpdae.Current_Monthly_Pre_Auth_Spend__c= total;
            accForUpdate.add(accToUpdae); 
            
            
        }
        
        update accForUpdate ;
        
        
        
    }
    
    
    
    public void onAfterUpdateOnDocuSignAmend(Waitlist_Item__c wiRec , Waitlist_Item__c wirecold) {
        System.debug('=== wiRecwiRecwiRecwiRec'+wiRec);
        System.debug('=== wirecoldwirecoldwirecold'+wirecold);
        
        if(wirecold.Amendment_Status__c!='Pending Pre-Auth Approval' && wiRec.Amendment_Status__c=='Pending Pre-Auth Approval'){
            String accId =wiRec.Account__c ;
            Waitlist__c waitListList = [select Id,Status__c 
                                        from Waitlist__c where Id=:wiRec.Waitlist__c];
            waitListList.Status__c='Pending Pre-Auth Approval';
            update waitListList ;
            list<Waitlist_Item__c> WLIData =[select Status__c 
                                             from Waitlist_Item__c where   Waitlist__c =: wiRec.Waitlist__c and Status__c ='Active'] ;
            list<Waitlist_Item__c> updateWLDataTemp = new  list<Waitlist_Item__c> ();
            for(Waitlist_Item__c wli : WLIData){
                wli.Status__c='Pending Pre-Auth Approval';
                updateWLDataTemp.add(wli);
            }
            System.debug('updateWLDataTemp==>'+updateWLDataTemp.size());
            update updateWLDataTemp ;
            if(!Test.isRunningTest()){
            SendDocusign.SendNow(wiRec.Waitlist__c);
            }
        }  
        if(wiRec.Status__c=='Fulfilled' ||wiRec.Status__c=='Expired'  || wiRec.Status__c=='Canceled'  ){
            // CRM-2678 Commented below code, no need to fire SOQL twice, written new logic to update WaitList Status in optimized way.
            /*
            Waitlist__c waitListList = [select Id,Status__c ,(select Id ,Status__c
                                                              from Waitlist_Items__r )
                                        from Waitlist__c where Id=:wiRec.Waitlist__c];
            list<Waitlist_Item__c> WLIData =[select Status__c 
                                             from Waitlist_Item__c where   Waitlist__c =: wiRec.Waitlist__c and Status__c =:wiRec.Status__c] ;
            
            
            If(waitListList.Waitlist_Items__r.size() == WLIData.size()){
                waitListList.Status__c = wiRec.Status__c ;
                update waitListList;
            }
            */
            
            // CRM-2678 New logic to update WaitList status
            Set<String> status = new Set<String>();
            if (wiRec.Status__c == 'Fulfilled') {
                status.add(wiRec.Status__c);
            }
            else if (wiRec.Status__c=='Expired' || wiRec.Status__c=='Canceled') {
                status.add('Expired');
                status.add('Canceled');
            }
            boolean allWIStatusSame = true;
            for (Waitlist_Item__c waitListItem : [SELECT Status__c, Waitlist__r.Status__c FROM Waitlist_Item__c WHERE Waitlist__c =:wiRec.Waitlist__c]) {
                // CRM-4775 - Added check on Waitlist__r.Status__c to avoid updating waitlist status when it is already Abandoned
                if (waitListItem.Waitlist__r.Status__c == 'Abandoned' || !status.contains(waitListItem.Status__c)) {
                    allWIStatusSame = false;
                    break;
                }
            }
            if (allWIStatusSame) {
                Waitlist__c waitList = new Waitlist__c(Id = wiRec.Waitlist__c, Status__c = wiRec.Status__c);
                update waitList;
            }
            // CRM-2678 End
        }            
        
    }   
    
    
}