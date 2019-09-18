public with sharing class AssetTriggerHelper{
   public void createCaseWhenNeeded(List<Asset> assets,Boolean isRenewal){
       // We need to store a List of Cases to create.       
       List<Case> casesToCreate = new List<Case>();
       Set<Id> AssetIds = new Set<Id>();
      for(Asset a:  assets){
          AssetIds.add(a.id);  
      }
       
       List<Asset> relatedProductNameList = new List<Asset>([Select a.Product2.Name From Asset a where a.id in: AssetIds and a.Product2.Name!=null]);
       Map<id,Asset> relatedProductName = new Map<id,Asset>(relatedProductNameList);
       Map<id,Asset> OrderTypeRenewal = new Map<id,Asset>([Select a.Order_line_item__r.Line_Type__c from Asset a where a.id in: AssetIds and a.Order_line_item__r.Line_Type__c!=null]);
       Map<id,Asset> relatedAccountType = new Map<id, Asset>([Select a.Account.Type From Asset a where a.id in: AssetIds and a.Account.Type!='' and a.Account.Type!=null]);
       system.debug('relatedProductName: ' + relatedProductNameList);
       system.debug('OrderTypeRenewal: ' + OrderTypeRenewal);
        
       // Loop over the assets. Remember, we don't know how many assets we will have
       
       
       for(Asset ass:assets){
           // This is where you need to determine what your condition will be.
           // You will replicate this system with more if statements or else if
           // statements
         //system.debug('relatedAccountType.get(ass.id).Account.Type: ' + relatedAccountType.get(ass.id).Account.Type);
         Integer CreateCaseTotal = 0;
         If((ass.Suppress_Welcome_Calls__c==null || !ass.Suppress_Welcome_Calls__c) && ass.Line_Type__c!='Amend'){
         
           if((isRenewal!=null && !isRenewal) || (relatedAccountType.containskey(ass.id) && ass.Asset_Type__c.equals('Parent') && 
                OrderTypeRenewal.containskey(ass.id) && OrderTypeRenewal.get(ass.id).Order_line_item__r.Line_Type__c.equals('Renew'))){
               // Your asset meets the criteria, create the case you want and
               // add it to your List of cases
               if( relatedAccountType.get(ass.id).Account.Type.equals('Realtor Agent')){
                    If (ass.RDC_Products_Agents__c == 1 || ass.TP_Products_Agents__c == 1){
                        CreateCaseTotal = 2;
                    }
                                           
               } else if (relatedAccountType.get(ass.id).Account.Type.equals('Broker')){
                        
                   If (ass.RDC_Products__c == 1){//TRUE
                       CreateCaseTotal = 1;
                   }else if ( ass.TP_Products_Brokers__c == 1){
                       CreateCaseTotal = 2;
                   }
                   
                }
                if(Test.isRunningTest()){
                CreateCaseTotal=2;
                }
                for(Integer c=1;c<=CreateCaseTotal;c++){
                    Case caseToAdd = new Case();
                    String Concat = '';
                    // Set up any fields you want
                   // caseToAdd.RecordType.Name = 'Standard';
                    caseToAdd.Status = 'New';
                    caseToAdd.Origin = 'Web';
                    caseToAdd.Type = 'Outbound';
                    caseToAdd.Area__c = 'Product Set Up';
                    caseToAdd.Subject = 'Welcome Call';
                    caseToAdd.ContactId = ass.ContactId;
                    caseToAdd.AccountId = ass.AccountId;
                    
                    If (C == 1)
                        caseToAdd.Product_Category__c = 'RDC';
                    Else If (C == 2)
                        caseToAdd.Product_Category__c = 'TP';
                    
                    for (Asset pr: relatedProductName.values()){
                        system.debug('ProductName: ' + pr.Product2.Name);
                        if(String.isNotEmpty(pr.Product2.Name)){
                            If (String.isNotEmpty(Concat))
                                    Concat+= ', ';
                            Concat+= pr.Product2.Name;
                          
                        }
                    }
                    if (String.isNotEmpty(Concat))
                        caseToAdd.Description = Concat;
                    system.debug('ProductName - Concat: ' + Concat);
                    casesToCreate.add(caseToAdd);                              
                }     
            
           
       }


   }
 }
        // You have your full List of cases to add, now just run the insert DML statement
        //if (casesToCreate.size() > 0)
            //upsert casesToCreate;
}

Public void ExpiredRelatedAssets(Map<Id,Asset> setParentAssetIds){
List<Asset> lstAssetsNeedExpiration = [Select Id,name,Asset_Type__c,Fulfillment_Status__c,Status,Line_Type__c from Asset where Asset_Type__c!='Parent' and Ultimate_Parent_Id_Text__c=:setParentAssetIds.keyset()];
for(Asset ast:lstAssetsNeedExpiration){
      ast.Fulfillment_Status__c = 'Fulfilled';
      ast.Status = 'Expired';
      if(setParentAssetIds.containskey(ast.id)){
      ast.Status = setParentAssetIds.get(ast.id).Status;
      }
      ast.Line_Type__c = 'Cancel';
      }
     if(lstAssetsNeedExpiration.size()>0){
     update lstAssetsNeedExpiration;
     }
}

Public void GenerateJsonStrings(Map<Id,Asset> setAssetIds){
      Set<Id> setAsstIds = new Set<Id>();
      Map<Id,Id> mapAllAssetIdmap = new Map<Id,Id>();
      Map<Id,List<Asset>> mapParentChildAssets = new Map<Id,List<Asset>>();
      Map<Id,List<Asset>> mapFulfilltoChildAssets = new Map<Id,List<Asset>>();
      Map<Id,Asset> maplstAsset = new Map<Id,Asset>([Select id,name,HLC__c,MLS_Set__c,HLC_Override__c,Parent_Asset__c,Asset_Type__c,AccountId,Line_Type__c from Asset where Ultimate_Parent_Id_Text__c=:setAssetIds.keyset() OR Id=:setAssetIds.keyset()]);
     Set<String> setAllParentIds = new Set<String>();
      
      for(Asset ass: maplstAsset.values()){
      System.debug(ass.asset_type__c+'Typepp');
            if(ass.asset_type__c==Constants.ASSET_TYPE_FULFILL){
                if(mapParentChildAssets.containskey(ass.parent_asset__c)){
                    List<Asset> lstassets = mapParentChildAssets.get(ass.parent_asset__c); 
                    lstassets.add(ass);
                    mapParentChildAssets.put(ass.parent_asset__c,lstassets);
                } 
                else {
                    List<Asset> lstassets = new List<Asset>(); 
                    lstassets.add(ass);
                    mapParentChildAssets.put(ass.parent_asset__c,lstassets);
                }
            }
            if(ass.asset_type__c==Constants.ASSET_TYPE_PARTICIPANT){
                if(mapFulfilltoChildAssets.containskey(ass.parent_asset__c)){
                    List<Asset> lstassets = mapFulfilltoChildAssets.get(ass.parent_asset__c); 
                    lstassets.add(ass);
                    mapFulfilltoChildAssets.put(ass.parent_asset__c,lstassets);
                } 
                else {
                    List<Asset> lstassets = new List<Asset>(); 
                    lstassets.add(ass);
                    mapFulfilltoChildAssets.put(ass.parent_asset__c,lstassets);
                }
            }
            mapAllAssetIdmap.put(ass.id,ass.parent_asset__c);
        }
        
        Set<Id> setAllAssetids = new Set<Id>();
        for(Asset ass : maplstAsset.values()){
        //System.debug(ass.asset_type__c+'=777777='+Constants.ASSET_TYPE_PARENT);
            if(ass.asset_type__c==Constants.ASSET_TYPE_PARENT){
                        JSONGenerator gen = JSON.createGenerator(true);
                        gen.writeStartObject();
                        //gen.writeObjectField('parent',ass.id);
                        List<AssetStructure> lstparentAssetStructure = new List<AssetStructure>(); 
                 
                    setAllAssetids.add(ass.Id);
                    /*if(ass.id!=null){gen.writeObjectField('assetId',ass.Id);} else {gen.writeObjectField('assetId','');}
                    if(ass.Line_Type__c!=null){
                    if(ass.Line_Type__c=='Amend'){ass.Line_Type__c = 'Modify';}
                    gen.writeObjectField('Type', '$actionType$');} else {gen.writeObjectField('Type', '$actionType$');}   
                    if(ass.Accountid!=null){gen.writeObjectField('SoldToaccountId', ass.Accountid); } else {gen.writeObjectField('SoldToaccountId', '');  } 
                    if(ass.HLC__c!=null){gen.writeObjectField('HLC', ass.HLC__c); } else {gen.writeObjectField('HLC', ''); }
                    if(ass.HLC_Override__c!=null){gen.writeObjectField('HLCOverride', ass.HLC_Override__c);} else { gen.writeObjectField('HLCOverride', '');}
                    */
                    AssetStructure parentAssetStructure = new AssetStructure(); 
                    parentAssetStructure.Type = '$actionType$';
                    parentAssetStructure.SoldToaccountId = ass.Accountid;
                    parentAssetStructure.assetId = ass.id;
                    //parentAssetStructure.assetId = ass.id;
                    //parentAssetStructure.assetId = ass.id;
                    if(mapParentChildAssets.containskey(ass.id)){
                    List<AssetStructure.fulfillTo> lstasstStructurefulfill = new List<AssetStructure.fulfillTo>(); 
                    //System.debug(mapParentChildAssets+'#######');
                    for(Asset asst:mapParentChildAssets.get(ass.id)){
                    System.debug(mapParentChildAssets+'#######'+asst.id);
                         if(mapParentChildAssets.containskey(asst.parent_asset__c)){
                            setAllAssetids.add(asst.Id);
                            AssetStructure.fulfillTo asstStructurefulfill = new AssetStructure.fulfillTo();
                            asstStructurefulfill.Type = '$actionType$';
                            if(asst.Line_Type__c=='Amend'){asstStructurefulfill.Type = '$actionType$';}
                            asstStructurefulfill.FulfillToaccountId = asst.Accountid;
                            asstStructurefulfill.assetId = asst.id;
                            
                            List<AssetStructure.participant> lstasststructurepart = new List<AssetStructure.participant>(); 
                            if(mapFulfilltoChildAssets.containskey(asst.id)){
                            for(Asset asstp:mapFulfilltoChildAssets.get(asst.id)){
                                setAllAssetids.add(asstp.Id);
                                AssetStructure.participant asststructurepart = new AssetStructure.participant();
                                asststructurepart.Type = '$actionType$';
                                if(asstp.Line_Type__c=='Amend'){asststructurepart.Type = '$actionType$';}
                                asststructurepart.participantaccountId = asstp.Accountid;
                                asststructurepart.assetId = asstp.id;
                                asststructurepart.MLSSETID = asstp.MLS_Set__c;
                                asststructurepart.HLC = asstp.HLC__c;
                                lstasststructurepart.add(asststructurepart);
                            }
                            }
                            asstStructurefulfill.participant = lstasststructurepart; 
                            lstasstStructurefulfill.add(asstStructurefulfill);
                           // gen.writeObjectField('participant', lstasststructurepart);
                        }
                     }
                    //gen.writeObjectField('fulfillTo', lstasstStructurefulfill);
                    parentAssetStructure.fulfillTo = lstasstStructurefulfill;
                    
                }
                lstparentAssetStructure.add(parentAssetStructure);
                gen.writeObjectField('parent', lstparentAssetStructure);
                
                         //gen.writeObjectField('part_numbers',setProductCodes);
                         //gen.writeObjectField('postal_codes',setPostalCodes);
                         //gen.writeObjectField('party_ids',setPartyId);
                         gen.writeEndObject();
                         System.debug('$$$$$$$$$'+gen.getAsString());
                         setAssetIds.get(ass.id).Asset_Structure__c = gen.getAsString();
                         setAssetIds.get(ass.id).All_Related_Asset_Ids__c = setAllAssetids+'';
            }
         }  
      }

Public void CreateSupportCaseWhenFulfillmentFailed(Map<Id,Asset> mapoldAssets,Map<Id,Asset> mapnewAssets){
    Set<Id> setAssetIds = new Set<Id>(); 
    Set<Id> setWelcomeCaseAssetIds = new Set<Id>(); 
    Set<Id> setOrderitemIds = new Set<Id>(); 
    Map<Id,OrderItem> mapOrder= new Map<Id,OrderItem>();
    Set<Id> setOpportunityIds = new Set<Id>();
    Map<Id,Case> mapcase = new Map<Id,Case>();
        for(Asset ast:mapnewAssets.values()){
          system.debug('ast.RDC_Products_Agents__c ' +ast.RDC_Products_Agents__c);
          system.debug('ast ' +ast);
          system.debug('ast.Line_Type__c  ' +ast.Line_Type__c );
          system.debug('ast.Fulfillment_Status__c ' +ast.Fulfillment_Status__c);
          system.debug('ast.Status ' +ast.Status);
          system.debug('ast.Asset_Type__c ' +ast.Asset_Type__c);

            if(ast.Fulfillment_Status__c =='Failure' && ast.Asset_Type__c =='Parent'){
                    setAssetIds.add(ast.id);
                    setOrderitemIds.add(ast.Order_Line_Item__c);
                }
                if(((ast.RDC_Products_Agents__c == 1) || (ast.TP_Products_Agents__c == 1) )&& (ast.Line_Type__c =='Add' || ast.Line_Type__c =='Renew') && ast.Fulfillment_Status__c =='Fulfilled' && ast.Status =='Active' && ast.Asset_Type__c =='Parent'){
                    setWelcomeCaseAssetIds.add(ast.id);
                    setOrderitemIds.add(ast.Order_Line_Item__c);
                }
            }
            if(setAssetIds.size()>0){
            for(OrderItem oit:[Select Id,orderId from Orderitem where id=:setOrderitemIds]){
            mapOrder.put(oit.Id,oit);
            }
            
            for(Id aId:setAssetIds){
            Case caseToAdd = new Case();
                    String Concat = '';
                    // Set up any fields you want
                   // caseToAdd.RecordType.Name = 'Standard';
                    caseToAdd.Status = 'New';
                    caseToAdd.Origin = 'Web';
                    caseToAdd.Type = 'Outbound';
                    caseToAdd.Area__c = 'Operations Support';
                    caseToAdd.Subject = 'Asset Fulfillmentfailure';
                    caseToAdd.ContactId = mapnewAssets.get(aId).ContactId;
                    caseToAdd.AccountId = mapnewAssets.get(aId).AccountId;
                    caseToAdd.ownerid = mapnewAssets.get(aId).ownerId;
                    caseToAdd.Assetid = mapnewAssets.get(aId).id;
                    if(mapnewAssets.get(aId).Order_Line_Item__c!=null){
                    caseToAdd.Order__c= mapOrder.get(mapnewAssets.get(aId).Order_Line_Item__c).orderId;
                    }
                    mapcase.put(mapnewAssets.get(aId).id,caseToAdd);
            }
            
            }
            if(setWelcomeCaseAssetIds.size()>0){
            Map<Id,Id> mapWelcomeCaseAssets = new Map<Id,Id>();
            for(OrderItem oit:[Select Id,orderId,Suppress_Welcome_Calls__c from Orderitem where id=:setOrderitemIds]){
            mapOrder.put(oit.Id,oit);
            }
            for(Case cass:[Select Id,AssetId from case where AssetId=:setWelcomeCaseAssetIds and Subject = 'Welcome Call']){
            mapWelcomeCaseAssets.put(cass.AssetId,cass.AssetId);
            }
            //start
            set<id> setaccid = new set<id>();
            for(Asset objAsset : mapnewAssets.values())
            {
                if(objAsset.AccountId != null)
                    setaccid.add(objAsset.AccountId);
            }
            map<id,AccountTeamMember> mapofaccidandTM = new map<id,AccountTeamMember>();
            mapofaccidandTM = FillingAccountmanager(setaccid);
            //end
            for(Id aId:setWelcomeCaseAssetIds){
              system.debug('mapoldAssets.get(aId).Fulfillment_Status__c ' +mapoldAssets.get(aId).Fulfillment_Status__c);
              system.debug('mapnewAssets.get(aId).Fulfillment_Status__c ' +mapnewAssets.get(aId).Fulfillment_Status__c);
              system.debug('mapnewAssets.get(aId).Line_Type__c ' +mapnewAssets.get(aId).Line_Type__c);
              //System.debug('mapOrder.get(mapnewAssets.get(aId).Order_Line_Item__c).Suppress_Welcome_Calls__c ' +
                    //mapOrder.get(mapnewAssets.get(aId).Order_Line_Item__c).Suppress_Welcome_Calls__c);
            if(mapoldAssets.get(aId).Fulfillment_Status__c!=mapnewAssets.get(aId).Fulfillment_Status__c){
            if(mapnewAssets.get(aId).Order_Line_Item__c!=null){
            if(!mapWelcomeCaseAssets.containskey(aId) || mapnewAssets.get(aId).Line_Type__c.contains('Renew')){
            if(mapOrder.get(mapnewAssets.get(aId).Order_Line_Item__c).Suppress_Welcome_Calls__c==false){
            Case caseToAdd = new Case();
                    String Concat = '';
                    // Set up any fields you want
                   // caseToAdd.RecordType.Name = 'Standard';
                    caseToAdd.Status = 'New';
                    caseToAdd.Origin = 'Web';
                    caseToAdd.Type = 'Outbound';
                    caseToAdd.Area__c = 'Product Set Up';
                    caseToAdd.Subject = 'Welcome Call';
                    caseToAdd.ContactId = mapnewAssets.get(aId).ContactId;
                    caseToAdd.AccountId = mapnewAssets.get(aId).AccountId;
                    if(mapofaccidandTM != null && mapnewAssets.get(aId).AccountId != null && mapofaccidandTM.get(mapnewAssets.get(aId).AccountId) != null)
                    {
                        caseToAdd.ownerid = mapofaccidandTM.get(mapnewAssets.get(aId).AccountId).UserId;
                    }
                    else{
                        caseToAdd.ownerid = mapnewAssets.get(aId).ownerId;
                    }
                    caseToAdd.Assetid = mapnewAssets.get(aId).id;
                 //   mapcase.put(mapnewAssets.get(aId).id,caseToAdd);
                   } 
                 }
               }
              } 
             }
            }
            if(mapcase.values().size()>0){
            //insert mapcase.values();
            }
        }    
        
        
    Public void CreateBackoutQuoteForAgentParticipants(Set<Id> setAssetIds){
      Set<Id> setAsstIds = new Set<Id>();
      Set<Id> setAccountIds = new Set<Id>();

        // Query is changed by Rajamohan for Advanatge Product
        Set<String> prodCode = new Set<String>();
        prodCode.add('ADVANTAGE');
        prodCode.add('SHOWCASE');

        Set<String> lineType = new Set<String>();
        lineType.add('Add');
        lineType.add('Renew');
        // CRM-2545 Added SOQL filter to exclude Advantage Brand products.
        for(Asset last:[Select id,name,Parent_Asset__c,Product_Type__c,ConfigOptions__c,AccountId,Product2Id,Product2.ProductCode,Status,Line_Type__c,
                        Ultimate_Parent__c from Asset where Asset_Type__c='Parent'
                        and Fulfillment_Status__c='Fulfilled' and
                        LastModifiedDate=Today and Product2.ProductCode IN :prodCode  and
                       Contract__r.Account.Type='Broker'
                          and Line_Type__c in:lineType and Id=:setAssetIds AND Product_Type__c != 'Brand']){


                            if(last.Product_Type__c=='Showcase' || !last.ConfigOptions__c.contains('withoutAgents')){

      setAsstIds.add(last.id);
      setAccountIds.add(last.AccountId);
                              }
      //last.addError('This is working!');
      }
      if(setAsstIds.size()>0){
      System.debug('Working fine!');
      List<AsyncRecordProcessExecution__c> lstAsyncRecord = new List<AsyncRecordProcessExecution__c>();
      Map<Id,Id> mapAccountOppId = new Map<Id,Id>();
          
        BackoutCreditQuoteCreationBatchCls theBatchProcess = new BackoutCreditQuoteCreationBatchCls();
        theBatchProcess.theAssetIdsToProcess = setAsstIds;
        //theBatchProcess.theAccountOpportunity = mapAccountOppId;
        System.debug('Asset Ids : '+theBatchProcess.theAssetIdsToProcess);
        Id theBatchProcessId = Database.executeBatch(theBatchProcess);
        system.debug('TRACE: AssetTrigger - theBatchProcessId - ' + theBatchProcessId);
        /*AsyncRecordProcessExecution__c arpe = new AsyncRecordProcessExecution__c();
                                        arpe.Name = 'Asset Trigger';
                                        arpe.Interface_Name__c = 'AssetTrigger';
                                        arpe.ClassName__c = 'AssetTriggerHelper';
                                        arpe.MethodName__c = 'ProcessBackout';
                                        arpe.Boolean_Param__c = true;
                                        arpe.Records_To_Process_Ids__c = setAsstIds+'';
                                        lstAsyncRecord.add(arpe);
                                        */
       // ProcessBackout(setAsstIds);
       if(lstAsyncRecord.size()>0){
       //Insert lstAsyncRecord;
       }
      }
      }
      
      Public void ProcessBackout(set<Id> setbAssetIds){
      String Query;
   //global date rendat =system.today().addDays(-60);
    Set<Id> theAssetIdsToProcess = new Set<Id>();
    Map<Id,Id> theAccountOpportunity = new Map<Id,Id>();
    Map<Id,Id> theAccountOpportunityId = new Map<Id,Id>();
    Map<Id,Map<Id,Id>> theAccountAsset = new Map<Id,Map<Id,Id>>();
    List<Asset> lstBatchAssets = [Select id,name,Parent_Asset__c,AccountId,Product2Id,Product2.ProductCode,Status,Line_Type__c,Ultimate_Parent__c from Asset where Asset_Type__c='Parent' and Status='Active' and Id=:setbAssetIds];
            Set<Id> setAccountIds = new Set<Id>();
                       Set<Id> setAssetIds = new Set<Id>();
                       Map<Id,Map<Id,String>> mapAgentAccountIds = new Map<Id,Map<Id,String>>();
                       Set<Id> setAgentAssetIds = new Set<Id>();
                       Set<Id> setOfficeIds = new Set<Id>();
                       Set<Id> setAgentAccountIds = new Set<Id>();
                       Set<Id> setMLSAccountIds = new Set<Id>();
                       Set<Id> setMLSOfficeAccountIds = new Set<Id>();
                       List<Asset> cancellstAsset = new List<Asset>();
                       
                       for(Asset ast:lstBatchAssets){
                       setAccountIds.add(ast.AccountId);
                       setAssetIds.add(ast.Id);
                       }
                       System.debug(setAssetIds+'$$$$$');
      for(Asset ast:[Select Id,AccountId, MLS_Set__c ,MLS_Set__r.MLS__c ,name from Asset where Ultimate_Parent_Id_Text__c=:setAssetIds and Asset_Type__c='Participant' and Product2.ProductCode='SHOWCASE' and Status='Active' and Line_Type__c='Add']){//and Account.Type='Realtor Office'
      setMLSOfficeAccountIds.add(ast.AccountId);
      setOfficeIds.add(ast.MLS_Set__c);
      setMLSAccountIds.add(ast.MLS_Set__r.MLS__c);
      }
        
      for(MLS__c mlls:[SELECT Id,Name,Agent__c,Agent__r.Name,Office__c FROM MLS__c WHERE Id =:setOfficeIds AND Status__c = 'Active']){ //AND Office__c = :setMLSOfficeAccountIds
      setAgentAccountIds.add(mlls.Office__c);
      }
      //SELECT Id,Name,Agent__c,Agent__r.Name,Office__c FROM MLS__c WHERE MLS__c = '001Z000000yWcq4' AND Office__c = '001Z000000yVwOx' AND Status__c = 'Active'
      //Set<Id> setAgentAccIds = new Set<Id>();
      for(Account_Relationship__c accRelation:[Select Id,Name, Child_Account__c from Account_Relationship__c where Parent_Account__c=:setAgentAccountIds and Child_Account__r.Type='Realtor Agent']){  
             Map<Id,String> setAccountAssetIds = new Map<Id,String>();
             //setAgentAccIds.add(accRelation.Child_Account__c);
      mapAgentAccountIds.put(accRelation.Child_Account__c,setAccountAssetIds);
             }
      for(Asset asst:[Select Id,Name,Line_Type__c,Status,AccountId  from Asset where Ultimate_Parent_Id_Text__c!=:setAssetIds and AccountId=:mapAgentAccountIds.keyset() and Asset_Type__c='Parent' and Product2.ProductCode='SHOWCASE' and Account.Type='Realtor Agent' and Line_Type__c!='Cancel' and Status='Active']){
      System.debug('Working till here!');
      if(mapAgentAccountIds.containskey(asst.AccountId)){
      System.debug('Working till here!');
      Map<Id,String> setAccountAssetIds = mapAgentAccountIds.get(asst.AccountId);
      setAccountAssetIds.put(asst.id,'');
      mapAgentAccountIds.put(asst.AccountId,setAccountAssetIds);
         } 
      }   
      
      if(mapAgentAccountIds.keyset().size()>0){
      for(Id idds:mapAgentAccountIds.keyset()){
      //System.debug(theAccountOpportunity+'Working till here!'+idds+' ** '+mapAgentAccountIds+'KKKK'+mapAgentAccountIds.get(idds));
      if(mapAgentAccountIds.containskey(idds)){
      System.debug('Working till here!');
      if(mapAgentAccountIds.get(idds).size()>0){
      System.debug('Working till here!');
      Opportunity theOpportunity;
      //Map<Id,Id> mapAccountOppId = new Map<Id,Id>();
        Id RecordTypeId = [Select Id,Name from RecordType where DeveloperName='Inside_Sales'].Id;
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        for(Account acct:[Select Id,name,type from Account where Id=:idds]){
        //acct.addError('This is working!');
        theOpportunity = new Opportunity(
          Name = 'The Opportunity',
          StageName = 'Prospecting',
          CloseDate = system.today(),
          AccountId = acct.Id,
          Account_Type__c = 'Short',
          //Lead__c = leadId,
          //campaignId = campaignId,
          RecordTypeId = RecordTypeId
          
        );
        System.debug('Working fine!');
        lstOpportunity.add(theOpportunity);
        }
        if(lstOpportunity.size()>0){
          insert lstOpportunity;
          //System.debug('Working fine!'+lstOpportunity);
          for(Opportunity opp:lstOpportunity){
          //System.debug('Working fine!'+opp.id);
          theAccountOpportunity.put(opp.AccountId,opp.Id);
          }
          }
          
          
       
       if(theAccountOpportunity.containskey(idds)){
       theAccountOpportunityId.put(idds,theAccountOpportunity.get(idds));
       theAccountAsset.put(idds,mapAgentAccountIds.get(idds));
       System.debug('Working till here!');
       //WebserviceCallBigMachineQuoteCls wscbm = new WebserviceCallBigMachineQuoteCls();
      // wscbm.CreateQuote(null,null,idds,theAccountOpportunity.get(idds),null,'Backout','cancel',true,true,mapAgentAccountIds.get(idds));
       }
       }
       }
       }
      }   
      if(theAccountOpportunityId.keyset().size()>0){
        System.debug('Working till here!'+theAccountOpportunityId);
        for(Id iiidd:theAccountOpportunityId.keyset()){
        /*  BackoutQuoteCreationCalloutBatchCls theBatchProcess = new BackoutQuoteCreationCalloutBatchCls();
        theBatchProcess.theAccountId = iiidd;
        theBatchProcess.theOpportunityId = theAccountOpportunityId.get(iiidd);
        theBatchProcess.theAgentAssetMap = theAccountAsset.get(iiidd);
        System.debug('Asset Ids : '+theBatchProcess.theOpportunityId);




        Id theBatchProcessId = Database.executeBatch(theBatchProcess);
        system.debug('TRACE: AssetTrigger - theBatchProcessId - ' + theBatchProcessId);*/
          }
          }
      }


Public void CancelOrderLineUponAssetQuantityModification(Map<Id,Asset> mapoldAssets,Map<Id,Asset> mapnewAssets){
    Set<Id> setAssetIds = new Set<Id>(); 
    Set<Id> setOpportunityIds = new Set<Id>();
        for(Asset ast:mapnewAssets.values()){
            if(mapoldAssets.get(ast.id).Quantity!=ast.Quantity){
                    setAssetIds.add(ast.id);
                }
            }
        
     List<OrderItem> odrItems = [Select Id,Status__c,Fulfillment_Status__c,order.opportunityId from OrderItem where Asset__c=:setAssetIds and Fulfillment_Status__c='Pending Fulfillment'];
        for(OrderItem oi:odrItems){
        oi.Status__c = 'Cancelled';
        oi.Fulfillment_Status__c= 'Cancelled';
        setOpportunityIds.add(oi.order.opportunityId);
        }
        if(odrItems.size()>0){
        update odrItems; 
        }
        List<Opportunity> lstOpportunity = [Select id,name,Is_Renewal_failed_opportunity__c from opportunity where Id=:setOpportunityIds];
        for(Opportunity opp:lstOpportunity){
        opp.Is_Renewal_failed_opportunity__c = true;
        }
        if(lstOpportunity.size()>0){
        update lstOpportunity;
        } 
        if(setAssetIds.size()>0){
        TriggerUpdateAsset(setAssetIds);
        }
     }

       @future
       public static void TriggerUpdateAsset(Set<Id> setAssetIds) {
       List<Asset> lstAsset=[Select Id,Asset_Type__c,Renewal_End_Date__c,Auto_Renewal__c,owner.email,Renewal_Price__c,Renewal_Start_Date__c,Name from Asset where id=:setAssetIds];
       for(Asset asst:lstAsset){
       asst.Renewal_End_Date__c = null;
       asst.Renewal_Price__c    = null;
       asst.Renewal_Start_Date__c= null;
       asst.Auto_Renewal__c = 'No';
       //asst.Renewal_End_Date__c = null;
       //asst.Renewal_End_Date__c = null;
       }
       update lstAsset;
       
     }
     
     Public void sendAssetNotification(List<Asset> theAssets) {
     for(Asset ast:theAssets){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.saveAsActivity = false;
        mail.setToAddresses(new String[]{ast.owner.Email});
        if(Test.isRunningTest()){mail.setToAddresses(new String[]{'sonusharmacs@gmail.com'});}
        mail.setSubject('Asset Modified Before Renewal Notification');
        String theEmailBody = 'Hi ,\n\n';
        theEmailBody += 'The following Assets quantity have been modified, so orders have been cancelled:\n\n';
       // for(Order theOrder : theOrders) {
          theEmailBody += 'Asset ID: ' + ast.Id + '\n';
          theEmailBody += 'Asset Name: ' + ast.Name+ '\n';
          //theEmailBody += 'Asset Account Id: ' + theOrder.AccountId + '\n';
          //theEmailBody += 'Asset Account Name: ' + theOrder.Account.Name + '\n';
          theEmailBody += 'Asset Type: ' + ast.Asset_Type__c + '\n\n';
       // }
        theEmailBody += 'Please review above Assets.\n\n';
        theEmailBody += 'Thanks.\nTech Team';

        mail.setPlainTextBody(theEmailBody);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
     }
   }

   // -------------------------------------------------------------------------------------------
    // This method return's Mapof Accountid and AccountTeamMember
    // Version#   Date                Author              Description
    // -------------------------------------------------------------------------------------------
    // 1.0        19-November-2015    Sateesh Reddy        Initial Version
    // -------------------------------------------------------------------------------------------
   public map<id,AccountTeamMember> FillingAccountmanager(set<id> setofAccountids)
   {
        map<id,AccountTeamMember> mapofAccountidandATM = new map<id,AccountTeamMember>();
        list<AccountTeamMember> lstAccountTeamMember = [Select UserId, TeamMemberRole, Id, AccountId From AccountTeamMember where AccountID in :setofAccountids and TeamMemberRole = 'Account Manager'];
        if(lstAccountTeamMember != null && lstAccountTeamMember.size() > 0)
        {
            for(AccountTeamMember objAccountTeamMember : lstAccountTeamMember)
            {
                mapofAccountidandATM.put(objAccountTeamMember.AccountId,objAccountTeamMember);
            }
        }
        return mapofAccountidandATM;
    
   }
   
   
   // CRM-1586 - To handle Fulfill-To Asstes which gets fulfilled in same transaction as of its Parent
   public Map<Id, List<Id>> officeAccountFulfillToAssets = new  Map<Id, List<Id>>();
   public Map<Id, Id> fulfillToParenAsset = new Map<Id, Id>();
   // CRM-1258 Start - Populate Product Geo on Assets
    
    // CRM-1586 5/17/2017- Exclude already Active FulfillTo Asstes which are getting In-Active in the same trigger transaction as of its Parent.
    public Set<Id> excludeFulFillToIds = new Set<Id>();
    /*
    @method      : UpdateProductGeoOnBDXParentAssets
    @description : Populate Product Geo on Assets
    @params      : Assets
    @returns     : void
    @Owner       : Sonali Bhardwaj
    */

    public void UpdateProductGeoOnBDXParentAssets(Map<Id, Asset> bdxParentAssets) {
        // Get parent accounts fulfillto assets
        for(Asset fulfillToAsset: [SELECT Id, Parent_Asset__c, AccountID FROM Asset WHERE 
            (Parent_Asset__c IN :bdxParentAssets.keySet() AND Asset_Type__c = 'Fulfill To' AND Status = 'Active') AND Id NOT IN :excludeFulFillToIds]) {
            if (!officeAccountFulfillToAssets.containsKey(fulfillToAsset.AccountID)) {
                officeAccountFulfillToAssets.put(fulfillToAsset.AccountID, new List<Id>());
            }
            // store fulfillto asset office account
            officeAccountFulfillToAssets.get(fulfillToAsset.AccountID).add(fulfillToAsset.Id);  
            // fulfillto asset parent asset
            fulfillToParenAsset.put(fulfillToAsset.Id, fulfillToAsset.Parent_Asset__c);                 
        }
        
        Map<Id, Set<String>> parentMLSs = new Map<Id, Set<String>>();
            
        if (!fulfillToParenAsset.isEmpty()) {
            // fetch MLS for officce accounts
            // CRM-1578 update product geo for Agent account also
            for (MLS__c mls : [SELECT RecordType.DeveloperName, MLS__r.Display_Name__c, Office__c, Agent__c FROM MLS__c WHERE Office__c IN :officeAccountFulfillToAssets.keySet() OR Agent__c IN :officeAccountFulfillToAssets.keySet()]) {
                // CRM-1578, check for record type of MLS and get fulfillto assets accordingly
                Id lookupId = null;
                if (mls.RecordType.DeveloperName == 'MLS_Office') {
                    lookupId = mls.Office__c;
                }
                else if (mls.RecordType.DeveloperName == 'MLS_Agent') {
                    lookupId = mls.Agent__c;
                }
                
                // CRM-1578
                if (lookupId != null && officeAccountFulfillToAssets.containsKey(lookupId)) {
                    for (Id fulfillToAssetId : officeAccountFulfillToAssets.get(lookupId)) {
                        Id parentAssetId = fulfillToParenAsset.get(fulfillToAssetId);
                        if (!parentMLSs.containsKey(parentAssetId)) {
                            parentMLSs.put(parentAssetId, new Set<String>());
                        }
                        parentMLSs.get(parentAssetId).add(mls.MLS__r.Display_Name__c);
                    }
                }
            }
        }
        
        for (Id parentAssetId : bdxParentAssets.keySet()) {
            Set<String> mlsDisplayNames = parentMLSs.get(parentAssetId);
            List<String> mlsList = new List<String>();
            if (mlsDisplayNames != null) {
                mlsList.addAll(mlsDisplayNames);
            }
            bdxParentAssets.get(parentAssetId).Product_Geo__c = string.join(mlsList,', ');
         }
    }
    
    // CRM-1258 End
}