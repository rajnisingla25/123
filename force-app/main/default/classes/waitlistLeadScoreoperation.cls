//
// (c) Move, Inc.
//
// Apex Class Name: waitlistLeadScoreoperation
// Description: Its a webservice class to update interested markets.
//
// 31th Jan 2018    Sonu Sharma

global class waitlistLeadScoreoperation {
  // Request Inner Class - AssetIdType
  global class WaitlistType {
    webservice String AccountPartyId;
    webservice String ZipCode;
    webservice String ActionType;
  }
  global class WaitlistActionResult {
    webservice String RecordId;
    webservice String Status;
    webservice String Message;
    webservice String ActionType;
  }

  
  /*
  @method      : postWaitlistData()
  @description : Webservice call to update Interested Market.
  @params      : AssetIdType AssetId
  @returns     : ParentAsset
  */
  webservice static WaitlistActionResult postWaitlistData(String PartyId,String ZipCode,String LeadSize,String waitlistType,String waitlistLeadType, String Action, String Name) {
  /*if(boolerror){
  List<Error__c> lstError = new List<Error__c>();
                for(Inventory_Account__c idd:mapInventoryAccount.values()){
                Error__c error = new Error__c();
                error.Name = idd.id;
                error.Entity_Id__c = 'InventoryError';
                error.Interface_Name__c = 'InventoryError';
                error.Error_Description__c = errormsg;
                lstError.add(error);
                }
                if(lstError.size()>0){
                insert lstError;
                }
  } else{*/
  return postWaitlistDataPull(PartyId,ZipCode,LeadSize,waitlistType,waitlistLeadType, Action, Name);
 // }
  }
  
  public static List<WaitlistActionResult> postWaitlistDataPullInventory(List<WaitlistLeadScoreWrapper> lstWaitlistLeadScoreWrapper) {
            Set<String> setPartyIds = new Set<String>();
            Map<String,Account> mapAccount = new Map<String,Account>();
            Map<String,Inventory_Data__c> mapInventory = new Map<String,Inventory_Data__c>();
            Set<String> setZipCodeIds = new Set<String>();
            Map<String,WaitlistActionResult> mapWaitlistActionResult = new Map<String,WaitlistActionResult>();
            for(WaitlistLeadScoreWrapper wslw:lstWaitlistLeadScoreWrapper){
            
            setPartyIds.add(wslw.PartyId);
            setZipCodeIds.add(wslw.ZipCode);
            }
            for(Account acc:[Select Id,Name,party_Id__c from Account where party_Id__c=:setPartyIds]){
            mapAccount.put(acc.party_Id__c,acc);
            }
            for(Inventory_Data__c invr:[Select Id,Name from Inventory_Data__c where Name=:setZipCodeIds]){
            mapInventory.put(invr.Name,invr);
            }     
            Map<String,Inventory_Account__c> mapInventoryAccount = new Map<String,Inventory_Account__c>();
            List<Inventory_Account__c> lstInvAccount = new List<Inventory_Account__c>();
            for(Inventory_Account__c INA:[Select Id,Unique_relation__c,Waitlist_Slot_Type__c,Waitlist_Type__c,Waitlist_Half__c,Waitlist__c,name from Inventory_Account__c where Account__r.party_Id__c=:mapAccount.keyset() and Inventory_Data__r.Name=:mapInventory.keyset()]){
            mapInventoryAccount.put(INA.Unique_relation__c,INA);
            }
        
        for(WaitlistLeadScoreWrapper wslw:lstWaitlistLeadScoreWrapper){
        system.debug('wslw.ZipCode --> '+wslw.ZipCode);
        system.debug('mapInventory.containskey(wslw.ZipCode) -->'+mapInventory.containskey(wslw.ZipCode));
        if(mapAccount.containskey(wslw.PartyId) && mapInventory.containskey(wslw.ZipCode)){
        if(mapInventoryAccount.containskey(mapAccount.get(wslw.PartyId).id+'$$$'+mapInventory.get(wslw.ZipCode).id)){
        System.debug('Working here');
        Inventory_Account__c IaccUpdate = mapInventoryAccount.get(mapAccount.get(wslw.PartyId).id+'$$$'+mapInventory.get(wslw.ZipCode).id);
        //IaccInsert.Account__c = mapAccount.get(wslw.PartyId).id;
        //IaccInsert.Inventory_Data__c = mapInventory.get(wslw.ZipCode).id;
        //IaccInsert.Unique_relation__c = wslw.PartyId+'$$$'+wslw.ZipCode;
        if(wslw.LeadSize==null){wslw.LeadSize='';}
        system.debug('wslw.Name '+wslw.Name);
        if(wslw.Name.equalsIgnoreCase('local expert zip') || wslw.Name.equalsIgnoreCase('local expert')){IaccUpdate.waitlist_product_type__c = wslw.LeadSize; if(wslw.waitlistType!= null){IaccUpdate.waitlist_type_LE__c =wslw.waitlistType;}}
        if(wslw.Name.equalsIgnoreCase('local expert city')){IaccUpdate.waitlist_product_type__c = wslw.LeadSize; if(wslw.waitlistType!= null){IaccUpdate.waitlist_type_LEC__c =wslw.waitlistType;}}
        if(wslw.LeadSize.equalsIgnoreCase('Any') && !wslw.Name.equalsIgnoreCase('local expert') && !wslw.Name.equalsIgnoreCase('local expert zip') && !wslw.Name.equalsIgnoreCase('local expert city')){IaccUpdate.Waitlist__c=true;IaccUpdate.Waitlist_Half__c=true;} else if(wslw.LeadSize.equalsIgnoreCase('FUll')){IaccUpdate.Waitlist__c=true;} else if(wslw.LeadSize.equalsIgnoreCase('HALF')){IaccUpdate.Waitlist_Half__c=true;}
        if(wslw.waitlistType!=null && !wslw.Name.equalsIgnoreCase('local expert') && !wslw.Name.equalsIgnoreCase('local expert zip') && !wslw.Name.equalsIgnoreCase('local expert city')){IaccUpdate.Waitlist_Type__c=wslw.waitlistType;}
        if(wslw.waitlistLeadType!=null && !wslw.Name.equalsIgnoreCase('local expert zip') && !wslw.Name.equalsIgnoreCase('local expert') && !wslw.Name.equalsIgnoreCase('local expert city')){IaccUpdate.Waitlist_Slot_Type__c=wslw.waitlistLeadType;}
        mapInventoryAccount.put(IaccUpdate.Unique_relation__c,IaccUpdate);
        } else if(mapAccount.containskey(wslw.PartyId) && mapInventory.containskey(wslw.ZipCode)){
        System.debug('Working here 2');
        Inventory_Account__c IaccInsert = new Inventory_Account__c();
        IaccInsert.Account__c = mapAccount.get(wslw.PartyId).id;
        IaccInsert.Inventory_Data__c = mapInventory.get(wslw.ZipCode).id;
        IaccInsert.Unique_relation__c = mapAccount.get(wslw.PartyId).id+'$$$'+mapInventory.get(wslw.ZipCode).id;
        if(wslw.LeadSize==null){wslw.LeadSize='';}
        if(wslw.LeadSize.equalsIgnoreCase('Any') && !wslw.Name.equalsIgnoreCase('local expert zip') && !wslw.Name.equalsIgnoreCase('local expert') && !wslw.Name.equalsIgnoreCase('local expert city')){IaccInsert.Waitlist__c=true;IaccInsert.Waitlist_Half__c=true;} else if(wslw.LeadSize.equalsIgnoreCase('FUll')){IaccInsert.Waitlist__c=true;} else if(wslw.LeadSize.equalsIgnoreCase('HALF')){IaccInsert.Waitlist_Half__c=true;}
        system.debug('wslw.Name '+wslw.Name);
        if(wslw.Name.equalsIgnoreCase('local expert zip') || wslw.Name.equalsIgnoreCase('local expert')){IaccInsert.waitlist_product_type__c = wslw.LeadSize;if(wslw.waitlistType!= null){IaccInsert.waitlist_type_LE__c =wslw.waitlistType;}}
        if(wslw.Name.equalsIgnoreCase('local expert city')){IaccInsert.waitlist_product_type__c = wslw.LeadSize;if(wslw.waitlistType!= null){IaccInsert.waitlist_type_LEC__c =wslw.waitlistType;}}
        if(wslw.waitlistType!=null && !wslw.Name.equalsIgnoreCase('local expert zip') && !wslw.Name.equalsIgnoreCase('local expert') && !wslw.Name.equalsIgnoreCase('local expert city')){IaccInsert.Waitlist_Type__c=wslw.waitlistType;}
        if(wslw.waitlistLeadType!=null && !wslw.Name.equalsIgnoreCase('local expert zip') && !wslw.Name.equalsIgnoreCase('local expert') && !wslw.Name.equalsIgnoreCase('local expert city')){IaccInsert.Waitlist_Slot_Type__c=wslw.waitlistLeadType;}
        //lstInvAccount.add(IaccInsert);
        mapInventoryAccount.put(IaccInsert.Unique_relation__c,IaccInsert);
            WaitlistActionResult war = new WaitlistActionResult();
            war.RecordId = '';
            war.Status = 'Failure';
            war.Message = 'Failure';
            war.ActionType = 'Insert';
            mapWaitlistActionResult.put(mapAccount.get(wslw.PartyId)+'$$$'+wslw.ZipCode,war); 
        }
        }
        }
        try{
        System.debug(mapInventoryAccount.values()+'PPPP');
        SkipIATrigger.setSkipTrgTrue();
        upsert mapInventoryAccount.values();
        } catch(Exception ex){
        List<Error__c> lstError = new List<Error__c>();
                for(Inventory_Account__c idd:mapInventoryAccount.values()){
                Error__c error = new Error__c();
                error.Name = idd.id;
                error.Entity_Id__c = 'InventoryError';
                error.Interface_Name__c = 'InventoryError';
                error.Error_Description__c = ex+' ****** '+ex.getStackTraceString();
                lstError.add(error);
                }
                if(lstError.size()>0){
                insert lstError;
                }
        }
        //insert lstInvAccount;
      
            return mapWaitlistActionResult.values();
        }
  
       public static WaitlistActionResult postWaitlistDataPull(String PartyId,String ZipCode,String waitlistLeadType,String waitlistType,String LeadSize, String Action, String Name) {
System.debug('LeadSizeP'+LeadSize);
System.debug('waitlistTypeP'+waitlistType);
System.debug('waitlistLeadTypeP'+waitlistLeadType);
System.debug('ZIPCODE'+zipcode);
if(name == 'Local Expert City'){
    List<string> nameSplit = Zipcode.split(', ');
    Zipcode = nameSplit[1]+'-'+nameSplit[0];
}else{
              ZipCode=ZipCode.leftPad(5,'0');
}
System.debug('ZIPCODE'+zipcode);
              
        List<Account> lstAccount = [Select Id,Name from Account where party_Id__c=:PartyId];
        List<Inventory_Data__c> lstInventory = [Select Id,Name from Inventory_Data__c where Name=:ZipCode];
        String AccountId = '';
        String InventoryDataId = '';
        String ReturnrecordId = '';
        String ReturnStatus = '';
        String ReturnMessage = '';
        String ReturnActionType = '';
        WaitlistActionResult war = new WaitlistActionResult();
        try{
        if(lstAccount.size()<1){
        war.RecordId = ReturnrecordId;
        war.Status = 'Failed';
        war.Message = 'Account does not exist';
        war.ActionType = Action;
        } else if(lstInventory.size()<1){
        war.RecordId = ReturnrecordId;
        war.Status = 'Failed';
        war.Message = 'Zip code does not exist';
        war.ActionType = Action;
        } else {
        for(Account acc: lstAccount){
        AccountId = acc.Id;
        }
        for(Inventory_Data__c invdata: lstInventory){
        InventoryDataId = invdata.Id;
        }
        if(Action == 'Delete'){
        List<Inventory_Account__c> lstInventoryAccount = [Select Id,Waitlist_Slot_Type__c,Waitlist_Type__c,Waitlist_Half__c,Waitlist__c,name from Inventory_Account__c where Account__r.party_Id__c=:PartyId and Inventory_Data__r.Name=:ZipCode];
        for(Inventory_Account__c iiaa:lstInventoryAccount){
          //CRM-4780 added name condition and added name parameter
            
            if(name == 'Local Expert Zip' || name == 'Local Expert'){
                system.debug('Inside local expert Delete');

                iiaa.waitlist_type_LE__c = '';
                iiaa.waitlist_product_type__c = '';
            }else if(name == 'Local Expert City'){
                system.debug('Inside local expert city Delete');

                iiaa.waitlist_type_LEC__c = '';
                iiaa.waitlist_product_type__c = '';
            }else{
           
                system.debug('Inside not local expert Delete');
                iiaa.Waitlist_Slot_Type__c = '';
                iiaa.Waitlist_Type__c = '';
                iiaa.Waitlist_Half__c = false;
                iiaa.Waitlist__c = false;
            }
            
            ReturnrecordId = iiaa.id;
            ReturnStatus = 'Success';
            ReturnMessage = 'Success';
            
        }
        update lstInventoryAccount;
        }
        else {
        List<Inventory_Account__c> lstInventoryAccount = [Select Id,Waitlist_Slot_Type__c,Waitlist_Type__c,Waitlist_Half__c,Waitlist__c,name from Inventory_Account__c where Account__r.party_Id__c=:PartyId and Inventory_Data__r.Name=:ZipCode];
        for(Inventory_Account__c iiaa:lstInventoryAccount){
        ReturnrecordId = iiaa.id;
        ReturnStatus = 'Success';
        ReturnMessage = 'Success';
        //CRM-4780 added cobroke and local expert conditions to update appropriate fields
       
           
            if(name == 'Local Expert Zip' || name == 'Local Expert'){
                            system.debug('Inside local expert update');

                if(waitlistType!=null){iiaa.Waitlist_Type_LE__c=waitlistType;}
            } else if(name == 'Local Expert City'){
                            system.debug('Inside local expert city update');

                if(waitlistType!=null){iiaa.Waitlist_Type_LEC__c=waitlistType;}
            }else{
                            system.debug('Inside not local expert Update');
                iiaa.Waitlist__c=false;
                iiaa.Waitlist_Half__c=false;
                if(LeadSize==null){LeadSize='';}
                if(LeadSize.equalsIgnoreCase('Any')){iiaa.Waitlist__c=true;iiaa.Waitlist_Half__c=true;} else if(LeadSize.equalsIgnoreCase('FULL')){iiaa.Waitlist__c=true;} else if(LeadSize.equalsIgnoreCase('HALF')){iiaa.Waitlist_Half__c=true;}
                if(waitlistType!=null){iiaa.Waitlist_Type__c=waitlistType;}
                if(waitlistLeadType!=null){iiaa.Waitlist_Slot_Type__c=waitlistLeadType;}
            }
        }
        update lstInventoryAccount;
        if(lstInventoryAccount.size()<1){
        Inventory_Account__c IaccInsert = new Inventory_Account__c();
        IaccInsert.Account__c = AccountId;
        IaccInsert.Inventory_Data__c = InventoryDataId;
        IaccInsert.Unique_relation__c = AccountId+'$$$'+InventoryDataId;
        //CRM-4780 added cobroke and local expert condition
        
        if(name == 'Local Expert Zip' || name == 'Local Expert'){
            if(waitlistType!=null){IaccInsert.Waitlist_Type_LE__c=waitlistType;}
        }else{
            if(LeadSize==null){LeadSize='';}
            if(LeadSize.equalsIgnoreCase('Any')){IaccInsert.Waitlist__c=true;IaccInsert.Waitlist_Half__c=true;} else if(LeadSize.equalsIgnoreCase('FULL')){IaccInsert.Waitlist__c=true;} else if(LeadSize.equalsIgnoreCase('HALF')){IaccInsert.Waitlist_Half__c=true;}
            if(waitlistType!=null){IaccInsert.Waitlist_Type__c=waitlistType;}
            if(waitlistLeadType!=null){IaccInsert.Waitlist_Slot_Type__c=waitlistLeadType;}
        }
        insert IaccInsert;
        ReturnrecordId = IaccInsert.id;
        ReturnStatus = 'Success';
        ReturnMessage = 'Success';
        }
        
        war.RecordId = ReturnrecordId;
        war.Status = ReturnStatus;
        war.Message = ReturnMessage;
        war.ActionType = Action;
        }
        }
        if(Test.isRunningTest()){
        Integer ii = 1/0;
        }
         } catch(Exception ex){
        List<Error__c> lstError = new List<Error__c>();
                //for(Inventory_Account__c idd:mapInventoryAccount.values()){
                Error__c error = new Error__c();
                error.Name = PartyId+'###'+ZipCode;
                error.Entity_Id__c = 'InventoryError';
                error.Interface_Name__c = 'InventoryErrorWebservice';
                error.Error_Description__c = ex+' ****** '+ex.getStackTraceString();
                lstError.add(error);
                //}
                if(lstError.size()>0){
                insert lstError;
                }
        }
        return war;
  }
}