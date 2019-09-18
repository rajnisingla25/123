/********************************************************************************************
*   @Author :       Vamsi Ch (Brillio Technologies)
*   @Purpose:       Controller To Load and transfom the emailTemplates
*   @Class          Send_Custom_Email
*   @TestClass      Wrap_Send_Custom_Email_Test
*   @JIRA           
*   @CreatedDate:   Aug 23, 2018
*********************************************************************************************
   JIRA No      Date        Modified By         Description                                   
   CRM-4429     Aug-23-2018 Vamsi Ch        Used to send email based on the template selected
*********************************************************************************************

*/
public  class Send_Custom_Email {
    
    //Variables Declaration    
    public String selectedTemplate{get;set;}
    public String selectedCategory{get;set;}
    public Map<String,Map<String,String>> IdToBodyAndSubject{get;set;}    
    public String body{get;set;}    
    public list<LookupQuery__c> lookupQueryList{get;set;}
    public list<EmailTransformation__c> emailTransformationList{get;set;}
    public id currentRecordId{get;set;}
    public string accountId{get;set;}
    public string contactId{get;set;}
    public string baseObject{get;set;}
    public string subject{get;set;}
    public string toAddress{get;set;}
    public string fromAddress{get;set;}
    public string ccAddress{get;set;}
    public string bccAddress{get;set;}
    public List<SelectOption> templateList{get;set;}
    public List<AssetWrapper> assetWrapperList{get; set;}
    public List<AssetWrapper> selectedAssetWrapperList{get; set;}
    public List<MLSWrapper> mlsWrapperList{get; set;}
    public List<MLSWrapper> selectedMLSWrapperList{get; set;}
    public List<string> toAddresses{get;set;}
    public List<string> ccAddresses{get;set;} 
    public List<string> bccAddresses{get;set;}
    public case caseRec{get;set;}
    public string selectedWrapperList{get;set;}
    public string selectedMWrapperList{get;set;}
    public string userid{get;set;}
    public string status{get;set;}
    public string assetType{get;set;}
    public boolean isEmailSuccess{get;set;}
    public boolean noAccountExists{get;set;}
    public boolean noAssetExists{get;set;}
    public boolean noMLSExists{get;set;}
    public user u{get;set;}
    public set<string> KeyPhraseSet{get;set;}
    public boolean isAttached{get;set;}
    public string fileNames{get;set;}
    public list<string> fileNameList {get;set;}
    private transient list<attachment> finalAttachments;
    /********************************************************************************
    Method Name: Constructor
    Description: Dummy Constructor
    Parameters:  ApexPages.StandardController
    ReturnType:  None
    ********************************************************************************/
    public Send_Custom_Email(){
        fileNameList = new list<string>();
        finalAttachments = new list<Attachment>();
        KeyPhraseSet = new Set<string>();
        isAttached = false;
        isEmailSuccess = false;
        noAccountExists = false;
        noAssetExists = false;
        noMLSExists = false;
        userid = Userinfo.getUserId();
        u = [select id,email from user where id=:userid];
        selectedWrapperList='';
        selectedMWrapperList = '';
        assetWrapperList = new List<assetWrapper>();
        mlsWrapperList = new List<MLSWrapper>();
        selectedAssetWrapperList = new List<AssetWrapper>();
        selectedMLSWrapperList = new List<MLSWrapper>();
        caseRec = new Case();
        toAddress='';
        ccAddress='';
        bccAddress='';
        toAddresses = new List<string>();
        ccAddresses = new List<string>();
        bccAddresses = new List<string>();
        
        currentRecordId = apexpages.currentpage().getparameters().get('id');        
        setBaseObject(currentRecordId);
        lookupQueryList = new List<LookupQuery__c>();
        emailTransformationList = new List<EmailTransformation__c>();
        selectedCategory = 'Sales';
        templateList();

    }    
    public Send_Custom_Email(ApexPages.StandardController controller) {    
    }
    
