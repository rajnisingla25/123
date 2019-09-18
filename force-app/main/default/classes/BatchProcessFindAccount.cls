global class BatchProcessFindAccount implements Database.Batchable<sObject>{
global String query;

    global Database.querylocator start(Database.BatchableContext BC){
        //Query = 'SELECT Id,Name,State__c,Phone__c,Result__c FROM Account_Search__c where Result__c=\'\'';
        Query = query; //'SELECT Id,Name,State__c,Phone__c,Result__c FROM Account_Search__c where Result__c=\'\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account_Search__c> scope){
       List<Account_Search__c> LeadList = new List<Account_Search__c>();
       for(Account_Search__c led : scope){
           String strName = led.name;
String searchquery = 'FIND \'' + strName + '\' IN ALL FIELDS RETURNING Account(Id,Name,party_id__c,MLS_Set_Id__c,BillingState,Work_Phone__c,Phone,Home_Phone__c,Mobile1__c,Mobile2_Other__c,ShippingState)'; 
List < List < Account > > searchList=search.query(searchquery);
system.debug('Search List is ' + searchList);
String finalResult = '';
//List < List < Account > > searchListFinal = new List < List < Account > >();
for(integer ii=0;ii<searchList.size();ii++ ){
List<Account> ObjExcludeAccount = searchList[ii];
integer kk=0;
searchList[ii] = new List<Account>();
for(Account saobj:ObjExcludeAccount){
string mlsCode = '';
if(saobj.MLS_Set_Id__c!=null){
mlsCode = saobj.MLS_Set_Id__c;
mlsCode = mlsCode.substring(4,6);
}
if(led.Name == saobj.Name || led.State__c == saobj.BillingState || led.State__c == saobj.ShippingState || led.State__c==mlsCode){
searchList[ii].Add(saobj);
//kk--;
}
System.debug(searchList[ii]+'KKKLP'+kk);
}
}
for(integer ii=0;ii<searchList.size();ii++ ){
List<Account> ObjAccount = searchList[ii];
List<Account> ObjStateAccount = new List<Account>();
List<Account> ObjStatePhoneAccount = new List<Account>();
List<Account> ObjStatePhoneMLSAccount = new List<Account>();
List<Account> ObjFinalAccount = new List<Account>();
if(ObjAccount.size()>1){
for(Account saobj:ObjAccount){
string mlsCode = '';
if(saobj.MLS_Set_Id__c!=null){
mlsCode = saobj.MLS_Set_Id__c;
mlsCode = mlsCode.substring(4,6);
}
if(led.State__c == saobj.BillingState || led.State__c == saobj.ShippingState || led.State__c==mlsCode){
ObjStateAccount.add(saobj);
}
}
System.debug(ObjStateAccount +' KKKKK '+ObjStateAccount.size());
if(ObjStateAccount.size()>1){
String ledPhone = convertFromFormatted(led.Phone__c);
for(Account saobj:ObjStateAccount){
String wphone = '';
if(saobj.Work_Phone__c!=null){wphone = convertFromFormatted(saobj.Work_Phone__c); wphone = wphone.left(3);}
String phne = '';
if(saobj.Phone!=null){phne = convertFromFormatted(saobj.Phone);phne = phne.left(3);}
String hphone = '';
if(saobj.Home_Phone__c!=null){hphone = convertFromFormatted(saobj.Home_Phone__c); hphone = hphone.left(3);}
String m1phone = '';
if(saobj.Mobile1__c!=null){m1phone = convertFromFormatted(saobj.Mobile1__c); m1phone = m1phone.left(3);}
String m2phone = '';
if(saobj.Mobile2_Other__c!=null){m2phone = convertFromFormatted(saobj.Mobile2_Other__c); m2phone = m2phone.left(3);}
if(wphone == led.Phone__c || phne == led.Phone__c || hphone == led.Phone__c || m1phone == led.Phone__c || m2phone == led.Phone__c){
ObjStatePhoneAccount.Add(saobj);
}
}
System.debug(ObjStatePhoneAccount +' KKKKK '+ObjStatePhoneAccount.size());
if(ObjStatePhoneAccount.size()==0){
ObjFinalAccount = ObjStateAccount;
} else{
ObjFinalAccount = ObjStatePhoneAccount;
}
} else{
ObjFinalAccount = ObjStateAccount;
}

} else {
ObjFinalAccount = ObjAccount;
}
if(ObjFinalAccount.size()==0){ //ObjFinalAccount= ObjAccount;
}
for(Account sobj:ObjFinalAccount){
if(finalResult.length()<220){
finalResult = finalResult +' | '+sobj.party_id__c;
}
}
}
           led.Result__c = finalResult;
           LeadList.add(led);
       }
       update LeadList;
    }
public static string convertFromFormatted(string phone)
    {
        system.debug('phone  =='+phone);
        string retPhone = '';
        string strChar;
        for(Integer iCount = 0; iCount < phone.length(); iCount++)
        {
            strChar = phone.subString(iCount, iCount+1);
            system.debug('strChar=='+strChar);
            if(strChar.isNumeric())
                retPhone += strChar;
        }
        
        system.debug('retPhone  =='+retPhone);
        
        if(retPhone.length() > 10)
            retPhone = retPhone.right(10);
        
        return retPhone;
    }    
    global void finish(Database.BatchableContext BC){
    }
}