//CRM-2456

public class ARIIUtility{
    public static void parallelProcessAccountsForPriceUpdate(Set<Id> accountIds){
        if(!accountIds.isEmpty()){
        
            //get the custom settings size for number of parallel processing.
            List<BigMachineUrls__c> bmUrlSettings = BigMachineUrls__c.getAll().values(); //getting all values since other users are also setup in this settings
            List<BigMachineUrls__c> parallelProcessingUsers = new List<BigMachineUrls__c>(); //creating a list to store only parallel processing users
            for(BigMachineUrls__c setting: bmURlSettings){
                if(setting.Parallel_Processing_User__c == true){ 
                    parallelProcessingUsers.add(setting); //adding parallel processing users
                }
            }
            
        
             if(parallelProcessingUsers.size() >1 && AccountIds.size() >= parallelProcessingUsers.size()){ //if there are more than one parallel processing users then do the split
                Integer eachSplitSize = AccountIds.size()/parallelProcessingUsers.size(); //getting the size for each split
                Integer remainingAccounts = Math.mod(AccountIds.size(),parallelProcessingUsers.size()); //getting the remaining accounts in case any
                Set<Id> eachSplit = new Set<Id>(); //set for storing accountIds for each split
                Integer counter = 0; //counter to check if each split size has reached while processing accounts
                Integer userIndex = 0; //userindex is for sending appropriate user for parallel processing
                for(ID accId: AccountIds){ //looping through the accounts
                    if(counter < eachSplitSize){ //checking if the split size is reached 
                        eachSplit.add(accId); //adding the account to the split set 
                        counter++; //incrementing the counter
                    }
                    if(counter == eachSplitsize){ //split size is reached in the above if statement, we need to make a call
                        if(userIndex == parallelProcessingUsers.size()-1){  //checking if its the last user to send remaining records
                            
                            if(remainingAccounts >= 0 ){ //need to add this condition to check the remaining records since the remaining records would be processed from next iteration
                                eachSplit.add(accId);    
                                remainingAccounts--; 
                            }
                            if(remainingAccounts < 0){    //when all the remaining accounts get processes, remaining accounts will be negative                          
                                ARIIAssettPriceUpdateBatch PriceBatch = new ARIIAssettPriceUpdateBatch(eachSplit, parallelProcessingUsers[userIndex]);
                               if(!Test.IsRunningTest()){database.executebatch(PriceBatch,1);}
                            }
                        }else{ //checking if its not the last user, then we are resetting all the values 
                            ARIIAssettPriceUpdateBatch PriceBatch = new ARIIAssettPriceUpdateBatch(eachSplit, parallelProcessingUsers[userIndex]);
                           if(!Test.IsRunningTest()){  database.executebatch(PriceBatch,1); }
                            userIndex++; //incrementing the user index to take the next parallel processing user
                            counter=0; //resetting the counter to 0 to check the split size again
                            eachSplit.clear(); //clearing the split set to add new accounts for the next user
                        }
                    }

                }
            }else{ //single user does not need splitting
                 ARIIAssettPriceUpdateBatch PriceBatch = new ARIIAssettPriceUpdateBatch(accountIds);
                 if(!Test.IsRunningTest()){database.executebatch(PriceBatch,1);}
            }
         }
    }
}