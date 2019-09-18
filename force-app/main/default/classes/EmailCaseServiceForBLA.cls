global class EmailCaseServiceForBLA implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
    	String partyId;
    	Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try{
            system.debug('email==>'+email);
            system.debug('envelope==>'+envelope);
            system.debug('plain==>'+email.plainTextBody);
            if(email.plainTextBody != null && email.plainTextBody != ''){
                
                String[] emailBodyRows = email.plainTextBody.split('\n');
                system.debug('emailBodyRows='+emailBodyRows);
                for(String bodyRow : emailBodyRows){
                    if(!String.isEmpty(bodyRow) && bodyRow.contains(':')){
                        String[] rowContents = bodyRow.Split(':');
                        String label = rowContents[0].trim();
                        String value = rowContents[1].trim();
                        switch on label {
                            when 'Party ID'{
                                partyId = value.trim();
                            }
                        }
                    }
                }
            }
            system.debug('partyId=='+partyId);
            if(!String.isEmpty(partyId)){
                List<Asset> fulfillToAsset = [Select Id,Account_Party_ID__c,Parent_Asset__c,Contract_Signed_Date__c,Stage__c,Product_Code__c,Asset_Type__c,Fulfillment_Status__c
                                         From Asset Where Account_Party_ID__c = :partyId AND Product_Code__c = 'OPCITYBLA' AND Asset_Type__c = 'Fulfill To'
                                         AND Fulfillment_Status__c = 'Manual' AND Line_Type__c = 'Add' LIMIT 1];
                
                
				List<Asset> associatedParentsAsset;
                if(fulfillToAsset.size() > 0 && fulfillToAsset[0].Parent_Asset__c != null){
                    associatedParentsAsset = [Select Id,AccountId,Account_Party_ID__c,Stage__c,Commission_field__c,Contract_Signed_Date__c,Product_Code__c,Asset_Type__c,Fulfillment_Status__c
                                         From Asset Where Id = :fulfillToAsset[0].Parent_Asset__c AND Product_Code__c = 'OPCITYBLA' AND Asset_Type__c = 'Parent'
                                         AND Fulfillment_Status__c = 'Manual' AND Line_Type__c = 'Add' LIMIT 1];
                    
                }
                                    
                 
                List<Asset> fulfillToAssetUpdate = new List<Asset>();
                List<Asset> associatedParentsAssetToUpdate = new List<Asset>();
                if(fulfillToAsset.size() == 1){
                    for(Asset asset : fulfillToAsset){
                        asset.Contract_Signed_Date__c = System.today();
                    	asset.Stage__c = 'Brokerage Signed (won deal)';
                        fulfillToAssetUpdate.add(asset);
                    }
                    
                    Database.SaveResult[] updateResult = Database.update(fulfillToAssetUpdate);
                    
                    Boolean IsParentAssetCalculate = false;
                    
                    if(updateResult[0].isSuccess()){
                        if(associatedParentsAsset.size() > 0){
                            List<Asset> parentAssetsFromAccount = [Select Id,Commission_field__c,AccountId,Product_Code__c,Fulfillment_Status__c,Line_Type__c,Asset_Type__c From Asset Where AccountId = :associatedParentsAsset[0].AccountId AND Product_Code__c = 'OPCITYBLA' AND Asset_Type__c = 'Parent'
                                                                   																											AND Fulfillment_Status__c = 'Manual' AND Line_Type__c = 'Add'];
                            if(parentAssetsFromAccount.size() > 0){
                                for(Asset parAsset : parentAssetsFromAccount){
                                    if(parAsset.Commission_field__c == 'Calculate'){
                                        IsParentAssetCalculate = true;
                                        break;
                                    }
                                }
                            }
                            
                            associatedParentsAsset[0].Contract_Signed_Date__c = System.today();
                            associatedParentsAsset[0].Stage__c = 'Brokerage Signed (won deal)';
                            if(!IsParentAssetCalculate)                                      
                            	associatedParentsAsset[0].Commission_field__c = 'Calculate';
                            
                            Database.SaveResult[] updateParentResult = Database.update(associatedParentsAsset);
                            if(updateParentResult[0].isSuccess()){
                                result.success = true;                
                                return result;
                            }
                            else{
                            	result.success = false;                
                                return result;    
                            }
                        }
                    }
                    else{
                        result.success = false;
                        return result;
                    }
                }
            }
        }
        catch(Exception ex){
        	system.debug('ex=='+ex);   
        }
        return result;
        
    }

}