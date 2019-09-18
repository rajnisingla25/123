Global with sharing class SendDocusign {
    

    public static DocuSignAPI.Tab ReturnTab(String tbType,String val,Integer recID,Integer docId, String anchorTabStr){
        DocuSignAPI.Tab tbb = new DocuSignAPI.Tab();
        tbb.Type_x                         = tbType;
        tbb.value                          = val != null? val.unescapejava() : '' ;
        tbb.RecipientID                    = recID;
        tbb.DocumentID                     = docId;
        tbb.AnchorTabItem                  = new DocuSignAPI.AnchorTab();        
        tbb.AnchorTabItem.AnchorTabString  = anchorTabStr;
        return tbb;
        }


    @Future(callout=true)
    Global static void SendNow(string WLid){
        String envelopeId;
        Integer I = 0;        
        Blob SignDocument= Blob.valueOf(' ');
        integer numberofproducts;
        string shortname;
        DocuSignCredentials__c DocSignCredentials = DocuSignCredentials__c.getAll().values();
        String accountId        = DocSignCredentials.AccountId__c;
        String userId           = DocSignCredentials.UserId__c;
        String password         = DocSignCredentials.Password__c;
        String integratorsKey   = DocSignCredentials.IntegratorsKey__c;
        String webServiceUrl    = DocSignCredentials.WebServiceUrl__c;
        
        DocuSignAPI.APIServiceSoap dsApiSend = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        dsApiSend.timeout_x=120000;
        // Added by Rajamohan - 
        String accId = [Select id , Account__c from Waitlist__c where id=:WLid].Account__c ;
        System.debug('accId === >'+accId) ;
        Waitlist__c waitListList = [select Id
                              from Waitlist__c where Id=:WLid ];
         list<Waitlist_Item__c> WLIData =[select Product__r.Name,Market__c,Market_Type__c,
                               Original_Max_Spend__c,Waitlist_Expiration_Date__c,Lead_Routing__c, Term__c, product_size__c 
                               from Waitlist_Item__c where Term__c In ('6','12') 
                                          AND Waitlist__c =:WLid AND Status__c NOT IN ('Fulfilled' ,
                                                                                       'Canceled',
                                                                                       'Rejected Pre-Auth',
                                                                                       'Expired') order by name DESC Limit 100] ;
        Waitlist__c WLData = [select CreatedDate , Submitted_Date__c, Pre_Auth_Email__c,
                              Current_Monthly_Pre_Auth_Spend__c ,
                              Total_MAX_Monthly_Pre_Auth_Spend__c ,
                              Pre_Auth_Contact__r.FirstName,Pre_Auth_Contact__r.LastName,Account__r.owner.email,
                              Account__r.owner.name,CC4Digits__c, Waitlist_Expiration_Date__c,
                              (select Product__r.Name,Market__c,Market_Type__c,
                               Original_Max_Spend__c,Waitlist_Expiration_Date__c,Lead_Routing__c, Term__c  
                               from Waitlist_Items__r where Term__c In ('6','12') AND Status__c NOT IN ('Fulfilled' ,'Canceled','Rejected Pre-Auth','Expired') ) 
                              from Waitlist__c where id = :WLid AND Status__c NOT IN ('Fulfilled' ,'Canceled','Rejected Pre-Auth','Expired')];
        
        
        numberofproducts = WLIData.size();
     
        
        
        if(numberofproducts > 0 && numberofproducts <= 10){
            SignDocument = [SELECT Body FROM Document WHERE Name = 'Pre-Auth for Waitlist10'].Body;
        }else if(numberofproducts > 10 && numberofproducts <= 20){
            SignDocument = [SELECT Body FROM Document WHERE Name = 'Pre-Auth for Waitlist20'].Body;
        }else if(numberofproducts > 20 && numberofproducts <= 40){
            SignDocument = [SELECT Body FROM Document WHERE Name = 'Pre-Auth for Waitlist40'].Body;
        }else if(numberofproducts > 40 && numberofproducts <= 60){
            SignDocument = [SELECT Body FROM Document WHERE Name = 'Pre-Auth for Waitlist60'].Body;
        }else if(numberofproducts > 60 && numberofproducts <= 80){
            SignDocument = [SELECT Body FROM Document WHERE Name = 'Pre-Auth for Waitlist80'].Body;
        }else if(numberofproducts > 80 && numberofproducts <= 100){
            SignDocument = [SELECT Body FROM Document WHERE Name = 'Pre-Auth for Waitlist100'].Body;
        }
        
        //Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ userId 
            +'</Username><Password>' + password 
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey></DocuSignCredentials>';
        
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication',auth);
        
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject    = 'Please Sign the Pre-Auth Form'; 
        envelope.EmailBlurb = 'Review all products in the form before signing';
        envelope.BrandId=System.Label.DocuSign_Brand_ID;

        envelope.AccountId  = accountId;
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID                     = 1;
        document.pdfBytes               = EncodingUtil.base64Encode(SignDocument);
        document.Name                   = 'Waitlist PreAuthform';
        document.FileExtension          = '.doc';
        envelope.Documents              = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document     = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0]  = document;
        System.debug('======>>document====>>'+document);
        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
        recipient.ID            = 1;
        recipient.Type_x        = 'Signer';
        recipient.RoutingOrder  = 1;
        recipient.Email         = WLData.Pre_Auth_Email__c;
        recipient.UserName      = WLData.Pre_Auth_Contact__r.FirstName + ' ' + WLData.Pre_Auth_Contact__r.LastName;
        recipient.SignerName    = WLData.Pre_Auth_Contact__r.FirstName + ' ' + WLData.Pre_Auth_Contact__r.LastName;
        
        
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
        
        
        
        
        
        // This setting required or you see the error:
        recipient.RequireIDLookup = false;      
        
        envelope.Recipients                 = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient       = new DocuSignAPI.Recipient[3];
        envelope.Recipients.Recipient[0]    = recipient;
        envelope.Recipients.Recipient[1]    = recipient1;
        if(skipOne){
        envelope.Recipients.Recipient[2]    = recipient2;
}
        // Tabs
        DocuSignAPI.Tab tab1                = ReturnTab('SignHere','  ',1,1,'signaturetag');
        DocuSignAPI.Tab tab2                = ReturnTab('DateSigned','  ',1,1,'signdatetag');
        DocuSignAPI.Tab tab3                = ReturnTab('Custom',string.valueof(WLData.Submitted_Date__c.addDays(90)),1,1,'expirationtag');
        DocuSignAPI.Tab tab4                = ReturnTab('FullName','  ',1,1,'nametag');
        DocuSignAPI.Tab tab5                = ReturnTab('FullName','  ',1,1,'Customername1tag');
        DocuSignAPI.Tab tab3MaxPrice        = ReturnTab('Custom',string.valueof(WLData.Total_MAX_Monthly_Pre_Auth_Spend__c),1,1,'totMnthlyPrSpend123');

        DocuSignAPI.Tab tab6                = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab7                = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab8                = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab9                = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab10               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab11               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab12               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab13               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab14               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab15               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab16               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab17               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab18               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab19               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab20               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab21               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab22               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab23               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab24               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab25               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab26               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab27               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab28               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab29               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab30               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab31               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab32               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab33               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab34               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab35               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab36               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab37               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab38               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab39               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab40               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab41               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab42               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab43               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab44               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab45               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab46               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab47               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab48               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab49               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab50               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab51               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab52               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab53               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab54               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab55               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab56               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab57               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab58               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab59               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab60               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab61               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab62               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab63               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab64               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab65               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab66               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab67               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab68               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab69               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab70               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab71               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab72               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab73               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab74               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab75               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab76               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab77               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab78               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab79               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab80               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab81               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab82               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab83               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab84               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab85               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab86               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab87               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab88               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab89               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab90               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab91               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab92               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab93               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab94               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab95               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab96               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab97               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab98               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab99               = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab100              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab101              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab102              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab103              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab104              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab105              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab106              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab107              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab108              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab109              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab110              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab111              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab112              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab113              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab114              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab115              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab116              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab117              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab118              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab119              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab120              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab121              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab122              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab123              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab124              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab125              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab126              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab127              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab128              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab129              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab130              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab131              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab132              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab133              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab134              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab135              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab136              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab137              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab138              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab139              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab140              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab141              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab142              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab143              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab144              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab145              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab146              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab147              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab148              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab149              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab150              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab151              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab152              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab153              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab154              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab155              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab156              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab157              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab158              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab159              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab160              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab161              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab162              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab163              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab164              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab165              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab166              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab167              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab168              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab169              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab170              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab171              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab172              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab173              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab174              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab175              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab176              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab177              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab178              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab179              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab180              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab181              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab182              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab183              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab184              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab185              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab186              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab187              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab188              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab189              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab190              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab191              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab192              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab193              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab194              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab195              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab196              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab197              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab198              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab199              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab200              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab201              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab202              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab203              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab204              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab205              = new DocuSignAPI.Tab();
        
        // Term 1 to Term 10
        DocuSignAPI.Tab tab503              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab504              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab505              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab506              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab507              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab508              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab509              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab510              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab511              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab512              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab513              = new DocuSignAPI.Tab();
        
        // 11 to 20 Term Tabs 
        
        DocuSignAPI.Tab tab514              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab515              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab516              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab517              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab518              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab519              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab520              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab521              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab522              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab523              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab524              = new DocuSignAPI.Tab();
        
        // 21 to 30 Term Tabs 
        
        
        DocuSignAPI.Tab tab525              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab526              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab527              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab528              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab529              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab530              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab531              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab532              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab533              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab534              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab535              = new DocuSignAPI.Tab();
        
        // 31 to 40 Term tabs 
        // 
        DocuSignAPI.Tab tab536             = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab537              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab538              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab539              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab540              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab541              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab542              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab543              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab544              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab545              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab546              = new DocuSignAPI.Tab();
        
        
        // 41 to 50 Term Tabs 
        
        
        DocuSignAPI.Tab tab547             = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab548              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab549              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab550              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab551              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab552              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab553              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab554              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab555              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab556              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab557              = new DocuSignAPI.Tab();
        
            
           // size 1 to size 10
        DocuSignAPI.Tab tab609              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab610              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab611              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab612              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab613              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab614              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab615              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab616              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab617              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab618              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab619              = new DocuSignAPI.Tab();
        
        // 11 to 20 size Tabs 
        
        DocuSignAPI.Tab tab620              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab621              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab622              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab623              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab624              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab625              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab626              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab627              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab628              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab629              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab630              = new DocuSignAPI.Tab();
        
        // 21 to 30 size Tabs 
        
        
        DocuSignAPI.Tab tab631              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab632              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab633              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab634              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab635              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab636              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab637              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab638              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab639              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab640              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab641              = new DocuSignAPI.Tab();
        
        // 31 to 40 size tabs 
        // 
        DocuSignAPI.Tab tab642             = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab643              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab644              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab645              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab646              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab647              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab648              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab649              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab650              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab651              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab652              = new DocuSignAPI.Tab();
        
        
        // 41 to 50 size Tabs 
        
        
        DocuSignAPI.Tab tab653             = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab654              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab655              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab656              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab657              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab658              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab659              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab660              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab661              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab662              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab663              = new DocuSignAPI.Tab();

        
        
        envelope.Tabs                       = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab                   = new DocuSignAPI.Tab[714];
        envelope.Tabs.Tab[0]                = tab1;        
        envelope.Tabs.Tab[1]                = tab2;       
        envelope.Tabs.Tab[2]                = tab3;       
        envelope.Tabs.Tab[3]                = tab4;       
        envelope.Tabs.Tab[4]                = tab5; 
        //Start --Added By Rajamohan
        envelope.Tabs.Tab[500]                = tab3MaxPrice; 
        //  envelope.Tabs.Tab[501]                = tab3CurrentPrice; 
        
        //End-- Added by Rajamohan
        //envelope.Tabs.Tab[499]              = tab500;       
        
        
        for(Waitlist_Item__c WLIloop : WLIData){
            //get product short name
            shortName = getDsShortName( WLIloop.Product__r.Name );         
            I++;
            String leadRoutingVal ='' ; 
            String leadroutingVal1 = '';
            String prodsize = '';
            String prodSize1 = '';
            String prodsize2 = '';
             if(shortname == 'Local Expert Zip' || shortname == 'Local Expert City'){
                if(shortname == 'Local Expert Zip'){
                    if(WLIloop.product_size__c=='Any'){
                         //CRM-5011
                        //leadRoutingVal='SOV50, or SOV30, or SOV20*';     
                        leadRoutingVal='SOM50, or SOM30, or SOM20*'; 
                    } else{
                        leadRoutingVal = WLIloop.product_size__c.replace('V','M');
                    } 
                }else{
                    leadRoutingVal='SOM10';
                }
            }else{
                if(WLIloop.Lead_Routing__c=='Any'){
                    leadRoutingVal='Flex if possible, otherwise Fast'; 
                }else{
                    leadRoutingVal = WLIloop.Lead_Routing__c;
                }
            }
 
            if(I == 1){

                tab6 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Markettag1');
                tab7 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spendtag1');
                tab8 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptypetag1');
                tab9 = ReturnTab('Custom',shortname,1,1,'Nameofproducttag1');
                tab503 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmptrms1'); 
                 
                
                envelope.Tabs.Tab[5]                = tab6;       
                envelope.Tabs.Tab[6]                = tab7;       
                envelope.Tabs.Tab[7]                = tab8;       
                envelope.Tabs.Tab[8]                = tab9; 
                envelope.Tabs.Tab[503]              = tab503; 
                
            }
            if(I == 2){
                
                tab10 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Markettag2');
                tab11 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spendtag2');
                tab12 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptypetag2');
                tab13 = ReturnTab('Custom',shortname,1,1,'Nameofproducttag2');
                tab504 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmptrms2'); 
               
               


                envelope.Tabs.Tab[9]                = tab10;       
                envelope.Tabs.Tab[10]               = tab11;       
                envelope.Tabs.Tab[11]               = tab12;       
                envelope.Tabs.Tab[12]               = tab13;      
                envelope.Tabs.Tab[504]              = tab504; 
                
            }            
            if(I == 3){
                tab14 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Markettag3');
                tab15 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spendtag3');
                tab16 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptypetag3');
                tab17 = ReturnTab('Custom',shortname,1,1,'Nameofproducttag3');
                tab505 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmptrms3'); 
              


                envelope.Tabs.Tab[13]                = tab14;       
                envelope.Tabs.Tab[14]               = tab15;       
                envelope.Tabs.Tab[15]               = tab16;       
                envelope.Tabs.Tab[16]               = tab17;      
                envelope.Tabs.Tab[505]              = tab505; 
                
            }
            if(I == 4){

                tab18 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Markettag4');
                tab19 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spendtag4');
                tab20 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptypetag4');
                tab21 = ReturnTab('Custom',shortname,1,1,'Nameofproducttag4');
                tab506 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmptrms4'); 
               
                envelope.Tabs.Tab[17]               = tab18;       
                envelope.Tabs.Tab[18]               = tab19;       
                envelope.Tabs.Tab[19]               = tab20;       
                envelope.Tabs.Tab[20]               = tab21; 
                envelope.Tabs.Tab[506]                = tab506; 
                
            }            
            if(I == 5){

                tab22 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Markettag5');
                tab23 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spendtag5');
                tab24 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptypetag5');
                tab25 = ReturnTab('Custom',shortname,1,1,'Nameofproducttag5');
                tab507 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmptrms5'); 
                
                
                envelope.Tabs.Tab[21]               = tab22;       
                envelope.Tabs.Tab[22]               = tab23;       
                envelope.Tabs.Tab[23]               = tab24;       
                envelope.Tabs.Tab[24]               = tab25;  
                envelope.Tabs.Tab[507]                = tab507; 
                
            }
            if(I == 6){

                tab26 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Markettag6');
                tab27 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spendtag6');
                tab28 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptypetag6');
                tab29 = ReturnTab('Custom',shortname,1,1,'Nameofproducttag6');
                tab508 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmptrms6');
                
              

                envelope.Tabs.Tab[25]               = tab26;       
                envelope.Tabs.Tab[26]               = tab27;       
                envelope.Tabs.Tab[27]               = tab28;       
                envelope.Tabs.Tab[28]               = tab29; 
                envelope.Tabs.Tab[508]                = tab508; 
                
            }
            if(I == 7){

                tab30 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Markettag7');
                tab31 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spendtag7');
                tab32 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptypetag7');
                tab33 = ReturnTab('Custom',shortname,1,1,'Nameofproducttag7');
                tab509 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmptrms7');

                
                envelope.Tabs.Tab[29]               = tab30;       
                envelope.Tabs.Tab[30]               = tab31;       
                envelope.Tabs.Tab[31]               = tab32;       
                envelope.Tabs.Tab[32]               = tab33;  
                envelope.Tabs.Tab[509]                = tab509; 
                
            }
            if(I == 8){

                tab34 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Markettag8');
                tab35 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spendtag8');
                tab36 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptypetag8');
                tab37 = ReturnTab('Custom',shortname,1,1,'Nameofproducttag8');
                tab510 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmptrms8');

              
                envelope.Tabs.Tab[33]               = tab34;       
                envelope.Tabs.Tab[34]               = tab35;       
                envelope.Tabs.Tab[35]               = tab36;                
                envelope.Tabs.Tab[36]               = tab37;      
                envelope.Tabs.Tab[510]                = tab510; 
                
            }            
            if(I == 9){

                tab38 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Markettag9');
                tab39 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spendtag9');
                tab40 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptypetag9');
                tab41 = ReturnTab('Custom',shortname,1,1,'Nameofproducttag9');
                tab511 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmptrms9');

             

                envelope.Tabs.Tab[37]               = tab38;       
                envelope.Tabs.Tab[38]               = tab39;       
                envelope.Tabs.Tab[39]               = tab40;                
                envelope.Tabs.Tab[40]               = tab41;  
                envelope.Tabs.Tab[511]                = tab511; 
                
            }
            if(I == 10){

                tab42 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market10tag');
                tab43 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend10tag');
                tab44 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype10tag');
                tab45 = ReturnTab('Custom',shortname,1,1,'Nameofproduct10tag');
                tab512 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Temaprts10tag');

               
                envelope.Tabs.Tab[41]               = tab42;       
                envelope.Tabs.Tab[42]               = tab43;       
                envelope.Tabs.Tab[43]               = tab44;                
                envelope.Tabs.Tab[44]               = tab45;   
                envelope.Tabs.Tab[512]                = tab512; 
                
            }                
            if(I == 11){

                tab46 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market11tag');
                tab47 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend11tag');
                tab48 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype11tag');
                tab49 = ReturnTab('Custom',shortname,1,1,'Nameofproduct11tag');
                tab514 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tematag11s');
                
                envelope.Tabs.Tab[514]                = tab514; 
                envelope.Tabs.Tab[45]               = tab46;       
                envelope.Tabs.Tab[46]               = tab47;       
                envelope.Tabs.Tab[47]               = tab48;                
                envelope.Tabs.Tab[48]               = tab49;    
            }  
            if(I == 12){

                tab50 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market12tag');
                tab51 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend12tag');
                tab52 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype12tag');
                tab53 = ReturnTab('Custom',shortname,1,1,'Nameofproduct12tag');
                tab515 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tematag12s');
                envelope.Tabs.Tab[515]                = tab515;                 
                envelope.Tabs.Tab[49]               = tab50;       
                envelope.Tabs.Tab[50]               = tab51;       
                envelope.Tabs.Tab[51]               = tab52;                
                envelope.Tabs.Tab[52]               = tab53;    
            } 
            
            if(I == 13){

                tab54 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market13tag');
                tab55 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend13tag');
                tab56 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype13tag');
                tab57 = ReturnTab('Custom',shortname,1,1,'Nameofproduct13tag');
                tab516 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tematag13s');
               
                envelope.Tabs.Tab[516]                = tab516; 
                envelope.Tabs.Tab[53]               = tab54;       
                envelope.Tabs.Tab[54]               = tab55;       
                envelope.Tabs.Tab[55]               = tab56;                
                envelope.Tabs.Tab[56]               = tab57;    
            } 
            if(I == 14){

                tab58 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market14tag');
                tab59 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend14tag');
                tab60 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype14tag');
                tab61 = ReturnTab('Custom',shortname,1,1,'Nameofproduct14tag');
                tab517 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tematag14s');
               
                envelope.Tabs.Tab[517]                = tab517; 
                envelope.Tabs.Tab[57]               = tab58;       
                envelope.Tabs.Tab[58]               = tab59;       
                envelope.Tabs.Tab[59]               = tab60;                
                envelope.Tabs.Tab[60]               = tab61;    
            }   
            if(I == 15){

                tab62 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market15tag');
                tab63 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend15tag');
                tab64 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype15tag');
                tab65 = ReturnTab('Custom',shortname,1,1,'Nameofproduct15tag');
                tab518 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tematag15s');
               
                envelope.Tabs.Tab[518]                = tab518;                 
                envelope.Tabs.Tab[61]               = tab62;       
                envelope.Tabs.Tab[62]               = tab63;       
                envelope.Tabs.Tab[63]               = tab64;                
                envelope.Tabs.Tab[64]               = tab65;    
            } 
            if(I == 16){
                tab66 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market16tag');
                tab67 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend16tag');
                tab68 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype16tag');
                tab69 = ReturnTab('Custom',shortname,1,1,'Nameofproduct16tag');
                tab519 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tematag16s');
               
                envelope.Tabs.Tab[519]                = tab519;                 
                envelope.Tabs.Tab[65]               = tab66;       
                envelope.Tabs.Tab[66]               = tab67;       
                envelope.Tabs.Tab[67]               = tab68;                
                envelope.Tabs.Tab[68]               = tab69;    
            }
            if(I == 17){

                tab70 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market17tag');
                tab71 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend17tag');
                tab72 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype17tag');
                tab73 = ReturnTab('Custom',shortname,1,1,'Nameofproduct17tag');
                tab520 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tematag17s');
                
                envelope.Tabs.Tab[520]                = tab520;            
                envelope.Tabs.Tab[69]               = tab70;       
                envelope.Tabs.Tab[70]               = tab71;       
                envelope.Tabs.Tab[71]               = tab72;                
                envelope.Tabs.Tab[72]               = tab73;    
            }
            if(I == 18){
                tab74 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market18tag');
                tab75 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend18tag');
                tab76 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype18tag');
                tab77 = ReturnTab('Custom',shortname,1,1,'Nameofproduct18tag');
                tab521 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tematag18s');
               
                envelope.Tabs.Tab[521]                = tab521; 
                envelope.Tabs.Tab[73]               = tab74;       
                envelope.Tabs.Tab[74]               = tab75;       
                envelope.Tabs.Tab[75]               = tab76;                
                envelope.Tabs.Tab[76]               = tab77;    
            }
            if(I == 19){

                tab78 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market19tag');
                tab79 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend19tag');
                tab80 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype19tag');
                tab81 = ReturnTab('Custom',shortname,1,1,'Nameofproduct19tag');
                tab522 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tematag19s');
                
                envelope.Tabs.Tab[522]                = tab522;       
                envelope.Tabs.Tab[77]               = tab78;       
                envelope.Tabs.Tab[78]               = tab79;       
                envelope.Tabs.Tab[79]               = tab80;                
                envelope.Tabs.Tab[80]               = tab81;    
            }
            if(I == 20){
                tab82 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market20tag');
                tab83 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend20tag');
                tab84 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype20tag');
                tab85 = ReturnTab('Custom',shortname,1,1,'Nameofproduct20tag');
                tab523 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tematag20s');
               
                envelope.Tabs.Tab[523]                = tab523; 
                envelope.Tabs.Tab[81]               = tab82;       
                envelope.Tabs.Tab[82]               = tab83;       
                envelope.Tabs.Tab[83]               = tab84;                
                envelope.Tabs.Tab[84]               = tab85;    
            }
            if(I == 21){
                tab86 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market21tag');
                tab87 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend21tag');
                tab88 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype21tag');
                tab89 = ReturnTab('Custom',shortname,1,1,'Nameofproduct21tag');
                tab525 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpaskdas21');
               
                envelope.Tabs.Tab[525]                = tab525; 
                envelope.Tabs.Tab[85]               = tab86;       
                envelope.Tabs.Tab[86]               = tab87;       
                envelope.Tabs.Tab[87]               = tab88;                
                envelope.Tabs.Tab[88]               = tab89;    
            }
            if(I == 22){

                tab90 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market22tag');
                tab91 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend22tag');
                tab92 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype22tag');
                tab93 = ReturnTab('Custom',shortname,1,1,'Nameofproduct22tag');
                tab526 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpaskdas22');      
               
                envelope.Tabs.Tab[526]                = tab526; 
                envelope.Tabs.Tab[89]               = tab90;       
                envelope.Tabs.Tab[90]               = tab91;       
                envelope.Tabs.Tab[91]               = tab92;                
                envelope.Tabs.Tab[92]               = tab93;    
            }
            if(I == 23){
                tab94 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market23tag');
                tab95 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend23tag');
                tab96 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype23tag');
                tab97 = ReturnTab('Custom',shortname,1,1,'Nameofproduct23tag');
                tab527 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpaskdas23');     
                
                envelope.Tabs.Tab[527]                = tab527;                 
                envelope.Tabs.Tab[93]               = tab94;       
                envelope.Tabs.Tab[94]               = tab95;       
                envelope.Tabs.Tab[95]               = tab96;                
                envelope.Tabs.Tab[96]               = tab97;    
            }
            if(I == 24){
                tab98 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market24tag');
                tab99 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend24tag');
                tab100 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype24tag');
                tab101 = ReturnTab('Custom',shortname,1,1,'Nameofproduct24tag');
                tab528 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpaskdas24');    
               
                envelope.Tabs.Tab[528]                = tab528;                 
                envelope.Tabs.Tab[97]               = tab98;       
                envelope.Tabs.Tab[98]               = tab99;       
                envelope.Tabs.Tab[99]               = tab100;                
                envelope.Tabs.Tab[100]              = tab101;    
            }
            if(I == 25){

                tab102 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market25tag');
                tab103 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend25tag');
                tab104 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype25tag');
                tab105 = ReturnTab('Custom',shortname,1,1,'Nameofproduct25tag');
                tab529 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpaskdas25');    
               
                envelope.Tabs.Tab[529]                = tab529;                
                envelope.Tabs.Tab[101]               = tab102;       
                envelope.Tabs.Tab[102]               = tab103;       
                envelope.Tabs.Tab[103]               = tab104;                
                envelope.Tabs.Tab[104]               = tab105;    
            }
            if(I == 26){

                tab106 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market26tag');
                tab107 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend26tag');
                tab108 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype26tag');
                tab109 = ReturnTab('Custom',shortname,1,1,'Nameofproduct26tag');
                tab530 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpaskdas26');    
               
                envelope.Tabs.Tab[530]                = tab530;       
                envelope.Tabs.Tab[105]               = tab106;       
                envelope.Tabs.Tab[106]               = tab107;       
                envelope.Tabs.Tab[107]               = tab108;                
                envelope.Tabs.Tab[108]               = tab109;    
            }
            if(I == 27){

                tab110 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market27tag');
                tab111 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend27tag');
                tab112 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype27tag');
                tab113 = ReturnTab('Custom',shortname,1,1,'Nameofproduct27tag');
                tab531 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpaskdas27');    
                
                envelope.Tabs.Tab[531]                = tab531;         
                envelope.Tabs.Tab[109]               = tab110;       
                envelope.Tabs.Tab[110]               = tab111;       
                envelope.Tabs.Tab[111]               = tab112;                
                envelope.Tabs.Tab[112]               = tab113;    
            }
            if(I == 28){

                tab114 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market28tag');
                tab115 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend28tag');
                tab116 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype28tag');
                tab117 = ReturnTab('Custom',shortname,1,1,'Nameofproduct28tag');
                tab532 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpaskdas28');    
               
                envelope.Tabs.Tab[532]                = tab532; 
                envelope.Tabs.Tab[113]               = tab114;       
                envelope.Tabs.Tab[114]               = tab115;       
                envelope.Tabs.Tab[115]               = tab116;                
                envelope.Tabs.Tab[116]               = tab117;    
            }
            if(I == 29){

                tab118 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market29tag');
                tab119 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend29tag');
                tab120 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype29tag');
                tab121 = ReturnTab('Custom',shortname,1,1,'Nameofproduct29tag');
                tab533 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpaskdas29');    
               
                envelope.Tabs.Tab[533]                = tab533;                 
                envelope.Tabs.Tab[117]               = tab118;       
                envelope.Tabs.Tab[118]               = tab119;       
                envelope.Tabs.Tab[119]               = tab120;                
                envelope.Tabs.Tab[120]               = tab121;    
            }
            if(I == 30){

                tab122 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market30tag');
                tab123 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend30tag');
                tab124 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype30tag');
                tab125 = ReturnTab('Custom',shortname,1,1,'Nameofproduct30tag');
                tab534 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpamhaj30');    
               
                
                envelope.Tabs.Tab[534]                = tab534; 
                envelope.Tabs.Tab[121]               = tab122;       
                envelope.Tabs.Tab[122]               = tab123;       
                envelope.Tabs.Tab[123]               = tab124;                
                envelope.Tabs.Tab[124]               = tab125;    
            }
            if(I == 31){
                tab126 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market31tag');
                tab127 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend31tag');
                tab128 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype31tag');
                tab129 = ReturnTab('Custom',shortname,1,1,'Nameofproduct31tag');
                tab536 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpamhaj31');    
               
                envelope.Tabs.Tab[536]                = tab536; 
                envelope.Tabs.Tab[125]               = tab126;       
                envelope.Tabs.Tab[126]               = tab127;       
                envelope.Tabs.Tab[127]               = tab128;                
                envelope.Tabs.Tab[128]               = tab129;    
            }
            if(I == 32){
                tab130 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market32tag');
                tab131 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend32tag');
                tab132 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype32tag');
                tab133 = ReturnTab('Custom',shortname,1,1,'Nameofproduct32tag');
                tab537 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpamhaj32');    
                
                envelope.Tabs.Tab[537]                = tab537; 
                envelope.Tabs.Tab[129]               = tab130;       
                envelope.Tabs.Tab[130]               = tab131;       
                envelope.Tabs.Tab[131]               = tab132;                
                envelope.Tabs.Tab[132]               = tab133;    
            }
            if(I == 33){
                tab134 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market33tag');
                tab135 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend33tag');
                tab136 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype33tag');
                tab137 = ReturnTab('Custom',shortname,1,1,'Nameofproduct33tag');
                tab538 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpamhaj33');    
               
                envelope.Tabs.Tab[538]                = tab538; 
                envelope.Tabs.Tab[133]               = tab134;       
                envelope.Tabs.Tab[134]               = tab135;       
                envelope.Tabs.Tab[135]               = tab136;                
                envelope.Tabs.Tab[136]               = tab137;    
            }
            if(I == 34){
                tab138 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market34tag');
                tab139 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend34tag');
                tab140 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype34tag');
                tab141 = ReturnTab('Custom',shortname,1,1,'Nameofproduct34tag');
                tab539 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpamhaj34');    
               
                envelope.Tabs.Tab[539]               = tab539; 
                envelope.Tabs.Tab[137]               = tab138;       
                envelope.Tabs.Tab[138]               = tab139;       
                envelope.Tabs.Tab[139]               = tab140;                
                envelope.Tabs.Tab[140]               = tab141;    
            }
            if(I == 35){

                tab142 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market35tag');
                tab143 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend35tag');
                tab144 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype35tag');
                tab145 = ReturnTab('Custom',shortname,1,1,'Nameofproduct35tag');
                tab540 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpamhaj35');  
                
                envelope.Tabs.Tab[540]                = tab540; 
                envelope.Tabs.Tab[141]               = tab142;       
                envelope.Tabs.Tab[142]               = tab143;       
                envelope.Tabs.Tab[143]               = tab144;                
                envelope.Tabs.Tab[144]               = tab145;    
            }
            if(I == 36){
                tab146 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market36tag');
                tab147 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend36tag');
                tab148 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype36tag');
                tab149 = ReturnTab('Custom',shortname,1,1,'Nameofproduct36tag');
                tab541 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpamhaj36'); 
               
                envelope.Tabs.Tab[541]                = tab541; 
                envelope.Tabs.Tab[145]               = tab146;       
                envelope.Tabs.Tab[146]               = tab147;       
                envelope.Tabs.Tab[147]               = tab148;                
                envelope.Tabs.Tab[148]               = tab149;    
            }
            if(I == 37){
                tab150 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market37tag');
                tab151 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend37tag');
                tab152 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype37tag');
                tab153 = ReturnTab('Custom',shortname,1,1,'Nameofproduct37tag');
                tab542 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpamhaj37'); 
                
                envelope.Tabs.Tab[542]                = tab542; 
                envelope.Tabs.Tab[149]               = tab150;       
                envelope.Tabs.Tab[150]               = tab151;       
                envelope.Tabs.Tab[151]               = tab152;                
                envelope.Tabs.Tab[152]               = tab153;    
            }
            if(I == 38){

                tab154 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market38tag');
                tab155 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend38tag');
                tab156 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype38tag');
                tab157 = ReturnTab('Custom',shortname,1,1,'Nameofproduct38tag');
                tab543 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpamhaj38'); 
               
                envelope.Tabs.Tab[543]               = tab543; 
                envelope.Tabs.Tab[153]               = tab154;       
                envelope.Tabs.Tab[154]               = tab155;       
                envelope.Tabs.Tab[155]               = tab156;                
                envelope.Tabs.Tab[156]               = tab157;    
            }
            if(I == 39){
                tab158 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market39tag');
                tab159 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend39tag');
                tab160 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype39tag');
                tab161 = ReturnTab('Custom',shortname,1,1,'Nameofproduct39tag');
                tab544 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpamhaj39'); 
                
                envelope.Tabs.Tab[544]                = tab544; 
                envelope.Tabs.Tab[157]               = tab158;       
                envelope.Tabs.Tab[158]               = tab159;       
                envelope.Tabs.Tab[159]               = tab160;                
                envelope.Tabs.Tab[160]               = tab161;    
            }
            if(I == 40){

                tab162 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market40tag');
                tab163 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend40tag');
                tab164 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype40tag');
                tab165 = ReturnTab('Custom',shortname,1,1,'Nameofproduct40tag');
                tab545 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmpamhaj40'); 
                
                envelope.Tabs.Tab[545]                = tab545; 
                envelope.Tabs.Tab[161]               = tab162;       
                envelope.Tabs.Tab[162]               = tab163;       
                envelope.Tabs.Tab[163]               = tab164;                
                envelope.Tabs.Tab[164]               = tab165;    
            }
            if(I == 41){

                tab166 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market41tag');
                tab167 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend41tag');
                tab168 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype41tag');
                tab169 = ReturnTab('Custom',shortname,1,1,'Nameofproduct41tag');
                tab547 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tpasamhh41'); 
               
                envelope.Tabs.Tab[547]                = tab547; 
                envelope.Tabs.Tab[165]               = tab166;       
                envelope.Tabs.Tab[166]               = tab167;       
                envelope.Tabs.Tab[167]               = tab168;                
                envelope.Tabs.Tab[168]               = tab169;    
            }
            if(I == 42){

                tab170 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market42tag');
                tab171 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend42tag');
                tab172 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype42tag');
                tab173 = ReturnTab('Custom',shortname,1,1,'Nameofproduct42tag');
                tab548 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tpasamhh42'); 
               
                envelope.Tabs.Tab[548]                = tab548; 
                envelope.Tabs.Tab[169]               = tab170;       
                envelope.Tabs.Tab[170]               = tab171;       
                envelope.Tabs.Tab[171]               = tab172;                
                envelope.Tabs.Tab[172]               = tab173;    
            }
            if(I == 43){
                tab174 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market43tag');
                tab175 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend43tag');
                tab176 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype43tag');
                tab177 = ReturnTab('Custom',shortname,1,1,'Nameofproduct43tag');
                tab549 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tpasamhh43'); 
               
                
                envelope.Tabs.Tab[549]                = tab549;
                envelope.Tabs.Tab[173]               = tab174;       
                envelope.Tabs.Tab[174]               = tab175;       
                envelope.Tabs.Tab[175]               = tab176;                
                envelope.Tabs.Tab[176]               = tab177;    
            }
            if(I == 44){
                tab178 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market44tag');
                tab179 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend44tag');
                tab180 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype44tag');
                tab181 = ReturnTab('Custom',shortname,1,1,'Nameofproduct44tag');
                tab550 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tpasamhh44'); 
                
                envelope.Tabs.Tab[550]                = tab550;  
                envelope.Tabs.Tab[177]               = tab178;       
                envelope.Tabs.Tab[178]               = tab179;       
                envelope.Tabs.Tab[179]               = tab180;                
                envelope.Tabs.Tab[180]               = tab181;    
            }
            if(I == 45){
                tab182 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market45tag');
                tab183 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend45tag');
                tab184 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype45tag');
                tab185 = ReturnTab('Custom',shortname,1,1,'Nameofproduct45tag');
                tab551 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tpasamhh45'); 
                
                
                envelope.Tabs.Tab[551]                = tab551;
                envelope.Tabs.Tab[181]               = tab182;       
                envelope.Tabs.Tab[182]               = tab183;       
                envelope.Tabs.Tab[183]               = tab184;                
                envelope.Tabs.Tab[184]               = tab185;    
            }
            if(I == 46){
                tab186 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market46tag');
                tab187 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend46tag');
                tab188 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype46tag');
                tab189 = ReturnTab('Custom',shortname,1,1,'Nameofproduct46tag');
                tab552 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tpasamhh46'); 
               
                envelope.Tabs.Tab[552]                = tab552;
                envelope.Tabs.Tab[185]               = tab186;       
                envelope.Tabs.Tab[186]               = tab187;       
                envelope.Tabs.Tab[187]               = tab188;                
                envelope.Tabs.Tab[188]               = tab189;    
            }
            if(I == 47){
                tab190 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market47tag');
                tab191 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend47tag');
                tab192 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype47tag');
                tab193 = ReturnTab('Custom',shortname,1,1,'Nameofproduct47tag');
                tab553 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tpasamhh47');
                
                
                envelope.Tabs.Tab[553]                = tab553;
                envelope.Tabs.Tab[189]               = tab190;       
                envelope.Tabs.Tab[190]               = tab191;       
                envelope.Tabs.Tab[191]               = tab192;                
                envelope.Tabs.Tab[192]               = tab193;    
            }
            if(I == 48){
                tab194 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market48tag');
                tab195 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend48tag');
                tab196 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype48tag');
                tab197 = ReturnTab('Custom',shortname,1,1,'Nameofproduct48tag');
                tab554 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tpasamhh48');
               
                envelope.Tabs.Tab[554]                = tab554;
                envelope.Tabs.Tab[193]               = tab194;       
                envelope.Tabs.Tab[194]               = tab195;       
                envelope.Tabs.Tab[195]               = tab196;                
                envelope.Tabs.Tab[196]               = tab197;    
            }
            if(I == 49){
                tab198 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market49tag');
                tab199 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend49tag');
                tab200 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype49tag');
                tab201 = ReturnTab('Custom',shortname,1,1,'Nameofproduct49tag');
                tab555 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tpasamhh49');
               
                
                envelope.Tabs.Tab[555]                = tab555;
                envelope.Tabs.Tab[197]               = tab198;       
                envelope.Tabs.Tab[198]               = tab199;       
                envelope.Tabs.Tab[199]               = tab200;                
                envelope.Tabs.Tab[200]               = tab201;    
            }
            if(I == 50){
                
                tab202 = ReturnTab('Custom',WLIloop.Market__c,1,1,'Market50tag');
                tab203 = ReturnTab('Custom',string.valueof(WLIloop.Original_Max_Spend__c),1,1,'Spend50tag');
                tab204 = ReturnTab('Custom',leadRoutingVal,1,1,'Ptype50tag');
                tab205 = ReturnTab('Custom',shortname,1,1,'Nameofproduct50tag');
                tab556 = ReturnTab('Custom',WLILoop.Term__c,1,1,'Tmahanp50');
                
                envelope.Tabs.Tab[556]                = tab556;
                envelope.Tabs.Tab[201]               = tab202;       
                envelope.Tabs.Tab[202]               = tab203;       
                envelope.Tabs.Tab[203]               = tab204;                
                envelope.Tabs.Tab[204]               = tab205;  

                document = senddocusign1.SendNow1(WLid, document, envelope);
            System.debug('document===>>'+document);
                
            }
        }
        
        // CRM-3406 - Start
        // Default values
        Integer reminderDelay=1, reminderFrequency=7, expireWarn=7, expireAfter=30;
        Map<String, Waitlist_Limit__c> defaultValues = Waitlist_Limit__c.getAll();
        if (defaultValues.containsKey('ReminderDelay')) {
            reminderDelay = Integer.valueOf(defaultValues.get('ReminderDelay').Value__c);
        }
        if (defaultValues.containsKey('ReminderFrequency')) {
            reminderFrequency = Integer.valueOf(defaultValues.get('ReminderFrequency').Value__c);
        }
        if (defaultValues.containsKey('ExpireWarn')) {
            expireWarn = Integer.valueOf(defaultValues.get('ExpireWarn').Value__c);
        }
        if (defaultValues.containsKey('ExpireAfter')) {
            expireAfter = Integer.valueOf(defaultValues.get('ExpireAfter').Value__c);
        }
        DocuSignAPI.Notification Notification = new DocuSignAPI.Notification();
        DocuSignAPI.Reminders Reminders = new DocuSignAPI.Reminders();
        Reminders.ReminderEnabled = true;
        Reminders.ReminderDelay = reminderDelay;
        Reminders.ReminderFrequency = reminderFrequency;
        Notification.UseAccountDefaults = false;
        Notification.Reminders = Reminders;
        
        // CRM-4190 - Start
        DocuSignAPI.Expirations  Expirations  = new DocuSignAPI.Expirations();      
        Expirations.ExpireEnabled = true;
        Expirations.ExpireWarn = expireWarn;
        Expirations.ExpireAfter = expireAfter;
        Notification.Expirations = Expirations;
        // CRM-4190 - End
        
        envelope.Notification = Notification;
        // CRM-3406 - End
                
        try {
            //sending Envelope
            System.debug('Came into try =====');
            DocuSignAPI.EnvelopeStatus EnvStatus = dsApiSend.CreateAndSendEnvelope(envelope);
            if ( !Test.isRunningTest() ){
                envelopeId = EnvStatus.EnvelopeID;
            } else{
                envelopeId = '12345';
            }
            System.debug('EnvStatus====='+EnvStatus); 
            //attaching DocuSign status object to Waitlist object
            System.debug('============ ATTACHING ======================'+WLid);
            dsfs__DocuSign_Status__c DocStatus      = new dsfs__DocuSign_Status__c();
            DocStatus.dsfs__DocuSign_Envelope_ID__c = envelopeId;
            DocStatus.dsfs__Sender__c               = userinfo.getusername();
            DocStatus.dsfs__Sender_Email__c         = userinfo.getuseremail();
            DocStatus.dsfs__Subject__c              = envelope.Subject;
            DocStatus.Waitlist__c                   = WLid;
            if ( !Test.isRunningTest() ){
                DocStatus.dsfs__Envelope_Status__c  = EnvStatus.status;
            } else{
                DocStatus.dsfs__Envelope_Status__c  = 'Sent';
            }
            insert DocStatus;
             System.debug('============ DocStatus ======================'+DocStatus.Id);
        } catch ( CalloutException error) {
            envelopeId = 'Exception - ' + error;
            Error__c logerror               = new Error__c();
            logerror.Name                   = WLid;
            logerror.Entity_Id__c           = 'Waitlist';
            logerror.Error_Description__c   = string.valueof(error);
            logerror.Interface_Name__c      = 'DocuSign';
            Insert logerror;
        }          
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
    
}