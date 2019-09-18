global class AssetCreateControlPanel_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    public string xmlStr = '';
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Name,BOP_Code__c,External_ID__c,AccountID,Account.Name,Account.Party_ID__c,Account.Type,Account.Customer_Id__c,Product2.Name,Product2.ProductCode FROM Asset WHERE Asset_Type__c = \'Parent\' AND  Fulfillment_Status__c = \'Fulfilled\' AND Get_CP_Login_Status__c = \'Ready\' ';                
        return Database.getQueryLocator(query);       
        
    }
   
    global void execute(Database.BatchableContext BC, List<Asset> scope)
    {
        map<ID,Asset> assetParentMap = new map<Id,Asset>();
        map<Id,list<Asset>> assetChildmap = new map<ID,list<Asset>>();
        
        for(Asset assetParent : scope){
            assetParentMap.put(assetParent.Id,assetParent);
        }
        
        map<ID,Asset> oassetChildMap = new map<Id,Asset>([select Product2.ProductCode,External_ID__c,Account.Party_ID__c,Asset_Type__c ,Parent_Asset__c,Id,Line_Type__c,Name,BOP_Code__c,AccountID,Account.Name,Account.Type,Account.Customer_Id__c,Product2.Name FROM Asset WHERE Parent_Asset__c  IN: assetParentMap.keyset() AND Asset_Type__c =: 'Fulfill To' AND (Line_Type__c =: 'Add'OR Line_Type__c =:'Renew')]);                   
        for(Asset oAssetC : oassetChildMap.values()){
            
                if(!assetChildmap.containsKey(oAssetC.Parent_Asset__c)){
                    assetChildmap.put(oAssetC.Parent_Asset__c,new list<Asset>()); 
                    assetChildmap.get(oAssetC.Parent_Asset__c).add(oAssetC);                                    
                }
                else{
                   assetChildmap.get(oAssetC.Parent_Asset__c).add(oAssetC);                
                }
        }
       CPxmlnsOracleCom.GetControlPanelInfoSFDC_pt   stub = new CPxmlnsOracleCom.GetControlPanelInfoSFDC_pt();
       list<CPMovecom.CPLoginInfo> Cplist = new list<CPMovecom.CPLoginInfo>();
      
      for(Asset oAssetP : assetParentMap.values()){           
            
            // add parent details
           CPMovecom.CPLoginInfo cpmove = new CPMovecom.CPLoginInfo();
            cpmove.CustID            = oAssetp.Account.Customer_Id__c!= null ? Integer.Valueof(oAssetp.Account.Customer_Id__c) : 0; 
            cpmove.SFDCAccountID     = String.valueOf(oAssetP.AccountID);            
            cpmove.AccountType       = String.valueOf(strconversion(oAssetP.Account.Type));      
            cpmove.BOPCode           = oAssetP.BOP_Code__c != null ? Integer.Valueof(oAssetP.BOP_Code__c) : 0;  
            cpmove.ParentAssetId     = String.valueOf(oAssetP.ID);
            cpmove.ProductPartNumber = String.valueOf(oAssetp.Product2.ProductCode);  
            cpmove.CDHOrgPartyId     = oAssetP.Account.Party_ID__c != null ? Integer.Valueof(oAssetP.Account.Party_ID__c) : 0;                      
            cpmove.System_x          = 'SFDC';
            cpmove.ParentExternalId  = String.valueOf(oAssetP.External_ID__c);                                     
                                                  
           
                CPMovecom.ListOfFulFillTo_element ListOfFulFillTo = new  CPMovecom.ListOfFulFillTo_element (); 
                                 
                    if(assetChildmap.containsKey(oAssetP.ID)){
                                   
                      list<CPMovecom.FulFillTo_element> FulFillTo = new list<CPMovecom.FulFillTo_element>();                  
                        for(Asset oAssetc : assetChildmap.get(oAssetP.ID)){
                             // add child details
                            CPMovecom.FulFillTo_element   oFulFillTo = new CPMovecom.FulFillTo_element();
                            oFulFillTo.CustID            =  oAssetc.Account.Customer_Id__c!= null ? Integer.Valueof(oAssetc.Account.Customer_Id__c) : 0;//Integer.Valueof(oAssetc.Account.Customer_Id__c);
                            oFulFillTo.SFDCAccountID     =  String.valueOf(oAssetc.AccountID);                        
                            oFulFillTo.AccountType       =  String.valueOf(strconversion(oAssetc.Account.Type));                      
                            oFulFillTo.AssetId           =  oAssetc.ID != null ? String.Valueof(oAssetc.ID) : '';                                               
                            oFulFillTo.ProductPartNumber =  String.valueOf(oAssetc.Product2.ProductCode);                     
                            oFulFillTo.CDHOrgPartyId     =  oAssetc.Account.Party_ID__c != null ? Integer.Valueof(oAssetc.Account.Party_ID__c) : 0;
                            oFulFillTo.ExternalId            = String.valueOf(oAssetc.External_ID__c);
                            cpmove.System_x              = 'SFDC'; 
                            FulFillTo.add(oFulFillTo);                                                                                                                          
                        }
                        ListOfFulFillTo.FulFillTo = FulFillTo;
                    }
                cpmove.ListOfFulFillTo =  ListOfFulFillTo;
                Cplist.add(cpmove); 
                 
        }
        if(!Cplist.isEmpty()){
         if(!Test.isRunningTest()){
        xmlStr =   stub.process(Cplist)  ; 
          }
        system.debug('Message Recevied'+xmlstr);
        }

    }   
    global void finish(Database.BatchableContext BC)
    {
    }
    
    public string strconversion(string input)
    { 
        if(String.isEmpty(input))        
        return '';
        return input;
    }
        
}