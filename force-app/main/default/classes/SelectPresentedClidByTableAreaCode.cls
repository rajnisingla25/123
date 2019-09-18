global class SelectPresentedClidByTableAreaCode implements NVMContactWorld.ISelectPresentedClid{

    // The clickToDialResult parameter contains the response string from the Salesforce ClickToDial event.
    // Salesforce passes the clickToDialResult parameter to us:
    // for example '{number: "07890123456", objectId: "0032000001FTGSo", object: "Contact"}'
    // Find more information at: https://www.salesforce.com/us/developer/docs/api_cti/Content/sforce_api_cti_onclicktodial.htm
    
    // This code covers NANP numbering system only.  It is not written for International numbers.  All International numbers will use defaultCLID.
public Integer randomWithLimit(Integer upperLimit){
        if(upperLimit > 0)
        {
            Integer rand = Math.round(Math.random()*100);
            return Math.mod(rand, upperLimit);
        }
        else
            return 0;
    }

    global String GetPresentedClid(String clickToDialResult){


        System.debug('Starting class SelectPresentedClidByTableAreaCode');
        Map<String,Object> clickToDialResultMap = (Map<String,Object>)JSON.deserializeUntyped(clickToDialResult);
        String customerNumber = (String)clickToDialResultMap.get('number');
        String objectId = (String)clickToDialResultMap.get('objectId');

        String AreaCodeI = customerNumber.mid(2,3);
        // For International formatting, Trying to remove the +1 and return only the area code
        
        String AreaCodeNA = customerNumber.mid(1,3); 
        // For Non International - Trying to remove the Left parenthesis and return only the area code
        
        String AreaCodeDot = customerNumber.mid(3,3);
        // For International with a period after the +1 - Trying to remove the +1. and return only the area code
        
        String AreaCodePar = customerNumber.mid(3,3);
        // For International with a parenthesis after the +1 - Trying to remove the +1( and return only the area code
        
        //Account default
        //String defaultCLID = '+14157693346';
        String defaultCLID = ' +18558567732';
        String presentedClid;
        String defaultRunningUserDID = '';
        

        System.debug('Customer number is ' + customerNumber + 'AreaCodeI is + ' + AreaCodeI + ' and AreaCodeNA is ' + AreaCodeNA + ' AreaCodeDot is ' + AreaCodeDot
                    + ' AreaCodePar is + ' + AreaCodePar);
        String AccountType = '';  
        for(Account acc:[Select Id,name,Type,Account_sub_type__c,owner.FirstName,owner.LastName,owner.Phone from Account where Id=:objectId and Account_sub_type__c='Customer']){
        AccountType = acc.Account_sub_type__c;
        defaultCLID = acc.Owner.FirstName+' '+acc.Owner.LastName;
        defaultCLID = acc.owner.Phone;
        }         
        if(AccountType==''){
        for(Lead led:[Select Id,Account__r.Account_sub_type__c,Account__r.owner.FirstName,Account__r.owner.Phone,Account__r.owner.LastName from Lead where Id=:objectId and Account__r.Account_sub_type__c='Customer']){
        AccountType = led.Account__r.Account_sub_type__c;
        defaultCLID = led.Account__r.Owner.FirstName+' '+led.Account__r.Owner.LastName;
        defaultCLID = led.Account__r.owner.Phone;
        }
        }
        if(AccountType==''){
        for(Opportunity opp:[Select Id,Account.Account_sub_type__c,Account.owner.FirstName,Account.owner.Phone,Account.owner.LastName from Opportunity where Id=:objectId and Account.Account_sub_type__c='Customer']){
        AccountType = opp.Account.Account_sub_type__c;
        defaultCLID = opp.Account.Owner.FirstName+' '+opp.Account.Owner.LastName;
        defaultCLID = opp.Account.owner.Phone;
        }
        }
        if(AccountType==''){
        for(Case cas:[Select Id,Account.Account_sub_type__c,Account.owner.FirstName,Account.owner.Phone,Account.owner.LastName from Case where Id=:objectId and Account.Account_sub_type__c='Customer']){
        //AccountType = cas.Account.Account_sub_type__c;
        //defaultCLID = cas.Account.Owner.FirstName+' '+cas.Account.Owner.LastName;
        //defaultCLID = cas.Account.owner.Phone;
        }
        }
                 if(defaultCLID==null || defaultCLID==''){
                 defaultCLID = [Select Id,phone from user where Id=:UserInfo.getUSERID()].phone;
                 }   

        if (customerNumber.startsWith('+1.')) {

            System.debug('Looking up +1 AreaCodeDot');
            Call_Prefix_Mapping__c [] a = [SELECT Id,Presented_Callback_Number__c FROM Call_Prefix_Mapping__c WHERE Name = :AreaCodeDot];
            System.debug('Query is SELECT CLIDValue__c FROM AreaCodeMap__c WHERE AreaCode__c = : ' + AreaCodeDot);
            
            if(a.size() > 0) {
                    Integer rand = randomWithLimit(a.size());
               if(AccountType=='Customer'){
                presentedClid = defaultCLID;
                    } else if(a[rand].Presented_Callback_Number__c != null) {
                
                    presentedClid = a[rand].Presented_Callback_Number__c;
                    System.debug('Result found - changing CLID');


                } else {     
                    presentedClid = defaultCLID;
                    System.debug('No result');


                } 
            }else {
                    presentedClid = defaultCLID;
                    System.debug('No area code record');
            }
            //For international numbers, trying to match the Variable AreaCodeDot to the AreaCode__c to return the 
            // number to present as the CLID
            
        } else if (customerNumber.startsWith('+1(')) {
            System.debug('Looking up +1 AreaCodePar');
            Call_Prefix_Mapping__c[] a = [SELECT Presented_Callback_Number__c FROM Call_Prefix_Mapping__c WHERE Name = :AreaCodePar];
            System.debug('Query is SELECT CLIDValue__c FROM AreaCodeMap__c WHERE AreaCode__c = : ' + AreaCodePar);
            
            if(a.size() > 0) {
                    Integer rand = randomWithLimit(a.size());
               if(AccountType=='Customer'){
                presentedClid = defaultCLID;
                    } else if(a[rand].Presented_Callback_Number__c != null) {
               // Integer rand = randomWithLimit(a.size()-1);
                    presentedClid = a[rand].Presented_Callback_Number__c;
                    System.debug('Result found - changing CLID');


                } else {     
                    presentedClid = defaultCLID;
                    System.debug('No result - default CLID');


                } 
            }else {
                    presentedClid = defaultCLID;
                    System.debug('No area code record - default CLID');
            }
            //For international numbers, trying to match the Variable AreaCodePar to the AreaCode__c to return the 
            // number to present as the CLID
            
        } else if (customerNumber.startsWith('+1')) {
            System.debug('Looking up +1 AreaCodeI');
            Call_Prefix_Mapping__c[] a = [SELECT Presented_Callback_Number__c FROM Call_Prefix_Mapping__c WHERE Name = :AreaCodeI];
            System.debug('Query is SELECT CLIDValue__c FROM AreaCodeMap__c WHERE AreaCode__c = : ' + AreaCodeI);
            
            if(a.size() > 0) {
                Integer rand = randomWithLimit(a.size());
                if(AccountType=='Customer'){
                presentedClid = defaultCLID;
                    } else if(a[rand].Presented_Callback_Number__c != null) {
                //Integer rand = randomWithLimit(a.size()-1);
                    presentedClid = a[rand].Presented_Callback_Number__c;
                    System.debug('Result found - changing CLID');


                } else {     
                    presentedClid = defaultCLID;
                    System.debug('No result - default CLID');


                } 
            }else {
                    presentedClid = defaultCLID;
                    System.debug('No area code record - default CLID');
            }
            //For international numbers, trying to match the Variable AreaCodeI to the AreaCode__c to return the 
            // number to present as the CLID
            
        }
else if(customerNumber.startsWith('+44')) { presentedCLID = '4420';


}
 else {
            
            System.debug('Looking up +1 AreaCodeNA = '+AreaCodeNA);
            Call_Prefix_Mapping__c[] a = [SELECT Id,Presented_Callback_Number__c FROM Call_Prefix_Mapping__c WHERE Name = :AreaCodeNA];
            System.debug('Query is SELECT CLIDValue__c FROM AreaCodeMap__c WHERE AreaCode__c = : ' + AreaCodeNA);
            
            if(a.size() > 0) {
                Integer rand = randomWithLimit(a.size());
                if(AccountType=='Customer'){
                presentedClid = defaultCLID;
                    } else if(a[rand].Presented_Callback_Number__c != null) {
               // Integer rand = randomWithLimit(a.size()-1);
                    presentedClid = a[rand].Presented_Callback_Number__c;
                    System.debug('Result found - changing CLID');


                } else {     
                    presentedClid = defaultCLID;
                    System.debug('No result - default CLID');


                } 
            }else {
                    presentedClid = defaultCLID;
                    System.debug('No area code record - default CLID');
            }
        }
            

    

        return presentedClid;   
    }
}