Public class SendDocusign1 {

public static DocuSignAPI.Document SendNow1(string WLid,DocuSignAPI.Document document,DocuSignAPI.Envelope envelope){
        Integer I = 0;        
        integer numberofproducts;
        string shortname;
        
        
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
        Waitlist__c WLData = [select CreatedDate ,Pre_Auth_Email__c,
                              Current_Monthly_Pre_Auth_Spend__c ,
                              Total_MAX_Monthly_Pre_Auth_Spend__c ,
                              Pre_Auth_Contact__r.FirstName,Pre_Auth_Contact__r.LastName,Account__r.owner.email,
                              Account__r.owner.name,CC4Digits__c,
                              (select Product__r.Name,Market__c,Market_Type__c,
                               Original_Max_Spend__c,Waitlist_Expiration_Date__c,Lead_Routing__c, Term__c  
                               from Waitlist_Items__r where Term__c In ('6','12') AND Status__c NOT IN ('Fulfilled' ,'Canceled','Rejected Pre-Auth','Expired') ) 
                              from Waitlist__c where id = :WLid AND Status__c NOT IN ('Fulfilled' ,'Canceled','Rejected Pre-Auth','Expired')];
        
        
        numberofproducts = WLIData.size();
     
        
        
       
        
         DocuSignAPI.Tab tab206              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab207              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab208              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab209              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab210              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab211              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab212              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab213              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab214              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab215              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab216              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab217              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab218              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab219              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab220              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab221              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab222              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab223              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab224              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab225              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab226              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab227              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab228              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab229              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab230              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab231              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab232              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab233              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab234              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab235              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab236              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab237              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab238              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab239              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab240              = new DocuSignAPI.Tab();
       DocuSignAPI.Tab tab241              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab242              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab243              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab244              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab245              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab499              = new DocuSignAPI.Tab();
        
        
        DocuSignAPI.Tab tab246              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab247              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab248              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab249              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab250              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab251              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab252              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab253              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab254              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab255              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab256              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab257              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab258              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab259              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab260              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab261              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab262              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab263              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab264              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab265              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab266              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab267              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab268              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab269              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab270              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab271              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab272              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab273              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab274              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab275              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab276              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab277              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab278              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab279              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab280              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab281              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab282              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab283              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab284              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab285              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab286              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab287              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab288              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab289              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab290              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab291              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab292              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab293              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab294              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab295              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab296              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab297              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab298              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab299              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab300              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab301              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab302              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab303              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab304              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab305              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab306              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab307              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab308              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab309              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab310              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab311              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab312              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab313              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab314              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab315              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab316              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab317              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab318              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab319              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab320              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab321              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab322              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab323              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab324              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab325              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab326              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab327              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab328              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab329              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab330              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab331              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab332              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab333              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab334              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab335              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab336              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab337              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab338              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab339              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab340              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab341              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab342              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab343              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab344              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab345              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab346              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab347              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab348              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab349              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab350              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab351              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab352              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab353              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab354              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab355              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab356              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab357              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab358              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab359              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab360              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab361              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab362              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab363              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab364              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab365              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab366              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab367              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab368              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab369              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab370              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab371              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab372              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab373              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab374              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab375              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab376              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab377              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab378              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab379              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab380              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab381              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab382              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab383              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab384              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab385              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab386              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab387              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab388              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab389              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab390              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab391              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab392              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab393              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab394              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab395              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab396              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab397              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab398              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab399              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab400              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab401              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab402              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab403              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab404              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab405              = new DocuSignAPI.Tab();  
        
        
         
        // Term 51 to 60 
        
        
           DocuSignAPI.Tab tab558           = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab559              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab560              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab561              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab562              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab563              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab564              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab565              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab566              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab567              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab568              = new DocuSignAPI.Tab();
        
        
        // Term 61 to 70 
        
        
        DocuSignAPI.Tab tab569             = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab570              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab571              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab572              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab573              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab574              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab575              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab576              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab577              = new DocuSignAPI.Tab();
                DocuSignAPI.Tab tab578             = new DocuSignAPI.Tab();

     
       
 // Term 71 to 80 
        
        
        DocuSignAPI.Tab tab579              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab580              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab581              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab582              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab583              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab584              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab585              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab586              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab587           = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab588              = new DocuSignAPI.Tab();

       // Term 81 to 90 
        
        
       
        DocuSignAPI.Tab tab589              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab590              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab591              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab592              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab593              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab594              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab595              = new DocuSignAPI.Tab();
       DocuSignAPI.Tab tab596            = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab597              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab598              = new DocuSignAPI.Tab();

       // Term 91 to 100 
        
        
        
        DocuSignAPI.Tab tab599              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab600              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab601              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab602              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab603              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab604              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab605              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab606              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab607              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab608              = new DocuSignAPI.Tab();
       

       
        // size 51 to 60 
        
        
           DocuSignAPI.Tab tab664           = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab665              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab666              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab667              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab668              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab669              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab670              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab671              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab672              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab673              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab674              = new DocuSignAPI.Tab();
        
        
        // size 61 to 70 
        
        
        DocuSignAPI.Tab tab675             = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab676              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab677              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab678              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab679              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab680              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab681              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab682              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab683              = new DocuSignAPI.Tab();
                DocuSignAPI.Tab tab684             = new DocuSignAPI.Tab();

     
       
 // size 71 to 80 
        
        
        DocuSignAPI.Tab tab685              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab686              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab687              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab688              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab689              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab690              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab691              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab692              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab693           = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab694              = new DocuSignAPI.Tab();

       // size 81 to 90 
        
        
       
        DocuSignAPI.Tab tab695              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab696              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab697              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab698              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab699              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab700              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab701              = new DocuSignAPI.Tab();
       DocuSignAPI.Tab tab702            = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab703              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab704              = new DocuSignAPI.Tab();

       // size 91 to 100 
        
        
        
        DocuSignAPI.Tab tab705              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab706              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab707              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab708              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab709              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab710              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab711              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab712              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab713              = new DocuSignAPI.Tab();
        DocuSignAPI.Tab tab714              = new DocuSignAPI.Tab();
       


        
        
        for(Waitlist_Item__c WLIloop : WLIData){
            //get product short name
            shortName = sendDocusign.getDsShortName( WLIloop.Product__r.Name );
            
            I++;
            String leadRoutingVal ='' ; 
            String leadroutingVal1 = '';
            String prodsize = '';
            if(shortname == 'Local Expert zip' || shortname == 'Local Expert City'){
                if(shortname == 'Local Expert zip'){
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

           
            if(I == 51){
                tab206.Type_x                         = 'Custom';
                tab206.value                          = WLIloop.Market__c;
                tab206.RecipientID                    = 1;
                tab206.DocumentID                     = 1;
                tab206.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab206.AnchorTabItem.AnchorTabString  = 'Market51tag';        
                
                
                tab207.Type_x                         = 'Custom';
                tab207.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab207.RecipientID                    = 1;
                tab207.DocumentID                     = 1;
                tab207.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab207.AnchorTabItem.AnchorTabString  = 'Spend51tag';
                
                tab208.Type_x                         = 'Custom';
                tab208.value                          =  leadRoutingVal.unescapeJava();
                
                tab208.RecipientID                    = 1;
                tab208.DocumentID                     = 1;
                tab208.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab208.AnchorTabItem.AnchorTabString  = 'Ptype51tag';
                
                tab209.Type_x                         = 'Custom';
                tab209.value                          = shortname;
                tab209.RecipientID                    = 1;
                tab209.DocumentID                     = 1;
                tab209.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab209.AnchorTabItem.AnchorTabString  = 'Nameofproduct51tag';
                
                tab558.Type_x                         = 'Custom';
                tab558.value                          =WLILoop.Term__c ;
                tab558.RecipientID                    = 1;
                tab558.DocumentID                     = 1;
                tab558.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab558.AnchorTabItem.AnchorTabString  = 'Tmahanp51';
                

                
                envelope.Tabs.Tab[205]               = tab206;       
                envelope.Tabs.Tab[206]               = tab207;       
                envelope.Tabs.Tab[207]               = tab208;                
                envelope.Tabs.Tab[208]               = tab209;    
                   envelope.Tabs.Tab[558]                = tab558;
             
            }
            if(I == 52){
                tab210.Type_x                         = 'Custom';
                tab210.value                          = WLIloop.Market__c;
                tab210.RecipientID                    = 1;
                tab210.DocumentID                     = 1;
                tab210.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab210.AnchorTabItem.AnchorTabString  = 'Market52tag';        
                
                
                tab211.Type_x                         = 'Custom';
                tab211.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab211.RecipientID                    = 1;
                tab211.DocumentID                     = 1;
                tab211.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab211.AnchorTabItem.AnchorTabString  = 'Spend52tag';
                
                tab212.Type_x                         = 'Custom';
                tab212.value                          = leadRoutingVal.unescapeJava();
                
                tab212.RecipientID                    = 1;
                tab212.DocumentID                     = 1;
                tab212.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab212.AnchorTabItem.AnchorTabString  = 'Ptype52tag';
                
                tab213.Type_x                         = 'Custom';
                tab213.value                          = shortname;
                tab213.RecipientID                    = 1;
                tab213.DocumentID                     = 1;
                tab213.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab213.AnchorTabItem.AnchorTabString  = 'Nameofproduct52tag';
                 
                tab559.Type_x                         = 'Custom';
                tab559.value                          =WLILoop.Term__c ;
                tab559.RecipientID                    = 1;
                tab559.DocumentID                     = 1;
                tab559.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab559.AnchorTabItem.AnchorTabString  = 'Tmahanp52';
             
                
                envelope.Tabs.Tab[209]               = tab210;       
                envelope.Tabs.Tab[210]               = tab211;       
                envelope.Tabs.Tab[211]               = tab212;                
                envelope.Tabs.Tab[212]               = tab213; 
                  envelope.Tabs.Tab[559]                = tab559;   
            }
            if(I == 53){
                tab214.Type_x                         = 'Custom';
                tab214.value                          = WLIloop.Market__c;
                tab214.RecipientID                    = 1;
                tab214.DocumentID                     = 1;
                tab214.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab214.AnchorTabItem.AnchorTabString  = 'Market53tag';        
                
                
                tab215.Type_x                         = 'Custom';
                tab215.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab215.RecipientID                    = 1;
                tab215.DocumentID                     = 1;
                tab215.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab215.AnchorTabItem.AnchorTabString  = 'Spend53tag';
                
                tab216.Type_x                         = 'Custom';
                tab216.value                          = leadRoutingVal.unescapeJava();
                
                tab216.RecipientID                    = 1;
                tab216.DocumentID                     = 1;
                tab216.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab216.AnchorTabItem.AnchorTabString  = 'Ptype53tag';
                
                tab217.Type_x                         = 'Custom';
                tab217.value                          = shortname;
                tab217.RecipientID                    = 1;
                tab217.DocumentID                     = 1;
                tab217.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab217.AnchorTabItem.AnchorTabString  = 'Nameofproduct53tag';
                
                 
                tab560.Type_x                         = 'Custom';
                tab560.value                          =WLILoop.Term__c ;
                tab560.RecipientID                    = 1;
                tab560.DocumentID                     = 1;
                tab560.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab560.AnchorTabItem.AnchorTabString  = 'Tmahanp53';
              
               
                
                envelope.Tabs.Tab[213]               = tab214;       
                envelope.Tabs.Tab[214]               = tab215;       
                envelope.Tabs.Tab[215]               = tab216;                
                envelope.Tabs.Tab[216]               = tab217;   
                  envelope.Tabs.Tab[560]                = tab560;
                 
            }
            if(I == 54){
                tab218.Type_x                         = 'Custom';
                tab218.value                          = WLIloop.Market__c;
                tab218.RecipientID                    = 1;
                tab218.DocumentID                     = 1;
                tab218.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab218.AnchorTabItem.AnchorTabString  = 'Market54tag';        
                
                
                tab219.Type_x                         = 'Custom';
                tab219.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab219.RecipientID                    = 1;
                tab219.DocumentID                     = 1;
                tab219.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab219.AnchorTabItem.AnchorTabString  = 'Spend54tag';
                
                tab220.Type_x                         = 'Custom';
                tab220.value                          = leadRoutingVal.unescapeJava();
                
                tab220.RecipientID                    = 1;
                tab220.DocumentID                     = 1;
                tab220.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab220.AnchorTabItem.AnchorTabString  = 'Ptype54tag';
                
                tab221.Type_x                         = 'Custom';
                tab221.value                          = shortname;
                tab221.RecipientID                    = 1;
                tab221.DocumentID                     = 1;
                tab221.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab221.AnchorTabItem.AnchorTabString  = 'Nameofproduct54tag';
                
                
                tab561.Type_x                         = 'Custom';
                tab561.value                          =WLILoop.Term__c ;
                tab561.RecipientID                    = 1;
                tab561.DocumentID                     = 1;
                tab561.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab561.AnchorTabItem.AnchorTabString  = 'Tmahanp54';
              
                envelope.Tabs.Tab[217]               = tab218;       
                envelope.Tabs.Tab[218]               = tab219;       
                envelope.Tabs.Tab[219]               = tab220;                
                envelope.Tabs.Tab[220]               = tab221; 
                 envelope.Tabs.Tab[561]                = tab561;   
            }
            if(I == 55){
                tab222.Type_x                         = 'Custom';
                tab222.value                          = WLIloop.Market__c;
                tab222.RecipientID                    = 1;
                tab222.DocumentID                     = 1;
                tab222.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab222.AnchorTabItem.AnchorTabString  = 'Market55tag';        
                
                
                tab223.Type_x                         = 'Custom';
                tab223.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab223.RecipientID                    = 1;
                tab223.DocumentID                     = 1;
                tab223.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab223.AnchorTabItem.AnchorTabString  = 'Spend55tag';
                
                tab224.Type_x                         = 'Custom';
                tab224.value                          =leadRoutingVal.unescapeJava();
                
                tab224.RecipientID                    = 1;
                tab224.DocumentID                     = 1;
                tab224.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab224.AnchorTabItem.AnchorTabString  = 'Ptype55tag';
                
                tab225.Type_x                         = 'Custom';
                tab225.value                          = shortname;
                tab225.RecipientID                    = 1;
                tab225.DocumentID                     = 1;
                tab225.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab225.AnchorTabItem.AnchorTabString  = 'Nameofproduct55tag';
                
                 tab562.Type_x                         = 'Custom';
                tab562.value                          =WLILoop.Term__c ;
                tab562.RecipientID                    = 1;
                tab562.DocumentID                     = 1;
                tab562.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab562.AnchorTabItem.AnchorTabString  = 'Tmahanp55';
               
            
                
                envelope.Tabs.Tab[221]               = tab222;       
                envelope.Tabs.Tab[222]               = tab223;       
                envelope.Tabs.Tab[223]               = tab224;                
                envelope.Tabs.Tab[224]               = tab225; 
                 envelope.Tabs.Tab[562]                = tab562;   
            }
            if(I == 56){
                tab226.Type_x                         = 'Custom';
                tab226.value                          = WLIloop.Market__c;
                tab226.RecipientID                    = 1;
                tab226.DocumentID                     = 1;
                tab226.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab226.AnchorTabItem.AnchorTabString  = 'Market56tag';        
                
                
                tab227.Type_x                         = 'Custom';
                tab227.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab227.RecipientID                    = 1;
                tab227.DocumentID                     = 1;
                tab227.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab227.AnchorTabItem.AnchorTabString  = 'Spend56tag';
                
                tab228.Type_x                         = 'Custom';
                tab228.value                          = leadRoutingVal.unescapeJava();
                
                tab228.RecipientID                    = 1;
                tab228.DocumentID                     = 1;
                tab228.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab228.AnchorTabItem.AnchorTabString  = 'Ptype56tag';
                
                tab229.Type_x                         = 'Custom';
                tab229.value                          = shortname;
                tab229.RecipientID                    = 1;
                tab229.DocumentID                     = 1;
                tab229.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab229.AnchorTabItem.AnchorTabString  = 'Nameofproduct56tag';
                
                
                  tab563.Type_x                         = 'Custom';
                tab563.value                          =WLILoop.Term__c ;
                tab563.RecipientID                    = 1;
                tab563.DocumentID                     = 1;
                tab563.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab563.AnchorTabItem.AnchorTabString  = 'Tmahanp56';
               
             
                
                envelope.Tabs.Tab[225]               = tab226;       
                envelope.Tabs.Tab[226]               = tab227;       
                envelope.Tabs.Tab[227]               = tab228;                
                envelope.Tabs.Tab[228]               = tab229; 
                 envelope.Tabs.Tab[563]                = tab563;   
            }
            if(I == 57){
                tab230.Type_x                         = 'Custom';
                tab230.value                          = WLIloop.Market__c;
                tab230.RecipientID                    = 1;
                tab230.DocumentID                     = 1;
                tab230.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab230.AnchorTabItem.AnchorTabString  = 'Market57tag';        
                
                
                tab231.Type_x                         = 'Custom';
                tab231.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab231.RecipientID                    = 1;
                tab231.DocumentID                     = 1;
                tab231.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab231.AnchorTabItem.AnchorTabString  = 'Spend57tag';
                
                tab232.Type_x                         = 'Custom';
                tab232.value                          = leadRoutingVal.unescapeJava();
                
                tab232.RecipientID                    = 1;
                tab232.DocumentID                     = 1;
                tab232.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab232.AnchorTabItem.AnchorTabString  = 'Ptype57tag';
                
                tab233.Type_x                         = 'Custom';
                tab233.value                          = shortname;
                tab233.RecipientID                    = 1;
                tab233.DocumentID                     = 1;
                tab233.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab233.AnchorTabItem.AnchorTabString  = 'Nameofproduct57tag';
                
                 tab564.Type_x                         = 'Custom';
                tab564.value                          =WLILoop.Term__c ;
                tab564.RecipientID                    = 1;
                tab564.DocumentID                     = 1;
                tab564.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab564.AnchorTabItem.AnchorTabString  = 'Tmahanp57';
                envelope.Tabs.Tab[564]                = tab564;
                
           
                
                envelope.Tabs.Tab[229]               = tab230;       
                envelope.Tabs.Tab[230]               = tab231;       
                envelope.Tabs.Tab[231]               = tab232;                
                envelope.Tabs.Tab[232]               = tab233;    
            }
            if(I == 58){
                tab234.Type_x                         = 'Custom';
                tab234.value                          = WLIloop.Market__c;
                tab234.RecipientID                    = 1;
                tab234.DocumentID                     = 1;
                tab234.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab234.AnchorTabItem.AnchorTabString  = 'Market58tag';        
                
                
                tab235.Type_x                         = 'Custom';
                tab235.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab235.RecipientID                    = 1;
                tab235.DocumentID                     = 1;
                tab235.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab235.AnchorTabItem.AnchorTabString  = 'Spend58tag';
               
                tab236.Type_x                         = 'Custom';
                tab236.value                          = leadRoutingVal.unescapeJava();
                
                tab236.RecipientID                    = 1;
                tab236.DocumentID                     = 1;
                tab236.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab236.AnchorTabItem.AnchorTabString  = 'Ptype58tag';
                
                tab237.Type_x                         = 'Custom';
                tab237.value                          = shortname;
                tab237.RecipientID                    = 1;
                tab237.DocumentID                     = 1;
                tab237.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab237.AnchorTabItem.AnchorTabString  = 'Nameofproduct58tag';
                
                 tab565.Type_x                         = 'Custom';
                tab565.value                          =WLILoop.Term__c ;
                tab565.RecipientID                    = 1;
                tab565.DocumentID                     = 1;
                tab565.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab565.AnchorTabItem.AnchorTabString  = 'Tmahanp58';
                envelope.Tabs.Tab[565]                = tab565;
              
                envelope.Tabs.Tab[233]               = tab234;       
                envelope.Tabs.Tab[234]               = tab235;       
                envelope.Tabs.Tab[235]               = tab236;                
                envelope.Tabs.Tab[236]               = tab237;    
            }
            if(I == 59){
                tab238.Type_x                         = 'Custom';
                tab238.value                          = WLIloop.Market__c;
                tab238.RecipientID                    = 1;
                tab238.DocumentID                     = 1;
                tab238.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab238.AnchorTabItem.AnchorTabString  = 'Market59tag';        
                
                
                tab239.Type_x                         = 'Custom';
                tab239.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab239.RecipientID                    = 1;
                tab239.DocumentID                     = 1;
                tab239.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab239.AnchorTabItem.AnchorTabString  = 'Spend59tag';
               
                tab240.Type_x                         = 'Custom';
                tab240.value                          = leadRoutingVal.unescapeJava();
                
                tab240.RecipientID                    = 1;
                tab240.DocumentID                     = 1;
                tab240.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab240.AnchorTabItem.AnchorTabString  = 'Ptype59tag';
                
                tab241.Type_x                         = 'Custom';
                tab241.value                          = shortname;
                tab241.RecipientID                    = 1;
                tab241.DocumentID                     = 1;
                tab241.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab241.AnchorTabItem.AnchorTabString  = 'Nameofproduct59tag';
                
                 tab566.Type_x                         = 'Custom';
                tab566.value                          =WLILoop.Term__c ;
                tab566.RecipientID                    = 1;
                tab566.DocumentID                     = 1;
                tab566.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab566.AnchorTabItem.AnchorTabString  = 'Tmahanp59';
                envelope.Tabs.Tab[566]                = tab566;

                envelope.Tabs.Tab[237]               = tab238;       
                envelope.Tabs.Tab[238]               = tab239;       
                envelope.Tabs.Tab[239]               = tab240;                
                envelope.Tabs.Tab[240]               = tab241;    
            }
            if(I == 60){
                tab242.Type_x                         = 'Custom';
                tab242.value                          = WLIloop.Market__c;
                tab242.RecipientID                    = 1;
                tab242.DocumentID                     = 1;
                tab242.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab242.AnchorTabItem.AnchorTabString  = 'Market60tag';        
                
                
                tab243.Type_x                         = 'Custom';
                tab243.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab243.RecipientID                    = 1;
                tab243.DocumentID                     = 1;
                tab243.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab243.AnchorTabItem.AnchorTabString  = 'Spend60tag';
               
                tab244.Type_x                         = 'Custom';
                tab244.value                          = leadRoutingVal.unescapeJava();
                
                tab244.RecipientID                    = 1;
                tab244.DocumentID                     = 1;
                tab244.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab244.AnchorTabItem.AnchorTabString  = 'Ptype60tag';
                
                tab245.Type_x                         = 'Custom';
                tab245.value                          = shortname;
                tab245.RecipientID                    = 1;
                tab245.DocumentID                     = 1;
                tab245.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab245.AnchorTabItem.AnchorTabString  = 'Nameofproduct60tag';
                
                
                tab567.Type_x                         = 'Custom';
                tab567.value                          =WLILoop.Term__c ;
                tab567.RecipientID                    = 1;
                tab567.DocumentID                     = 1;
                tab567.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab567.AnchorTabItem.AnchorTabString  = 'Tmahanp60';
                envelope.Tabs.Tab[567]                = tab567;
                
              
                envelope.Tabs.Tab[241]               = tab242;       
                envelope.Tabs.Tab[242]               = tab243;       
                envelope.Tabs.Tab[243]               = tab244;                
                envelope.Tabs.Tab[244]               = tab245;
                
            }
            if(I == 61){
                tab246.Type_x                         = 'Custom';
                tab246.value                          = WLIloop.Market__c;
                tab246.RecipientID                    = 1;
                tab246.DocumentID                     = 1;
                tab246.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab246.AnchorTabItem.AnchorTabString  = 'Market61tag';        
                
                
                tab247.Type_x                         = 'Custom';
                tab247.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab247.RecipientID                    = 1;
                tab247.DocumentID                     = 1;
                tab247.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab247.AnchorTabItem.AnchorTabString  = 'Spend61tag';
                
                tab248.Type_x                         = 'Custom';
                tab248.value                          = leadRoutingVal.unescapeJava();
                
                tab248.RecipientID                    = 1;
                tab248.DocumentID                     = 1;
                tab248.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab248.AnchorTabItem.AnchorTabString  = 'Ptype61tag';
                
                tab249.Type_x                         = 'Custom';
                tab249.value                          = shortname;
                tab249.RecipientID                    = 1;
                tab249.DocumentID                     = 1;
                tab249.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab249.AnchorTabItem.AnchorTabString  = 'Nameofproduct61tag';
                
                
                  tab569.Type_x                         = 'Custom';
                tab569.value                          =WLILoop.Term__c ;
                tab569.RecipientID                    = 1;
                tab569.DocumentID                     = 1;
                tab569.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab569.AnchorTabItem.AnchorTabString  = 'Tynmpxz61';
                envelope.Tabs.Tab[569]                = tab569;
              
            
                
                
                
                envelope.Tabs.Tab[245]               = tab246;       
                envelope.Tabs.Tab[246]               = tab247;       
                envelope.Tabs.Tab[247]               = tab248;                
                envelope.Tabs.Tab[248]               = tab249;    
            }
            if(I == 62){
                tab250.Type_x                         = 'Custom';
                tab250.value                          = WLIloop.Market__c;
                tab250.RecipientID                    = 1;
                tab250.DocumentID                     = 1;
                tab250.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab250.AnchorTabItem.AnchorTabString  = 'Market62tag';        
                
                
                tab251.Type_x                         = 'Custom';
                tab251.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab251.RecipientID                    = 1;
                tab251.DocumentID                     = 1;
                tab251.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab251.AnchorTabItem.AnchorTabString  = 'Spend62tag';
                
                tab252.Type_x                         = 'Custom';
                tab252.value                          = leadRoutingVal.unescapeJava();
                
                tab252.RecipientID                    = 1;
                tab252.DocumentID                     = 1;
                tab252.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab252.AnchorTabItem.AnchorTabString  = 'Ptype62tag';
                
                tab253.Type_x                         = 'Custom';
                tab253.value                          = shortname;
                tab253.RecipientID                    = 1;
                tab253.DocumentID                     = 1;
                tab253.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab253.AnchorTabItem.AnchorTabString  = 'Nameofproduct62tag';
                
                tab570.Type_x                         = 'Custom';
                tab570.value                          =WLILoop.Term__c ;
                tab570.RecipientID                    = 1;
                tab570.DocumentID                     = 1;
                tab570.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab570.AnchorTabItem.AnchorTabString  = 'Tynmpxz62';
                envelope.Tabs.Tab[570]                = tab570;
              
            
                
                envelope.Tabs.Tab[249]               = tab250;       
                envelope.Tabs.Tab[250]               = tab251;       
                envelope.Tabs.Tab[251]               = tab252;                
                envelope.Tabs.Tab[252]               = tab253;    
            }
            if(I == 63){
                tab254.Type_x                         = 'Custom';
                tab254.value                          = WLIloop.Market__c;
                tab254.RecipientID                    = 1;
                tab254.DocumentID                     = 1;
                tab254.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab254.AnchorTabItem.AnchorTabString  = 'Market63tag';        
                
                
                tab255.Type_x                         = 'Custom';
                tab255.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab255.RecipientID                    = 1;
                tab255.DocumentID                     = 1;
                tab255.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab255.AnchorTabItem.AnchorTabString  = 'Spend63tag';
                
                tab256.Type_x                         = 'Custom';
                tab256.value                          = leadRoutingVal.unescapeJava();
                
                tab256.RecipientID                    = 1;
                tab256.DocumentID                     = 1;
                tab256.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab256.AnchorTabItem.AnchorTabString  = 'Ptype63tag';
                
                tab257.Type_x                         = 'Custom';
                tab257.value                          = shortname;
                tab257.RecipientID                    = 1;
                tab257.DocumentID                     = 1;
                tab257.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab257.AnchorTabItem.AnchorTabString  = 'Nameofproduct63tag';
                
                 tab571.Type_x                         = 'Custom';
                tab571.value                          =WLILoop.Term__c ;
                tab571.RecipientID                    = 1;
                tab571.DocumentID                     = 1;
                tab571.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab571.AnchorTabItem.AnchorTabString  = 'Tynmpxz63';
                envelope.Tabs.Tab[571]                = tab571;
            
                envelope.Tabs.Tab[253]               = tab254;       
                envelope.Tabs.Tab[254]               = tab255;       
                envelope.Tabs.Tab[255]               = tab256;                
                envelope.Tabs.Tab[256]               = tab257;    
            }
            if(I == 64){
                tab258.Type_x                         = 'Custom';
                tab258.value                          = WLIloop.Market__c;
                tab258.RecipientID                    = 1;
                tab258.DocumentID                     = 1;
                tab258.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab258.AnchorTabItem.AnchorTabString  = 'Market64tag';        
                
                
                tab259.Type_x                         = 'Custom';
                tab259.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab259.RecipientID                    = 1;
                tab259.DocumentID                     = 1;
                tab259.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab259.AnchorTabItem.AnchorTabString  = 'Spend64tag';
                
                tab260.Type_x                         = 'Custom';
                tab260.value                          = leadRoutingVal.unescapeJava();
                
                tab260.RecipientID                    = 1;
                tab260.DocumentID                     = 1;
                tab260.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab260.AnchorTabItem.AnchorTabString  = 'Ptype64tag';
                
                tab261.Type_x                         = 'Custom';
                tab261.value                          = shortname;
                tab261.RecipientID                    = 1;
                tab261.DocumentID                     = 1;
                tab261.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab261.AnchorTabItem.AnchorTabString  = 'Nameofproduct64tag';
                
                
                 tab572.Type_x                         = 'Custom';
                tab572.value                          =WLILoop.Term__c ;
                tab572.RecipientID                    = 1;
                tab572.DocumentID                     = 1;
                tab572.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab572.AnchorTabItem.AnchorTabString  = 'Tynmpxz64';
                envelope.Tabs.Tab[572]                = tab572;

            
                envelope.Tabs.Tab[257]               = tab258;       
                envelope.Tabs.Tab[258]               = tab259;       
                envelope.Tabs.Tab[259]               = tab260;                
                envelope.Tabs.Tab[260]               = tab261;    
            }
            if(I == 65){
                tab262.Type_x                         = 'Custom';
                tab262.value                          = WLIloop.Market__c;
                tab262.RecipientID                    = 1;
                tab262.DocumentID                     = 1;
                tab262.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab262.AnchorTabItem.AnchorTabString  = 'Market65tag';        
                
                
                tab263.Type_x                         = 'Custom';
                tab263.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab263.RecipientID                    = 1;
                tab263.DocumentID                     = 1;
                tab263.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab263.AnchorTabItem.AnchorTabString  = 'Spend65tag';
                
                tab264.Type_x                         = 'Custom';
                tab264.value                          = leadRoutingVal.unescapeJava();
                
                tab264.RecipientID                    = 1;
                tab264.DocumentID                     = 1;
                tab264.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab264.AnchorTabItem.AnchorTabString  = 'Ptype65tag';
                
                tab265.Type_x                         = 'Custom';
                tab265.value                          = shortname;
                tab265.RecipientID                    = 1;
                tab265.DocumentID                     = 1;
                tab265.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab265.AnchorTabItem.AnchorTabString  = 'Nameofproduct65tag';
                
                  
                 tab573.Type_x                         = 'Custom';
                tab573.value                          =WLILoop.Term__c ;
                tab573.RecipientID                    = 1;
                tab573.DocumentID                     = 1;
                tab573.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab573.AnchorTabItem.AnchorTabString  = 'Tynmpxz65';
                envelope.Tabs.Tab[573]                = tab573;

         
                
                envelope.Tabs.Tab[261]               = tab262;       
                envelope.Tabs.Tab[262]               = tab263;       
                envelope.Tabs.Tab[263]               = tab264;                
                envelope.Tabs.Tab[264]               = tab265;    
            }
            if(I == 66){
                tab266.Type_x                         = 'Custom';
                tab266.value                          = WLIloop.Market__c;
                tab266.RecipientID                    = 1;
                tab266.DocumentID                     = 1;
                tab266.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab266.AnchorTabItem.AnchorTabString  = 'Market66tag';        
                
                
                tab267.Type_x                         = 'Custom';
                tab267.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab267.RecipientID                    = 1;
                tab267.DocumentID                     = 1;
                tab267.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab267.AnchorTabItem.AnchorTabString  = 'Spend66tag';
                
                tab268.Type_x                         = 'Custom';
                tab268.value                          = leadRoutingVal.unescapeJava();
                
                tab268.RecipientID                    = 1;
                tab268.DocumentID                     = 1;
                tab268.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab268.AnchorTabItem.AnchorTabString  = 'Ptype66tag';
                
                tab269.Type_x                         = 'Custom';
                tab269.value                          = shortname;
                tab269.RecipientID                    = 1;
                tab269.DocumentID                     = 1;
                tab269.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab269.AnchorTabItem.AnchorTabString  = 'Nameofproduct66tag';
                
                
                tab574.Type_x                         = 'Custom';
                tab574.value                          =WLILoop.Term__c ;
                tab574.RecipientID                    = 1;
                tab574.DocumentID                     = 1;
                tab574.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab574.AnchorTabItem.AnchorTabString  = 'Tynmpxz66';
                envelope.Tabs.Tab[574]                = tab574;

            
                envelope.Tabs.Tab[265]               = tab266;       
                envelope.Tabs.Tab[266]               = tab267;       
                envelope.Tabs.Tab[267]               = tab268;                
                envelope.Tabs.Tab[268]               = tab269;    
            }
            if(I == 67){
                tab270.Type_x                         = 'Custom';
                tab270.value                          = WLIloop.Market__c;
                tab270.RecipientID                    = 1;
                tab270.DocumentID                     = 1;
                tab270.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab270.AnchorTabItem.AnchorTabString  = 'Market67tag';        
                
                
                tab271.Type_x                         = 'Custom';
                tab271.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab271.RecipientID                    = 1;
                tab271.DocumentID                     = 1;
                tab271.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab271.AnchorTabItem.AnchorTabString  = 'Spend67tag';
                
                tab272.Type_x                         = 'Custom';
                tab272.value                          = leadRoutingVal.unescapeJava();
                
                tab272.RecipientID                    = 1;
                tab272.DocumentID                     = 1;
                tab272.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab272.AnchorTabItem.AnchorTabString  = 'Ptype67tag';
                
                tab273.Type_x                         = 'Custom';
                tab273.value                          = shortname;
                tab273.RecipientID                    = 1;
                tab273.DocumentID                     = 1;
                tab273.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab273.AnchorTabItem.AnchorTabString  = 'Nameofproduct67tag';
                
                 tab575.Type_x                         = 'Custom';
                tab575.value                          =WLILoop.Term__c ;
                tab575.RecipientID                    = 1;
                tab575.DocumentID                     = 1;
                tab575.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab575.AnchorTabItem.AnchorTabString  = 'Tynmpxz67';
                envelope.Tabs.Tab[575]                = tab575;

   
                
                envelope.Tabs.Tab[269]               = tab270;       
                envelope.Tabs.Tab[270]               = tab271;       
                envelope.Tabs.Tab[271]               = tab272;                
                envelope.Tabs.Tab[272]               = tab273;    
            }
            if(I == 68){
                tab274.Type_x                         = 'Custom';
                tab274.value                          = WLIloop.Market__c;
                tab274.RecipientID                    = 1;
                tab274.DocumentID                     = 1;
                tab274.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab274.AnchorTabItem.AnchorTabString  = 'Market68tag';        
                
                
                tab275.Type_x                         = 'Custom';
                tab275.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab275.RecipientID                    = 1;
                tab275.DocumentID                     = 1;
                tab275.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab275.AnchorTabItem.AnchorTabString  = 'Spend68tag';
                
                tab276.Type_x                         = 'Custom';
                tab276.value                          = leadRoutingVal.unescapeJava();
                
                tab276.RecipientID                    = 1;
                tab276.DocumentID                     = 1;
                tab276.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab276.AnchorTabItem.AnchorTabString  = 'Ptype68tag';
                
                tab277.Type_x                         = 'Custom';
                tab277.value                          = shortname;
                tab277.RecipientID                    = 1;
                tab277.DocumentID                     = 1;
                tab277.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab277.AnchorTabItem.AnchorTabString  = 'Nameofproduct68tag';
                
                  tab576.Type_x                         = 'Custom';
                tab576.value                          =WLILoop.Term__c ;
                tab576.RecipientID                    = 1;
                tab576.DocumentID                     = 1;
                tab576.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab576.AnchorTabItem.AnchorTabString  = 'Tynmpxz68';
                envelope.Tabs.Tab[576]                = tab576;

                envelope.Tabs.Tab[273]               = tab274;       
                envelope.Tabs.Tab[274]               = tab275;       
                envelope.Tabs.Tab[275]               = tab276;                
                envelope.Tabs.Tab[276]               = tab277;    
            }
            if(I == 69){
                tab278.Type_x                         = 'Custom';
                tab278.value                          = WLIloop.Market__c;
                tab278.RecipientID                    = 1;
                tab278.DocumentID                     = 1;
                tab278.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab278.AnchorTabItem.AnchorTabString  = 'Market69tag';        
                
                
                tab279.Type_x                         = 'Custom';
                tab279.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab279.RecipientID                    = 1;
                tab279.DocumentID                     = 1;
                tab279.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab279.AnchorTabItem.AnchorTabString  = 'Spend69tag';
                
                tab280.Type_x                         = 'Custom';
                tab280.value                          = leadRoutingVal.unescapeJava();
                
                tab280.RecipientID                    = 1;
                tab280.DocumentID                     = 1;
                tab280.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab280.AnchorTabItem.AnchorTabString  = 'Ptype69tag';
                
                tab281.Type_x                         = 'Custom';
                tab281.value                          = shortname;
                tab281.RecipientID                    = 1;
                tab281.DocumentID                     = 1;
                tab281.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab281.AnchorTabItem.AnchorTabString  = 'Nameofproduct69tag';
                
                
                tab577.Type_x                         = 'Custom';
                tab577.value                          =WLILoop.Term__c ;
                tab577.RecipientID                    = 1;
                tab577.DocumentID                     = 1;
                tab577.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab577.AnchorTabItem.AnchorTabString  = 'Tynmpxz69';
                envelope.Tabs.Tab[577]                = tab577;
                
         
                
                envelope.Tabs.Tab[277]               = tab278;       
                envelope.Tabs.Tab[278]               = tab279;       
                envelope.Tabs.Tab[279]               = tab280;                
                envelope.Tabs.Tab[280]               = tab281;    
            }
            if(I == 70){
                tab282.Type_x                         = 'Custom';
                tab282.value                          = WLIloop.Market__c;
                tab282.RecipientID                    = 1;
                tab282.DocumentID                     = 1;
                tab282.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab282.AnchorTabItem.AnchorTabString  = 'Market70tag';        
                
                
                tab283.Type_x                         = 'Custom';
                tab283.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab283.RecipientID                    = 1;
                tab283.DocumentID                     = 1;
                tab283.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab283.AnchorTabItem.AnchorTabString  = 'Spend70tag';
                
                tab284.Type_x                         = 'Custom';
                tab284.value                          = leadRoutingVal.unescapeJava();
                
                tab284.RecipientID                    = 1;
                tab284.DocumentID                     = 1;
                tab284.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab284.AnchorTabItem.AnchorTabString  = 'Ptype70tag';
                
                tab285.Type_x                         = 'Custom';
                tab285.value                          = shortname;
                tab285.RecipientID                    = 1;
                tab285.DocumentID                     = 1;
                tab285.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab285.AnchorTabItem.AnchorTabString  = 'Nameofproduct70tag';
                
                
                 tab578.Type_x                         = 'Custom';
                tab578.value                          =WLILoop.Term__c ;
                tab578.RecipientID                    = 1;
                tab578.DocumentID                     = 1;
                tab578.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab578.AnchorTabItem.AnchorTabString  = 'Tumkaka70';
                envelope.Tabs.Tab[578]                = tab578;
            

                envelope.Tabs.Tab[281]               = tab282;       
                envelope.Tabs.Tab[282]               = tab283;       
                envelope.Tabs.Tab[283]               = tab284;                
                envelope.Tabs.Tab[284]               = tab285;    
            }
            if(I == 71){
                tab286.Type_x                         = 'Custom';
                tab286.value                          = WLIloop.Market__c;
                tab286.RecipientID                    = 1;
                tab286.DocumentID                     = 1;
                tab286.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab286.AnchorTabItem.AnchorTabString  = 'Market71tag';        
                
                
                tab287.Type_x                         = 'Custom';
                tab287.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab287.RecipientID                    = 1;
                tab287.DocumentID                     = 1;
                tab287.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab287.AnchorTabItem.AnchorTabString  = 'Spend71tag';
                
                tab288.Type_x                         = 'Custom';
                tab288.value                          = leadRoutingVal.unescapeJava();
                
                tab288.RecipientID                    = 1;
                tab288.DocumentID                     = 1;
                tab288.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab288.AnchorTabItem.AnchorTabString  = 'Ptype71tag';
                
                tab289.Type_x                         = 'Custom';
                tab289.value                          = shortname;
                tab289.RecipientID                    = 1;
                tab289.DocumentID                     = 1;
                tab289.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab289.AnchorTabItem.AnchorTabString  = 'Nameofproduct71tag';
                
                 tab579.Type_x                         = 'Custom';
                tab579.value                          =WLILoop.Term__c ;
                tab579.RecipientID                    = 1;
                tab579.DocumentID                     = 1;
                tab579.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab579.AnchorTabItem.AnchorTabString  = 'Tumkaka71';
                envelope.Tabs.Tab[579]                = tab579;

               
                
                envelope.Tabs.Tab[285]               = tab286;       
                envelope.Tabs.Tab[286]               = tab287;       
                envelope.Tabs.Tab[287]               = tab288;                
                envelope.Tabs.Tab[288]               = tab289;    
            }
            if(I == 72){
                tab290.Type_x                         = 'Custom';
                tab290.value                          = WLIloop.Market__c;
                tab290.RecipientID                    = 1;
                tab290.DocumentID                     = 1;
                tab290.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab290.AnchorTabItem.AnchorTabString  = 'Market72tag';        
                
                
                tab291.Type_x                         = 'Custom';
                tab291.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab291.RecipientID                    = 1;
                tab291.DocumentID                     = 1;
                tab291.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab291.AnchorTabItem.AnchorTabString  = 'Spend72tag';
                
                tab292.Type_x                         = 'Custom';
                tab292.value                          = leadRoutingVal.unescapeJava();
                
                tab292.RecipientID                    = 1;
                tab292.DocumentID                     = 1;
                tab292.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab292.AnchorTabItem.AnchorTabString  = 'Ptype72tag';
                
                tab293.Type_x                         = 'Custom';
                tab293.value                          = shortname;
                tab293.RecipientID                    = 1;
                tab293.DocumentID                     = 1;
                tab293.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab293.AnchorTabItem.AnchorTabString  = 'Nameofproduct72tag';
                
                 tab580.Type_x                         = 'Custom';
                tab580.value                          =WLILoop.Term__c ;
                tab580.RecipientID                    = 1;
                tab580.DocumentID                     = 1;
                tab580.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab580.AnchorTabItem.AnchorTabString  = 'Tumkaka72';
                envelope.Tabs.Tab[580]                = tab580;

             
                
                
                envelope.Tabs.Tab[289]               = tab290;       
                envelope.Tabs.Tab[290]               = tab291;       
                envelope.Tabs.Tab[291]               = tab292;                
                envelope.Tabs.Tab[292]               = tab293;    
            }
            if(I == 73){
                tab294.Type_x                         = 'Custom';
                tab294.value                          = WLIloop.Market__c;
                tab294.RecipientID                    = 1;
                tab294.DocumentID                     = 1;
                tab294.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab294.AnchorTabItem.AnchorTabString  = 'Market73tag';        
                
                
                tab295.Type_x                         = 'Custom';
                tab295.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab295.RecipientID                    = 1;
                tab295.DocumentID                     = 1;
                tab295.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab295.AnchorTabItem.AnchorTabString  = 'Spend73tag';
                
                tab296.Type_x                         = 'Custom';
                tab296.value                          = leadRoutingVal.unescapeJava();
                
                tab296.RecipientID                    = 1;
                tab296.DocumentID                     = 1;
                tab296.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab296.AnchorTabItem.AnchorTabString  = 'Ptype73tag';
                
                tab297.Type_x                         = 'Custom';
                tab297.value                          = shortname;
                tab297.RecipientID                    = 1;
                tab297.DocumentID                     = 1;
                tab297.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab297.AnchorTabItem.AnchorTabString  = 'Nameofproduct73tag';
                
                
                 tab581.Type_x                         = 'Custom';
                tab581.value                          =WLILoop.Term__c ;
                tab581.RecipientID                    = 1;
                tab581.DocumentID                     = 1;
                tab581.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab581.AnchorTabItem.AnchorTabString  = 'Tumkaka73';
                envelope.Tabs.Tab[581]                = tab581;
                
              
                envelope.Tabs.Tab[293]               = tab294;       
                envelope.Tabs.Tab[294]               = tab295;       
                envelope.Tabs.Tab[295]               = tab296;                
                envelope.Tabs.Tab[296]               = tab297;    
            }
            if(I == 74){
                tab298.Type_x                         = 'Custom';
                tab298.value                          = WLIloop.Market__c;
                tab298.RecipientID                    = 1;
                tab298.DocumentID                     = 1;
                tab298.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab298.AnchorTabItem.AnchorTabString  = 'Market74tag';        
                
                
                tab299.Type_x                         = 'Custom';
                tab299.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab299.RecipientID                    = 1;
                tab299.DocumentID                     = 1;
                tab299.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab299.AnchorTabItem.AnchorTabString  = 'Spend74tag';
                
                tab300.Type_x                         = 'Custom';
                tab300.value                          = leadRoutingVal.unescapeJava();
                
                tab300.RecipientID                    = 1;
                tab300.DocumentID                     = 1;
                tab300.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab300.AnchorTabItem.AnchorTabString  = 'Ptype74tag';
                
                tab301.Type_x                         = 'Custom';
                tab301.value                          = shortname;
                tab301.RecipientID                    = 1;
                tab301.DocumentID                     = 1;
                tab301.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab301.AnchorTabItem.AnchorTabString  = 'Nameofproduct74tag';
                
                
                tab582.Type_x                         = 'Custom';
                tab582.value                          =WLILoop.Term__c ;
                tab582.RecipientID                    = 1;
                tab582.DocumentID                     = 1;
                tab582.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab582.AnchorTabItem.AnchorTabString  = 'Tumkaka74';
                envelope.Tabs.Tab[582]                = tab582;

               
                
                envelope.Tabs.Tab[297]               = tab298;       
                envelope.Tabs.Tab[298]               = tab299;       
                envelope.Tabs.Tab[299]               = tab300;                
                envelope.Tabs.Tab[300]               = tab301;    
            }
            if(I == 75){
                tab302.Type_x                         = 'Custom';
                tab302.value                          = WLIloop.Market__c;
                tab302.RecipientID                    = 1;
                tab302.DocumentID                     = 1;
                tab302.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab302.AnchorTabItem.AnchorTabString  = 'Market75tag';        
                
                
                tab303.Type_x                         = 'Custom';
                tab303.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab303.RecipientID                    = 1;
                tab303.DocumentID                     = 1;
                tab303.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab303.AnchorTabItem.AnchorTabString  = 'Spend75tag';
               
                tab304.Type_x                         = 'Custom';
                tab304.value                          = leadRoutingVal.unescapeJava();
                
                tab304.RecipientID                    = 1;
                tab304.DocumentID                     = 1;
                tab304.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab304.AnchorTabItem.AnchorTabString  = 'Ptype75tag';
                
                tab305.Type_x                         = 'Custom';
                tab305.value                          = shortname;
                tab305.RecipientID                    = 1;
                tab305.DocumentID                     = 1;
                tab305.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab305.AnchorTabItem.AnchorTabString  = 'Nameofproduct75tag';
                
                
                 tab583.Type_x                         = 'Custom';
                tab583.value                          =WLILoop.Term__c ;
                tab583.RecipientID                    = 1;
                tab583.DocumentID                     = 1;
                tab583.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab583.AnchorTabItem.AnchorTabString  = 'Tumkaka75';
                envelope.Tabs.Tab[583]                = tab583;
                
               
                envelope.Tabs.Tab[301]               = tab302;       
                envelope.Tabs.Tab[302]               = tab303;       
                envelope.Tabs.Tab[303]               = tab304;                
                envelope.Tabs.Tab[304]               = tab305;    
            }
            if(I == 76){
                tab306.Type_x                         = 'Custom';
                tab306.value                          = WLIloop.Market__c;
                tab306.RecipientID                    = 1;
                tab306.DocumentID                     = 1;
                tab306.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab306.AnchorTabItem.AnchorTabString  = 'Market76tag';        
                
                
                tab307.Type_x                         = 'Custom';
                tab307.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab307.RecipientID                    = 1;
                tab307.DocumentID                     = 1;
                tab307.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab307.AnchorTabItem.AnchorTabString  = 'Spend76tag';
                
                tab308.Type_x                         = 'Custom';
                tab308.value                          = leadRoutingVal.unescapeJava();
                
                tab308.RecipientID                    = 1;
                tab308.DocumentID                     = 1;
                tab308.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab308.AnchorTabItem.AnchorTabString  = 'Ptype76tag';
                
                tab309.Type_x                         = 'Custom';
                tab309.value                          = shortname;
                tab309.RecipientID                    = 1;
                tab309.DocumentID                     = 1;
                tab309.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab309.AnchorTabItem.AnchorTabString  = 'Nameofproduct76tag';
                
                
                 tab584.Type_x                         = 'Custom';
                tab584.value                          =WLILoop.Term__c ;
                tab584.RecipientID                    = 1;
                tab584.DocumentID                     = 1;
                tab584.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab584.AnchorTabItem.AnchorTabString  = 'Tumkaka76';
                envelope.Tabs.Tab[584]                = tab584;
                
               

                envelope.Tabs.Tab[305]               = tab306;       
                envelope.Tabs.Tab[306]               = tab307;       
                envelope.Tabs.Tab[307]               = tab308;                
                envelope.Tabs.Tab[308]               = tab309;    
            }
            if(I == 77){
                tab310.Type_x                         = 'Custom';
                tab310.value                          = WLIloop.Market__c;
                tab310.RecipientID                    = 1;
                tab310.DocumentID                     = 1;
                tab310.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab310.AnchorTabItem.AnchorTabString  = 'Market77tag';        
                
                
                tab311.Type_x                         = 'Custom';
                tab311.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab311.RecipientID                    = 1;
                tab311.DocumentID                     = 1;
                tab311.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab311.AnchorTabItem.AnchorTabString  = 'Spend77tag';
                
                tab312.Type_x                         = 'Custom';
                tab312.value                          = leadRoutingVal.unescapeJava();
                
                tab312.RecipientID                    = 1;
                tab312.DocumentID                     = 1;
                tab312.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab312.AnchorTabItem.AnchorTabString  = 'Ptype77tag';
                
                tab313.Type_x                         = 'Custom';
                tab313.value                          = shortname;
                tab313.RecipientID                    = 1;
                tab313.DocumentID                     = 1;
                tab313.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab313.AnchorTabItem.AnchorTabString  = 'Nameofproduct77tag';
                
                 tab585.Type_x                         = 'Custom';
                tab585.value                          =WLILoop.Term__c ;
                tab585.RecipientID                    = 1;
                tab585.DocumentID                     = 1;
                tab585.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab585.AnchorTabItem.AnchorTabString  = 'Tumkaka77';
                envelope.Tabs.Tab[585]                = tab585;

               
                
                envelope.Tabs.Tab[309]               = tab310;       
                envelope.Tabs.Tab[310]               = tab311;       
                envelope.Tabs.Tab[311]               = tab312;                
                envelope.Tabs.Tab[312]               = tab313;    
            }
            if(I == 78){
                tab314.Type_x                         = 'Custom';
                tab314.value                          = WLIloop.Market__c;
                tab314.RecipientID                    = 1;
                tab314.DocumentID                     = 1;
                tab314.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab314.AnchorTabItem.AnchorTabString  = 'Market78tag';        
                
                
                tab315.Type_x                         = 'Custom';
                tab315.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab315.RecipientID                    = 1;
                tab315.DocumentID                     = 1;
                tab315.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab315.AnchorTabItem.AnchorTabString  = 'Spend78tag';
                
                tab316.Type_x                         = 'Custom';
                tab316.value                          = leadRoutingVal.unescapeJava();
                
                tab316.RecipientID                    = 1;
                tab316.DocumentID                     = 1;
                tab316.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab316.AnchorTabItem.AnchorTabString  = 'Ptype78tag';
                
                tab317.Type_x                         = 'Custom';
                tab317.value                          = shortname;
                tab317.RecipientID                    = 1;
                tab317.DocumentID                     = 1;
                tab317.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab317.AnchorTabItem.AnchorTabString  = 'Nameofproduct78tag';
                
                
                 tab586.Type_x                         = 'Custom';
                tab586.value                          =WLILoop.Term__c ;
                tab586.RecipientID                    = 1;
                tab586.DocumentID                     = 1;
                tab586.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab586.AnchorTabItem.AnchorTabString  = 'Tumkaka78';
                envelope.Tabs.Tab[586]                = tab586;
                
               

                envelope.Tabs.Tab[313]               = tab314;       
                envelope.Tabs.Tab[314]               = tab315;       
                envelope.Tabs.Tab[315]               = tab316;                
                envelope.Tabs.Tab[316]               = tab317;    
            }
            if(I == 79){
                tab318.Type_x                         = 'Custom';
                tab318.value                          = WLIloop.Market__c;
                tab318.RecipientID                    = 1;
                tab318.DocumentID                     = 1;
                tab318.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab318.AnchorTabItem.AnchorTabString  = 'Market79tag';        
                
                
                tab319.Type_x                         = 'Custom';
                tab319.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab319.RecipientID                    = 1;
                tab319.DocumentID                     = 1;
                tab319.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab319.AnchorTabItem.AnchorTabString  = 'Spend79tag';
                
                tab320.Type_x                         = 'Custom';
                tab320.value                          = leadRoutingVal.unescapeJava();
                
                tab320.RecipientID                    = 1;
                tab320.DocumentID                     = 1;
                tab320.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab320.AnchorTabItem.AnchorTabString  = 'Ptype79tag';
                
                tab321.Type_x                         = 'Custom';
                tab321.value                          = shortname;
                tab321.RecipientID                    = 1;
                tab321.DocumentID                     = 1;
                tab321.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab321.AnchorTabItem.AnchorTabString  = 'Nameofproduct79tag';
                
                
                
                 tab587.Type_x                         = 'Custom';
                tab587.value                          =WLILoop.Term__c ;
                tab587.RecipientID                    = 1;
                tab587.DocumentID                     = 1;
                tab587.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab587.AnchorTabItem.AnchorTabString  = 'Tumkaka79';
                envelope.Tabs.Tab[587]                = tab587;

              
                envelope.Tabs.Tab[317]               = tab318;       
                envelope.Tabs.Tab[318]               = tab319;       
                envelope.Tabs.Tab[319]               = tab320;                
                envelope.Tabs.Tab[320]               = tab321;    
            }
            if(I == 80){
                tab322.Type_x                         = 'Custom';
                tab322.value                          = WLIloop.Market__c;
                tab322.RecipientID                    = 1;
                tab322.DocumentID                     = 1;
                tab322.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab322.AnchorTabItem.AnchorTabString  = 'Market80tag';        
                
                
                tab323.Type_x                         = 'Custom';
                tab323.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab323.RecipientID                    = 1;
                tab323.DocumentID                     = 1;
                tab323.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab323.AnchorTabItem.AnchorTabString  = 'Spend80tag';
                
                tab324.Type_x                         = 'Custom';
                tab324.value                          = leadRoutingVal.unescapeJava();
                
                tab324.RecipientID                    = 1;
                tab324.DocumentID                     = 1;
                tab324.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab324.AnchorTabItem.AnchorTabString  = 'Ptype80tag';
                
                tab325.Type_x                         = 'Custom';
                tab325.value                          = shortname;
                tab325.RecipientID                    = 1;
                tab325.DocumentID                     = 1;
                tab325.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab325.AnchorTabItem.AnchorTabString  = 'Nameofproduct80tag';
                
                 tab588.Type_x                         = 'Custom';
                tab588.value                          =WLILoop.Term__c ;
                tab588.RecipientID                    = 1;
                tab588.DocumentID                     = 1;
                tab588.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab588.AnchorTabItem.AnchorTabString  = 'Tumkaka80';
                envelope.Tabs.Tab[588]                = tab588;
                
              

                envelope.Tabs.Tab[321]               = tab322;       
                envelope.Tabs.Tab[322]               = tab323;       
                envelope.Tabs.Tab[323]               = tab324;                
                envelope.Tabs.Tab[324]               = tab325;    
            }
            if(I == 81){
                tab326.Type_x                         = 'Custom';
                tab326.value                          = WLIloop.Market__c;
                tab326.RecipientID                    = 1;
                tab326.DocumentID                     = 1;
                tab326.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab326.AnchorTabItem.AnchorTabString  = 'Market81tag';        
                
                
                tab327.Type_x                         = 'Custom';
                tab327.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab327.RecipientID                    = 1;
                tab327.DocumentID                     = 1;
                tab327.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab327.AnchorTabItem.AnchorTabString  = 'Spend81tag';
                
                tab328.Type_x                         = 'Custom';
                tab328.value                          = leadRoutingVal.unescapeJava();
                
                tab328.RecipientID                    = 1;
                tab328.DocumentID                     = 1;
                tab328.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab328.AnchorTabItem.AnchorTabString  = 'Ptype81tag';
                
                tab329.Type_x                         = 'Custom';
                tab329.value                          = shortname;
                tab329.RecipientID                    = 1;
                tab329.DocumentID                     = 1;
                tab329.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab329.AnchorTabItem.AnchorTabString  = 'Nameofproduct81tag';
                
                tab589.Type_x                         = 'Custom';
                tab589.value                          =WLILoop.Term__c ;
                tab589.RecipientID                    = 1;
                tab589.DocumentID                     = 1;
                tab589.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab589.AnchorTabItem.AnchorTabString  = 'Tpamdyc81';
                envelope.Tabs.Tab[589]                = tab589;

              

                envelope.Tabs.Tab[325]               = tab326;       
                envelope.Tabs.Tab[326]               = tab327;       
                envelope.Tabs.Tab[327]               = tab328;                
                envelope.Tabs.Tab[328]               = tab329;    
            }
            if(I == 82){
                tab330.Type_x                         = 'Custom';
                tab330.value                          = WLIloop.Market__c;
                tab330.RecipientID                    = 1;
                tab330.DocumentID                     = 1;
                tab330.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab330.AnchorTabItem.AnchorTabString  = 'Market82tag';        
                
                
                tab331.Type_x                         = 'Custom';
                tab331.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab331.RecipientID                    = 1;
                tab331.DocumentID                     = 1;
                tab331.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab331.AnchorTabItem.AnchorTabString  = 'Spend82tag';
                
                tab332.Type_x                         = 'Custom';
                tab332.value                          = leadRoutingVal.unescapeJava();
                
                tab332.RecipientID                    = 1;
                tab332.DocumentID                     = 1;
                tab332.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab332.AnchorTabItem.AnchorTabString  = 'Ptype82tag';
                
                tab333.Type_x                         = 'Custom';
                tab333.value                          = shortname;
                tab333.RecipientID                    = 1;
                tab333.DocumentID                     = 1;
                tab333.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab333.AnchorTabItem.AnchorTabString  = 'Nameofproduct82tag';
                
                tab590.Type_x                         = 'Custom';
                tab590.value                          =WLILoop.Term__c ;
                tab590.RecipientID                    = 1;
                tab590.DocumentID                     = 1;
                tab590.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab590.AnchorTabItem.AnchorTabString  = 'Tpamdyc82';
                envelope.Tabs.Tab[590]                = tab590;
                

               

                
                envelope.Tabs.Tab[329]               = tab330;       
                envelope.Tabs.Tab[330]               = tab331;       
                envelope.Tabs.Tab[331]               = tab332;                
                envelope.Tabs.Tab[332]               = tab333;    
            }
            if(I == 83){
                tab334.Type_x                         = 'Custom';
                tab334.value                          = WLIloop.Market__c;
                tab334.RecipientID                    = 1;
                tab334.DocumentID                     = 1;
                tab334.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab334.AnchorTabItem.AnchorTabString  = 'Market83tag';        
                
                
                tab335.Type_x                         = 'Custom';
                tab335.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab335.RecipientID                    = 1;
                tab335.DocumentID                     = 1;
                tab335.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab335.AnchorTabItem.AnchorTabString  = 'Spend83tag';
                
                tab336.Type_x                         = 'Custom';
                tab336.value                          = leadRoutingVal.unescapeJava();
                
                tab336.RecipientID                    = 1;
                tab336.DocumentID                     = 1;
                tab336.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab336.AnchorTabItem.AnchorTabString  = 'Ptype83tag';
                
                tab337.Type_x                         = 'Custom';
                tab337.value                          = shortname;
                tab337.RecipientID                    = 1;
                tab337.DocumentID                     = 1;
                tab337.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab337.AnchorTabItem.AnchorTabString  = 'Nameofproduct83tag';
                
                  tab591.Type_x                         = 'Custom';
                tab591.value                          =WLILoop.Term__c ;
                tab591.RecipientID                    = 1;
                tab591.DocumentID                     = 1;
                tab591.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab591.AnchorTabItem.AnchorTabString  = 'Tpamdyc83';
                envelope.Tabs.Tab[591]                = tab591;
                
               

                envelope.Tabs.Tab[333]               = tab334;       
                envelope.Tabs.Tab[334]               = tab335;       
                envelope.Tabs.Tab[335]               = tab336;                
                envelope.Tabs.Tab[336]               = tab337;    
            }
            if(I == 84){
                tab338.Type_x                         = 'Custom';
                tab338.value                          = WLIloop.Market__c;
                tab338.RecipientID                    = 1;
                tab338.DocumentID                     = 1;
                tab338.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab338.AnchorTabItem.AnchorTabString  = 'Market84tag';        
                
                
                tab339.Type_x                         = 'Custom';
                tab339.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab339.RecipientID                    = 1;
                tab339.DocumentID                     = 1;
                tab339.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab339.AnchorTabItem.AnchorTabString  = 'Spend84tag';
                
                tab340.Type_x                         = 'Custom';
                tab340.value                          = leadRoutingVal.unescapeJava();
                
                tab340.RecipientID                    = 1;
                tab340.DocumentID                     = 1;
                tab340.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab340.AnchorTabItem.AnchorTabString  = 'Ptype84tag';
                
                tab341.Type_x                         = 'Custom';
                tab341.value                          = shortname;
                tab341.RecipientID                    = 1;
                tab341.DocumentID                     = 1;
                tab341.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab341.AnchorTabItem.AnchorTabString  = 'Nameofproduct84tag';
                
                 tab592.Type_x                         = 'Custom';
                tab592.value                          =WLILoop.Term__c ;
                tab592.RecipientID                    = 1;
                tab592.DocumentID                     = 1;
                tab592.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab592.AnchorTabItem.AnchorTabString  = 'Tpamdyc84';
                envelope.Tabs.Tab[592]                = tab592;
                
              
                
                envelope.Tabs.Tab[337]               = tab338;       
                envelope.Tabs.Tab[338]               = tab339;       
                envelope.Tabs.Tab[339]               = tab340;                
                envelope.Tabs.Tab[340]               = tab341;    
            }
            if(I == 85){
                tab342.Type_x                         = 'Custom';
                tab342.value                          = WLIloop.Market__c;
                tab342.RecipientID                    = 1;
                tab342.DocumentID                     = 1;
                tab342.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab342.AnchorTabItem.AnchorTabString  = 'Market85tag';        
                
                
                tab343.Type_x                         = 'Custom';
                tab343.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab343.RecipientID                    = 1;
                tab343.DocumentID                     = 1;
                tab343.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab343.AnchorTabItem.AnchorTabString  = 'Spend85tag';
                
                tab344.Type_x                         = 'Custom';
                tab344.value                          = leadRoutingVal.unescapeJava();
                
                tab344.RecipientID                    = 1;
                tab344.DocumentID                     = 1;
                tab344.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab344.AnchorTabItem.AnchorTabString  = 'Ptype85tag';
                
                tab345.Type_x                         = 'Custom';
                tab345.value                          = shortname;
                tab345.RecipientID                    = 1;
                tab345.DocumentID                     = 1;
                tab345.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab345.AnchorTabItem.AnchorTabString  = 'Nameofproduct85tag';
                
                tab593.Type_x                         = 'Custom';
                tab593.value                          =WLILoop.Term__c ;
                tab593.RecipientID                    = 1;
                tab593.DocumentID                     = 1;
                tab593.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab593.AnchorTabItem.AnchorTabString  = 'Tpamdyc85';
                envelope.Tabs.Tab[593]                = tab593;

               
                
                envelope.Tabs.Tab[341]               = tab342;       
                envelope.Tabs.Tab[342]               = tab343;       
                envelope.Tabs.Tab[343]               = tab344;                
                envelope.Tabs.Tab[344]               = tab345;    
            }
            if(I == 86){
                tab346.Type_x                         = 'Custom';
                tab346.value                          = WLIloop.Market__c;
                tab346.RecipientID                    = 1;
                tab346.DocumentID                     = 1;
                tab346.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab346.AnchorTabItem.AnchorTabString  = 'Market86tag';        
                
                
                tab347.Type_x                         = 'Custom';
                tab347.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab347.RecipientID                    = 1;
                tab347.DocumentID                     = 1;
                tab347.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab347.AnchorTabItem.AnchorTabString  = 'Spend86tag';
                
                tab348.Type_x                         = 'Custom';
                tab348.value                          = leadRoutingVal.unescapeJava();
                
                tab348.RecipientID                    = 1;
                tab348.DocumentID                     = 1;
                tab348.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab348.AnchorTabItem.AnchorTabString  = 'Ptype86tag';
                
                tab349.Type_x                         = 'Custom';
                tab349.value                          = shortname;
                tab349.RecipientID                    = 1;
                tab349.DocumentID                     = 1;
                tab349.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab349.AnchorTabItem.AnchorTabString  = 'Nameofproduct86tag';
                
                
                 tab594.Type_x                         = 'Custom';
                tab594.value                          =WLILoop.Term__c ;
                tab594.RecipientID                    = 1;
                tab594.DocumentID                     = 1;
                tab594.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab594.AnchorTabItem.AnchorTabString  = 'Tpamdyc86';
                envelope.Tabs.Tab[594]                = tab594;
                
               

                envelope.Tabs.Tab[345]               = tab346;       
                envelope.Tabs.Tab[346]               = tab347;       
                envelope.Tabs.Tab[347]               = tab348;                
                envelope.Tabs.Tab[348]               = tab349;    
            }
            if(I == 87){
                tab350.Type_x                         = 'Custom';
                tab350.value                          = WLIloop.Market__c;
                tab350.RecipientID                    = 1;
                tab350.DocumentID                     = 1;
                tab350.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab350.AnchorTabItem.AnchorTabString  = 'Market87tag';        
                
                
                tab351.Type_x                         = 'Custom';
                tab351.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab351.RecipientID                    = 1;
                tab351.DocumentID                     = 1;
                tab351.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab351.AnchorTabItem.AnchorTabString  = 'Spend87tag';
                
                tab352.Type_x                         = 'Custom';
                tab352.value                          = leadRoutingVal.unescapeJava();
                
                tab352.RecipientID                    = 1;
                tab352.DocumentID                     = 1;
                tab352.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab352.AnchorTabItem.AnchorTabString  = 'Ptype87tag';
                
                tab353.Type_x                         = 'Custom';
                tab353.value                          = shortname;
                tab353.RecipientID                    = 1;
                tab353.DocumentID                     = 1;
                tab353.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab353.AnchorTabItem.AnchorTabString  = 'Nameofproduct87tag';
                
                  
                 tab595.Type_x                         = 'Custom';
                tab595.value                          =WLILoop.Term__c ;
                tab595.RecipientID                    = 1;
                tab595.DocumentID                     = 1;
                tab595.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab595.AnchorTabItem.AnchorTabString  = 'Tpamdyc87';
                envelope.Tabs.Tab[595]                = tab595;

                
                
                envelope.Tabs.Tab[349]               = tab350;       
                envelope.Tabs.Tab[350]               = tab351;       
                envelope.Tabs.Tab[351]               = tab352;                
                envelope.Tabs.Tab[352]               = tab353;    
            }
            if(I == 88){
                tab354.Type_x                         = 'Custom';
                tab354.value                          = WLIloop.Market__c;
                tab354.RecipientID                    = 1;
                tab354.DocumentID                     = 1;
                tab354.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab354.AnchorTabItem.AnchorTabString  = 'Market88tag';        
                
                
                tab355.Type_x                         = 'Custom';
                tab355.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab355.RecipientID                    = 1;
                tab355.DocumentID                     = 1;
                tab355.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab355.AnchorTabItem.AnchorTabString  = 'Spend88tag';
                
                tab356.Type_x                         = 'Custom';
                tab356.value                          = leadRoutingVal.unescapeJava();
                
                tab356.RecipientID                    = 1;
                tab356.DocumentID                     = 1;
                tab356.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab356.AnchorTabItem.AnchorTabString  = 'Ptype88tag';
                
                tab357.Type_x                         = 'Custom';
                tab357.value                          = shortname;
                tab357.RecipientID                    = 1;
                tab357.DocumentID                     = 1;
                tab357.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab357.AnchorTabItem.AnchorTabString  = 'Nameofproduct88tag';
                
                  
                 tab596.Type_x                         = 'Custom';
                tab596.value                          =WLILoop.Term__c ;
                tab596.RecipientID                    = 1;
                tab596.DocumentID                     = 1;
                tab596.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab596.AnchorTabItem.AnchorTabString  = 'Tpamdyc88';
                envelope.Tabs.Tab[596]                = tab596;

                
                
                envelope.Tabs.Tab[353]               = tab354;       
                envelope.Tabs.Tab[354]               = tab355;       
                envelope.Tabs.Tab[355]               = tab356;                
                envelope.Tabs.Tab[356]               = tab357;    
            }
            if(I == 89){
                tab358.Type_x                         = 'Custom';
                tab358.value                          = WLIloop.Market__c;
                tab358.RecipientID                    = 1;
                tab358.DocumentID                     = 1;
                tab358.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab358.AnchorTabItem.AnchorTabString  = 'Market89tag';        
                
                
                tab359.Type_x                         = 'Custom';
                tab359.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab359.RecipientID                    = 1;
                tab359.DocumentID                     = 1;
                tab359.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab359.AnchorTabItem.AnchorTabString  = 'Spend89tag';
                
                tab360.Type_x                         = 'Custom';
                tab360.value                          = leadRoutingVal.unescapeJava();
                
                tab360.RecipientID                    = 1;
                tab360.DocumentID                     = 1;
                tab360.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab360.AnchorTabItem.AnchorTabString  = 'Ptype89tag';
                
                tab361.Type_x                         = 'Custom';
                tab361.value                          = shortname;
                tab361.RecipientID                    = 1;
                tab361.DocumentID                     = 1;
                tab361.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab361.AnchorTabItem.AnchorTabString  = 'Nameofproduct89tag';
                
                tab597.Type_x                         = 'Custom';
                tab597.value                          =WLILoop.Term__c ;
                tab597.RecipientID                    = 1;
                tab597.DocumentID                     = 1;
                tab597.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab597.AnchorTabItem.AnchorTabString  = 'Tpamdyc89';
                envelope.Tabs.Tab[597]                = tab597;

                
                
                envelope.Tabs.Tab[357]               = tab358;       
                envelope.Tabs.Tab[358]               = tab359;       
                envelope.Tabs.Tab[359]               = tab360;                
                envelope.Tabs.Tab[360]               = tab361;    
            }
            if(I == 90){
                tab362.Type_x                         = 'Custom';
                tab362.value                          = WLIloop.Market__c;
                tab362.RecipientID                    = 1;
                tab362.DocumentID                     = 1;
                tab362.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab362.AnchorTabItem.AnchorTabString  = 'Market90tag';        
                
                
                tab363.Type_x                         = 'Custom';
                tab363.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab363.RecipientID                    = 1;
                tab363.DocumentID                     = 1;
                tab363.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab363.AnchorTabItem.AnchorTabString  = 'Spend90tag';
                
                tab364.Type_x                         = 'Custom';
                tab364.value                          = leadRoutingVal.unescapeJava();
                
                tab364.RecipientID                    = 1;
                tab364.DocumentID                     = 1;
                tab364.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab364.AnchorTabItem.AnchorTabString  = 'Ptype90tag';
                
                tab365.Type_x                         = 'Custom';
                tab365.value                          = shortname;
                tab365.RecipientID                    = 1;
                tab365.DocumentID                     = 1;
                tab365.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab365.AnchorTabItem.AnchorTabString  = 'Nameofproduct90tag';
                
                tab598.Type_x                         = 'Custom';
                tab598.value                          =WLILoop.Term__c ;
                tab598.RecipientID                    = 1;
                tab598.DocumentID                     = 1;
                tab598.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab598.AnchorTabItem.AnchorTabString  = 'Tsuxzc90';
                envelope.Tabs.Tab[598]                = tab598;
                
              

                envelope.Tabs.Tab[361]               = tab362;       
                envelope.Tabs.Tab[362]               = tab363;       
                envelope.Tabs.Tab[363]               = tab364;                
                envelope.Tabs.Tab[364]               = tab365;    
            }
            if(I == 91){
                tab366.Type_x                         = 'Custom';
                tab366.value                          = WLIloop.Market__c;
                tab366.RecipientID                    = 1;
                tab366.DocumentID                     = 1;
                tab366.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab366.AnchorTabItem.AnchorTabString  = 'Market91tag';        
                
                
                tab367.Type_x                         = 'Custom';
                tab367.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab367.RecipientID                    = 1;
                tab367.DocumentID                     = 1;
                tab367.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab367.AnchorTabItem.AnchorTabString  = 'Spend91tag';
                
                tab368.Type_x                         = 'Custom';
                tab368.value                          = leadRoutingVal.unescapeJava();
                
                tab368.RecipientID                    = 1;
                tab368.DocumentID                     = 1;
                tab368.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab368.AnchorTabItem.AnchorTabString  = 'Ptype91tag';
                
                tab369.Type_x                         = 'Custom';
                tab369.value                          = shortname;
                tab369.RecipientID                    = 1;
                tab369.DocumentID                     = 1;
                tab369.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab369.AnchorTabItem.AnchorTabString  = 'Nameofproduct91tag';
                
                
                 tab599.Type_x                         = 'Custom';
                tab599.value                          =WLILoop.Term__c ;
                tab599.RecipientID                    = 1;
                tab599.DocumentID                     = 1;
                tab599.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab599.AnchorTabItem.AnchorTabString  = 'Tsuxzc91';
                envelope.Tabs.Tab[599]                = tab599;

               

                
                envelope.Tabs.Tab[365]               = tab366;       
                envelope.Tabs.Tab[366]               = tab367;       
                envelope.Tabs.Tab[367]               = tab368;                
                envelope.Tabs.Tab[368]               = tab369;    
            }
            if(I == 92){
                tab370.Type_x                         = 'Custom';
                tab370.value                          = WLIloop.Market__c;
                tab370.RecipientID                    = 1;
                tab370.DocumentID                     = 1;
                tab370.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab370.AnchorTabItem.AnchorTabString  = 'Market92tag';        
                
                
                tab371.Type_x                         = 'Custom';
                tab371.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab371.RecipientID                    = 1;
                tab371.DocumentID                     = 1;
                tab371.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab371.AnchorTabItem.AnchorTabString  = 'Spend92tag';
                
                tab372.Type_x                         = 'Custom';
                tab372.value                          = leadRoutingVal.unescapeJava();
                
                tab372.RecipientID                    = 1;
                tab372.DocumentID                     = 1;
                tab372.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab372.AnchorTabItem.AnchorTabString  = 'Ptype92tag';
                
                tab373.Type_x                         = 'Custom';
                tab373.value                          = shortname;
                tab373.RecipientID                    = 1;
                tab373.DocumentID                     = 1;
                tab373.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab373.AnchorTabItem.AnchorTabString  = 'Nameofproduct92tag';
                
                
                 tab600.Type_x                         = 'Custom';
                tab600.value                          =WLILoop.Term__c ;
                tab600.RecipientID                    = 1;
                tab600.DocumentID                     = 1;
                tab600.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab600.AnchorTabItem.AnchorTabString  = 'Tsuxzc92';
                envelope.Tabs.Tab[600]                = tab600;
                
               


                envelope.Tabs.Tab[369]               = tab370;       
                envelope.Tabs.Tab[370]               = tab371;       
                envelope.Tabs.Tab[371]               = tab372;                
                envelope.Tabs.Tab[372]               = tab373;    
            }
            if(I == 93){
                tab374.Type_x                         = 'Custom';
                tab374.value                          = WLIloop.Market__c;
                tab374.RecipientID                    = 1;
                tab374.DocumentID                     = 1;
                tab374.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab374.AnchorTabItem.AnchorTabString  = 'Market93tag';        
                
                
                tab375.Type_x                         = 'Custom';
                tab375.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab375.RecipientID                    = 1;
                tab375.DocumentID                     = 1;
                tab375.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab375.AnchorTabItem.AnchorTabString  = 'Spend93tag';
                
                tab376.Type_x                         = 'Custom';
                tab376.value                          = leadRoutingVal.unescapeJava();
                
                tab376.RecipientID                    = 1;
                tab376.DocumentID                     = 1;
                tab376.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab376.AnchorTabItem.AnchorTabString  = 'Ptype93tag';
                
                tab377.Type_x                         = 'Custom';
                tab377.value                          = shortname;
                tab377.RecipientID                    = 1;
                tab377.DocumentID                     = 1;
                tab377.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab377.AnchorTabItem.AnchorTabString  = 'Nameofproduct93tag';
                
                
                    tab601.Type_x                         = 'Custom';
                tab601.value                          =WLILoop.Term__c ;
                tab601.RecipientID                    = 1;
                tab601.DocumentID                     = 1;
                tab601.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab601.AnchorTabItem.AnchorTabString  = 'Tsuxzc93';
                envelope.Tabs.Tab[601]                = tab601;

                
                
                envelope.Tabs.Tab[373]               = tab374;       
                envelope.Tabs.Tab[374]               = tab375;       
                envelope.Tabs.Tab[375]               = tab376;                
                envelope.Tabs.Tab[376]               = tab377;    
            }
            if(I == 94){
                tab378.Type_x                         = 'Custom';
                tab378.value                          = WLIloop.Market__c;
                tab378.RecipientID                    = 1;
                tab378.DocumentID                     = 1;
                tab378.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab378.AnchorTabItem.AnchorTabString  = 'Market94tag';        
                
                
                tab379.Type_x                         = 'Custom';
                tab379.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab379.RecipientID                    = 1;
                tab379.DocumentID                     = 1;
                tab379.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab379.AnchorTabItem.AnchorTabString  = 'Spend94tag';
                
                tab380.Type_x                         = 'Custom';
                tab380.value                          = leadRoutingVal.unescapeJava();
                
                tab380.RecipientID                    = 1;
                tab380.DocumentID                     = 1;
                tab380.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab380.AnchorTabItem.AnchorTabString  = 'Ptype94tag';
                
                tab381.Type_x                         = 'Custom';
                tab381.value                          = shortname;
                tab381.RecipientID                    = 1;
                tab381.DocumentID                     = 1;
                tab381.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab381.AnchorTabItem.AnchorTabString  = 'Nameofproduct94tag';
                
                
                    tab602.Type_x                         = 'Custom';
                tab602.value                          =WLILoop.Term__c ;
                tab602.RecipientID                    = 1;
                tab602.DocumentID                     = 1;
                tab602.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab602.AnchorTabItem.AnchorTabString  = 'Tsuxzc94';
                envelope.Tabs.Tab[602]                = tab602;
                

                
                
                envelope.Tabs.Tab[377]               = tab378;       
                envelope.Tabs.Tab[378]               = tab379;       
                envelope.Tabs.Tab[379]               = tab380;                
                envelope.Tabs.Tab[380]               = tab381;    
            }
            if(I == 95){
                tab382.Type_x                         = 'Custom';
                tab382.value                          = WLIloop.Market__c;
                tab382.RecipientID                    = 1;
                tab382.DocumentID                     = 1;
                tab382.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab382.AnchorTabItem.AnchorTabString  = 'Market95tag';        
                
                
                tab383.Type_x                         = 'Custom';
                tab383.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab383.RecipientID                    = 1;
                tab383.DocumentID                     = 1;
                tab383.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab383.AnchorTabItem.AnchorTabString  = 'Spend95tag';
                
                tab384.Type_x                         = 'Custom';
                tab384.value                          = leadRoutingVal.unescapeJava();
                
                tab384.RecipientID                    = 1;
                tab384.DocumentID                     = 1;
                tab384.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab384.AnchorTabItem.AnchorTabString  = 'Ptype95tag';
                
                tab385.Type_x                         = 'Custom';
                tab385.value                          = shortname;
                tab385.RecipientID                    = 1;
                tab385.DocumentID                     = 1;
                tab385.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab385.AnchorTabItem.AnchorTabString  = 'Nameofproduct95tag';
                
                tab603.Type_x                         = 'Custom';
                tab603.value                          =WLILoop.Term__c ;
                tab603.RecipientID                    = 1;
                tab603.DocumentID                     = 1;
                tab603.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab603.AnchorTabItem.AnchorTabString  = 'Tsuxzc95';
                envelope.Tabs.Tab[603]                = tab603;
                
                

                envelope.Tabs.Tab[381]               = tab382;       
                envelope.Tabs.Tab[382]               = tab383;       
                envelope.Tabs.Tab[383]               = tab384;                
                envelope.Tabs.Tab[384]               = tab385;    
            }
            if(I == 96){
                tab386.Type_x                         = 'Custom';
                tab386.value                          = WLIloop.Market__c;
                tab386.RecipientID                    = 1;
                tab386.DocumentID                     = 1;
                tab386.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab386.AnchorTabItem.AnchorTabString  = 'Market96tag';        
                
                
                tab387.Type_x                         = 'Custom';
                tab387.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab387.RecipientID                    = 1;
                tab387.DocumentID                     = 1;
                tab387.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab387.AnchorTabItem.AnchorTabString  = 'Spend96tag';
                
                tab388.Type_x                         = 'Custom';
                tab388.value                          = leadRoutingVal.unescapeJava();
                
                tab388.RecipientID                    = 1;
                tab388.DocumentID                     = 1;
                tab388.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab388.AnchorTabItem.AnchorTabString  = 'Ptype96tag';
                
                tab389.Type_x                         = 'Custom';
                tab389.value                          = shortname;
                tab389.RecipientID                    = 1;
                tab389.DocumentID                     = 1;
                tab389.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab389.AnchorTabItem.AnchorTabString  = 'Nameofproduct96tag';
                
                tab604.Type_x                         = 'Custom';
                tab604.value                          =WLILoop.Term__c ;
                tab604.RecipientID                    = 1;
                tab604.DocumentID                     = 1;
                tab604.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab604.AnchorTabItem.AnchorTabString  = 'Tsuxzc96';
                envelope.Tabs.Tab[604]                = tab604;

               

                
                envelope.Tabs.Tab[385]               = tab386;       
                envelope.Tabs.Tab[386]               = tab387;       
                envelope.Tabs.Tab[387]               = tab388;                
                envelope.Tabs.Tab[388]               = tab389;    
            }
            if(I == 97){
                tab390.Type_x                         = 'Custom';
                tab390.value                          = WLIloop.Market__c;
                tab390.RecipientID                    = 1;
                tab390.DocumentID                     = 1;
                tab390.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab390.AnchorTabItem.AnchorTabString  = 'Market97tag';        
                
                
                tab391.Type_x                         = 'Custom';
                tab391.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab391.RecipientID                    = 1;
                tab391.DocumentID                     = 1;
                tab391.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab391.AnchorTabItem.AnchorTabString  = 'Spend97tag';
                
                tab392.Type_x                         = 'Custom';
                tab392.value                          = leadRoutingVal.unescapeJava();
                
                tab392.RecipientID                    = 1;
                tab392.DocumentID                     = 1;
                tab392.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab392.AnchorTabItem.AnchorTabString  = 'Ptype97tag';
                
                tab393.Type_x                         = 'Custom';
                tab393.value                          = shortname;
                tab393.RecipientID                    = 1;
                tab393.DocumentID                     = 1;
                tab393.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab393.AnchorTabItem.AnchorTabString  = 'Nameofproduct97tag';
                
                
                tab605.Type_x                         = 'Custom';
                tab605.value                          =WLILoop.Term__c ;
                tab605.RecipientID                    = 1;
                tab605.DocumentID                     = 1;
                tab605.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab605.AnchorTabItem.AnchorTabString  = 'Tsuxzc97';
                envelope.Tabs.Tab[605]                = tab605;

               
                
                
                envelope.Tabs.Tab[389]               = tab390;       
                envelope.Tabs.Tab[390]               = tab391;       
                envelope.Tabs.Tab[391]               = tab392;                
                envelope.Tabs.Tab[392]               = tab393;    
            }
            if(I == 98){
                tab394.Type_x                         = 'Custom';
                tab394.value                          = WLIloop.Market__c;
                tab394.RecipientID                    = 1;
                tab394.DocumentID                     = 1;
                tab394.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab394.AnchorTabItem.AnchorTabString  = 'Market98tag';        
                
                
                tab395.Type_x                         = 'Custom';
                tab395.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab395.RecipientID                    = 1;
                tab395.DocumentID                     = 1;
                tab395.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab395.AnchorTabItem.AnchorTabString  = 'Spend98tag';
                
                tab396.Type_x                         = 'Custom';
                tab396.value                          = leadRoutingVal.unescapeJava();
                
                tab396.RecipientID                    = 1;
                tab396.DocumentID                     = 1;
                tab396.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab396.AnchorTabItem.AnchorTabString  = 'Ptype98tag';
                
                tab397.Type_x                         = 'Custom';
                tab397.value                          = shortname;
                tab397.RecipientID                    = 1;
                tab397.DocumentID                     = 1;
                tab397.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab397.AnchorTabItem.AnchorTabString  = 'Nameofproduct98tag';
                
                tab606.Type_x                         = 'Custom';
                tab606.value                          =WLILoop.Term__c ;
                tab606.RecipientID                    = 1;
                tab606.DocumentID                     = 1;
                tab606.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab606.AnchorTabItem.AnchorTabString  = 'Tsuxzc98';
                envelope.Tabs.Tab[606]                = tab606;

                
                

                envelope.Tabs.Tab[393]               = tab394;       
                envelope.Tabs.Tab[394]               = tab395;       
                envelope.Tabs.Tab[395]               = tab396;                
                envelope.Tabs.Tab[396]               = tab397;    
            }
            if(I == 99){
                tab398.Type_x                         = 'Custom';
                tab398.value                          = WLIloop.Market__c;
                tab398.RecipientID                    = 1;
                tab398.DocumentID                     = 1;
                tab398.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab398.AnchorTabItem.AnchorTabString  = 'Market99tag';        
                
                
                tab399.Type_x                         = 'Custom';
                tab399.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab399.RecipientID                    = 1;
                tab399.DocumentID                     = 1;
                tab399.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab399.AnchorTabItem.AnchorTabString  = 'Spend99tag';
                
                tab400.Type_x                         = 'Custom';
                tab400.value                          = leadRoutingVal.unescapeJava();
                
                tab400.RecipientID                    = 1;
                tab400.DocumentID                     = 1;
                tab400.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab400.AnchorTabItem.AnchorTabString  = 'Ptype99tag';
                
                tab401.Type_x                         = 'Custom';
                tab401.value                          = shortname;
                tab401.RecipientID                    = 1;
                tab401.DocumentID                     = 1;
                tab401.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab401.AnchorTabItem.AnchorTabString  = 'Nameofproduct99tag';
                
                
                tab607.Type_x                         = 'Custom';
                tab607.value                          =WLILoop.Term__c ;
                tab607.RecipientID                    = 1;
                tab607.DocumentID                     = 1;
                tab607.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab607.AnchorTabItem.AnchorTabString  = 'Tsuxzc99';
                envelope.Tabs.Tab[607]                = tab607;

                
                
                
                envelope.Tabs.Tab[397]               = tab398;       
                envelope.Tabs.Tab[398]               = tab399;       
                envelope.Tabs.Tab[399]               = tab400;                
                envelope.Tabs.Tab[400]               = tab401;    
            }
            if(I == 100){
                tab402.Type_x                         = 'Custom';
                tab402.value                          = WLIloop.Market__c;
                tab402.RecipientID                    = 1;
                tab402.DocumentID                     = 1;
                tab402.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                
                tab402.AnchorTabItem.AnchorTabString  = 'Market10ttag';        
                
                
                tab403.Type_x                         = 'Custom';
                tab403.value                          = string.valueof(WLIloop.Original_Max_Spend__c);
                tab403.RecipientID                    = 1;
                tab403.DocumentID                     = 1;
                tab403.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab403.AnchorTabItem.AnchorTabString  = 'Spend10ttag';
               
                tab404.Type_x                         = 'Custom';
                tab404.value                          = leadRoutingVal.unescapeJava();
                
                tab404.RecipientID                    = 1;
                tab404.DocumentID                     = 1;
                tab404.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab404.AnchorTabItem.AnchorTabString  = 'Ptype10ttag';
                
                tab405.Type_x                         = 'Custom';
                tab405.value                          = shortname;
                tab405.RecipientID                    = 1;
                tab405.DocumentID                     = 1;
                tab405.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab405.AnchorTabItem.AnchorTabString  = 'Nameofproduct10ttag';
                
                  tab608.Type_x                         = 'Custom';
                tab608.value                          =WLILoop.Term__c ;
                tab608.RecipientID                    = 1;
                tab608.DocumentID                     = 1;
                tab608.AnchorTabItem                  = new DocuSignAPI.AnchorTab();
                tab608.AnchorTabItem.AnchorTabString  = 'Tsuxzc100';
                envelope.Tabs.Tab[608]                = tab608;
                
               

                envelope.Tabs.Tab[401]               = tab402;       
                envelope.Tabs.Tab[402]               = tab403;       
                envelope.Tabs.Tab[403]               = tab404;                
                envelope.Tabs.Tab[404]               = tab405;    
            }
        }   
        return document;
    }
}