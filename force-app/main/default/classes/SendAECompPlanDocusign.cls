Global with sharing class SendAECompPlanDocusign {    
    
    public static DocuSignAPI.Tab ReturnTab(String tbType,String val,Integer recID,Integer docId, String anchorTabStr, String Fontcolor){
        DocuSignAPI.Tab tbb = new DocuSignAPI.Tab();
        // CRM-5788, start
        If(string.isNotBlank(val) && val.containsAny('$%') && !val.contains('.')){
            val = val.startsWith('$') ? val+'.00' : (val.endsWith('%') ? val.replace(' ','').replace('%', '.00%') : val);
        } // CRM-5788, ends.
        tbb.Type_x                         = tbType;
        tbb.value                          = val != null? val.unescapejava() : '' ;
        // tbb.Bold = true; 
        //tbb.FontSize = 'Size16';
        tbb.FontColor = Fontcolor;
        tbb.RecipientID                    = recID;
        tbb.DocumentID                     = docId;
        tbb.CustomTabRequired  = false;
        tbb.AnchorTabItem                  = new DocuSignAPI.AnchorTab();        
        tbb.AnchorTabItem.AnchorTabString  = anchorTabStr;
        
        return tbb;
    }
    
    
    @Future(callout=true)
    Global static void SendNow(set<Id> listQuotaIds, Boolean sendToFinance){
        system.debug('listQuotaIds===>'+listQuotaIds);
        String envelopeId;
        Integer I = 0;        
        Blob SignDocument= Blob.valueOf(' ');
        string shortname;
        Comp_Plan_Docusign_Cred__c  DocSignCredentials = Comp_Plan_Docusign_Cred__c.getAll().values();//Comp_Plan_Docusign_Cred__c
        if(DocSignCredentials == null){
        	System.debug('Excpetion | Error : Docusign Credential for *CompensationPlan* Not Found in Setting.');
            Error__c logerror               = new Error__c();
            logerror.Name                   = 'Docusign Credential Not Found';
            logerror.Entity_Id__c           = 'CompensationPlan';
            logerror.Error_Description__c   = 'Docusign Credential for *CompensationPlan* Not Found in Setting.';
            logerror.Interface_Name__c      = 'DocuSign';
            insert logerror;
        	return;
        }
        String accountId        = DocSignCredentials.AccountId__c;
        String userId           = DocSignCredentials.UserId__c;
        String password         = DocSignCredentials.Password__c;
        String integratorsKey   = DocSignCredentials.IntegratorsKey__c;
        String webServiceUrl    = DocSignCredentials.WebServiceUrl__c;
        //sendToFinance = true;
        DocuSignAPI.APIServiceSoap dsApiSend = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        dsApiSend.timeout_x = 120000;
        set<string> nonAETeamNames = new set<string>{'managers team'};
        set<string> statusesToIgnore = new set<string>{'Completed', 'Declined', 'Void', 'Voided'};       
        map<id, Quota__c> mapQuotas = new map<id, Quota__c>([
            SELECT Id, Name, User_Team__c, Comp_Plan_Sent__c,Quota_StartDate__c, Quota_EndDate__c, User__r.Name, User__r.Email,User__r.Title,Employee_Number__c, User__r.UserRole.Name
            ,Target_Amount__c, Target_Amount_Renewal__c, Period_Name__c, Quota_Owner_Name__c,Collection_Target_Amount__c
            ,Period_Name__r.Agent_Sigh_In_AE__c, Period_Name__r.Agent_Asset_Owner__c, Period_Name__r.Sigh_In_AE__c, Period_Name__r.Asset_Owner__c
            ,(SELECT Id, Product_Name1__c, Product_Family__c, Sales__c FROM Quota_Products__r)
            ,(SELECT Id, dsfs__DocuSign_Envelope_ID__c, dsfs__Envelope_Status__c FROM DocuSign_Status__r WHERE dsfs__Envelope_Status__c NOT IN :statusesToIgnore)
            FROM Quota__c
            WHERE Id in :listQuotaIds]);
       
        system.debug('mapQuotas=='+mapQuotas);
        map<string, map<string,map<string,Payout__c>>> mapTeamPayouts = new map<string, map<string,map<string,Payout__c>>>();
        set<string> userTeamNames = new set<string>();
        set<Id> periodIds = new set<Id>();
        set<String> quotaUserName = new Set<String>();
        Set<String> setCollectionTeamNames = new Set<String>();
        for(CollectionTeams__mdt collTeamName : [Select MasterLabel,DeveloperName,Team_Name__c From CollectionTeams__mdt]){
        	if(string.isNotBlank(collTeamName.Team_Name__c)){
            	setCollectionTeamNames.add(collTeamName.Team_Name__c.trim().toLowerCase());
        	}
        }
        for(Quota__c q : mapQuotas.values()){
            string periodUserTeamKey = '';
            if(q.Period_Name__c != null){
                periodIds.add(q.Period_Name__c);
            }
            system.debug('quserteam=>'+q.User_Team__c);
            if(String.isNotBlank(q.User_Team__c)){
                if(setCollectionTeamNames.contains(q.User_Team__c.toLowerCase())){
                    userTeamNames.add(q.User_Team__c.toLowerCase());
                }
                else if(nonAETeamNames.contains(q.User_Team__c.toLowerCase()) && q.User__r != null && String.isNotBlank(q.User__r.Name)){
                    userTeamNames.add(q.User__r.Name.toLowerCase());
                }
                else{
                  userTeamNames.add(q.User_Team__c.toLowerCase());
                }
            }
        }
        system.debug('periodIds===>'+periodIds);
        system.debug('userTeamNames===>'+userTeamNames);
        map<id,Period__c> mapPeriods = new map<id,Period__c>([
            SELECT Id
            ,(SELECT Id,Name,Tier_Number__c, Low_Level__c, High_Level__c, RecordType.Name, Connection_SM_for_Co_Brokerage__c,Commissionable__c FROM Payouts__r WHERE RecordType.Name in :userTeamNames Order by Low_Level__c ASC)
            ,(SELECT Id,Tier_Number__c, Low_Level__c, High_Level__c FROM Payout_Tiers__r Order by Low_Level__c ASC)
            FROM Period__c
            WHERE Id IN :periodIds
        ]);
        system.debug('mapPeriods=='+mapPeriods);
        for(Period__c periodRec : mapPeriods.values()){
            system.debug('Payouts__r24=='+periodRec.Payouts__r.size());
            system.debug('Payout_Tiers__r6=='+periodRec.Payout_Tiers__r.size());
            for(Payout__c p : periodRec.Payouts__r){
                string periodIdTeamNameKey = periodRec.Id + p.RecordType.Name.toLowerCase();
                system.debug('periodIdTeamNameKey=='+periodIdTeamNameKey);    
                map<String, map<string,Payout__c>> mapTierWisePayouts = mapTeamPayouts.get(periodIdTeamNameKey);
                if(mapTierWisePayouts == null){
                    mapTierWisePayouts = new map<String, map<string,Payout__c>>();
                }
                //CRM-5589
                string tier = '';
                if(string.isNotBlank(p.Tier_Number__c)){
                    tier = p.Tier_Number__c.toLowerCase();
                } else { 
                    for(Payout_Tier__c pt : periodRec.Payout_Tiers__r){
                        system.debug('pt=='+ pt);
                        if(string.isNotBlank(pt.Tier_Number__c) && pt.Low_Level__c == p.Low_Level__c && pt.High_Level__c == p.High_Level__c){
                            tier = pt.Tier_Number__c.toLowerCase();
                            break;
                        }
                    }
                }
                if(string.isBlank(tier)){
                    continue;
                }
                map<String, Payout__c> mapSaleQualifierPayouts = mapTierWisePayouts.get(tier);
                if(mapSaleQualifierPayouts == null){
                    mapSaleQualifierPayouts = new map<string, Payout__c>();
                }
                if(p.Name.equalsIgnoreCase('New sale with qualifier')){
                    mapSaleQualifierPayouts.put('nwq', p);
                } else if(p.Name.equalsIgnoreCase('New sale without qualifier')){
                    mapSaleQualifierPayouts.put('nwoq', p);
                } else if(p.Name.equalsIgnoreCase('Renewal with qualifier')){
                    mapSaleQualifierPayouts.put('rwq', p);
                } else if(p.Name.equalsIgnoreCase('Renewal without qualifier')){
                    mapSaleQualifierPayouts.put('rwoq', p);
                }
                system.debug('mapSaleQualifierPayouts=='+mapSaleQualifierPayouts);
                mapTierWisePayouts.put(tier, mapSaleQualifierPayouts);
                system.debug('mapTierWisePayouts=='+mapTierWisePayouts);
                mapTeamPayouts.put(periodIdTeamNameKey, mapTierWisePayouts);
            }
        }
        system.debug('mapTeamPayouts=='+mapTeamPayouts.size()); 
        system.debug('mapTeamPayouts=='+mapTeamPayouts);        
         
        list<string> lstProsoftProdNames = new list<string>();
        list<Product_Family__c> customProdFamilyNames = Product_Family__c.getall().values();
        for(Product_Family__c prodFam :  customProdFamilyNames){
            if(string.isNotBlank(prodFam.Family_Name__c) && 'Prosoft'.equalsIgnoreCase(prodFam.Family_Name__c)){
                lstProsoftProdNames.add(prodFam.Name);
            }
        }
        // string strProsoftProdNames = String.join(lstProsoftProdNames, '\n');
        
        //Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ userId 
            +'</Username><Password>' + password 
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey></DocuSignCredentials>';
        
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication',auth);
        List<dsfs__DocuSign_Status__c> insertStatuslist = new  List<dsfs__DocuSign_Status__c>();
        List<Error__c> logErroslist = new List<Error__c>();
        List<Quota__c> UpdateQuotalist = new List<Quota__c>();
               
        system.debug('size==>'+mapQuotas.size());
        for(Quota__c q : mapQuotas.values()){
            if(String.isNotBlank(q.User_Team__c)){
                string periodIdTeamNameKey = q.Period_Name__c + (nonAETeamNames.contains(q.User_Team__c.toLowerCase()) ? q.User__r.Name.toLowerCase() : q.User_Team__c.toLowerCase());
                system.debug('periodIdTeamNameKey-->'+periodIdTeamNameKey);
                map<String, map<string,Payout__c>> mapTierWisePayouts = mapTeamPayouts.get(periodIdTeamNameKey);
                system.debug('mapTierWisePayouts-->'+mapTierWisePayouts);
                if(mapTierWisePayouts == null || mapTierWisePayouts.size() < 1){  //CRM-5589
                  continue;
                }
                try{
                    system.debug('Team====>' + q.User_Team__c.toLowerCase());
                    system.debug('q==' + q);
                    system.debug('q==' + q.Collection_Target_Amount__c);
                    system.debug('sendToFinance==>'+ sendToFinance);
                    if(!nonAETeamNames.contains(q.User_Team__c.ToLowerCase()) && !setCollectionTeamNames.contains(q.User_Team__c.ToLowerCase())){
                      insertStatuslist.add(sendForQuota(accountId, q, mapTierWisePayouts, dsApiSend, lstProsoftProdNames,sendToFinance));
                    }                                        
                    else if(nonAETeamNames.contains(q.User_Team__c.toLowerCase()) && q.Collection_Target_Amount__c != null && q.Collection_Target_Amount__c > 0){
                    	insertStatuslist.add(sendForCollectionManagersQuota(accountId, q, mapTierWisePayouts, dsApiSend, lstProsoftProdNames,sendToFinance));    
                    }
                    else if(setCollectionTeamNames.contains(q.User_Team__c.toLowerCase())){
                    	insertStatuslist.add(sendForCollectionRepsQuota(accountId, q, mapTierWisePayouts, dsApiSend, lstProsoftProdNames,sendToFinance));    
                    }
                    else if(nonAETeamNames.contains(q.User_Team__c.toLowerCase())){
                      insertStatuslist.add(sendForManagersQuota(accountId, q, mapTierWisePayouts, dsApiSend, lstProsoftProdNames,sendToFinance));   
                    }
                    system.debug('insertStatuslist='+insertStatuslist+'q='+q.User_Team__c);
                    for(dsfs__DocuSign_Status__c existingDsStatus : q.DocuSign_Status__r){
                        //existingDsStatus.dsfs__Envelope_Status__c = 'Void';
                        VoidDocusign(existingDsStatus.dsfs__DocuSign_Envelope_ID__c, auth, webServiceUrl, accountId);
                       // insertStatuslist.add(existingDsStatus);
                    }
                    //Quota__c Quotaa = new Quota__c(Id =q.Id, Send_Comp_Plan__c = false, Send_Comp_Plan_To__c = '',Comp_Plan_Sent__c = DateTime.Now());
                    Quota__c Quotaa = new Quota__c();
                    Quotaa.Id = q.Id;
                    Quotaa.Send_Comp_Plan__c = false;
                    Quotaa.Send_Comp_Plan_To__c = '';
                    if(!sendToFinance)
                    	Quotaa.Comp_Plan_Sent__c = DateTime.Now();
                    UpdateQuotalist.add(Quotaa);
                    system.debug('UpdateQuotalist==>'+UpdateQuotalist);
                } catch ( CalloutException error) {
                    system.debug('error '+ error);
                    envelopeId = 'Exception - ' + error;
                    Error__c logerror               = new Error__c();
                    logerror.Name                   = q.Id;
                    logerror.Entity_Id__c           = 'AEwQualCompensationPlan';
                    logerror.Error_Description__c   = string.valueof(error);
                    logerror.Interface_Name__c      = 'DocuSign';
                    logErroslist.add(logerror);
                    
                }  
            }
        }
        system.debug('insertStatuslist=='+insertStatuslist.size());
        system.debug('insertStatuslist=='+insertStatuslist);
        upsert insertStatuslist;
        
        system.debug('UpdateQuotalist=='+UpdateQuotalist.size());
        system.debug('UpdateQuotalist=='+UpdateQuotalist);
        update UpdateQuotalist;
        if(logErroslist.size()>0)
            insert logErroslist;
    }
    
    public static  dsfs__DocuSign_Status__c sendForCollectionManagersQuota(string accountId , Quota__c q, map<String, map<string,Payout__c>> mapTierWisePayouts, DocuSignAPI.APIServiceSoap dsApiSend,  list<string> lstProsoftProdNames, Boolean sendToFinance ){        
        String envelopeId;
        Integer I = 0;        
        Blob SignDocument = Blob.valueOf(' ');
        string shortname;
        system.debug('in sendForCollectionManagersQuota');
        
		SignDocument = [SELECT Body FROM Document WHERE Name = 'CollectionManagersCompensationPlanTemplate'].Body;
        
        
        DateTime dt = q.Quota_EndDate__c;
        String monthName = dt.format('MMMMM');
        Integer year = dt.year();
        System.debug('Month Name : ' + monthName);
        
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject    = sendToFinance ? 'Sample Docusign - '+ q.User__r.Name +' - '+  monthName + ' ' + year+ ' (Finance Use Only)': 'Please sign the compensation plan for '+ monthName + ' ' + year ;   //CRM-5688
        envelope.EmailBlurb = 'Review all compensation plan in the form before signing';
        envelope.BrandId=System.Label.CompPlan_DocuSign_Brand_ID;
        
        envelope.AccountId  = accountId;
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID                     = 1;
        document.pdfBytes               = EncodingUtil.base64Encode(SignDocument);
        document.Name                   = 'compensation_plan';
        document.FileExtension          = '.doc';
        envelope.Documents              = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document     = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0]  = document;
        System.debug('======>>document====>>'+document);
        
        
        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
        
        recipient.ID            = 1;
        recipient.Type_x        = 'Signer';
        recipient.RoutingOrder  = 1;
        //'pravin.sonawane.contractor@move.com'; 'janaki.chilakamarthi@move.com';//baswaraj.patil.contractor@move.com';
        system.debug('sendToFinanceInManagerQuota=='+sendToFinance);
        recipient.Email         = sendToFinance ? UserInfo.getUserEmail() : q.User__r.Email; 
        //recipient.Email = 'janaki.chilakamarthi@move.com';
        recipient.UserName      = q.Quota_Owner_Name__c;
        recipient.SignerName    = q.Quota_Owner_Name__c;
        System.debug('@@');
        
        
        // This setting required or you see the error:
        recipient.RequireIDLookup = false;      
        System.debug('@@@');
        envelope.Recipients                 = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient       = new DocuSignAPI.Recipient[1];
        envelope.Recipients.Recipient[0]    = recipient;
                
        envelope.Tabs                       = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab                   = new DocuSignAPI.Tab[100];
        String FontSize = 'Size9';
        
        
        envelope.Tabs.Tab.add(ReturnTab('Custom',q.Quota_Owner_Name__c,1,1,'QuotaUserName', 'Black'));
        
        envelope.Tabs.Tab.add(ReturnTab('Custom','$'+ (q.Collection_Target_Amount__c != null ? (string.valueof(((Decimal)q.Collection_Target_Amount__c).setScale(2).format())) : String.valueof(0.00)) ,1,1,'QuotaCollectionTargetAmt','Black'));
		
		envelope.Tabs.Tab.add(ReturnTab('Custom',q.User_Team__c ,1,1,'quotaUserTeam', 'Black'));
        System.debug('@@@@');
           
        Integer t = 0;
        if(!test.isrunningtest())
         t = 13 - mapTierWisePayouts.size();
              
        System.debug('@@@@@$');
        for(; t <= 12; t++){
            Integer ti = t + mapTierWisePayouts.size() - 12;
            //Ar1from   Ar1to   T1Nq    T1Nwoq  T1Rq    T1Rwoq
            Integer idxMultiplier = (ti - 1) * 6;
            if(mapTierWisePayouts.containsKey('tier '+ti) && mapTierWisePayouts.get('tier '+ti) != null){
                map<string,Payout__c> mapSQPayout = mapTierWisePayouts.get('tier '+ti);
                system.debug('mapSQPayout=='+mapSQPayout);
                Payout__c pr = mapSQPayout.get('nwoq');
                system.debug('pr=='+pr);
                
                envelope.Tabs.Tab.add(ReturnTab('Custom', string.valueOf(pr.Low_Level__c) + '%' ,1,1,('Ar'+t+'from'),'Black'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', ( ti == mapTierWisePayouts.size() ? 'Greater' : string.valueOf(pr.High_Level__c) + '%') ,1,1,('Ar'+t+'to'),'Black'));
                             
                if(mapSQPayout.get('nwoq') != null){
                    pr = mapSQPayout.get('nwoq');
                    envelope.Tabs.Tab.add(ReturnTab('Custom', string.valueOf(pr.Commissionable__c) + '%' ,1,1,('T'+t+'wqRate_n'),'Black'));
                    if(pr.High_Level__c == 100.00){
                    	Decimal MonthlyTargetIncentive = (q.Collection_Target_Amount__c * pr.Commissionable__c)/100;
                        envelope.Tabs.Tab.add(ReturnTab('Custom','$'+ string.valueof(MonthlyTargetIncentive.setScale(2).format()) ,1,1,'MonthlyTargetIncentive','Black'));
                    }
                    
                } else{
                    envelope.Tabs.Tab.add(ReturnTab('Custom', '' ,1,1,('T'+t+'wqRate_n'),'Black'));
                }
                
                
                Payout__c pr1 = mapSQPayout.get('nwq');
                if(ti == mapTierWisePayouts.size()){
                 	envelope.Tabs.Tab.add(ReturnTab('Custom', string.valueOf(pr1.Commissionable__c) + '%' ,1,1,('TnwqRate'),'Black'));   
                }
                
            }
            else{
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('Ar'+t+'from'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('Ar'+t+'to'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('T'+t+'wqRate_n'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('TnwqRate'), 'White'));
            }
        }
        
       
          System.debug('@@@@@@');
        envelope.Tabs.Tab.add(ReturnTab('SignHere', 'Somevalue' ,1,1,'signaturetag','Black'));
        
        
        envelope.Tabs.Tab.add(ReturnTab('InitialHere', 'Somevalue' ,1,1,'Initialr','Black'));
        envelope.Tabs.Tab.add(ReturnTab('DateSigned', 'Somevalue' ,1,1,'Dater','Black'));
        System.debug('document===>>'+document);
        
        Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
            6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October',
            11=>'November', 12=>'December'};
                
        String startMonth   = '';
        String endMonth = '';
        if(!test.isrunningtest()){
            startMonth = monthNameMap.get(((Date)q.Quota_StartDate__c).month()) + ' '+ ((Date)q.Quota_StartDate__c).day() +', ' + ((Date)q.Quota_StartDate__c).year();
            endMonth = monthNameMap.get(((Date)q.Quota_EndDate__c).month()) + ' '+ ((Date)q.Quota_EndDate__c).day() +', ' +  ((Date)q.Quota_EndDate__c).year();
        }                                                                     
        envelope.Tabs.Tab.add(ReturnTab('Custom', startMonth ,1,1,'QuotaStartDate','Black'));
               
        envelope.Tabs.Tab.add(ReturnTab('Custom', endMonth ,1,1,'QuotaEndDate','Black'));
        
        // Default values
        Integer reminderDelay=1, reminderFrequency=7, expireWarn=7, expireAfter=30;
        DocuSignAPI.Notification Notification = new DocuSignAPI.Notification();
        DocuSignAPI.Reminders Reminders = new DocuSignAPI.Reminders();
        Reminders.ReminderEnabled = true;
        Reminders.ReminderDelay = reminderDelay;
        Reminders.ReminderFrequency = reminderFrequency;
        Notification.UseAccountDefaults = false;
        Notification.Reminders = Reminders;
        
    System.debug('@@@@@@@');        
        DocuSignAPI.Expirations  Expirations  = new DocuSignAPI.Expirations();      
        Expirations.ExpireEnabled = true;
        Expirations.ExpireWarn = expireWarn;
        Expirations.ExpireAfter = expireAfter;
        Notification.Expirations = Expirations;
        
        envelope.Notification = Notification;
        
        //sending Envelope
        system.debug('Sending.....');
        DocuSignAPI.EnvelopeStatus EnvStatus = dsApiSend.CreateAndSendEnvelope(envelope);
        if ( !Test.isRunningTest() ){
            envelopeId = EnvStatus.EnvelopeID;
        } else{
            envelopeId = '12345';
        }
        System.debug('EnvStatus====='+EnvStatus); 
        //attaching DocuSign status object to Quota object
        
        dsfs__DocuSign_Status__c DocStatus      = new dsfs__DocuSign_Status__c();
        DocStatus.dsfs__DocuSign_Envelope_ID__c = envelopeId;
        DocStatus.dsfs__Sender__c               = userinfo.getusername();
        DocStatus.dsfs__Sender_Email__c         = userinfo.getuseremail();
        DocStatus.dsfs__Subject__c              = envelope.Subject;
        DocStatus.Quota__c                      = q.Id;
        
        if ( !Test.isRunningTest() ){
            DocStatus.dsfs__Envelope_Status__c  = EnvStatus.status;
        } else{
            DocStatus.dsfs__Envelope_Status__c  = 'Sent';
        }           
        return DocStatus;
    }
    
    public static  dsfs__DocuSign_Status__c sendForCollectionRepsQuota(string accountId , Quota__c q, map<String, map<string,Payout__c>> mapTierWisePayouts, DocuSignAPI.APIServiceSoap dsApiSend,  list<string> lstProsoftProdNames, Boolean sendToFinance ){        
        String envelopeId;
        Integer I = 0;        
        Blob SignDocument = Blob.valueOf(' ');
        string shortname;
        system.debug('in sendForCollectionRepsQuota');
        
		SignDocument = [SELECT Body FROM Document WHERE Name = 'CollectionRepsCompensationPlanTemplate'].Body;
        
        
        DateTime dt = q.Quota_EndDate__c;
        String monthName = dt.format('MMMMM');
        Integer year = dt.year();
        System.debug('Month Name : ' + monthName);
        
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject    = sendToFinance ? 'Sample Docusign - '+ q.User__r.Name +' - '+  monthName + ' ' + year+ ' (Finance Use Only)': 'Please sign the compensation plan for '+ monthName + ' ' + year ;   //CRM-5688
        envelope.EmailBlurb = 'Review all compensation plan in the form before signing';
        envelope.BrandId=System.Label.CompPlan_DocuSign_Brand_ID;
        
        envelope.AccountId  = accountId;
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID                     = 1;
        document.pdfBytes               = EncodingUtil.base64Encode(SignDocument);
        document.Name                   = 'compensation_plan';
        document.FileExtension          = '.doc';
        envelope.Documents              = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document     = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0]  = document;
        System.debug('======>>document====>>'+document);
        
        
        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
        
        recipient.ID            = 1;
        recipient.Type_x        = 'Signer';
        recipient.RoutingOrder  = 1;
        //'pravin.sonawane.contractor@move.com'; 'janaki.chilakamarthi@move.com';//baswaraj.patil.contractor@move.com';
        system.debug('sendToFinanceInManagerQuota=='+sendToFinance);
        recipient.Email         = sendToFinance ? UserInfo.getUserEmail() : q.User__r.Email; 
        //recipient.Email = 'janaki.chilakamarthi@move.com';
        recipient.UserName      = q.Quota_Owner_Name__c;
        recipient.SignerName    = q.Quota_Owner_Name__c;
        System.debug('@@');
        
        
        // This setting required or you see the error:
        recipient.RequireIDLookup = false;      
        System.debug('@@@');
        envelope.Recipients                 = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient       = new DocuSignAPI.Recipient[1];
        envelope.Recipients.Recipient[0]    = recipient;
                
        envelope.Tabs                       = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab                   = new list<DocuSignAPI.Tab>();
        String FontSize = 'Size9';
        
        
        envelope.Tabs.Tab.add(ReturnTab('Custom',q.Quota_Owner_Name__c,1,1,'QuotaUserName', 'Black'));
        
        string QuotaCollectionTargetAmt = q.Collection_Target_Amount__c != null ? '$'+(((Decimal)q.Collection_Target_Amount__c).setScale(2)).format() : '$0.00'; 
        system.debug('QuotaCollectionTargetAmt=='+QuotaCollectionTargetAmt);
        envelope.Tabs.Tab.add(ReturnTab('Custom',QuotaCollectionTargetAmt ,1,1,'QuotaCollectionTargetAmt','Black'));
		
		envelope.Tabs.Tab.add(ReturnTab('Custom',q.User__r.UserRole.Name,1,1,'QuotaUserRoleName', 'Black'));
        System.debug('@@@@');
           
        Integer t = 0;
        //if(!test.isrunningtest())
         t = 13 - mapTierWisePayouts.size();
              
        System.debug('@@@@@$');
        for(; t <= 12; t++){
            Integer ti = t + mapTierWisePayouts.size() - 12;
            //Ar1from   Ar1to   T1Nq    T1Nwoq  T1Rq    T1Rwoq
            Integer idxMultiplier = (ti - 1) * 6;
            if(mapTierWisePayouts.containsKey('tier '+ti) && mapTierWisePayouts.get('tier '+ti) != null){
                map<string,Payout__c> mapSQPayout = mapTierWisePayouts.get('tier '+ti);
                system.debug('mapSQPayout=='+mapSQPayout);
                Payout__c pr = mapSQPayout.get('nwoq');
                system.debug('pr=='+pr);
                if(mapSQPayout.get('nwoq') != null){
                    pr = mapSQPayout.get('nwoq');
                    
                    envelope.Tabs.Tab.add(ReturnTab('Custom', string.valueOf(pr.Low_Level__c) + '%' ,1,1,('Ar'+t+'from'),'Black'));
                    envelope.Tabs.Tab.add(ReturnTab('Custom', ( ti == mapTierWisePayouts.size() ? 'Greater' : string.valueOf(pr.High_Level__c) + '%') ,1,1,('Ar'+t+'to'),'Black'));
                             
                    envelope.Tabs.Tab.add(ReturnTab('Custom', string.valueOf(pr.Commissionable__c) + '%' ,1,1,('T'+t+'wqRate_n'),'Black'));
                    if(pr.High_Level__c == 100.00){
                    	String MonthlyTargetIncentive = q.Collection_Target_Amount__c != null ? '$'+((Decimal)(q.Collection_Target_Amount__c * pr.Commissionable__c)/100).setScale(2).format() : '$0.00';
                        system.debug('MonthlyTargetIncentive=='+MonthlyTargetIncentive);
                        envelope.Tabs.Tab.add(ReturnTab('Custom', MonthlyTargetIncentive ,1,1,'MonthlyTargetIncentive','Black'));
                    }                    
                } 
                else{
                    envelope.Tabs.Tab.add(ReturnTab('Custom', '' ,1,1,('T'+t+'wqRate_n'),'Black'));
                }
                
                
                Payout__c pr1 = mapSQPayout.get('nwq');
                if(ti == mapTierWisePayouts.size()){
                 	envelope.Tabs.Tab.add(ReturnTab('Custom', string.valueOf(pr1.Commissionable__c) + '%' ,1,1,('TnwqRate'),'Black'));   
                }
                
            }
            else{
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('Ar'+t+'from'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('Ar'+t+'to'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('T'+t+'wqRate_n'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('TnwqRate'), 'White'));
            }
        }
        
       
          System.debug('@@@@@@');
        envelope.Tabs.Tab.add(ReturnTab('SignHere', 'Somevalue' ,1,1,'signaturetag','Black'));
        
        
        envelope.Tabs.Tab.add(ReturnTab('InitialHere', 'Somevalue' ,1,1,'Initialr','Black'));
        envelope.Tabs.Tab.add(ReturnTab('DateSigned', 'Somevalue' ,1,1,'Dater','Black'));
        System.debug('document===>>'+document);
        
        Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
            6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October',
            11=>'November', 12=>'December'};
                
        String startMonth   = '';
        String endMonth = '';
        if(!test.isrunningtest()){
            startMonth = monthNameMap.get(((Date)q.Quota_StartDate__c).month()) + ' '+ ((Date)q.Quota_StartDate__c).day() +', ' + ((Date)q.Quota_StartDate__c).year();
            endMonth = monthNameMap.get(((Date)q.Quota_EndDate__c).month()) + ' '+ ((Date)q.Quota_EndDate__c).day() +', ' +  ((Date)q.Quota_EndDate__c).year();
        }
        envelope.Tabs.Tab.add(ReturnTab('Custom', startMonth ,1,1,'QuotaStartDate','Black'));
               
        envelope.Tabs.Tab.add(ReturnTab('Custom', endMonth ,1,1,'QuotaEndDate','Black'));
        
        // Default values
        Integer reminderDelay=1, reminderFrequency=7, expireWarn=7, expireAfter=30;
        DocuSignAPI.Notification Notification = new DocuSignAPI.Notification();
        DocuSignAPI.Reminders Reminders = new DocuSignAPI.Reminders();
        Reminders.ReminderEnabled = true;
        Reminders.ReminderDelay = reminderDelay;
        Reminders.ReminderFrequency = reminderFrequency;
        Notification.UseAccountDefaults = false;
        Notification.Reminders = Reminders;
        
    System.debug('@@@@@@@');        
        DocuSignAPI.Expirations  Expirations  = new DocuSignAPI.Expirations();      
        Expirations.ExpireEnabled = true;
        Expirations.ExpireWarn = expireWarn;
        Expirations.ExpireAfter = expireAfter;
        Notification.Expirations = Expirations;
        
        envelope.Notification = Notification;
        
        //sending Envelope
        system.debug('Sending.....');
        DocuSignAPI.EnvelopeStatus EnvStatus = dsApiSend.CreateAndSendEnvelope(envelope);
        if ( !Test.isRunningTest() ){
            envelopeId = EnvStatus.EnvelopeID;
        } else{
            envelopeId = '12345';
        }
        System.debug('EnvStatus====='+EnvStatus); 
        //attaching DocuSign status object to Quota object
        
        dsfs__DocuSign_Status__c DocStatus      = new dsfs__DocuSign_Status__c();
        DocStatus.dsfs__DocuSign_Envelope_ID__c = envelopeId;
        DocStatus.dsfs__Sender__c               = userinfo.getusername();
        DocStatus.dsfs__Sender_Email__c         = userinfo.getuseremail();
        DocStatus.dsfs__Subject__c              = envelope.Subject;
        DocStatus.Quota__c                      = q.Id;
        
        if ( !Test.isRunningTest() ){
            DocStatus.dsfs__Envelope_Status__c  = EnvStatus.status;
        } else{
            DocStatus.dsfs__Envelope_Status__c  = 'Sent';
        }           
        return DocStatus;
    }
    
    public static  dsfs__DocuSign_Status__c sendForQuota(string accountId , Quota__c q, map<String, map<string,Payout__c>> mapTierWisePayouts, DocuSignAPI.APIServiceSoap dsApiSend,  list<string> lstProsoftProdNames, Boolean sendToFinance ){        
        String envelopeId;
        Integer I = 0;        
        Blob SignDocument = Blob.valueOf(' ');
        string shortname;
        system.debug('in sendForQuota');
        if(q.Quota_Products__r.size() > 0){
            SignDocument = [SELECT Body FROM Document WHERE Name = 'AEwithQualifierCompensationPlanTemplate'].Body;
        }else{
            SignDocument = [SELECT Body FROM Document WHERE Name = 'AEwithoutQualifierCompensationPlanTemplate'].Body;  //AEwithoutQualifierCompensationPlanTemplatetest
            system.debug('at without compansation template');
        }
        
        DateTime dt = q.Quota_EndDate__c;
        String monthName = dt.format('MMMMM');
        Integer year = dt.year();
        System.debug('Month Name : ' + monthName);
        
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        
        envelope.Subject    = sendToFinance ? 'Sample Docusign - '+ q.User_Team__c +' - '+  monthName + ' ' + year+ ' (Finance Use Only)' : 'Please sign the compensation plan for '+ monthName + ' ' + year ;//CRM-5688
        envelope.EmailBlurb = 'Review all compensation plan in the form before signing';
        envelope.BrandId = System.Label.CompPlan_DocuSign_Brand_ID;
        
        envelope.AccountId  = accountId;
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID                     = 1;
        document.pdfBytes               = EncodingUtil.base64Encode(SignDocument);
        document.Name                   = 'compensation_plan';
        document.FileExtension          = '.doc';
        envelope.Documents              = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document     = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0]  = document;
        System.debug('======>>document====>>'+document);
        System.debug('@@');
        
        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
        
        recipient.ID            = 1;
        recipient.Type_x        = 'Signer';
        recipient.RoutingOrder  = 1;
        system.debug('sendToFinanceInSendQuota=='+sendToFinance);
        recipient.Email         =  sendToFinance ? UserInfo.getUserEmail() : q.User__r.Email;      //  'pravin.sonawane.contractor@move.com';//////
        //recipient.Email = 'janaki.chilakamarthi@move.com';
        recipient.UserName      = q.Quota_Owner_Name__c;
        recipient.SignerName    = q.Quota_Owner_Name__c;
        System.debug('@@@');
        /*
// Copy Account AE
DocuSignAPI.Recipient recipient1 = new DocuSignAPI.Recipient();
recipient1.ID = 2;
recipient1.Type_x = 'CarbonCopy';
recipient1.RoutingOrder = 1;
recipient1.UserName = WLData.Account__r.owner.Name; 
recipient1.Email =  WLData.Account__r.owner.email; 
boolean skipOne = true ; 
if(WLData.Account__r.owner.email == UserInfo.getUserEmail()){
skipOne =false ;  
}
// Copy Pre Auth QA Team .
DocuSignAPI.Recipient recipient2 = new DocuSignAPI.Recipient();
recipient2.ID = 3;
recipient2.Type_x = 'CarbonCopy';
recipient2.RoutingOrder = 1;
recipient2.UserName = UserInfo.getFirstName()+' '+ UserInfo.getLastName(); 
recipient2.Email =  UserInfo.getUserEmail(); 

*/
        
        // This setting required or you see the error:
        recipient.RequireIDLookup = false;      
        
        envelope.Recipients                 = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient       = new DocuSignAPI.Recipient[1];
        envelope.Recipients.Recipient[0]    = recipient;
        //envelope.Recipients.Recipient[1]    = recipient1;
        //if(skipOne){
        //  envelope.Recipients.Recipient[2]    = recipient2;
        //}
        // Tabs
         System.debug('@@@@');
        envelope.Tabs                       = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab                   = new DocuSignAPI.Tab[123];
        String FontSize = 'Size9';
        DocuSignAPI.Tab tb0  = ReturnTab('Custom',q.User_Team__c ,1,1,'quotaUserTeam', 'Black');
        tb0.Bold = true;
        tb0.FontSize = FontSize;       
        envelope.Tabs.Tab[0]     =  tb0;
        
        envelope.Tabs.Tab[1]    = ReturnTab('Custom',q.Quota_Owner_Name__c,1,1,'QuotaUserName', 'Black');
        
        envelope.Tabs.Tab[2]    = ReturnTab('Custom',string.valueof(q.Employee_Number__c),1,1,'QuotaUserEmpNumber','Black');
        
        envelope.Tabs.Tab[3]    = ReturnTab('Custom','$ '+string.valueof(((Decimal)q.Target_Amount__c).setScale(2).format()),1,1,'QuotaTargetAmtNew','Black');
        
        envelope.Tabs.Tab[4]    = ReturnTab('Custom','$ '+string.valueof(((Decimal)q.Target_Amount_Renewal__c).setScale(2).format()),1,1,'QuotaTargetAmtRenewal','Black');
                    
        
        envelope.Tabs.Tab[5]    = ReturnTab('Custom',string.valueof(q.Period_Name__r.Agent_Sigh_In_AE__c.intValue())+'%' ,1,1,'AgntSAEPer','Black');
        
        envelope.Tabs.Tab[6]    = ReturnTab('Custom',string.valueof(q.Period_Name__r.Agent_Asset_Owner__c.intValue()) +'%',1,1,'AgntOwnPer','Black');
        
        envelope.Tabs.Tab[7]    = ReturnTab('Custom',string.valueof(q.Period_Name__r.Sigh_In_AE__c.intValue())+'%' ,1,1,'BrkrSAEPer','Black');
        
        envelope.Tabs.Tab[8]    = ReturnTab('Custom',string.valueof(q.Period_Name__r.Asset_Owner__c.intValue())+'%' ,1,1,'BrkrOwnPer','Black');
        
        
        System.debug('@@@@@');
        system.debug('QP==>'+q.Quota_Products__r.size());
        if(q.Quota_Products__r.size() > 0){
            envelope.Tabs.Tab[9]    = new DocuSignAPI.Tab();
            envelope.Tabs.Tab[10]   = new DocuSignAPI.Tab();
            envelope.Tabs.Tab[11]   = new DocuSignAPI.Tab();
            envelope.Tabs.Tab[12]   = new DocuSignAPI.Tab();
            envelope.Tabs.Tab[13]   = new DocuSignAPI.Tab();
            envelope.Tabs.Tab[14]   = new DocuSignAPI.Tab();
            
            string QP1ProdOrFamilyName = '';
            if(q.Quota_Products__r.size() >= 1 && q.Quota_Products__r[0] != null){              
                if(!String.isEmpty(q.Quota_Products__r[0].Product_Name1__c))
                    QP1ProdOrFamilyName = q.Quota_Products__r[0].Product_Name1__c;
                else if(!String.isEmpty(q.Quota_Products__r[0].Product_Family__c))
                    QP1ProdOrFamilyName = q.Quota_Products__r[0].Product_Family__c;
            }
            envelope.Tabs.Tab[9]    = QP1ProdOrFamilyName != '' ? ReturnTab('Custom', QP1ProdOrFamilyName ,1,1,'QP1ProdOrFamilyName','Black') : ReturnTab('Custom', '....' ,1,1,'QP1ProdOrFamilyName', 'White');
            String QP1tgtSaleAmt    = q.Quota_Products__r[0] != null ? '$ '+(((Decimal)q.Quota_Products__r[0].Sales__c).setScale(2)).format() : '';
            envelope.Tabs.Tab[10]   = QP1tgtSaleAmt != '' ? ReturnTab('Custom',  QP1tgtSaleAmt ,1,1,'QP1tgtSaleAmt','Black') : ReturnTab('Custom', '....' ,1,1,'QP1tgtSaleAmt','White');            
                        
            string QP2ProdOrFamilyName = ''; 
            if(q.Quota_Products__r.size() >= 2 && q.Quota_Products__r[1] != null){              
                if(!String.isEmpty(q.Quota_Products__r[1].Product_Name1__c))
                    QP2ProdOrFamilyName = q.Quota_Products__r[1].Product_Name1__c;
                else if(!String.isEmpty(q.Quota_Products__r[1].Product_Family__c))
                    QP2ProdOrFamilyName = q.Quota_Products__r[1].Product_Family__c;
            }
            envelope.Tabs.Tab[11]   = QP2ProdOrFamilyName != '' ? ReturnTab('Custom', QP2ProdOrFamilyName ,1,1,'QP2ProdOrFamilyName','Black') : ReturnTab('Custom', '....' ,1,1,'QP2ProdOrFamilyName', 'White');
            string QP2tgtSaleAmt    = q.Quota_Products__r.size() > 1 && q.Quota_Products__r[1] != null ? '$ '+(((Decimal)q.Quota_Products__r[1].Sales__c).setScale(2)).format()  : '';
            envelope.Tabs.Tab[12]   = QP2tgtSaleAmt != '' ? ReturnTab('Custom', QP2tgtSaleAmt ,1,1,'QP2tgtSaleAmt','Black') : ReturnTab('Custom', '....' ,1,1,'QP2tgtSaleAmt','White');            
                       
            string QP3ProdOrFamilyName = '';
            if(q.Quota_Products__r.size() >= 3 && q.Quota_Products__r[2] != null){              
                if(!String.isEmpty(q.Quota_Products__r[2].Product_Name1__c))
                    QP3ProdOrFamilyName = q.Quota_Products__r[2].Product_Name1__c;
                else if(!String.isEmpty(q.Quota_Products__r[2].Product_Family__c))
                    QP3ProdOrFamilyName = q.Quota_Products__r[2].Product_Family__c;
            }
            envelope.Tabs.Tab[13]   = QP3ProdOrFamilyName != '' ? ReturnTab('Custom', QP3ProdOrFamilyName ,1,1,'QP3ProdOrFamilyName','Black') : ReturnTab('Custom', '....' ,1,1,'QP3ProdOrFamilyName', 'White');
            string QP3tgtSaleAmt    = q.Quota_Products__r.size() > 2 && q.Quota_Products__r[2] != null ? '$ '+(((Decimal)q.Quota_Products__r[2].Sales__c).setScale(2)).format() : '';
            envelope.Tabs.Tab[14]   = QP3tgtSaleAmt!= '' ? ReturnTab('Custom', QP3tgtSaleAmt ,1,1,'QP3tgtSaleAmt','Black') : ReturnTab('Custom', '....' ,1,1,'QP3tgtSaleAmt','White');
            
        }
        // string strProsoftProdNames = String.join(lstProsoftProdNames, '\n');
        //envelope.Tabs.Tab[15]   = ReturnTab('Custom', strProsoftProdNames ,1,1,'customSettingProsoftFamily');
        
        /* DocuSignAPI.Tab tab15              = new DocuSignAPI.Tab();
tab15.Type_x                         = 'Custom';
tab15.value                   = strProsoftProdNames;
tab15.RecipientID                    = 1;
tab15.DocumentID                     = 1;
tab15.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
tab15.AnchorTabItem.AnchorTabString  = 'customSettingProsoftFamily';
envelope.Tabs.Tab[15] = tab15;*/
         System.debug('@@@@@@');
        Integer t = 13 - mapTierWisePayouts.size();
        for(; t <= 12; t++){
            Integer ti = t + mapTierWisePayouts.size() - 12;
            //Ar1from   Ar1to   T1Nq    T1Nwoq  T1Rq    T1Rwoq
            Integer idxMultiplier = (ti - 1) * 6;
            if(mapTierWisePayouts.containsKey('tier '+ti) && mapTierWisePayouts.get('tier '+ti) != null){
                map<string,Payout__c> mapSQPayout = mapTierWisePayouts.get('tier '+ti);
                Payout__c pr = mapSQPayout.get('nwq') != null ? mapSQPayout.get('nwq') : mapSQPayout.get('nwoq');
                
                envelope.Tabs.Tab[(16+idxMultiplier)]   = ReturnTab('Custom', string.valueOf(pr.Low_Level__c) + '%' ,1,1,('Ar'+t+'from'),'Black');
                envelope.Tabs.Tab[(17+idxMultiplier)]   = ReturnTab('Custom', ( ti == mapTierWisePayouts.size() ? 'Greater' : string.valueOf(pr.High_Level__c) + '%') ,1,1,('Ar'+t+'to'),'Black');
                if(q.Quota_Products__r.size() > 0 && mapSQPayout.get('nwq') != null){
                    pr = mapSQPayout.get('nwq');
                    envelope.Tabs.Tab[(18+idxMultiplier)]   = pr.Connection_SM_for_Co_Brokerage__c != null ? ReturnTab('Custom', string.valueOf(pr.Connection_SM_for_Co_Brokerage__c.setScale(4)) + '%' ,1,1,('T'+t+'Nq'),'Black') : ReturnTab('Custom', '', 1,1,('T'+t+'Nq'),'Black');
                } else{
                    envelope.Tabs.Tab[(18+idxMultiplier)]   = ReturnTab('Custom', '....' ,1,1,('T'+t+'Nq'),'White');
                }
                
                if(mapSQPayout.get('nwoq') != null){
                    pr = mapSQPayout.get('nwoq');
                    envelope.Tabs.Tab[(19+idxMultiplier)]   = pr.Connection_SM_for_Co_Brokerage__c != null ? ReturnTab('Custom', string.valueOf(pr.Connection_SM_for_Co_Brokerage__c.setScale(4)) + '%' ,1,1,('T'+t+'Nwoq'),'Black') : ReturnTab('Custom', '' ,1,1,('T'+t+'Nwoq'),'Black');
                } else{
                    envelope.Tabs.Tab[(19+idxMultiplier)]   = ReturnTab('Custom', '' ,1,1,('T'+t+'Nwoq'),'Black');
                }
                
                if(q.Quota_Products__r.size() > 0 && mapSQPayout.get('rwq') != null){
                    pr = mapSQPayout.get('rwq');
                    envelope.Tabs.Tab[(20+idxMultiplier)]   = pr.Connection_SM_for_Co_Brokerage__c != null ? ReturnTab('Custom', string.valueOf(pr.Connection_SM_for_Co_Brokerage__c.setScale(4)) + '%' ,1,1,('T'+t+'Rq'),'Black') : ReturnTab('Custom', '' ,1,1,('T'+t+'Rq'),'Black');
                } else{
                    envelope.Tabs.Tab[(20+idxMultiplier)]   = ReturnTab('Custom', '....' ,1,1,('T'+t+'Rq'),'White');
                }
                
                if(mapSQPayout.get('rwoq') != null){
                    pr = mapSQPayout.get('rwoq');
                    envelope.Tabs.Tab[(21+idxMultiplier)]   = pr.Connection_SM_for_Co_Brokerage__c != null ? ReturnTab('Custom', string.valueOf(pr.Connection_SM_for_Co_Brokerage__c.setscale(4)) + '%' ,1,1,('T'+t+'Rwoq'),'Black') : ReturnTab('Custom', '' ,1,1,('T'+t+'Rwoq'),'Black');
                } else{
                    envelope.Tabs.Tab[(21+idxMultiplier)]   = ReturnTab('Custom', '' ,1,1,('T'+t+'Rwoq'),'Black');
                }
            }
            else{
                envelope.Tabs.Tab[(16+idxMultiplier)]   = ReturnTab('Custom', '....' ,1,1,('Ar'+t+'from'), 'White');
                envelope.Tabs.Tab[(17+idxMultiplier)]   = ReturnTab('Custom', '....' ,1,1,('Ar'+t+'to'), 'White');
                envelope.Tabs.Tab[(18+idxMultiplier)]   = ReturnTab('Custom', '....' ,1,1,('T'+t+'Nq'), 'White');
                envelope.Tabs.Tab[(19+idxMultiplier)]   = ReturnTab('Custom', '....' ,1,1,('T'+t+'Nwoq'), 'White');
                envelope.Tabs.Tab[(20+idxMultiplier)]   = ReturnTab('Custom', '....' ,1,1,('T'+t+'Rq'), 'White');
                envelope.Tabs.Tab[(21+idxMultiplier)]   = ReturnTab('Custom', '....' ,1,1,('T'+t+'Rwoq'), 'White');
            }
        }
        
        Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
            6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October',
            11=>'November', 12=>'December'};
                
        String startMonth   = '';
        String endMonth = '';
        if(!test.isrunningtest()){
            startMonth = monthNameMap.get(((Date)q.Quota_StartDate__c).month()) + ' '+ ((Date)q.Quota_StartDate__c).day() +', ' + ((Date)q.Quota_StartDate__c).year();
            endMonth = monthNameMap.get(((Date)q.Quota_EndDate__c).month()) + ' '+ ((Date)q.Quota_EndDate__c).day() +', ' +  ((Date)q.Quota_EndDate__c).year();
        }                                                             
        DocuSignAPI.Tab tab88  = ReturnTab('Custom', startMonth ,1,1,'QuotaStartDate','Black');
        tab88.Bold = true;
        tab88.FontSize = FontSize;
        envelope.Tabs.Tab[88] =tab88;
        
        DocuSignAPI.Tab tab89    = ReturnTab('Custom', endMonth ,1,1,'QuotaEndDate','Black');
        tab89.Bold = true;
        tab89.FontSize = FontSize;
        envelope.Tabs.Tab[89] =tab89;
        
        envelope.Tabs.Tab[90]    = ReturnTab('SignHere', 'Somevalue' ,1,1,'signaturetag','Black');
        
        
        for(Integer p = 0; p <=13; p++){             
            if(p <lstProsoftProdNames.size())
                envelope.Tabs.Tab[(91+p)] = ReturnTab('Custom', lstProsoftProdNames[p] ,1,1,('p'+p+'Name'),'Black'); 
            else
                envelope.Tabs.Tab[(91+p)]   = ReturnTab('Custom', '...................',1,1,('p'+p+'Name'),'White');             
        }
        
        envelope.Tabs.Tab[120]  = ReturnTab('InitialHere', 'Somevalue' ,1,1,'Initialr','Black');
        envelope.Tabs.Tab[121]  = ReturnTab('DateSigned', 'Somevalue' ,1,1,'Dater','Black');
        
        //document = senddocusign1.SendNow1(q.Id, document, envelope);
        
        System.debug('document===>>'+document);
        
        // Default values
        Integer reminderDelay=1, reminderFrequency=7, expireWarn=7, expireAfter=30;
        DocuSignAPI.Notification Notification = new DocuSignAPI.Notification();
        DocuSignAPI.Reminders Reminders = new DocuSignAPI.Reminders();
        Reminders.ReminderEnabled = true;
        Reminders.ReminderDelay = reminderDelay;
        Reminders.ReminderFrequency = reminderFrequency;
        Notification.UseAccountDefaults = false;
        Notification.Reminders = Reminders;
        
        
        DocuSignAPI.Expirations  Expirations  = new DocuSignAPI.Expirations();      
        Expirations.ExpireEnabled = true;
        Expirations.ExpireWarn = expireWarn;
        Expirations.ExpireAfter = expireAfter;
        Notification.Expirations = Expirations;
        
        envelope.Notification = Notification;
        
        //sending Envelope
        system.debug('Sending.....');
        DocuSignAPI.EnvelopeStatus EnvStatus = dsApiSend.CreateAndSendEnvelope(envelope);
        if ( !Test.isRunningTest() ){
            envelopeId = EnvStatus.EnvelopeID;
        } else{
            envelopeId = '12345';
        }
        System.debug('EnvStatus====='+EnvStatus); 
        //attaching DocuSign status object to Quota object
        
        dsfs__DocuSign_Status__c DocStatus      = new dsfs__DocuSign_Status__c();
        DocStatus.dsfs__DocuSign_Envelope_ID__c = envelopeId;
        DocStatus.dsfs__Sender__c               = userinfo.getusername();
        DocStatus.dsfs__Sender_Email__c         = userinfo.getuseremail();
        DocStatus.dsfs__Subject__c              = envelope.Subject;
        DocStatus.Quota__c                      = q.Id;
        //DocStatus.Quota__r = new Quota__c(Id =q.Id, Send_Comp_Plan__c = false);
        if ( !Test.isRunningTest() ){
            DocStatus.dsfs__Envelope_Status__c  = EnvStatus.status;
        } else{
            DocStatus.dsfs__Envelope_Status__c  = 'Sent';
        }           
        return DocStatus;           
    }
    
    public static  dsfs__DocuSign_Status__c sendForManagersQuota(string accountId , Quota__c q, map<String, map<string,Payout__c>> mapTierWisePayouts, DocuSignAPI.APIServiceSoap dsApiSend,  list<string> lstProsoftProdNames, Boolean sendToFinance ){        
        String envelopeId;
        Integer I = 0;        
        Blob SignDocument = Blob.valueOf(' ');
        string shortname;
        system.debug('in sendForManagersQuota');
        if(q.Quota_Products__r.size() > 0){
            SignDocument = [SELECT Body FROM Document WHERE Name = 'ManagerwithQualifierCompensationPlanTemplate'].Body;
        }else{
            SignDocument = [SELECT Body FROM Document WHERE Name = 'ManagerwithoutQualifierCompensationPlanTemplate'].Body;  //AEwithoutQualifierCompensationPlanTemplatetest
            system.debug('at without compansation template');
        }
        
        DateTime dt = q.Quota_EndDate__c;
        String monthName = dt.format('MMMMM');
        Integer year = dt.year();
        System.debug('Month Name : ' + monthName);
        
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject    = sendToFinance ? 'Sample Docusign - '+ q.User__r.Name +' - '+  monthName + ' ' + year+ ' (Finance Use Only)': 'Please sign the compensation plan for '+ monthName + ' ' + year ;   //CRM-5688
        envelope.EmailBlurb = 'Review all compensation plan in the form before signing';
        envelope.BrandId=System.Label.CompPlan_DocuSign_Brand_ID;
        
        envelope.AccountId  = accountId;
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID                     = 1;
        document.pdfBytes               = EncodingUtil.base64Encode(SignDocument);
        document.Name                   = 'compensation_plan';
        document.FileExtension          = '.doc';
        envelope.Documents              = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document     = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0]  = document;
        System.debug('======>>document====>>'+document);
        
        
        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
        
        recipient.ID            = 1;
        recipient.Type_x        = 'Signer';
        recipient.RoutingOrder  = 1;
        //'pravin.sonawane.contractor@move.com'; 'janaki.chilakamarthi@move.com';//baswaraj.patil.contractor@move.com';
        system.debug('sendToFinanceInManagerQuota=='+sendToFinance);
        recipient.Email         = sendToFinance ? UserInfo.getUserEmail() : q.User__r.Email; 
        //recipient.Email = 'janaki.chilakamarthi@move.com';
        recipient.UserName      = q.Quota_Owner_Name__c;
        recipient.SignerName    = q.Quota_Owner_Name__c;
        System.debug('@@');
        /*
// Copy Account AE
DocuSignAPI.Recipient recipient1 = new DocuSignAPI.Recipient();
recipient1.ID = 2;
recipient1.Type_x = 'CarbonCopy';
recipient1.RoutingOrder = 1;
recipient1.UserName = WLData.Account__r.owner.Name; 
recipient1.Email =  WLData.Account__r.owner.email; 
boolean skipOne = true ; 
if(WLData.Account__r.owner.email == UserInfo.getUserEmail()){
skipOne =false ;  
}
// Copy Pre Auth QA Team .
DocuSignAPI.Recipient recipient2 = new DocuSignAPI.Recipient();
recipient2.ID = 3;
recipient2.Type_x = 'CarbonCopy';
recipient2.RoutingOrder = 1;
recipient2.UserName = UserInfo.getFirstName()+' '+ UserInfo.getLastName(); 
recipient2.Email =  UserInfo.getUserEmail(); 

*/
        
        // This setting required or you see the error:
        recipient.RequireIDLookup = false;      
        System.debug('@@@');
        envelope.Recipients                 = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient       = new DocuSignAPI.Recipient[1];
        envelope.Recipients.Recipient[0]    = recipient;
        //envelope.Recipients.Recipient[1]    = recipient1;
        //if(skipOne){
        //  envelope.Recipients.Recipient[2]    = recipient2;
        //}
        // Tabs
        
        envelope.Tabs                       = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab                   = new DocuSignAPI.Tab[250];
        String FontSize = 'Size9';
        
        
        DocuSignAPI.Tab tb0  = ReturnTab('Custom',string.valueof(q.User__r.Title),1,1,'QuotaUserTitle','Black');
        tb0.Bold = true;
        tb0.FontSize = FontSize;       
        envelope.Tabs.Tab.add(tb0);
        
        envelope.Tabs.Tab.add(ReturnTab('Custom',q.Quota_Owner_Name__c,1,1,'QuotaUserName', 'Black'));
        
        envelope.Tabs.Tab.add(ReturnTab('Custom',q.User_Team__c ,1,1,'quotaUserTeam', 'Black'));
        system.debug('targetAmt==>'+q);
        system.debug('targetAmt==>'+q.Target_Amount__c);
        envelope.Tabs.Tab.add(ReturnTab('Custom','$ '+ string.valueof(((Decimal)q.Target_Amount__c).setScale(2).format()) ,1,1,'QuotaTargetAmtNew','Black'));
        
        envelope.Tabs.Tab.add(ReturnTab('Custom','$ '+ string.valueof(((Decimal)q.Target_Amount_Renewal__c).setScale(2).format()) ,1,1,'QuotaTargetAmtRenewal','Black'));
        
        envelope.Tabs.Tab.add(ReturnTab('Custom',string.valueof(q.Period_Name__r.Agent_Sigh_In_AE__c.intValue()) +'%' ,1,1,'AgntSAEPer','Black'));
        
        envelope.Tabs.Tab.add(ReturnTab('Custom',string.valueof(q.Period_Name__r.Agent_Asset_Owner__c.intValue())+'%' ,1,1,'AgntOwnPer','Black'));
        
        envelope.Tabs.Tab.add(ReturnTab('Custom',string.valueof(q.Period_Name__r.Sigh_In_AE__c.intValue())+'%' ,1,1,'BrkrSAEPer','Black'));
        
        envelope.Tabs.Tab.add(ReturnTab('Custom',string.valueof(q.Period_Name__r.Asset_Owner__c.intValue())+'%' ,1,1,'BrkrOwnPer','Black'));
        
        
        System.debug('@@@@');
        if(q.Quota_Products__r.size() > 0){ 
            string QP1ProdOrFamilyName = '';
            if(q.Quota_Products__r.size() >= 1 && q.Quota_Products__r[0] != null){
                if(!String.isEmpty(q.Quota_Products__r[0].Product_Name1__c))
                    QP1ProdOrFamilyName = q.Quota_Products__r[0].Product_Name1__c;
                else if(!String.isEmpty(q.Quota_Products__r[0].Product_Family__c))
                    QP1ProdOrFamilyName = q.Quota_Products__r[0].Product_Family__c;
            
            if(QP1ProdOrFamilyName != '')
                envelope.Tabs.Tab.add(ReturnTab('Custom', QP1ProdOrFamilyName ,1,1,'QP1ProdOrFamilyName','Black'));
            else
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,'QP1ProdOrFamilyName','White'));
            string QP1tgtSaleAmt = q.Quota_Products__r[0] != null ? '$ '+(((Decimal)q.Quota_Products__r[0].Sales__c).setScale(2)).format() : '';
            if(QP1tgtSaleAmt != '')
                envelope.Tabs.Tab.add(ReturnTab('Custom', QP1tgtSaleAmt ,1,1,'QP1tgtSaleAmt','Black'));            
            else
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,'QP1tgtSaleAmt','White'));
            }
            
            string QP2ProdOrFamilyName = '';
            if(q.Quota_Products__r.size() >= 2 && q.Quota_Products__r[1] != null){
                if(!String.isEmpty(q.Quota_Products__r[1].Product_Name1__c))
                    QP2ProdOrFamilyName = q.Quota_Products__r[1].Product_Name1__c;
                else if(!String.isEmpty(q.Quota_Products__r[1].Product_Family__c))
                    QP2ProdOrFamilyName = q.Quota_Products__r[1].Product_Family__c;
            if(QP2ProdOrFamilyName != '')
                envelope.Tabs.Tab.add(ReturnTab('Custom', QP2ProdOrFamilyName ,1,1,'QP2ProdOrFamilyName','Black'));
            else
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,'QP2ProdOrFamilyName','White'));
            string QP2tgtSaleAmt    = q.Quota_Products__r.size() > 1 && q.Quota_Products__r[1] != null ? '$ '+(((Decimal)q.Quota_Products__r[1].Sales__c).setScale(2)).format() : '';   
            if(QP2tgtSaleAmt != '')
                envelope.Tabs.Tab.add(ReturnTab('Custom', QP2tgtSaleAmt ,1,1,'QP2tgtSaleAmt','Black'));
            else
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,'QP2tgtSaleAmt','White'));
            }
            
            string QP3ProdOrFamilyName = ''; 
            if(q.Quota_Products__r.size() >= 3 && q.Quota_Products__r[2] != null){
                if(!String.isEmpty(q.Quota_Products__r[2].Product_Name1__c))
                    QP3ProdOrFamilyName = q.Quota_Products__r[2].Product_Name1__c;
                else if(!String.isEmpty(q.Quota_Products__r[2].Product_Family__c))
                    QP3ProdOrFamilyName = q.Quota_Products__r[2].Product_Family__c;
            
            if(QP3ProdOrFamilyName != '')
                envelope.Tabs.Tab.add(ReturnTab('Custom', QP3ProdOrFamilyName ,1,1,'QP3ProdOrFamilyName','Black'));
            else
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,'QP3ProdOrFamilyName','White'));
            string QP3tgtSaleAmt = q.Quota_Products__r.size() > 2 && q.Quota_Products__r[2] != null ? '$ '+(((Decimal)q.Quota_Products__r[2].Sales__c).setScale(2)).format() : '';
            if(QP3tgtSaleAmt != '')
                envelope.Tabs.Tab.add(ReturnTab('Custom', QP3tgtSaleAmt ,1,1,'QP3tgtSaleAmt','Black'));
            else
               envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,'QP3tgtSaleAmt','White')); 
            }
        }
        // string strProsoftProdNames = String.join(lstProsoftProdNames, '\n');
        //envelope.Tabs.Tab[15]   = ReturnTab('Custom', strProsoftProdNames ,1,1,'customSettingProsoftFamily');
        
        /* DocuSignAPI.Tab tab15              = new DocuSignAPI.Tab();
tab15.Type_x                         = 'Custom';
tab15.value                   = strProsoftProdNames;
tab15.RecipientID                    = 1;
tab15.DocumentID                     = 1;
tab15.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
tab15.AnchorTabItem.AnchorTabString  = 'customSettingProsoftFamily';
envelope.Tabs.Tab[15] = tab15;*/
        
        
        Integer t = 0;
        if(!test.isrunningtest())
         t = 13 - mapTierWisePayouts.size();
              
        System.debug('@@@@@$');
        for(; t <= 12; t++){
            Integer ti = t + mapTierWisePayouts.size() - 12;
            //Ar1from   Ar1to   T1Nq    T1Nwoq  T1Rq    T1Rwoq
            Integer idxMultiplier = (ti - 1) * 6;
            if(mapTierWisePayouts.containsKey('tier '+ti) && mapTierWisePayouts.get('tier '+ti) != null){
                map<string,Payout__c> mapSQPayout = mapTierWisePayouts.get('tier '+ti);
                system.debug('mapSQPayout=='+mapSQPayout);
                Payout__c pr = mapSQPayout.get('nwq') != null ? mapSQPayout.get('nwq') : mapSQPayout.get('nwoq');
                system.debug('pr=='+pr);
                system.debug('High_Level__c=='+pr.High_Level__c);
                system.debug('Low_Level__c=='+pr.Low_Level__c);
                system.debug('Target_Amount__c=='+q.Target_Amount__c);
                Decimal Monthly_NewSale= (((t==1 || t==7) ? pr.High_Level__c : pr.Low_Level__c) *q.Target_Amount__c)/100;
                Decimal Monthly_Renewal= (((t==1 || t==7) ? pr.High_Level__c : pr.Low_Level__c) *q.Target_Amount_Renewal__c)/100;
                system.debug('Monthly_NewSale=='+Monthly_NewSale);
                system.debug('Monthly_Renewal=='+Monthly_Renewal);
                envelope.Tabs.Tab.add(ReturnTab('Custom', string.valueOf(pr.Low_Level__c) + '%' ,1,1,('Ar'+t+'from'),'Black'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', ( ti == mapTierWisePayouts.size() ? 'Greater' : string.valueOf(pr.High_Level__c) + '%') ,1,1,('Ar'+t+'to'),'Black'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '$'+Monthly_NewSale.setScale(2).format() ,1,1,(t+'monthlySale_n'),'Black'));
        envelope.Tabs.Tab.add(ReturnTab('Custom', '$'+Monthly_Renewal.setScale(2).format()  ,1,1,(t+'monthlySale_r'),'Black'));                
                if(mapSQPayout.get('nwoq') != null){
                    pr = mapSQPayout.get('nwoq');
                    envelope.Tabs.Tab.add(ReturnTab('Custom', string.valueOf(pr.Commissionable__c) + '%' ,1,1,('T'+t+'wqRate_n'),'Black'));
                    envelope.Tabs.Tab.add(ReturnTab('Custom', '$'+string.valueOf(((Decimal)(pr.Commissionable__c * Monthly_NewSale/100)).setScale(2).format()),1,1,('T'+t+'wqPVE_n'),'Black'));
                    
                } else{
                    envelope.Tabs.Tab.add(ReturnTab('Custom', '' ,1,1,('T'+t+'wqRate_n'),'Black'));
                    envelope.Tabs.Tab.add(ReturnTab('Custom', '' ,1,1,('T'+t+'wqPVE_n'),'Black'));
                }
                
                if(q.Quota_Products__r.size() > 0){
                    if(mapSQPayout.get('nwq') != null){
                        pr = mapSQPayout.get('nwq');
                        envelope.Tabs.Tab.add(ReturnTab('Custom', string.valueOf(pr.Commissionable__c) + '%' ,1,1,('Tier'+t+'Rate_n'),'Black'));
                        envelope.Tabs.Tab.add(ReturnTab('Custom', '$'+string.valueOf(((Decimal)(pr.Commissionable__c * Monthly_NewSale/100)).setScale(2).format()),1,1,('Tier'+t+'PVE_n'),'Black'));
                    } else{
                        envelope.Tabs.Tab.add(ReturnTab('Custom', '' ,1,1,('Tier'+t+'Rate_n'),'Black'));
                        envelope.Tabs.Tab.add(ReturnTab('Custom', '' ,1,1,('Tier'+t+'PVE_n'),'Black'));
                    }
                }
                
                
                if(mapSQPayout.get('rwoq') != null){
                    pr = mapSQPayout.get('rwoq');
                    envelope.Tabs.Tab.add(ReturnTab('Custom', string.valueOf(pr.Commissionable__c) + '%' ,1,1,('T'+t+'wqRate_r'),'Black'));
                    envelope.Tabs.Tab.add(ReturnTab('Custom', '$'+string.valueOf(((Decimal)(pr.Commissionable__c * Monthly_Renewal/100)).setScale(2).format()),1,1,('T'+t+'wqPVE_r'),'Black'));
                    
                } else{
                    envelope.Tabs.Tab.add(ReturnTab('Custom', '' ,1,1,('T'+t+'wqRate_r'),'Black'));
                    envelope.Tabs.Tab.add(ReturnTab('Custom', '' ,1,1,('T'+t+'wqPVE_r'),'Black'));
                }
                
                if(q.Quota_Products__r.size() > 0){
                    if(mapSQPayout.get('rwq') != null){
                        pr = mapSQPayout.get('rwq');
                        envelope.Tabs.Tab.add(ReturnTab('Custom', string.valueOf(pr.Commissionable__c) + '%' ,1,1,('Tier'+t+'Rate_r'),'Black'));
                        envelope.Tabs.Tab.add(ReturnTab('Custom', '$'+string.valueOf(((Decimal)(pr.Commissionable__c * Monthly_Renewal/100)).setScale(2).format()),1,1,('Tier'+t+'PVE_r'),'Black'));
                    } else{
                        envelope.Tabs.Tab.add(ReturnTab('Custom', '' ,1,1,('Tier'+t+'Rate_r'),'Black'));
                        envelope.Tabs.Tab.add(ReturnTab('Custom', '' ,1,1,('Tier'+t+'PVE_r'),'Black'));
                    }
                }
            }
            else{
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('Ar'+t+'from'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('Ar'+t+'to'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,(t+'monthlySale_n'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,(t+'monthlySale_r'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('T'+t+'wqRate_n'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('T'+t+'wqPVE_n'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('Tier'+t+'Rate_n'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('Tier'+t+'PVE_n'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('T'+t+'wqRate_r'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('T'+t+'wqPVE_r'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('Tier'+t+'Rate_r'), 'White'));
                envelope.Tabs.Tab.add(ReturnTab('Custom', '....' ,1,1,('Tier'+t+'PVE_r'), 'White'));
            }
        }
        
       
          System.debug('@@@@@@');
        envelope.Tabs.Tab.add(ReturnTab('SignHere', 'Somevalue' ,1,1,'signaturetag','Black'));
        
        
        for(Integer p = 0; p <=13; p++){             
            if(p <lstProsoftProdNames.size())
                envelope.Tabs.Tab.add(ReturnTab('Custom', lstProsoftProdNames[p] ,1,1,('p'+p+'Name'),'Black')); 
            else
                envelope.Tabs.Tab.add(ReturnTab('Custom', '...................',1,1,('p'+p+'Name'),'White'));             
        }
        
        envelope.Tabs.Tab.add(ReturnTab('InitialHere', 'Somevalue' ,1,1,'Initialr','Black'));
        envelope.Tabs.Tab.add(ReturnTab('DateSigned', 'Somevalue' ,1,1,'Dater','Black'));
        
        Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
            6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October',
            11=>'November', 12=>'December'};
                
        String startMonth   = '';
        String endMonth = '';
        if(!test.isrunningtest()){
            startMonth = monthNameMap.get(((Date)q.Quota_StartDate__c).month()) + ' '+ ((Date)q.Quota_StartDate__c).day() +', ' + ((Date)q.Quota_StartDate__c).year();
            endMonth = monthNameMap.get(((Date)q.Quota_EndDate__c).month()) + ' '+ ((Date)q.Quota_EndDate__c).day() +', ' +  ((Date)q.Quota_EndDate__c).year();
        }                                                             
        DocuSignAPI.Tab tab124  = ReturnTab('Custom', startMonth ,1,1,'QuotaStartDate','Black');
        tab124.Bold = true;
        tab124.FontSize = FontSize;
        envelope.Tabs.Tab.add(tab124);
        
        DocuSignAPI.Tab tab125    = ReturnTab('Custom', endMonth ,1,1,'QuotaEndDate','Black');
        tab125.Bold = true;
        tab125.FontSize = FontSize;
        envelope.Tabs.Tab.add(tab125);
        
        //document = senddocusign1.SendNow1(q.Id, document, envelope);
        
        System.debug('document===>>'+document);
        
        // Default values
        Integer reminderDelay=1, reminderFrequency=7, expireWarn=7, expireAfter=30;
        DocuSignAPI.Notification Notification = new DocuSignAPI.Notification();
        DocuSignAPI.Reminders Reminders = new DocuSignAPI.Reminders();
        Reminders.ReminderEnabled = true;
        Reminders.ReminderDelay = reminderDelay;
        Reminders.ReminderFrequency = reminderFrequency;
        Notification.UseAccountDefaults = false;
        Notification.Reminders = Reminders;
        
    System.debug('@@@@@@@');        
        DocuSignAPI.Expirations  Expirations  = new DocuSignAPI.Expirations();      
        Expirations.ExpireEnabled = true;
        Expirations.ExpireWarn = expireWarn;
        Expirations.ExpireAfter = expireAfter;
        Notification.Expirations = Expirations;
        
        envelope.Notification = Notification;
        
        //sending Envelope
        system.debug('Sending.....');
        DocuSignAPI.EnvelopeStatus EnvStatus = dsApiSend.CreateAndSendEnvelope(envelope);
        if ( !Test.isRunningTest() ){
            envelopeId = EnvStatus.EnvelopeID;
        } else{
            envelopeId = '12345';
        }
        System.debug('EnvStatus====='+EnvStatus); 
        //attaching DocuSign status object to Quota object
        
        dsfs__DocuSign_Status__c DocStatus      = new dsfs__DocuSign_Status__c();
        DocStatus.dsfs__DocuSign_Envelope_ID__c = envelopeId;
        DocStatus.dsfs__Sender__c               = userinfo.getusername();
        DocStatus.dsfs__Sender_Email__c         = userinfo.getuseremail();
        DocStatus.dsfs__Subject__c              = envelope.Subject;
        DocStatus.Quota__c                      = q.Id;
        
        if ( !Test.isRunningTest() ){
            DocStatus.dsfs__Envelope_Status__c  = EnvStatus.status;
        } else{
            DocStatus.dsfs__Envelope_Status__c  = 'Sent';
        }           
        return DocStatus;           
    }
    
    
    
    //Method returns short name for a product from custom setting
    public static string getDsShortName(string pName){
        string sName = '';
        if( !String.isBlank(pName) ){
            DocusingShortName__c sNameIntance = DocusingShortName__c.getValues(pName);
            if( sNameIntance!=null && !String.isBlank(sNameIntance.Short_Name__c) ){
                sName = sNameIntance.Short_Name__c;
            }
        }
        
        return sName;
    }
    
    //@Future(callout=true)
    public static void VoidDocusign(string envelopeID, string auth, string webServiceUrl, string accountId){
        
        DocuSignAPI30.APIServiceSoap dsApiSend = new DocuSignAPI30.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        
        //Set Authentication
        /*String auth = '<DocuSignCredentials><Username>'+ userId 
            +'</Username><Password>' + password 
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey></DocuSignCredentials>';*/
        
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication',auth);
        
        try{
                DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
                envelope.Subject    = 'Cancellation'; 
                envelope.EmailBlurb = 'Please find the voided form';
                envelope.AccountId  = accountId;
                
                //envelopeID = this.sDocusign.dsfs__DocuSign_Envelope_ID__c;
                string reason = 'New compensation plan generated & sent.';
                DocusignApi30.VoidEnvelopeStatus VoidStatus = dsApiSend.VoidEnvelope(envelopeID, reason);
                
         }
         catch(CalloutException DSerror)
         {
                System.debug('DSException - ' + DSerror );
                Error__c logerror               = new Error__c();
                logerror.Name                   = EnvelopeID;
                logerror.Entity_Id__c           = 'Compensation plan Docusign Void';
                logerror.Error_Description__c   = string.valueof(DSerror);
                logerror.Interface_Name__c      = 'DocuSign';
                Insert logerror;
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,''+DSerror.getMessage());
                //ApexPages.addMessage(myMsg);                  
         }
    }
}