    public void setBaseObject(string currentRecordId){
        system.debug('@@ currentRecordId in setBaseObject'+currentRecordId);
        //Get prefix from record ID 
        if(currentRecordId!=null){
            String myIdPrefix = String.valueOf(currentRecordId).substring(0,3);
            if(myIdPrefix =='500'){
                baseObject = 'Case';
                caseRec = [select id,contactId,contact.email,Incoming_Email_Address__c from case where id =:currentRecordId];                              
            }
            else if(myIdPrefix=='001'){
                baseObject = 'Account';
            }
        }
    }
    public void templateList(){
            isAttached = false;
            List<EmailTemplateSetting__c> EmailTemp = new List<EmailTemplateSetting__c>();
            if(baseObject=='Case'){
                EmailTemp = [SELECT Id, TemplateName__c, EmailHeader__c, EmailBody__c, EmailFooter__c,categories__c
                                                          FROM EmailTemplateSetting__c WHERE Deactivated__c = false
                                                          ORDER BY TemplateName__c ];
            }
            if(baseObject=='Account'){
                EmailTemp = [SELECT Id, TemplateName__c, EmailHeader__c, EmailBody__c, EmailFooter__c,categories__c 
                                                          FROM EmailTemplateSetting__c where Available_for_Account__c = true and Deactivated__c = false
                                                          ORDER BY TemplateName__c ];
            }
            //CRM-5380
            Map<string, Email_template_settings_categories__c> groupCatMap = Email_template_settings_categories__c.getAll();
            Set<String> templateCt = new Set<String>();
            for(Groupmember gm: [select userorgroupid,group.name from groupmember where group.name IN :groupCatMap.keySet() and userorgroupid = :userInfo.getUserId()]){
                Email_template_settings_categories__c ct = groupCatMap.get(gm.group.name);
                List<string> catList = ct.category_names__c.split(',');
                templateCt.addAll(catList);
            }   // End CRM-5380

            templateList = new List<SelectOption>();
            templatelist.add(new SelectOption('--None--','--None--')); 
            IdToBodyAndSubject = new Map<String,Map<String,String>>();
            for(EmailTemplateSetting__c et : EmailTemp){
                 //CRM-5380
                boolean addToList = false;
                if(et.categories__c != null){ 
                    for(String ct: et.categories__c.split(';')){
                        if(templateCt.contains(ct)){
                            addToList = true;
                            break;
                        }
                    }
                } else {
                    addToList = true;
                }
                // End CRM-5380
                if(addToList){
                    if(et.TemplateName__c!=null)
                    templatelist.add(new SelectOption(et.Id,et.templatename__c));
                    Map<String,String> templateDetails = new Map<String,String>();
                    if(et.EmailHeader__c!=null)
                        templateDetails.put('hdr',et.EmailHeader__c);
                    if(et.EmailBody__c!=null)
                       templateDetails.put('body',et.EmailBody__c);
                    if(et.EmailFooter__c!=null)
                       templateDetails.put('ftr',et.EmailFooter__c);               
                    
                    IdToBodyAndSubject.put(et.Id,templateDetails);   
                    system.debug('@@ IdToBodyAndSubject'+IdToBodyAndSubject.get('body'));  
                }
            }
            //return templateList; 
        
    }
    
    /********************************************************************************
    Method Name: QueryTemplateInfo
    Description: Called on EmailTemplate Selection;Sets the transformed emailbody on to the CkEditor
    Parameters:  None
    ReturnType:  None
    ********************************************************************************/
    public void QueryTemplateInfo(){ 
        try{
            isAttached = false;
            if(selectedTemplate!='--None--'){
                body='';
                assetWrapperList = new List<assetWrapper>();
                mlsWrapperList = new List<MLSWrapper>();
                if(IdToBodyAndSubject.get(selectedTemplate).get('hdr')!=null){
                    body = IdToBodyAndSubject.get(selectedTemplate).get('hdr');
                }
                string formattedBody = '';
                List<EmailTemplateSetting__c> etList = [select subject__c,from_Address__c,to_address__c,CC_Address__c from EmailTemplateSetting__c where id=:selectedTemplate];
                if(etList.size()>0){
                    subject = etList[0].subject__c;
                    if(etList[0].from_Address__c!=null){
                        if(etList[0].from_Address__c=='{!User_Email}'){
                           fromAddress =  u.email;
                        }
                        else{
                            fromAddress=etList[0].from_Address__c;
                        }
                    }
                    if(etList[0].to_address__c!=null){                                               
                            toAddress=etList[0].to_address__c;
                        
                    }
                    else{                                      
                        if(caseRec.contact.email!=null){
                            toAddress = caseRec.contact.email;                          
                        }                       
                    }
                    if(etList[0].CC_Address__c!=null){                                               
                            ccAddress=etList[0].CC_Address__c;
                        
                    }
                    
                }
                formattedBody= transformEmailBody(selectedTemplate,baseObject,subject);
                system.debug('@@ formattedBody'+formattedBody);
                if(formattedBody!=''){
                    body+=formattedBody;                  
                }
                else{
                    if(IdToBodyAndSubject.get(selectedTemplate).get('body')!=null){
                        body = IdToBodyAndSubject.get(selectedTemplate).get('body');
                    }
                }                
                if(IdToBodyAndSubject.get(selectedTemplate).get('ftr')!=null){
                    body += IdToBodyAndSubject.get(selectedTemplate).get('ftr');
                }
                system.debug('@@ body'+body);
            }
            else{
               body=''; 
               subject='';
               assetWrapperList = new List<assetWrapper>();
               mlsWrapperList = new List<MLSWrapper>();
            }
        }
        catch(exception e){
            system.debug('@@ in QueryTemplateInfo exception'+e.getMessage());
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.error,e.getMessage()));
        }
    }
    
    /********************************************************************************
    Method Name: transformEmailBody
    Description: To modify the emailbody by populating the merge fields 
    Parameters:  string 
    ReturnType:  string
    ********************************************************************************/    
    public string transformEmailBody(string selectedTemplate,string baseObject,string sub){
        string formattedBody = '';
        try{
            finalAttachments = new list<Attachment>();
            KeyPhraseSet = new Set<string>();
            noAccountExists = false;
            noMLSExists = false;
            noAssetExists = false;
            lookupQueryList = fetchLookupQueries(selectedTemplate);
            emailTransformationList = fetchEmailTransformations(selectedTemplate);            
            if(lookupQueryList.size()>0){
                
                List<case> caseList= new List<case>();
                List<Account> accountList = new List<Account>();
                List<Contact> contactList = new List<Contact>();
                List<Asset> assetList = new List<Asset>();
                List<MLS__c> MLSList = new List<MLS__c>();
                List<User> userList = new List<User>();
                //Querying the base objects Case and Account first
                Map<string,string> objectQueryMap = new Map<string,string>();
                Set<string> objectNameSet = new Set<string>();
                string query;
                for(LookupQuery__c lq: lookupQueryList){
                    objectQueryMap.put(lq.ObjectApiName__c,lq.Query__c);
                    objectNameSet.add(lq.ObjectApiName__c);
                }
                if(baseObject==null){
                    currentRecordId = apexpages.currentpage().getparameters().get('id'); 
                    system.debug('@@ currentRecordId'+currentRecordId);
                    setBaseObject(currentRecordId);
                }
                system.debug('@@ baseObject'+baseObject);
                if(baseObject=='Case'){
                    query = objectQueryMap.get('Case');
                    query+=' where id =:currentRecordId';
                    caseList= (List<Case>) queryRelatedRecords(query);
                    if(caseList.size()>0){
                        if(caseList[0].AccountId!=null){
                            accountId = caseList[0].AccountId;
                            if(objectQueryMap.get('Account')!=null){
                                query = objectQueryMap.get('Account');
                                query+= ' where id =:accountId';
                                AccountList = (List<Account>) queryRelatedRecords(query);
                                system.debug('@@ AccountList'+AccountList);
                                if(accountList.size()==0){
                                    noAccountExists=true;
                                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Info,'The Account does not exist.'));
                                }
                            }
                        }
                        else{
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Info,'The Account does not exist.'));
                        }
                    }
                }
                if(baseObject=='Account'){
                    query = objectQueryMap.get('Account');
                    query+=' where id =:currentRecordId';
                    system.debug('@@ query'+query);
                    system.debug('@@ currentRecordId'+currentRecordId);
                    AccountList = (List<Account>) queryRelatedRecords(query);
                    if(accountList.size()==0){
                        noAccountExists = true;
                    }
                        
                }                                
                system.debug('@@ AccounList'+AccountList);
                //Querying using the lookupqueryRecords
                for(LookupQuery__c lq: lookupQueryList){
                    string objectName = lq.ObjectApiName__c;                     
                    query = lq.Query__c;                                
                    
                    if(objectName=='Contact'){
                        system.debug('@@ in contact3'+baseObject);
                        if(baseObject=='Case'){                            
                            if(caseList.size()>0){
                                if(caseList[0].contactId!=null){                               
                                    contactId = caseList[0].contactId;
                                }
                            }
                        }
                        else if(baseObject=='Account'){
                            system.debug('@@ in account for contact');
                            if(AccountList.size()>0){
                                
                                contactId = [select id from contact where accountId =:AccountList[0].Id limit 1].Id;
                            }
                        }
                        system.debug('@@ contactId'+contactId);
                        query+= ' where id =:contactId';
                        contactList = (List<contact>) queryRelatedRecords(query); 
                        system.debug('@@ in contactList'+contactList);
                    }
                    else if(objectName=='Asset'){
                        system.debug('@@ in Asset acc size'+AccountList.size());
                        if(AccountList.size()>0){
                            accountId = AccountList[0].Id;      
                            status ='Active';
                            assetType= 'Parent';
                            query+= ' where AccountId =:accountId AND status=:status AND Asset_Type__c = :assetType ';
                            AssetList = (List<Asset>) queryRelatedRecords(query);
                            system.debug('@@ AssetList'+AssetList);
                            if(AssetList.size()==0){
                                noAssetExists = true;
                            }
                            for(asset a: AssetList){
                                assetWrapperList.add(new AssetWrapper(a,false)); 
                            }
                        }
                    }
                    else if(objectName=='MLS'){                        
                        system.debug('@@ in mls');
                        if(AccountList.size()>0){
                            accountId = AccountList[0].Id;                                
                            query+= ' where MLS__c =:accountId';                            
                            MLSList = (List<MLS__c>) queryRelatedRecords(query);
                            system.debug('@@ in MLSList'+MLSList.size());
                            if(MLSList.size()==0){
                                noMLSExists = true;
                            }
                            for(MLS__c m: MLSList){
                                system.debug('@@ in forloop m'+m);
                               mlsWrapperList.add(new MLSWrapper(m,false)); 
                               system.debug('@@ after loop');
                            }
                        }
                    }
                    else if(objectName=='User'){                        
                        query+= ' where id =:userid';
                        userList = (List<user>) queryRelatedRecords(query);
                        system.debug('@@ in userList'+userList);
                    }
                    
                }
                //End Querying using the lookupRecords
                
                //Start Transforming the emailBody
                
                formattedBody = IdToBodyAndSubject.get(selectedTemplate).get('body');   
                if(emailTransformationList.size()>0){
                    for(integer i=0;i<emailTransformationList.size();i++){
                        if(emailTransformationList[i].KeyPhrase__c!=null){
                            KeyPhraseSet.add(emailTransformationList[i].KeyPhrase__c);
                        }
                        system.debug('@@ in forloop'+emailTransformationList[i]);
                        string value  ='';
                        if(emailTransformationList[i].Type__c=='Field Name'){
                        if(emailTransformationList[i].ObjectName__c=='Case'){
                            if(caseList.size()>0){
                                system.debug('@@ in case');                                
                                if(caseList[0].get(emailTransformationList[i].Replacewith__c)!=null){
                                    if(emailTransformationList[i].DataType__c!=null && emailTransformationList[i].DataType__c=='Date'){
                                        date dateVal = date.valueOf(caseList[0].get(emailTransformationList[i].Replacewith__c)); 
                                        value = string.valueOf(dateVal);
                                    }
                                    else{
                                        value =string.valueOf(caseList[0].get(emailTransformationList[i].Replacewith__c));
                                    }
                                }
                            }
                        }
                        if(emailTransformationList[i].ObjectName__c=='Account'){
                            if(accountList.size()>0){ 
                                if(accountList[0].get(emailTransformationList[i].Replacewith__c)!=null){
                                    if(emailTransformationList[i].DataType__c!=null && emailTransformationList[i].DataType__c=='Date'){
                                        date dateVal = date.valueOf(caseList[0].get(emailTransformationList[i].Replacewith__c)); 
                                        value = string.valueOf(dateVal);
                                    }
                                    else{
                                        value =string.valueOf(accountList[0].get(emailTransformationList[i].Replacewith__c));
                                    }
                                }
                            }
                        }
                        if(emailTransformationList[i].ObjectName__c=='Contact'){
                            if(contactList.size()>0){
                                if(contactList[0].get(emailTransformationList[i].Replacewith__c)!=null){
                                    if(emailTransformationList[i].DataType__c!=null && emailTransformationList[i].DataType__c=='Date'){
                                        date dateVal = date.valueOf(caseList[0].get(emailTransformationList[i].Replacewith__c)); 
                                        value = string.valueOf(dateVal);
                                    }
                                    else{
                                        value =string.valueOf(contactList[0].get(emailTransformationList[i].Replacewith__c));
                                    }
                                }
                            }
                        }
                        if(emailTransformationList[i].ObjectName__c=='User'){
                            if(userList.size()>0){
                                if(userList[0].get(emailTransformationList[i].Replacewith__c)!=null){
                                    if(emailTransformationList[i].DataType__c!=null && emailTransformationList[i].DataType__c=='Date'){
                                        date dateVal = date.valueOf(caseList[0].get(emailTransformationList[i].Replacewith__c)); 
                                        value = string.valueOf(dateVal);
                                    }
                                    else{
                                        value =string.valueOf(userList[0].get(emailTransformationList[i].Replacewith__c));
                                    }
                                }
                            }
                        }
                        system.debug('@@ value'+value);                
                        formattedBody = formattedBody.replace(emailTransformationList[i].KeyPhrase__c,value);
                        system.debug('@@ sub'+sub);
                        if(sub.contains(emailTransformationList[i].KeyPhrase__c)){
                            if(value!=''){
                                sub  = sub.replace(emailTransformationList[i].KeyPhrase__c,value);
                                subject = sub.replace(emailTransformationList[i].KeyPhrase__c,value);
                            }
                            system.debug('@@ subject'+subject);
                        }
                        }
                    }
                }
                //End Transforming the emailBody                
            }
            return formattedBody;
        }
        catch(exception e){
           system.debug('@@ in exception transformEmailBody'+e.getMessage()); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.error,e.getMessage()));
           return null;
        }
    }
    /********************************************************************************
    Method Name: displayAssets
    Description: To generate a json string from the selected Assets
    Parameters:  None 
    ReturnType:  None
    ********************************************************************************/
    public void displayAssets(){ 
        selectedWrapperList='';
        selectedAssetWrapperList = new List<AssetWrapper>();
        for(AssetWrapper aw : assetWrapperList){
            system.debug('@@ aw'+aw);
            if(aw.selected){
                selectedAssetWrapperList.add(aw);
            }
        }
        system.debug('@@ selectedAssetWrapperList'+selectedAssetWrapperList);
        selectedWrapperList = JSON.serialize(selectedAssetWrapperList);
        system.debug('@@ selectedWrapperList'+selectedWrapperList);        
    }
    
    /********************************************************************************
    Method Name: displayMLS
    Description: To generate a json string from the selected MLS Records
    Parameters:  None 
    ReturnType:  None
    ********************************************************************************/
    public void displayMLS(){ 
        selectedMWrapperList='';
        selectedMLSWrapperList = new List<MLSWrapper>();
        for(MLSWrapper mw : mlsWrapperList){
            system.debug('@@ mw'+mw);
            if(mw.selected){
                selectedMLSWrapperList.add(mw);
            }
        }
        system.debug('@@ selectedMLSWrapperList'+selectedMLSWrapperList);
        selectedMWrapperList = JSON.serialize(selectedMLSWrapperList);
        system.debug('@@ selectedMWrapperList'+selectedMWrapperList);        
    }
    
    /********************************************************************************
    Method Name: queryRelatedRecords
    Description: To query the related records 
    Parameters:  string 
    ReturnType:  List<sObject>
    ********************************************************************************/
    public list<sObject> queryRelatedRecords(string query){
        try{
            return database.query(query);
        }
        catch(exception e){
            system.debug('@@ in queryRelatedRecords exception'+e.getmessage());
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.error,e.getMessage()));
            return null;
        }
    }
    
    
    /********************************************************************************
    Method Name: fetchLookupQueries
    Description: To get the Queries associated with the EmailTemplate
    Parameters:  string 
    ReturnType:  List<LookupQuery__c>
    ********************************************************************************/
    public List<LookupQuery__c> fetchLookupQueries(string selectedTemplate){
        try{
            List<LookupQuery__c> tempLQList = new List<LookupQuery__c>();
            tempLQList = [select Query__c,ObjectApiName__c from LookupQuery__c where Email_Template_Setting__c =:selectedTemplate ];
            system.debug('@@ tempLQList'+tempLQList);
            return tempLQList;
        }
        catch(exception e){
            system.debug('@@ in fetchLookupQueries exception'+e.getmessage());
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.error,e.getMessage()));
            return null;
        }
    }
    
    /********************************************************************************
    Method Name: fetchEmailTransformations
    Description: To get the email transformations associated with the template
    Parameters:  String
    ReturnType:  List<EmailTransformation__c>
    ********************************************************************************/
    public List<EmailTransformation__c> fetchEmailTransformations(string selectedTemplate){
        try{
            List<EmailTransformation__c> tempETList = new List<EmailTransformation__c>();
            tempETList = [select EmailTemplateSetting__c,EmailTemplateSetting__r.subject__c,KeyPhrase__c,ObjectName__c,Replacewith__c,DataType__c,Type__c from EmailTransformation__c where EmailTemplateSetting__c=:selectedTemplate and (Type__c='Field Name' OR Type__c ='Manual') order by Type__c];
            system.debug('@@ tempETList'+tempETList);
            return tempETList;
        }
        catch(exception e){
            system.debug('@@ in fetchEmailTransformations exception'+e.getmessage());
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.error,e.getMessage()));
            return null;
        }
    }
    
    /********************************************************************************
    Method Name: updateAttach
    Description: To display the Attachment uploaded pagemessage
    Parameters:  None
    ReturnType:  None
    ********************************************************************************/
    public void updateAttach(){
       system.debug('@@ in updateAttach fileNames'+fileNames);
        if(fileNames.contains(',')){
            fileNameList = fileNames.split(',');
        }
       system.debug('@@ fileNameList'+fileNameList);
       isAttached=true; 
       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Confirm,'The attachment(s) was uploaded successfully.'));
    }
    /********************************************************************************
    Method Name: removeAttach
    Description: To display the Attachment uploaded pagemessage
    Parameters:  None
    ReturnType:  None
    ********************************************************************************/
    public void removeAttach(){       
        system.debug('@@ in removeAttach fileNames'+fileNames);
        if(fileNames==''){
           fileNames = '';
           fileNameList = new list<string>();
        }
        if(fileNames.contains(',')){
            fileNameList = fileNames.split(',');       
        }
        system.debug('@@ removeAttach fileNameList'+fileNameList);
       //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Confirm,'The attachment(s) was removed successfully.'));
    }
    /********************************************************************************
    Class Name: Wrapper
    Description: Wrapper Class to parse the javscript variable to attachment
    Parameters:  None
    ReturnType:  Pagereference
    ********************************************************************************/ 
    class Wrapper {
        String name, body, ContentType;
    }
    
    /********************************************************************************
    Method Name: sendmail
    Description: To send the email
    Parameters:  None
    ReturnType:  Pagereference
    ********************************************************************************/    
    public void sendmail(){
        try{
            system.debug('@@ fileNames'+fileNames);
            system.debug('@@ KeyPhraseSet'+KeyPhraseSet);
            system.debug('@@ body'+body);
            system.debug('@@ isEmailSuccess'+isEmailSuccess);
            boolean isError = false;
            string unResolvedMergeFields = '';
            for(string kp: KeyPhraseSet){ 
                if(body.contains(kp) ){
                   isError = true;
                   unResolvedMergeFields += kp+',';                 
                }
            }
            system.debug('@@ unResolvedMergeFields'+unResolvedMergeFields);
            if(unResolvedMergeFields!='')
            unResolvedMergeFields = unResolvedMergeFields.removeEnd(',');
            if(isError){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error,'The below Merge fields are missing in the template:<br/>'+unResolvedMergeFields+'<br/> Please resolve them before sending the email')); 
            }
            if(!isError){
            toAddresses = new list<string>();
            ccAddresses = new list<string>();
            bccAddresses = new list<string>();
            system.debug('@@ in sendmail'+toAddress);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            toAddresses.add(toAddress);                                       
            //Splitting comma separated emails to a list            
            
            if(ccAddress.contains(',')){                
                ccAddresses = ccAddress.split(',');
            }
            else{
                if(ccAddress!='')
                ccAddresses.add(ccAddress);
                system.debug('@@ ccAddresses'+ccAddresses);
            }
            
            if(bccAddress.contains(',')){                
                bccAddresses = bccAddress.split(',');
            }
            else{
                if(bccAddress!='')
                bccAddresses.add(bccAddress);
            }                        
            system.debug('@@ bccAddresses'+bccAddresses);
                        
            mail.setToAddresses(toAddresses);
            if(ccAddresses.size()>0){
                system.debug('@@ in ccAddresses'+ccAddresses);
                mail.setCcAddresses(ccAddresses);
            }
            if(bccAddresses.size()>0){
                system.debug('@@ in bccAddress');
                mail.setBccAddresses(bccAddresses);
            }
            
            /*if(caseRec.contactId!=null){
                mail.setTargetObjectId(caseRec.Contactid);
            }*/
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAddress];            
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            mail.setSaveAsActivity(true);
            mail.setSubject(subject);
            mail.setPlainTextBody('');
            mail.setWhatId(currentRecordId);           
            mail.setHtmlBody(body);
            
            finalAttachments = new list<Attachment>(); 
            if(isAttached){
                system.debug('## @@ node'+Apexpages.currentPage().getParameters().get('node'));
                list<wrapper> ls = ( List<Wrapper> )JSON.deserialize( Apexpages.currentPage().getParameters().get('node'), List<Wrapper>.class ) ;        
                System.debug('@@ ======================= ls' + ls );
                for(Wrapper item: ls) {                        
                    finalAttachments.add(new attachment(name=item.name, body=EncodingUtil.base64Decode(item.body),ContentType=item.ContentType));
                }
                system.debug('@@ finalAttachments'+finalAttachments);
                
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();                
                for (Attachment a : finalAttachments){
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(a.Name);
                    efa.setBody(a.Body);
                    fileAttachments.add(efa);
                }
                mail.setFileAttachments(fileAttachments);
            }   
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail}); 
            
            if (results[0].success) {
                isEmailSuccess = true;
                System.debug('The email was sent successfully.');
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Confirm,'The email was sent successfully.'));
                
                EmailMessage emailMsg = new EmailMessage(); // Created a EmailMessage and copy all details.
                string emailToAddress = '';
                if(mail.getToAddresses()!=null){
                    for(string toAddr: mail.getToAddresses()){
                        emailToAddress+=toAddr+';';
                    }
                }
                string emailccAddress = '' ;
                if(mail.getccAddresses()!=null){
                    for(string ccAddr: mail.getccAddresses()){
                        emailccAddress+=ccAddr+';';
                    }
                }
                string emailbccAddress = '';
                if(mail.getbccAddresses()!=null){
                    for(string bccAddr: mail.getbccAddresses()){
                        emailbccAddress+=bccAddr+';';
                    }
                }
                emailToAddress.removeEnd(';');
                emailMsg.ToAddress=emailToAddress;
                emailMsg.ccAddress=emailccAddress;
                emailMsg.BccAddress=emailbccAddress;
                emailMsg.Subject=subject;
                emailMsg.HtmlBody=body;
                emailMsg.ParentId =caseRec.Id; //Attach with the case
                emailMsg.MessageDate = system.now(); 
                //Insert emailMsg;
                
                for (Attachment a : finalAttachments){
                    a.parentId=emailMsg.id;
                }
                insert finalAttachments;
            } 
            else {
                isEmailSuccess = false;
                System.debug('The email failed to send: '+ results[0].errors[0].message);
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error,'The email failed to send: '+ results[0].errors[0].message));
            }
            }
            finalAttachments.clear();
            finalAttachments = new list<attachment>();
            //return ApexPages.currentPage();
        }
        catch(exception e){
            isEmailSuccess = false;
            system.debug('@@ in sendEmail exception'+e.getMessage());
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.error,e.getMessage())); 
            //return null;
        }
    }
    
    public void checkEmailSuccess(){
        system.debug('@@ in checkEmailSuccess'+isEmailSuccess);
        //return isEmailSuccess;
    }
        
              
    public class AssetWrapper {
        public Asset at {get; set;}
        public Boolean selected {get; set;}

        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public AssetWrapper(Asset at,boolean selected) {
            this.at = at;
            this.selected = selected;
        }
    } 

    public class MLSWrapper {
        public MLS__c mlist {get; set;}
        public Boolean selected {get; set;}

        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public MLSWrapper(MLS__c mlist,boolean selected) {
            this.mlist= mlist;
            this.selected = selected;
        }
    } 
}